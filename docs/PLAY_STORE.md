# Google Play Store — Mudabbir (مُدَبِّر)

Guide for publishing the Flutter app to Google Play Console.

---

## Prerequisites

1. **Google Play Developer account** ($25 one-time fee).
2. **Upload keystore** — copy `frontend/android/key.properties.example` → `frontend/android/key.properties` (gitignored).
3. **Production API** — `frontend/config/release.json` with your Render URL.
4. **Signed AAB** — run from repo root:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/build-release-aab.ps1
```

For sideload/testing APK instead:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/build-release-apk.ps1
```

---

## Store listing (suggested copy)

### App name

| Language | Title |
|----------|--------|
| Arabic (default) | مُدَبِّر — ميزانيتك وأهدافك |
| English | Mudabbir — Budget & Goals |

### Short description (≤ 80 chars)

| AR | EN |
|----|-----|
| تطبيق مالي شخصي: ميزانية، أهداف ادخار، تحليل سلوكي، ومساعد ذكي. | Personal finance: budgets, savings goals, insights & AI coach. |

### Full description

**Arabic**

مُدَبِّر يساعدك على إدارة أموالك بالعربية والإنجليزية:

- تتبع الدخل والمصروفات مع مزامنة سحابية
- حدود ميزانية شهرية مع تنبيهات محلية
- أهداف ادخار وتقدم مرئي
- تحديات ادخار جماعية
- إحصائيات وتحليل سلوكي
- مساعد مالي ذكي (عربي/إنجليزي)
- تقارير PDF شهرية بخط ثمانية

**English**

Mudabbir helps you manage money in Arabic and English:

- Track income & expenses with cloud sync
- Monthly budgets with on-device alerts
- Savings goals with progress tracking
- Social saving challenges
- Statistics & behavioral insights
- Bilingual AI financial coach
- Monthly PDF reports (Thmanyah font, SAR ﷼)

### Category

**Finance**

### Content rating

Complete the IARC questionnaire — no gambling, no user-generated public content.

---

## Graphics checklist

| Asset | Size | Notes |
|-------|------|--------|
| App icon | 512×512 PNG | From `flutter_launcher_icons` |
| Feature graphic | 1024×500 PNG | Brand + tagline |
| Phone screenshots | 2–8 | See `screenshots/` (add budget screen) |
| Privacy policy URL | — | Required (host on GitHub Pages or your site) |

---

## Data safety (summary for the form)

| Data type | Collected | Purpose | Encrypted in transit |
|-----------|-----------|---------|----------------------|
| Email, name | Yes (account) | Authentication | Yes (HTTPS) |
| Financial transactions | Yes | Core app feature | Yes |
| Savings goals & budgets | Yes | Core app feature | Yes |
| Device identifiers | No (unless you add analytics later) | — | — |

**Permissions**

- `INTERNET` — API sync
- `POST_NOTIFICATIONS` — local budget/goal alerts (Android 13+); user can deny

---

## Release workflow

1. Bump `version` in `frontend/pubspec.yaml` (`1.0.0+1` → `1.0.1+2`).
2. Build AAB with `scripts/build-release-aab.ps1`.
3. Upload to **Internal testing** track first.
4. Verify: login, expenses/goals/budgets sync, offline mode, notifications.
5. Promote to **Production** after review.

---

## Privacy policy

The app includes an in-app **Privacy policy** screen at **Settings → Privacy policy** (`/privacy`), available in Arabic and English. You can also host the same text on a public URL for Play Console.

Host a page (or reference the in-app copy) stating:

- Who operates the app (your name / graduation project).
- Data stored: account email, expenses, goals, budgets on Laravel backend (Render).
- Data not sold to third parties.
- User can request account/data deletion via support email.
- OpenAI/Gemini used only for chatbot when user sends messages.

---

## Related docs

- [README.md](../README.md) — dev setup & release checklist
- [docs/DEPLOY_RENDER_AR.md](DEPLOY_RENDER_AR.md) — backend deployment
