<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\GenerateContentRequest;
use App\Services\OpenAiService;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;
use RuntimeException;
use Throwable;

class GenerateContentController extends Controller
{
    public function __construct(private readonly OpenAiService $openAiService) {}

    public function __invoke(GenerateContentRequest $request): JsonResponse
    {
        $requestId = 'req_'.Str::uuid()->toString();

        try {
            $content = trim((string) $request->validated('content'));
            $message = $this->openAiService->generate($content);
            $baseUrl = (string) config('openai.base_url', '');
            $provider = str_contains(strtolower($baseUrl), 'integrate.api.nvidia.com') ? 'nvidia-nim' : 'openai';

            return response()->json([
                'success' => true,
                'request_id' => $requestId,
                'message' => $message,
                'meta' => [
                    'provider' => $provider,
                    'model' => config('openai.model'),
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
