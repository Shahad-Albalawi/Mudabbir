<?php

namespace App\Services;

use RuntimeException;

class AiCoachService
{
    /** @var OpenAiService */
    private $openAiService;

    /** @var GeminiService */
    private $geminiService;

    public function __construct(OpenAiService $openAiService, GeminiService $geminiService)
    {
        $this->openAiService = $openAiService;
        $this->geminiService = $geminiService;
    }

    public function generate(string $prompt): string
    {
        $provider = strtolower((string) config('ai.provider', 'openai'));

        if ($provider === 'gemini') {
            return $this->geminiService->generate($prompt);
        }

        if ($provider === 'openai') {
            return $this->openAiService->generate($prompt);
        }

        throw new RuntimeException("Unsupported AI provider: {$provider}. Use openai or gemini.");
    }

    public function provider(): string
    {
        return strtolower((string) config('ai.provider', 'openai'));
    }

    public function model(): string
    {
        $provider = $this->provider();

        if ($provider === 'gemini') {
            return (string) config('gemini.model', 'gemini-2.0-flash');
        }

        return (string) config('openai.model', 'gpt-4o-mini');
    }
}
