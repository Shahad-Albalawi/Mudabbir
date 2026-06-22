<?php

namespace App\Support;

use Illuminate\Http\JsonResponse;

/**
 * Consistent JSON envelope for Mudabbir API responses.
 *
 * { success, data, message, errors }
 */
final class ApiResponse
{
    public static function success(
        mixed $data = null,
        string $message = '',
        int $status = 200,
        array $extra = [],
    ): JsonResponse {
        return response()->json(array_merge([
            'success' => true,
            'data' => $data,
            'message' => $message,
            'errors' => null,
        ], $extra), $status);
    }

    public static function created(mixed $data, string $message = 'Created'): JsonResponse
    {
        return self::success($data, $message, 201);
    }

    public static function error(
        string $message,
        int $status = 400,
        ?array $errors = null,
        mixed $data = null,
    ): JsonResponse {
        return response()->json([
            'success' => false,
            'data' => $data,
            'message' => $message,
            'errors' => $errors,
        ], $status);
    }

    public static function notFound(string $message = 'Resource not found'): JsonResponse
    {
        return self::error($message, 404);
    }

    public static function forbidden(string $message = 'Forbidden'): JsonResponse
    {
        return self::error($message, 403);
    }

    public static function conflict(string $message, mixed $data = null): JsonResponse
    {
        return self::error($message, 409, null, $data);
    }

    /**
     * @param  array<string, mixed>|null  $details
     */
    public static function codedError(
        string $code,
        string $message,
        int $status = 400,
        ?array $details = null,
    ): JsonResponse {
        return response()->json([
            'success' => false,
            'data' => null,
            'message' => $message,
            'errors' => [
                'code' => $code,
                'details' => $details,
            ],
        ], $status);
    }
}
