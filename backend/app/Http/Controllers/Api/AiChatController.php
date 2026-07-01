<?php

namespace App\Http\Controllers\Api;

use App\Exceptions\AiQuotaExceededException;
use App\Http\Controllers\Controller;
use App\Http\Requests\Ai\AiChatRequest;
use App\Services\OpenAiStreamService;
use App\Services\UserFinancialContextService;
use Illuminate\Http\JsonResponse;
use RuntimeException;
use Symfony\Component\HttpFoundation\StreamedResponse;
use Throwable;

class AiChatController extends Controller
{
    public function __construct(
        private OpenAiStreamService $openAi,
        private UserFinancialContextService $contextService,
    ) {}

    public function __invoke(AiChatRequest $request): JsonResponse|StreamedResponse
    {
        $userId = (int) $request->user()->id;
        $message = trim((string) $request->validated()['message']);
        $stream = (bool) ($request->validated()['stream'] ?? true);
        $clientContext = trim((string) ($request->validated()['context_summary'] ?? ''));

        $context = $this->contextService->buildForUser($userId);
        $fullClientPrompt = $clientContext !== '';
        $contextBlock = $fullClientPrompt
            ? $clientContext
            : $this->contextService->toArabicPromptContext($context);

        try {
            if ($stream) {
                return $this->openAi->streamChat($message, $contextBlock, $fullClientPrompt);
            }

            $reply = $this->openAi->chat($message, $contextBlock, $fullClientPrompt);

            return $this->success([
                'message' => $reply,
                'context' => $context,
            ]);
        } catch (AiQuotaExceededException $e) {
            return $this->error($e->getMessage(), 429);
        } catch (RuntimeException $e) {
            return $this->error($e->getMessage(), 502);
        } catch (Throwable $e) {
            report($e);

            return $this->error('Unexpected server error.', 500);
        }
    }
}
