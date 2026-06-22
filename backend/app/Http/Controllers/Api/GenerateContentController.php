<?php

namespace App\Http\Controllers\Api;

use App\Exceptions\AiQuotaExceededException;
use App\Http\Controllers\Controller;
use App\Http\Requests\GenerateContentRequest;
use App\Services\AiCoachService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;
use RuntimeException;
use Throwable;

class GenerateContentController extends Controller
{
    public function __construct(private readonly AiCoachService $aiCoachService) {}

    public function __invoke(GenerateContentRequest $request): JsonResponse
    {
        $requestId = 'req_'.Str::uuid()->toString();

        try {
            $content = trim((string) $request->validated()['content']);
            $message = $this->aiCoachService->generate($content);
            $meta = [
                'provider' => $this->aiCoachService->provider(),
                'model' => $this->aiCoachService->model(),
            ];

            return ApiResponse::success(
                data: [
                    'message' => $message,
                    'request_id' => $requestId,
                    'meta' => $meta,
                ],
                message: $message,
                extra: [
                    // Backward compatibility for existing clients/tests.
                    'request_id' => $requestId,
                    'meta' => $meta,
                ],
            );
        } catch (ValidationException $e) {
            return ApiResponse::codedError(
                'VALIDATION_ERROR',
                'Invalid request payload.',
                422,
                $e->errors(),
            );
        } catch (AiQuotaExceededException $e) {
            return ApiResponse::codedError(
                'QUOTA_EXCEEDED',
                $e->getMessage(),
                429,
            );
        } catch (RuntimeException $e) {
            return ApiResponse::codedError(
                'UPSTREAM_ERROR',
                $e->getMessage(),
                502,
            );
        } catch (Throwable $e) {
            report($e);

            return ApiResponse::codedError(
                'INTERNAL_ERROR',
                'Unexpected server error.',
                500,
            );
        }
    }
}
