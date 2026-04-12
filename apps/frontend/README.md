# Mudabbir مُدَبِّر

تطبيق **Flutter** للوحة مالية شخصية بالعربية: الميزانية، الأهداف، التحديات، الإحصائيات، وتكامل مع خادم (Laravel / تحديات).

**Mudabbir** is a Flutter personal finance app with Arabic UI: budgeting, goals, challenges, statistics, and API integration.

## المتطلبات | Requirements

- [Flutter](https://docs.flutter.dev/get-started/install) stable (Dart SDK **^3.8.1** — see `pubspec.yaml`)
- Android Studio / Xcode (للبناء على الجهاز | for device builds)

كل خطوات المستودع (باكند، Android Studio، نشر): **[../../README.md](../../README.md)** في جذر المشروع.

## التشغيل السريع | Quick start

```bash
cd apps/frontend
flutter pub get
flutter run
```

في **Debug** يُفعَّل تلقائياً (ما لم تعطِ `DISABLE_INSTANT_BROWSE=true`):

- تخطي الإعداد المبدئي والدخول كضيف مع **بيانات تجريبية** (معاملات، أهداف، ميزانيات، تحديات محلية).

لاختبار مسار التسجيل الحقيقي من الصفر:

```bash
flutter run --dart-define=DISABLE_INSTANT_BROWSE=true
```

**باكند محلي** على المحاكي فقط (المضيف `localhost:8000` عبر `10.0.2.2`):

```bash
flutter run --dart-define=USE_LOCAL_API=true
```

## الإعداد | Configuration

- **عنوان الـ API:** الافتراضي هو السحابة في `lib/constants/api_constants.dart` (`baseUrl`). يمكن تجاوزه بـ `--dart-define=API_BASE_URL=...` أو التطوير المحلي بـ `USE_LOCAL_API=true` كما فوق.
- **تحديات السيرفر (Dio):** نفس المضيف مع لاحقة `/api` عبر `ApiConstants.apiV1Base`.

لا ترفع مفاتيح أو `.env` يحتوي أسرارًا — تظل الملفات الحساسة خارج Git (راجع `.gitignore`).

Do not commit API secrets; keep them in local env or CI variables.

### المظهر (فاتح / داكن / النظام) | Appearance

- من شاشة **الرئيسية (استكشاف)** اضغط أيقونة **القمر والنجوم** أعلى اليمين لتدوير: نظام الجهاز → فاتح → داكن.
- On **Explore / Home**, tap the **moon & stars** icon (top-right of the greeting) to cycle **system → light → dark**.

### جلسة الدخول الآمنة | Auth session

- بعد تسجيل الدخول/التسجيل يُحفظ التوكن في **Hive** و**Flutter Secure Storage**؛ عند فقدان Hive يُستعاد من التخزين الآمن.
- عند **تسجيل الخروج** يُمسح كلاهما.

## هيكل المشروع | Project structure

| المسار | الوصف |
|--------|--------|
| `lib/presentation/` | الشاشات والواجهات |
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
