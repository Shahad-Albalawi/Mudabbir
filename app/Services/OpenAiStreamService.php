<?php

namespace App\Services;

use App\Exceptions\AiQuotaExceededException;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Http\Client\RequestException;
use Illuminate\Support\Facades\Http;
use RuntimeException;
use Symfony\Component\HttpFoundation\StreamedResponse;
use Throwable;

class OpenAiStreamService
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
        $apiKey = (string) config('openai.api_key');
        $model = (string) config('openai.model', 'gpt-4o-mini');
        $baseUrl = rtrim((string) config('openai.base_url', 'https://api.openai.com/v1'), '/');

        if ($apiKey === '') {
            throw new RuntimeException('OpenAI API key is missing.');
        }

        $messages = $this->buildMessages($userMessage, $contextBlock, $fullSystemPrompt);

        return new StreamedResponse(function () use ($apiKey, $model, $baseUrl, $messages): void {
            $response = Http::withToken($apiKey)
                ->acceptJson()
                ->withOptions(['stream' => true])
                ->timeout((int) config('openai.timeout', 60))
                ->post("{$baseUrl}/chat/completions", [
                    'model' => $model,
                    'stream' => true,
                    'messages' => $messages,
                    'temperature' => 0.6,
                ]);

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
                if ($line === '') {
                    continue;
                }
                if (! str_starts_with($line, 'data: ')) {
                    continue;
                }
                $payload = trim(substr($line, 6));
                if ($payload === '[DONE]') {
                    echo "data: [DONE]\n\n";
                    break;
                }
                $json = json_decode($payload, true);
                $delta = $json['choices'][0]['delta']['content'] ?? null;
                if (is_string($delta) && $delta !== '') {
                    echo 'data: '.json_encode(['token' => $delta], JSON_UNESCAPED_UNICODE)."\n\n";
                }
                if (ob_get_level() > 0) {
                    ob_flush();
                }
                flush();
            }
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
        $apiKey = (string) config('openai.api_key');
        $model = (string) config('openai.model', 'gpt-4o-mini');
        $baseUrl = rtrim((string) config('openai.base_url', 'https://api.openai.com/v1'), '/');

        if ($apiKey === '') {
            throw new RuntimeException('OpenAI API key is missing.');
        }

        $messages = $this->buildMessages($userMessage, $contextBlock, $fullSystemPrompt);

        try {
            $response = Http::withToken($apiKey)
                ->acceptJson()
                ->timeout((int) config('openai.timeout', 30))
                ->post("{$baseUrl}/chat/completions", [
                    'model' => $model,
                    'messages' => $messages,
                    'temperature' => 0.6,
                ]);

            if ($response->failed()) {
                throw new RequestException($response);
            }

            $text = $response->json('choices.0.message.content');
            if (! is_string($text) || trim($text) === '') {
                throw new RuntimeException('OpenAI returned an empty response.');
            }

            return trim($text);
        } catch (RequestException $e) {
            $status = $e->response?->status();
            if ($status === 429) {
                throw new AiQuotaExceededException('OpenAI rate limit exceeded.');
            }
            throw new RuntimeException('OpenAI request failed.');
        } catch (ConnectionException) {
            throw new RuntimeException('Failed to connect to OpenAI.');
        } catch (Throwable $e) {
            throw new RuntimeException($e->getMessage());
        }
    }

    /**
     * @return list<array{role: string, content: string}>
     */
    private function buildMessages(
        string $userMessage,
        string $contextBlock,
        bool $fullSystemPrompt,
    ): array {
        if ($fullSystemPrompt) {
            return [
                ['role' => 'system', 'content' => $contextBlock],
                ['role' => 'user', 'content' => $userMessage],
            ];
        }

        return [
            ['role' => 'system', 'content' => self::SYSTEM_PROMPT],
            ['role' => 'system', 'content' => "سياق المستخدم المالي:\n".$contextBlock],
            ['role' => 'user', 'content' => $userMessage],
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
