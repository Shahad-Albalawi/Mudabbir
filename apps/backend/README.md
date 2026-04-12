# Mudabbir — Laravel API

REST API للتطبيق: شات بوت (`POST /api/generate-content`) وتحديات (`/api/challenges` …). التشغيل والنشر والـ API مذكورة في **README.md في جذر المستودع** (ملف واحد لكل التعليمات).

```bash
cd apps/backend
composer install
cp .env.example .env   # Windows: copy
php artisan key:generate
# أنشئ database/database.sqlite ثم:
php artisan migrate
php artisan serve
```

ضع `OPENAI_API_KEY` في `.env`. الاختبارات: `php artisan test`.
