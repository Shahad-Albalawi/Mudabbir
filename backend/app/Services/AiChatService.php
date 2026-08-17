<?php

namespace App\Services;

use RuntimeException;
use Symfony\Component\HttpFoundation\StreamedResponse;

class AiChatService
{
    public function __construct(
        private OpenAiStreamService $openAi,
        private GeminiStreamService $gemini,
    ) {}

    public function streamChat(
        string $userMessage,
        string $contextBlock,
        bool $fullSystemPrompt = false,
    ): StreamedResponse {
        return $this->providerService()->streamChat($userMessage, $contextBlock, $fullSystemPrompt);
    }

    public function chat(
        string $userMessage,
        string $contextBlock,
        bool $fullSystemPrompt = false,
    ): string {
        return $this->providerService()->chat($userMessage, $contextBlock, $fullSystemPrompt);
    }

    private function providerService(): OpenAiStreamService|GeminiStreamService
    {
        $provider = strtolower((string) config('ai.provider', 'openai'));

        if ($provider === 'gemini') {
            return $this->gemini;
        }

        if ($provider === 'openai') {
            return $this->openAi;
        }

        throw new RuntimeException("Unsupported AI provider: {$provider}. Use openai or gemini.");
    }
}
