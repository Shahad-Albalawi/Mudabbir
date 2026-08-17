<?php

namespace App\Services;

use App\Exceptions\AiQuotaExceededException;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Http\Client\RequestException;
use Illuminate\Support\Facades\Http;
use RuntimeException;
use Symfony\Component\HttpFoundation\StreamedResponse;
use Throwable;

class GeminiStreamService
{
    private const SYSTEM_PROMPT = <<<'PROMPT'
أنت مدبّر، مساعد مالي ذكي ومفيد. تتحدث بالعربية الفصحى البسيطة مع لمسة سعودية خفيفة.
قدّم نصائح عملية قصيرة ومباشرة حول الميزانية، الادخار، وتقليل المصروفات.
لا تخترع أرقاماً — استخدم سياق المستخدم فقط. إذا لم تتوفر بيانات كافية، اطلب توضيحاً بلطف.
PROMPT;

    public function streamChat(
        string $userMessage,
        string $contextBlock,
        bool $fullSystemPrompt = false,
    ): StreamedResponse {
        $apiKey = (string) config('gemini.api_key');
        $model = (string) config('gemini.model', 'gemini-2.0-flash');
        $baseUrl = rtrim((string) config('gemini.base_url', 'https://generativelanguage.googleapis.com/v1beta'), '/');

        if ($apiKey === '') {
            throw new RuntimeException('Gemini API key is missing.');
        }

        $url = "{$baseUrl}/models/{$model}:streamGenerateContent?alt=sse";
        $payload = $this->buildPayload($userMessage, $contextBlock, $fullSystemPrompt);

        return new StreamedResponse(function () use ($apiKey, $url, $payload): void {
            $response = Http::acceptJson()
                ->withHeaders(['x-goog-api-key' => $apiKey])
                ->withOptions(['stream' => true])
                ->timeout((int) config('gemini.timeout', 60))
                ->post($url, $payload);

            if ($response->failed()) {
                echo 'data: '.json_encode(['error' => 'تعذر الاتصال بخدمة الذكاء الاصطناعي'], JSON_UNESCAPED_UNICODE)."\n\n";
                if (ob_get_level() > 0) {
                    ob_flush();
                }
                flush();

                return;
            }

            $body = $response->toPsrResponse()->getBody();
            while (! $body->eof()) {
                $line = $this->readLine($body);
                if ($line === '' || ! str_starts_with($line, 'data: ')) {
                    continue;
                }

                $json = json_decode(trim(substr($line, 6)), true);
                if (! is_array($json)) {
                    continue;
                }

                $text = $json['candidates'][0]['content']['parts'][0]['text'] ?? null;
                if (is_string($text) && $text !== '') {
                    echo 'data: '.json_encode(['token' => $text], JSON_UNESCAPED_UNICODE)."\n\n";
                }

                if (ob_get_level() > 0) {
                    ob_flush();
                }
                flush();
            }

            echo "data: [DONE]\n\n";
            if (ob_get_level() > 0) {
                ob_flush();
            }
            flush();
        }, 200, [
            'Content-Type' => 'text/event-stream',
            'Cache-Control' => 'no-cache',
            'X-Accel-Buffering' => 'no',
        ]);
    }

    public function chat(
        string $userMessage,
        string $contextBlock,
        bool $fullSystemPrompt = false,
    ): string {
        $apiKey = (string) config('gemini.api_key');
        $model = (string) config('gemini.model', 'gemini-2.0-flash');
        $baseUrl = rtrim((string) config('gemini.base_url', 'https://generativelanguage.googleapis.com/v1beta'), '/');

        if ($apiKey === '') {
            throw new RuntimeException('Gemini API key is missing.');
        }

        $url = "{$baseUrl}/models/{$model}:generateContent";

        try {
            $response = Http::acceptJson()
                ->withHeaders(['x-goog-api-key' => $apiKey])
                ->timeout((int) config('gemini.timeout', 30))
                ->post($url, $this->buildPayload($userMessage, $contextBlock, $fullSystemPrompt));

            if ($response->failed()) {
                throw new RequestException($response);
            }

            $text = $response->json('candidates.0.content.parts.0.text');
            if (! is_string($text) || trim($text) === '') {
                throw new RuntimeException('Gemini returned an empty response.');
            }

            return trim($text);
        } catch (RequestException $e) {
            $status = $e->response?->status();
            if ($status === 429) {
                throw new AiQuotaExceededException('Gemini rate limit exceeded.');
            }
            throw new RuntimeException('Gemini request failed.');
        } catch (ConnectionException) {
            throw new RuntimeException('Failed to connect to Gemini.');
        } catch (Throwable $e) {
            throw new RuntimeException($e->getMessage());
        }
    }

    /**
     * @return array<string, mixed>
     */
    private function buildPayload(
        string $userMessage,
        string $contextBlock,
        bool $fullSystemPrompt,
    ): array {
        if ($fullSystemPrompt) {
            return [
                'contents' => [[
                    'role' => 'user',
                    'parts' => [['text' => $contextBlock."\n\n".$userMessage]],
                ]],
                'generationConfig' => ['temperature' => 0.6],
            ];
        }

        return [
            'systemInstruction' => [
                'parts' => [['text' => self::SYSTEM_PROMPT."\n\nسياق المستخدم المالي:\n".$contextBlock]],
            ],
            'contents' => [[
                'role' => 'user',
                'parts' => [['text' => $userMessage]],
            ]],
            'generationConfig' => ['temperature' => 0.6],
        ];
    }

    /**
     * @param  resource|\Psr\Http\Message\StreamInterface  $body
     */
    private function readLine($body): string
    {
        $buffer = '';
        while (! $body->eof()) {
            $char = $body->read(1);
            if ($char === '') {
                break;
            }
            if ($char === "\n") {
                break;
            }
            $buffer .= $char;
        }

        return rtrim($buffer, "\r");
    }
}
