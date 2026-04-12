# Mudabbir مُدَبِّر

تطبيق **Flutter** للوحة مالية شخصية بالعربية: الميزانية، الأهداف، التحديات، الإحصائيات، وتكامل مع خادم (Laravel / تحديات).

**Mudabbir** is a Flutter personal finance app with Arabic UI: budgeting, goals, challenges, statistics, and API integration.

## المتطلبات | Requirements

- [Flutter](https://docs.flutter.dev/get-started/install) stable (Dart SDK **^3.8.1** — see `pubspec.yaml`)
- Android Studio / Xcode (للبناء على الجهاز | for device builds)

كل خطوات المستودع (باكند، Android Studio، نشر): **[../../README.md](../../README.md)** في جذر المشروع.

## التشغيل السريع | Quick start

```bash
git clone <your-repo-url>
cd apps/frontend
flutter pub get
flutter run
```

## الإعداد | Configuration

- **عنوان الـ API (تسجيل الدخول / التسجيل):**  
  `lib/constants/api_constants.dart` → `baseUrl`
- **تحديات السيرفر (Dio):**  
  `lib/persentation/server_challenges/utils/dio_client.dart` → `baseUrl`  
  يجب أن يتوافق المسار مع شكل الـ API لديك (مثل `/api`).

لا ترفع مفاتيح أو `.env` يحتوي أسرارًا — تظل الملفات الحساسة خارج Git (راجع `.gitignore`).

Do not commit API secrets; keep them in local env or CI variables.

### المظهر (فاتح / داكن / النظام) | Appearance

- من شاشة **الرئيسية (استكشاف)** اضغط أيقونة **القمر والنجوم** أعلى اليمين لتدوير: نظام الجهاز → فاتح → داكن.
- On **Explore / Home**, tap the **moon & stars** icon (top-right of the greeting) to cycle **system → light → dark**.

### الإشعارات (Firebase) | Push notifications

- المشروع يتضمن **`firebase_core`**, **`firebase_messaging`**, **`flutter_local_notifications`**.
- حتى تشغّل الإشعارات عبر FCM، نفّذ:  
  `dart pub global activate flutterfire_cli` ثم **`flutterfire configure`** ليُولَّد `lib/firebase_options.dart` بمفاتيح حقيقية.  
  بدون ذلك، التطبيق يعمل لكن يطبع في الـ log أن الإشعارات متجاهلة.
- راجع **`../../README.md`** (قسم API و Firebase) لربط الرمز مع Laravel أو الإشعارات.

### جلسة الدخول الآمنة | Auth session

- بعد تسجيل الدخول/التسجيل يُحفظ التوكن في **Hive** و**Flutter Secure Storage**؛ عند فقدان Hive يُستعاد من التخزين الآمن.
- عند **تسجيل الخروج** يُمسح كلاهما.

## هيكل المشروع | Project structure

| المسار | الوصف |
|--------|--------|
| `lib/persentation/` | الشاشات والواجهات (اسم المجلد تاريخي بخطأ إملائي *presentation*؛ تغييره يتطلب إعادة تسمية واسعة للاستيرادات). |
| `lib/domain/` | النماذج والمستودعات المجردة |
| `lib/service/` | الخدمات، التوجيه، Hive، الـ API، الإشعارات، الأمان |
| `../../README.md` | تعليمات المستودع كاملة (باكند، Android Studio، نشر) |
| `lib/data/` | الشبكة، الأخطاء، التخزين المحلي |
| `assets/` | صور، Lottie، خط Tajawal |

## أوامر مفيدة | Useful commands

```bash
flutter analyze
flutter test
```

## المساهمة | Contributing

افتح **Issue** أو **Pull Request** مع وصف واضح للتغيير.

---

**ملاحظة:** Monorepo يحتوي `apps/frontend` و `apps/backend` — التوثيق المركزي في **`README.md`** عند جذر المستودع.
