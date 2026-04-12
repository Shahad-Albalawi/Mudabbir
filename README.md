# Mudabbir — مُدَبِّر

تطبيق مالية شخصية: **Flutter** + **Laravel**. واجهة عربية أساساً (ميزانية، أهداف، تحديات، إحصائيات، شات ذكي).

| المجلد | الوظيفة |
|--------|---------|
| **`frontend/`** | تطبيق Flutter — التشغيل والإعداد: `frontend/README.md` |
| **`backend/`** | واجهة Laravel REST — التشغيل: `backend/README.md` |
| **`docs/`** | نشر Render وغيره (اختياري) |
| **`.devcontainer/`** | Cursor / VS Code: فتح المشروع داخل حاوية PHP + Composer (يتطلب Docker Desktop) |
| **`scripts/run-backend-docker.ps1`** | تشغيل الباكند بـ Docker من PowerShell بدون PHP محلي |

---

## كيفية الاستخدام (ملخص)

### 1) التطبيق (Flutter)

```bash
cd frontend
flutter pub get
flutter run
```

تفاصيل التعريفات (`API_BASE_URL`، `USE_LOCAL_API`، وضيف التجربة): راجع **`frontend/README.md`**.

### 2) الـ API (Laravel)

```bash
cd backend
composer install
copy .env.example .env
php artisan key:generate
```

أنشئ ملف SQLite ثم الهجرات (راجع **`backend/README.md`**). إذا **PHP غير متوفر** على Windows: استخدم **Docker** أو **`.devcontainer`** أو السكربت **`scripts/run-backend-docker.ps1`**.

---

## Tech stack

Flutter / Dart · Laravel / PHP · SQLite · REST
