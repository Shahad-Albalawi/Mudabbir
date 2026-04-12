import 'package:mudabbir/persentation/resources/strings_manager.dart';

/// All bilingual strings used by [ChatbotViewModel] and chat UI.
class ChatbotUi {
  ChatbotUi._();

  static bool get _e => AppStrings.isEnglishLocale;

  static String get reduceCategoryHint => _e
      ? 'To cut spending in a category, try: "analyze food category" or "how do I reduce transport spending?".'
      : 'لخفض الإنفاق في فئة معينة، اكتب: "حلل فئة الطعام" أو "كيف أقلل إنفاق النقل؟".';

  static String get undoNone =>
      _e ? 'Nothing recent to undo.' : 'لا توجد عملية حديثة يمكن التراجع عنها.';

  static String undoDone(String summary) => _e
      ? 'Undone: $summary ↩️'
      : 'تم التراجع عن العملية: $summary ↩️';

  static String get undoMissing =>
      _e ? 'Could not undo — record not found.' : 'تعذر التراجع لأن السجل غير موجود حالياً.';

  static String get undoError =>
      _e ? 'Something went wrong while undoing.' : 'حدث خطأ أثناء محاولة التراجع.';

  static String get whatIfError =>
      _e ? 'Could not run the what-if scenario. Try again.' : 'تعذر حساب سيناريو "ماذا لو" الآن. حاول مرة أخرى.';

  static String get subsError => _e
      ? 'Could not analyze subscriptions right now. Try later.'
      : 'تعذر تحليل الاشتراكات حاليًا. حاول لاحقًا.';

  static String get insightError => _e
      ? 'Could not compute financial indicators now. Try again shortly.'
      : 'تعذر تحليل المؤشرات المالية الآن. جرّب مرة أخرى بعد قليل.';

  static String get genericProcessError => _e
      ? 'Sorry, something went wrong processing your request. Please try again.'
      : 'عذراً، حدث خطأ أثناء معالجة طلبك. يرجى المحاولة مرة أخرى.';

  static String get pendingHint => _e
      ? 'You have a pending action. Type "confirm" to run or "cancel" to abort.'
      : 'لدي عملية معلّقة. اكتب "تأكيد" للتنفيذ أو "إلغاء" للإلغاء.';

  static String get pendingCancelled =>
      _e ? 'Pending action cancelled.' : 'تم إلغاء العملية المعلّقة.';

  static String goalCreatedSummary(String name) =>
      _e ? 'Create goal $name' : 'إنشاء هدف $name';

  static String goalCreatedOk(String name) => _e
      ? 'Goal "$name" created successfully.'
      : 'تم إنشاء الهدف "$name" بنجاح.';

  static String budgetCreatedSummary(String amount) =>
      _e ? 'Create budget $amount ﷼' : 'إنشاء ميزانية $amount ﷼';

  static String budgetCreatedOk(String amount) => _e
      ? 'Next month\'s budget created: $amount ﷼.'
      : 'تم إنشاء الميزانية للشهر القادم بقيمة $amount ﷼.';

  static String get needGoalAmount => _e
      ? 'To create a goal I need an amount. Example: create goal car 25000 in 12 months.'
      : 'لفهم أمر إنشاء الهدف، أحتاج المبلغ. مثال: أنشئ هدف سيارة 25000 خلال 12 شهر.';

  static String previewGoal(String name, String amount, int months) => _e
      ? 'Preview 🧾\n'
          '- Action: Create goal\n'
          '- Name: $name\n'
          '- Target: $amount ﷼\n'
          '- Duration: $months months\n\n'
          'Type "confirm" to apply or "cancel" to abort.'
      : 'معاينة قبل التنفيذ 🧾\n'
          '- نوع العملية: إنشاء هدف\n'
          '- الاسم: $name\n'
          '- المبلغ: $amount ﷼\n'
          '- المدة: $months شهر\n\n'
          'اكتب "تأكيد" للتنفيذ أو "إلغاء" للإلغاء.';

  static String get needBudgetAmount => _e
      ? 'I need a budget amount. Example: create budget 3000 next month.'
      : 'لفهم أمر الميزانية، أحتاج قيمة الميزانية. مثال: أنشئ ميزانية 3000 الشهر القادم.';

  static String get noAccountForBudget =>
      _e ? 'No account available to attach this budget.' : 'لا يوجد حساب متاح لإنشاء الميزانية.';

  static String previewBudget(String amount, String start, String end) => _e
      ? 'Preview 🧾\n'
          '- Action: Create budget\n'
          '- Amount: $amount ﷼\n'
          '- Period: $start to $end\n\n'
          'Type "confirm" to apply or "cancel" to abort.'
      : 'معاينة قبل التنفيذ 🧾\n'
          '- نوع العملية: إنشاء ميزانية\n'
          '- القيمة: $amount ﷼\n'
          '- الفترة: $start إلى $end\n\n'
          'اكتب "تأكيد" للتنفيذ أو "إلغاء" للإلغاء.';

  static String get defaultNewGoalName =>
      _e ? 'My new goal' : 'هدفي الجديد';

  static String insightStatus(int score) {
    if (_e) {
      if (score >= 75) return 'Strong';
      if (score >= 50) return 'Good with room to improve';
      return 'Needs attention';
    }
    if (score >= 75) return 'ممتازة';
    if (score >= 50) return 'جيدة مع مجال للتحسين';
    return 'تحتاج متابعة';
  }

  static String insightBody(int score, String status, String alertBlock) => _e
      ? 'Financial health score: $score/100\nStatus: $status\n\n$alertBlock'
      : 'درجة الصحة المالية الحالية: $score/100\nالحالة: $status\n\n$alertBlock';

  static String get noSpendingAlerts => _e
      ? 'No unusual spending alerts right now.'
      : 'لا توجد تنبيهات إنفاق غير طبيعي حاليًا.';

  static String get whatIfNeedAmount => _e
      ? 'For a what-if scenario, include an amount. Example: if I save 300 a month when do I reach my goal?'
      : 'لعمل سيناريو "ماذا لو"، اذكر مبلغًا واضحًا. مثال: لو أوفر 300 ريال شهريًا متى أوصل لهدفي؟';

  static String get whatIfNoGoals => _e
      ? 'You have no saved goals yet. Add a goal first, then run a what-if.'
      : 'لا يوجد لديك أهداف محفوظة حاليًا. أضف هدفًا أولًا ثم احسب سيناريو "ماذا لو".';

  static String get whatIfAllGoalsDone => _e
      ? 'Great — it looks like you\'ve completed your current goals.'
      : 'ممتاز، يبدو أنك حققت جميع أهدافك الحالية.';

  static String get nextGoalFallback =>
      _e ? 'Your next goal' : 'هدفك القادم';

  static String whatIfScenario(
    String amount,
    String name,
    String remaining,
    int months,
    String eta,
  ) =>
      _e
          ? 'What-if scenario 💡\n'
              '- If you save $amount ﷼ / month\n'
              '- Goal: $name\n'
              '- Remaining: $remaining ﷼\n'
              '- Estimated time: ~$months months\n'
              '- Estimated finish date: $eta'
          : 'سيناريو ماذا لو 💡\n'
              '- إذا ادخرت $amount ﷼ شهريًا\n'
              '- الهدف: $name\n'
              '- المتبقي: $remaining ﷼\n'
              '- المدة المتوقعة: حوالي $months شهر\n'
              '- التاريخ المتوقع للإنجاز: $eta';

  static String get optimizerNoGoals => _e
      ? 'No goals yet. Add goals first so I can suggest a savings split.'
      : 'لا توجد أهداف حالياً. أضف أهدافك أولاً لأبني لك خطة توزيع ادخار.';

  static String get optimizerNoSurplus => _e
      ? 'No clear monthly surplus yet. Reduce expenses first for a precise goal plan.'
      : 'حالياً لا يوجد فائض ادخار شهري واضح. ابدأ بتقليل مصروفاتك أولاً ثم أقدر أبني خطة أهداف دقيقة.';

  static String get defaultGoalWord => _e ? 'Goal' : 'هدف';

  static String get optimizerGoalsDone => _e
      ? 'Great — your current goals are nearly complete.'
      : 'ممتاز، أهدافك الحالية مكتملة تقريباً.';

  static String optimizerLine(
    String name,
    String perMonth,
    String remaining,
  ) =>
      _e
          ? '- $name: $perMonth ﷼/month (remaining $remaining ﷼)'
          : '- $name: $perMonth ﷼/شهر (متبقي $remaining ﷼)';

  static String optimizerIntro(String monthly) => _e
      ? 'Goal optimizer\nBased on your monthly surplus ($monthly ﷼), suggested split:\n'
      : 'محسّن الأهداف\nبناءً على فائضك الشهري ($monthly ﷼)، هذه أفضل خطة توزيع:\n';

  static String alertExpenseOverIncome => _e
      ? 'This month\'s spending is higher than income.'
      : 'مصروفات هذا الشهر أعلى من الدخل.';

  static String alertSpendingGrowth(String pct) => _e
      ? 'Spending rose about $pct% vs last month.'
      : 'الإنفاق ارتفع بنسبة $pct% مقارنة بالشهر الماضي.';

  static String get subsNone => _e
      ? 'I didn\'t find clear recurring subscriptions in your transactions.'
      : 'لم أكتشف اشتراكات متكررة واضحة في معاملاتك الحالية.';

  static String subsLine(String name, String amount, int count) => _e
      ? '- $name: ~$amount ﷼ (repeated $count times)'
      : '- $name: حوالي $amount ﷼ (تكرر $count مرات)';

  static String subsSummary(String lines, String total) => _e
      ? 'Recurring patterns found 📌\n$lines\n\nApprox. monthly total: $total ﷼'
      : 'الاشتراكات المتكررة المكتشفة 📌\n$lines\n\nالإجمالي الشهري التقريبي: $total ﷼';

  static String get unnamedRecurring =>
      _e ? 'Unnamed recurring expense' : 'مصروف متكرر غير مسمى';

  static String get pdfOk => _e
      ? 'Monthly PDF report generated and share sheet opened.'
      : 'تم توليد التقرير الشهري PDF وفتح المشاركة بنجاح.';

  static String get pdfFail => _e
      ? 'Could not create the PDF report. Ensure you have data and try again.'
      : 'تعذر إنشاء تقرير PDF حالياً. تأكد من توفر بيانات ثم حاول مرة أخرى.';

  static String get dlgCreateGoalTitle =>
      _e ? 'Quick create goal' : 'إنشاء هدف سريع';

  static String get dlgGoalNameLabel =>
      _e ? 'Goal name' : 'اسم الهدف';

  static String get dlgGoalTargetLabel =>
      _e ? 'Target amount' : 'المبلغ المستهدف';

  static String get requiredField => _e ? 'Required' : 'مطلوب';

  static String get invalidNumber => _e ? 'Invalid number' : 'رقم غير صحيح';

  static String get dlgCreate => _e ? 'Create' : 'إنشاء';

  static String get dlgAdjustBudgetTitle =>
      _e ? 'Quick budget' : 'تعديل الميزانية سريعًا';

  static String get dlgMonthlyBudgetLabel =>
      _e ? 'Monthly budget amount' : 'مبلغ الميزانية الشهرية';

  static String get dlgSave => _e ? 'Save' : 'حفظ';

  static String get dlgCancel => _e ? 'Cancel' : 'إلغاء';

  static String goalCreatedDialog(String name) => _e
      ? 'Goal "${name.trim()}" created successfully.'
      : 'تم إنشاء الهدف "${name.trim()}" بنجاح.';

  static String budgetCreatedDialog(String amount) => _e
      ? 'Next month\'s budget set to $amount ﷼.'
      : 'تم إنشاء ميزانية الشهر القادم بقيمة $amount ﷼.';

  static String get whoAmI => _e
      ? 'I\'m Mudabbir, your smart assistant for personal finance.'
      : 'أنا مدبر، مساعدك الذكي في إدارة الأموال الشخصية.';

  static String get greetBack => _e
      ? 'Hello! How can I help you manage your money today?'
      : 'مرحباً بك. كيف يمكنني مساعدتك في إدارة أموالك اليوم؟';

  static String timeNow(int displayHour, String mm, bool isPm) => _e
      ? 'The time is $displayHour:$mm ${isPm ? 'PM' : 'AM'}.'
      : 'الساعة الآن $displayHour:$mm ${isPm ? 'مساءً' : 'صباحاً'}.';

  static String dateToday(String day, int d, String month, int y) => _e
      ? 'Today is $day, $d $month $y.'
      : 'اليوم هو $day، $d $month $y.';

  static List<String> get weekdays => _e
      ? [
          'Sunday',
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
        ]
      : [
          'الأحد',
          'الاثنين',
          'الثلاثاء',
          'الأربعاء',
          'الخميس',
          'الجمعة',
          'السبت',
        ];

  static List<String> get months => _e
      ? [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        ]
      : [
          'يناير',
          'فبراير',
          'مارس',
          'أبريل',
          'مايو',
          'يونيو',
          'يوليو',
          'أغسطس',
          'سبتمبر',
          'أكتوبر',
          'نوفمبر',
          'ديسمبر',
        ];

  static String get thanksReply =>
      _e ? 'You\'re welcome — happy to help anytime.' : 'العفو، سعيد بمساعدتك دائماً.';

  static String get howAreYouReply => _e
      ? 'I\'m doing well, thanks for asking. How can I help with your finances?'
      : 'بخير والحمد لله. شكراً لسؤالك. كيف يمكنني مساعدتك في إدارة أموالك؟';

  static String get jsonNoData =>
      _e ? 'No data' : 'لا توجد بيانات';

  static String get rateLimited => _e
      ? 'Sorry, rate limit reached. Try again later.'
      : 'عذراً، تم تجاوز حد الطلبات. يرجى المحاولة لاحقاً.';

  static String get server53 => _e
      ? 'Smart service unavailable (server error 53). Try again shortly.'
      : 'الخدمة الذكية غير متاحة حالياً (خطأ خادم 53). يرجى المحاولة بعد قليل.';

  static String httpError(int code) => _e
      ? 'Connection error (code: $code).'
      : 'عذراً، حدث خطأ في الاتصال. (رمز: $code)';

  static String get requestTimeout => _e
      ? 'The request took too long. Check your connection and try again.'
      : 'عذراً، استغرق الطلب وقتاً طويلاً. يرجى التحقق من الاتصال والمحاولة مرة أخرى.';

  static String get noInternet => _e
      ? 'No internet connection. Please check your network.'
      : 'عذراً، لا يوجد اتصال بالإنترنت. يرجى التحقق من الاتصال.';

  static String get assistantUnreachable => _e
      ? 'Could not reach the assistant service. Try again later.'
      : 'تعذر الوصول إلى خدمة المساعد حالياً. يرجى المحاولة لاحقاً.';

  static String get parseResponseFail => _e
      ? 'Sorry, I couldn\'t parse the response.'
      : 'عذراً، لم أتمكن من فهم السؤال.';

  static String get parseError =>
      _e ? 'Sorry, an error occurred while reading the response.' : 'عذراً، حدث خطأ في معالجة الاستجابة.';

  static String get chatCleared => _e
      ? 'Chat cleared. How can I help?'
      : 'تم مسح المحادثة. كيف يمكنني مساعدتك؟';

  static String get quickCreateGoal =>
      _e ? 'Create goal' : 'أنشئ هدف';

  static String get quickAdjustBudget =>
      _e ? 'Adjust budget' : 'عدّل ميزانيتي';

  static String get quickReduceCategory =>
      _e ? 'Cut category spend' : 'خفّض فئة إنفاق';

  static String get quickPdf => _e ? 'PDF report' : 'تقرير PDF';

  static String get quickUndo =>
      _e ? 'Undo last action' : 'تراجع آخر عملية';

  static String get suggestBalanceTitle =>
      _e ? 'Ask about your balance' : 'اسأل عن رصيدك';

  static String get suggestBalanceSubtitle =>
      _e ? 'Track your accounts' : 'تابع حساباتك المالية';

  static String get suggestExpenseTitle =>
      _e ? 'Spending analysis' : 'تحليل المصروفات';

  static String get suggestExpenseSubtitle =>
      _e ? 'Review transactions and budgets' : 'راجع معاملاتك وميزانياتك';

  static String get suggestGoalsTitle =>
      _e ? 'Track goals' : 'تتبع الأهداف';

  static String get suggestGoalsSubtitle =>
      _e ? 'See progress toward your goals' : 'اعرف تقدمك نحو أهدافك';

  static String get clearDialogTitle =>
      _e ? 'Clear chat' : 'مسح المحادثة';

  static String get clearDialogBody => _e
      ? 'Start a new chat? All current messages will be removed.'
      : 'هل تريد بدء محادثة جديدة؟ سيتم حذف جميع الرسائل الحالية.';

  static String get clearDialogConfirm => _e ? 'Clear' : 'مسح';
}
