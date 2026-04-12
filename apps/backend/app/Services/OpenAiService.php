<?php

namespace App\Services;

use Illuminate\Http\Client\ConnectionException;
use Illuminate\Http\Client\RequestException;
use Illuminate\Support\Facades\Http;
use RuntimeException;
use Throwable;

class OpenAiService
{
    public function generate(string $prompt): string
    {
        $apiKey = (string) config('openai.api_key');
        $model = (string) config('openai.model', 'gpt-4o-mini');
        $baseUrl = rtrim((string) config('openai.base_url', 'https://api.openai.com/v1'), '/');

        if ($apiKey === '') {
            throw new RuntimeException('OpenAI API key is missing.');
        }

        $url = "{$baseUrl}/chat/completions";

        try {
            $response = Http::withToken($apiKey)
                ->acceptJson()
                ->withOptions([
                    'verify' => filter_var(config('openai.verify_ssl', true), FILTER_VALIDATE_BOOL),
                ])
                ->timeout((int) config('openai.timeout', 30))
                ->connectTimeout((int) config('openai.connect_timeout', 10))
                ->retry(
                    (int) config('openai.retries', 2),
                    (int) config('openai.retry_sleep_ms', 250),
                    function (Throwable $exception) {
                        return $exception instanceof ConnectionException;
                    }
                )
                ->post($url, [
                    'model' => $model,
                    'messages' => [
                        [
                            'role' => 'system',
                            'content' => 'You are a concise Arabic financial assistant.',
                        ],
                        [
                            'role' => 'user',
                            'content' => $prompt,
                        ],
                    ],
                    'temperature' => 0.7,
                ]);

            if ($response->failed()) {
                throw new RequestException($response);
            }

            $json = $response->json();
            $text = $json['choices'][0]['message']['content'] ?? null;

            if (! is_string($text) || trim($text) === '') {
                throw new RuntimeException('OpenAI returned an empty response.');
            }

            return trim($text);
        } catch (RequestException $e) {
            $status = $e->response?->status();
            $apiMessage = $this->extractApiErrorMessage($e->response?->json());

            if ($status === 401 || $status === 403) {
                throw new RuntimeException($apiMessage ?: 'OpenAI authentication failed.');
            }

            if ($status === 429) {
                throw new RuntimeException($apiMessage ?: 'OpenAI rate limit exceeded.');
            }

            if ($status !== null && $status >= 500) {
                throw new RuntimeException($apiMessage ?: 'OpenAI service temporarily unavailable.');
            }

            throw new RuntimeException($apiMessage ?: 'OpenAI request failed.');
        } catch (ConnectionException) {
            throw new RuntimeException('Failed to connect to OpenAI.');
        }
    }

    private function extractApiErrorMessage(mixed $json): ?string
    {
        if (! is_array($json)) {
            return null;
        }

        $message = $json['error']['message'] ?? null;

        if (! is_string($message)) {
            return null;
        }

        $message = trim($message);

        return $message === '' ? null : $message;
    }
}
