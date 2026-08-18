<?php

namespace App\Exceptions;

use App\Helpers\ApiResponse;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Foundation\Exceptions\Handler as ExceptionHandler;
use Illuminate\Http\Exceptions\ThrottleRequestsException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\App;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\HttpExceptionInterface;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Throwable;

class Handler extends ExceptionHandler
{
    /**
     * @var array<class-string<\Throwable>, \Psr\Log\LogLevel::*>
     */
    protected $levels = [
        //
    ];

    /**
     * @var array<int, class-string<\Throwable>>
     */
    protected $dontReport = [
        //
    ];

    /**
     * @var array<int, string>
     */
    protected $dontFlash = [
        'current_password',
        'password',
        'password_confirmation',
    ];

    public function register(): void
    {
        $this->reportable(function (Throwable $e): void {
            //
        });
    }

    public function render($request, Throwable $e)
    {
        if ($this->isApiRequest($request)) {
            $response = $this->renderApiException($request, $e);
            if ($response !== null) {
                return $response;
            }
        }

        return parent::render($request, $e);
    }

    private function isApiRequest(Request $request): bool
    {
        return $request->is('api/*') || $request->expectsJson();
    }

    private function renderApiException(Request $request, Throwable $e): ?\Illuminate\Http\JsonResponse
    {
        App::setLocale($this->resolveApiLocale($request));

        if ($e instanceof ValidationException) {
            return ApiResponse::validationError(
                'بيانات غير صالحة. يرجى مراجعة الحقول المحددة.',
                $this->translateValidationErrors($e->errors()),
                422,
            );
        }

        if ($e instanceof AuthenticationException) {
            return ApiResponse::unauthorized();
        }

        if ($e instanceof NotFoundHttpException) {
            return ApiResponse::notFound();
        }

        if ($e instanceof ThrottleRequestsException) {
            return ApiResponse::error(
                'تم تجاوز حد الطلبات المسموح. يرجى المحاولة بعد قليل.',
                429,
            );
        }

        if ($e instanceof HttpExceptionInterface && $e->getStatusCode() === 403) {
            return ApiResponse::forbidden();
        }

        if ($this->shouldReport($e)) {
            report($e);
        }

        if (! config('app.debug') || ! $this->isApiRequest($request)) {
            if ($e instanceof HttpExceptionInterface) {
                $status = $e->getStatusCode();

                if ($status >= 500) {
                    return ApiResponse::serverError();
                }

                return ApiResponse::error($e->getMessage() ?: 'حدث خطأ غير متوقع.', $status);
            }

            return ApiResponse::serverError();
        }

        return null;
    }

    private function resolveApiLocale(Request $request): string
    {
        $preferred = strtolower((string) $request->header('Accept-Language', 'ar'));

        return str_starts_with($preferred, 'en') ? 'en' : 'ar';
    }

    /**
     * @param  array<string, array<int, string>>  $errors
     * @return array<string, array<int, string>>
     */
    private function translateValidationErrors(array $errors): array
    {
        $translated = [];

        foreach ($errors as $field => $messages) {
            $translated[$field] = array_map(
                fn (string $message): string => $this->translateValidationMessage($message),
                $messages,
            );
        }

        return $translated;
    }

    private function translateValidationMessage(string $message): string
    {
        if (App::getLocale() !== 'ar') {
            return $message;
        }

        if (preg_match('/^Too many login attempts/', $message)) {
            return preg_replace(
                '/Please try again in (\d+) seconds\./',
                'يرجى المحاولة بعد $1 ثانية.',
                str_replace(
                    'Too many login attempts.',
                    'محاولات دخول كثيرة.',
                    $message,
                ),
            );
        }

        $replacements = [
            'The name field is required.' => 'حقل الاسم مطلوب.',
            'The email field is required.' => 'حقل البريد الإلكتروني مطلوب.',
            'The password field is required.' => 'حقل كلمة المرور مطلوب.',
            'The content field is required.' => 'حقل المحتوى مطلوب.',
            'The message field is required.' => 'حقل الرسالة مطلوب.',
            'The email must be a valid email address.' => 'يجب إدخال بريد إلكتروني صالح.',
            'The password must be at least 8 characters.' => 'يجب أن تكون كلمة المرور 8 أحرف على الأقل.',
            'These credentials do not match our records.' => 'بيانات الدخول غير صحيحة.',
            'The provided credentials are incorrect.' => 'بيانات الدخول غير صحيحة.',
        ];

        return $replacements[$message] ?? $message;
    }
}
