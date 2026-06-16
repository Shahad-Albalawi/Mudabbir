<?php

namespace App\Http\Controllers\Api;

use App\Exceptions\AiQuotaExceededException;
use App\Http\Controllers\Controller;
use App\Http\Requests\GenerateContentRequest;
use App\Services\AiCoachService;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;
use RuntimeException;
use Throwable;

class GenerateContentController extends Controller
{
    /** @var AiCoachService */
    private $aiCoachService;

    public function __construct(AiCoachService $aiCoachService)
    {
        $this->aiCoachService = $aiCoachService;
    }

    public function __invoke(GenerateContentRequest $request): JsonResponse
    {
        $requestId = 'req_'.Str::uuid()->toString();

        try {
            $content = trim((string) $request->validated()['content']);
            $message = $this->aiCoachService->generate($content);

            return response()->json([
                'success' => true,
                'request_id' => $requestId,
                'message' => $message,
                'meta' => [
                    'provider' => $this->aiCoachService->provider(),
                    'model' => $this->aiCoachService->model(),
                ],
            ], 200);
        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'request_id' => $requestId,
                'error' => [
                    'code' => 'VALIDATION_ERROR',
                    'message' => 'Invalid request payload.',
                    'details' => $e->errors(),
                ],
            ], 422);
        } catch (AiQuotaExceededException $e) {
            return response()->json([
                'success' => false,
                'request_id' => $requestId,
                'error' => [
                    'code' => 'QUOTA_EXCEEDED',
                    'message' => $e->getMessage(),
                ],
            ], 429);
        } catch (RuntimeException $e) {
            return response()->json([
                'success' => false,
                'request_id' => $requestId,
                'error' => [
                    'code' => 'UPSTREAM_ERROR',
                    'message' => $e->getMessage(),
                ],
            ], 502);
        } catch (Throwable $e) {
            report($e);

            return response()->json([
                'success' => false,
                'request_id' => $requestId,
                'error' => [
                    'code' => 'INTERNAL_ERROR',
                    'message' => 'Unexpected server error.',
                ],
            ], 500);
        }
    }
}
