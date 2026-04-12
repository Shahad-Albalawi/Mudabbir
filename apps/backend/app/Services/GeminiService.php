<?php

namespace App\Services;

use Illuminate\Http\Client\ConnectionException;
use Illuminate\Http\Client\RequestException;
use Illuminate\Support\Facades\Http;
use RuntimeException;
use Throwable;

class GeminiService
{
    public function generate(string $prompt): string
    {
        $apiKey = (string) config('gemini.api_key');
        $model = (string) config('gemini.model', 'gemini-1.5-flash');
        $baseUrl = rtrim((string) config('gemini.base_url'), '/');

        if ($apiKey === '') {
            throw new RuntimeException('Gemini API key is missing.');
        }

        $url = "{$baseUrl}/models/{$model}:generateContent?key={$apiKey}";

        try {
            $response = Http::withHeaders([
                'Accept' => 'application/json',
                'Content-Type' => 'application/json',
            ])
                ->withOptions([
                    'verify' => filter_var(config('gemini.verify_ssl', true), FILTER_VALIDATE_BOOL),
                ])
                ->timeout((int) config('gemini.timeout', 30))
                ->connectTimeout((int) config('gemini.connect_timeout', 10))
                ->retry(
                    (int) config('gemini.retries', 2),
                    (int) config('gemini.retry_sleep_ms', 250),
                    function (Throwable $exception) {
                        return $exception instanceof ConnectionException;
                    }
                )
                ->post($url, [
                    'contents' => [[
                        'parts' => [[
                            'text' => $prompt,
                        ]],
                    ]],
                ]);

            if ($response->failed()) {
                throw new RequestException($response);
            }

            $json = $response->json();
            $text = $json['candidates'][0]['content']['parts'][0]['text'] ?? null;

            if (! is_string($text) || trim($text) === '') {
                throw new RuntimeException('Gemini returned an empty response.');
            }

            return trim($text);
        } catch (RequestException $e) {
            $status = $e->response?->status();
            $apiMessage = $this->extractApiErrorMessage($e->response?->json());

            if ($status === 401 || $status === 403) {
                throw new RuntimeException($apiMessage ?: 'Gemini authentication failed.');
            }

            if ($status === 429) {
                throw new RuntimeException($apiMessage ?: 'Gemini rate limit exceeded.');
            }

            if ($status !== null && $status >= 500) {
                throw new RuntimeException($apiMessage ?: 'Gemini service temporarily unavailable.');
            }

            throw new RuntimeException($apiMessage ?: 'Gemini request failed.');
        } catch (ConnectionException) {
            throw new RuntimeException('Failed to connect to Gemini.');
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
