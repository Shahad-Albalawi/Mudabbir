# نشر Mudabbir API على Render (بديل Laravel Cloud)

دليل عربي خطوة بخطوة — يستغرق ~10 دقائق.

---

## 1) حساب Render

1. افتحي [dashboard.render.com](https://dashboard.render.com/)
2. سجّلي دخول بحساب GitHub
3. اربطي GitHub إذا طُلب

---

## 2) إنشاء الخدمة من Blueprint

1. اضغطي **New +** → **Blueprint**
2. اختاري المستودع: **`Shahad-Albalawi/Mudabbir`**
3. **Branch:** `main` · **Blueprint Path:** `render.yaml`
4. اضغطي **Apply**

> Render **لا يدعم** `runtime: php`. المشروع يستخدم **Docker** (`backend/Dockerfile`).

---

## 3) متغيرات البيئة (مهم)

من الخدمة → **Environment** → أضيفي:

| المتغير | القيمة |
|---------|--------|
| `APP_KEY` | انسخي من السكربت أدناه |
| `APP_URL` | `https://mudabbir-backend-api.onrender.com` (أو الرابط اللي يعطيك Render) |

### توليد APP_KEY (من جهازك)

```powershell
powershell -ExecutionPolicy Bypass -File scripts/generate-app-key.ps1
```

انسخي السطر اللي يبدأ بـ `base64:` والصقيه في Render كـ `APP_KEY`.

> `APP_ENV`, `APP_DEBUG`, `DB_CONNECTION` مضبوطة في `render.yaml` — لا تحتاج تكرارها إلا إذا Render ما طبّقها.

### الشات بوت (اختياري)

| المتغير | ملاحظة |
|---------|--------|
| `OPENAI_API_KEY` | مفتاح OpenAI أو NVIDIA |
| `AI_PROVIDER` | `openai` |

---

## 4) النشر

1. **Manual Deploy** أو انتظري أول build تلقائي
2. انتظري **Live** (5–10 دقائق أول مرة)
3. الرابط يكون مثل: `https://mudabbir-backend-api.onrender.com`

> **Free plan:** السيرفر ينام بعد ~15 دقيقة بدون زيارات — أول طلب قد يأخذ 30–60 ثانية (cold start).

---

## 5) التحقق

```powershell
curl.exe -sS "https://mudabbir-backend-api.onrender.com/api/health"
```

المتوقع:

```json
{"success":true,"status":"ok","service":"mudabbir-api"}
```

أو:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/check-production-api.ps1 -ApiBaseUrl "https://YOUR-SERVICE.onrender.com"
```

---

## 6) ربط تطبيق Flutter

بعد ما يشتغل الرابط، حدّثي:

- `frontend/config/release.json`
- `frontend/lib/constants/api_constants.dart`

أو ابعثي الرابط هنا — نحدّثه في المستودع.

بناء APK:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/build-release-apk.ps1
```

---

## استكشاف الأخطاء

| المشكلة | الحل |
|---------|------|
| Build فشل `composer` | تأكدي **Root Directory** = `backend` |
| 500 بعد النشر | `APP_KEY` ناقص أو `migrate` فشل — راجع **Logs** |
| بطء أول طلب | طبيعي على Free — انتظري دقيقة |
| 401 على `/api/expenses` | طبيعي بدون توكن — سجّلي دخول من التطبيق |

---

## مرجع إنجليزي

[DEPLOY_RENDER.md](./DEPLOY_RENDER.md)
