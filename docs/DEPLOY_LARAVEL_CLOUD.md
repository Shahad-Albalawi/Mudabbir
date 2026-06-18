# نشر Mudabbir على Laravel Cloud (الخيار أ)

دليل استعادة السيرفر الإنتاجي على `*.laravel.cloud` بعد خطأ **530 / 1016**.

---

## لماذا يظهر 530؟

الاسم `gemini-api-s-challenges-uvxa39.laravel.cloud` يصل إلى **Cloudflare**، لكن **بيئة Laravel Cloud الأصلية** (origin) متوقفة أو محذوفة أو فشل نشرها. إعادة النشر من لوحة التحكم تحل المشكلة في أغلب الحالات.

---

## 1) الدخول إلى Laravel Cloud

1. افتح [cloud.laravel.com](https://cloud.laravel.com) وسجّل الدخول.
2. ابحث عن التطبيق المرتبط بـ `gemini-api-s-challenges` أو أنشئ تطبيقاً جديداً.
3. افتح بيئة **production** (أو أنشئ بيئة جديدة).

> **ملاحظة:** إذا حُذفت البيئة القديمة، سيُنشأ رابط `*.laravel.cloud` **جديد**. حدّثه في `frontend/config/release.json` بعد النشر.

---

## 2) ربط المستودع

| الإعداد | القيمة |
|---------|--------|
| المستودع | `Shahad-Albalawi/Mudabbir` على GitHub |
| **الفرع** | **`laravel-cloud`** (مو `main`) |

### لماذا فرع `laravel-cloud`؟

المشروع **monorepo** — Laravel داخل `backend/` ولا يوجد حقل Root directory في Laravel Cloud.

**GitHub Action** (`laravel-cloud-branch.yml`) ينشئ فرع `laravel-cloud` تلقائياً فيه محتوى `backend/` فقط في الجذر. Laravel Cloud يبني مباشرة بدون سكربت معقّد.

> بعد كل `push` على `main`، يُحدَّث فرع `laravel-cloud` خلال دقيقة. في Laravel Cloud اختر هذا الفرع ثم **Save & Deploy**.

### بديل (إذا بقيت على فرع `main`)

انسخ سكربت `.laravel-cloud/build.sh` في أوامر البناء — راجع القسم 3 أدناه.

---

## 3) أوامر البناء والنشر (Deployments)

افتح البيئة → **Deployments**.

### إذا الفرع = `laravel-cloud` (مُوصى به)

**Build commands** — سطر واحد فقط (يتجنب أخطاء الإملاء):

```bash
bash cloud-build.sh
```

**Deploy commands:**

```bash
bash cloud-deploy.sh
```

> لا تكتب `composer install` يدوياً في لوحة Laravel Cloud — السكربت `cloud-build.sh` في فرع `laravel-cloud` يشغّل الأوامر الصحيحة.

### إذا الفرع = `main` (بديل)

**Build commands:**

```bash
bash .laravel-cloud/build.sh
composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev
php artisan config:cache
php artisan route:cache
```

**Deploy commands:**

```bash
php artisan migrate --force
```

> احذف أوامر `npm install` / `npm run build` الافتراضية إذا فشلت — الـ API لا يحتاج بناء Flutter.

لا تشغّل `php artisan storage:link` على Laravel Cloud (لا يُحفظ بين النشرات). ملفات JSON للمصروفات/الأهداف/التحديات تُخزَّن في `storage/app/` — على القرص المؤقت؛ للإنتاج الجاد يُفضّل لاحقاً قاعدة بيانات أو Object Storage.

---

## 4) متغيرات البيئة (Environment)

أضف في **Settings → Environment variables**:

| المتغير | مثال / ملاحظة |
|---------|----------------|
| `APP_NAME` | `Mudabbir` |
| `APP_ENV` | `production` |
| `APP_DEBUG` | `false` |
| `APP_URL` | `https://laravel-main-nb0wjv.free.laravel.cloud` |
| `APP_KEY` | انسخ من `php artisan key:generate --show` محلياً |
| `LOG_LEVEL` | `warning` |
| **`DB_CONNECTION`** | **`sqlite`** إذا ما أرفقتِ Database — **مهم** |
| `DB_DATABASE` | اتركيه فارغاً (يستخدم `database/database.sqlite` تلقائياً) |

**قاعدة البيانات — اختاري واحد:**

| الخيار | الإعداد |
|--------|---------|
| **أ) بدون Cloud Database (أسرع)** | `DB_CONNECTION=sqlite` — احذفي أي `DB_HOST` / `DB_USERNAME` / `DB_PASSWORD` قديمة بقيم `forge` |
| **ب) إنتاج دائم (مُوصى به)** | من Laravel Cloud: **Add resource → Database** — يحقن المتغيرات تلقائياً ويُبقي المستخدمين بعد إعادة النشر |

> خطأ `Connection refused` + `table_schema = forge` = Laravel يحاول MySQL بدون سيرفر. الحل: `DB_CONNECTION=sqlite` أو أرفقي Database.
| `AI_PROVIDER` | `openai` أو `gemini` |
| `OPENAI_API_KEY` | مفتاحك (للشات بوت) |
| `GEMINI_API_KEY` | اختياري |

بعد Sanctum (المرحلة 1): المستخدمون وجلسات API تحتاج **قاعدة بيانات دائمة**. للإنتاج يُنصح بإرفاق **Laravel Cloud Database** (MySQL) وتشغيل `migrate --force`.

---

## 5) النشر

1. من صفحة البيئة اضغط **Deploy** (أو **Save & Deploy** بعد حفظ الإعدادات).
2. انتظر اكتمال البناء (أقل من 15 دقيقة).
3. تأكد أن الحالة **Running** وليست **Stopped** — إن كانت متوقفة: القائمة `...` → **Restart**.

### نشر تلقائي (اختياري — مرة واحدة)

1. Laravel Cloud → **Settings → Deployments** → فعّل **Deploy hook** وانسخ الرابط.
2. GitHub → `Shahad-Albalawi/Mudabbir` → **Settings → Secrets → Actions** → أضف:
   - الاسم: `LARAVEL_CLOUD_DEPLOY_HOOK`
   - القيمة: الرابط المنسوخ
3. بعدها كل `push` على `main` يحدّث فرع `laravel-cloud` **ويشغّل النشر** تلقائياً.

أو من جهازك (بدون GitHub secret):

```powershell
$env:LARAVEL_CLOUD_DEPLOY_HOOK = "https://YOUR-DEPLOY-HOOK-URL"
powershell -ExecutionPolicy Bypass -File scripts/laravel-cloud-redeploy.ps1
```

---

## 6) التحقق

من جذر المستودع:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/check-production-api.ps1 `
  -ApiBaseUrl "https://laravel-main-nb0wjv.free.laravel.cloud"
```

المتوقع:

- `GET /api/health` → **200** و `{ "success": true, "status": "ok" }`
- `POST /api/register` → **201** (مستخدم جديد)

اختبار يدوي:

```powershell
curl.exe -sS "https://YOUR-URL.laravel.cloud/api/health"
```

---

## 7) ربط تطبيق Flutter

إذا بقي نفس الرابط — لا تغيير. إذا تغيّر الرابط:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/build-release-apk.ps1 `
  -ApiBaseUrl "https://YOUR-NEW-URL.laravel.cloud"
```

أو عدّل `frontend/config/release.json` يدوياً.

---

## 8) استكشاف الأخطاء

| العرض | الإجراء |
|-------|---------|
| `composer.lock` / `composer.json` could not be found | استخدم فرع `laravel-cloud` بدل `main` |
| `--optimize-autoliader` option does not exist | خطأ إملائي — استبدل أوامر البناء بـ `bash cloud-build.sh` |
| `nette/schema` requires php 7.1 - 8.3 | Laravel Cloud على PHP 8.5 — `cloud-build.sh` يحدّث الحزم تلقائياً |
| 530 / 1016 بعد النشر | تأكد أن النشر نجح وأن البيئة **Running**؛ أعد Deploy |
| 500 على `/api/health` | راجع سجلات البيئة في Laravel Cloud؛ غالباً `APP_KEY` ناقص أو `migrate` فشل |
| `Connection refused` + `forge` عند migrate | MySQL غير مربوط — عيّني `DB_CONNECTION=sqlite` أو أرفقي **Database** من Laravel Cloud |
| 401 على `/api/expenses` | طبيعي بدون توكن — سجّل دخول من التطبيق أولاً |
| البيانات تختفي بعد إعادة النشر | JSON + sqlite على قرص مؤقت — أرفق Database دائمة |

---

## مراجع

- [Laravel Cloud — Deployments](https://cloud.laravel.com/docs/deployments)
- [Laravel Cloud — Environments](https://cloud.laravel.com/docs/environments)
- تشخيص 530: `docs/PRODUCTION_API.md`
