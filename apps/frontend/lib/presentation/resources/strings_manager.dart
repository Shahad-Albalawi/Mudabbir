import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/language/app_language_controller.dart';

class AppStrings {
  static bool get _isEnglish {
    try {
      return getIt<AppLanguageController>().locale.languageCode == 'en';
    } catch (_) {
      return false;
    }
  }

  /// Use for display helpers that are not widgets (e.g. DB label mapping).
  static bool get isEnglishLocale => _isEnglish;

  static String get noRouteFound =>
      _isEnglish ? 'No route found' : 'المسار غير موجود';

  static String get onBoardingTitle1 =>
      _isEnglish ? 'Welcome to Mudabbir' : 'مرحباً بك في مدبر';
  static String get onBoardingTitle2 =>
      _isEnglish ? 'Track your budget easily' : 'تابع ميزانيتك بسهولة';
  static String get onBoardingTitle3 => _isEnglish
      ? 'Your smart assistant for expense management'
      : 'مساعدك الذكي لإدارة المصروفات';
  static String get onBoardingTitle4 =>
      _isEnglish ? 'Achieve your financial goals' : 'حقق أهدافك المالية';

  static String get onBoardingSubTitle1 => _isEnglish
      ? 'Mudabbir helps you organize spending and savings.'
      : 'تطبيق مدبر يساعدك على تنظيم نفقاتك ومدخراتك.';
  static String get onBoardingSubTitle2 => _isEnglish
      ? 'Track your income and expenses in one place.'
      : 'تابع دخلك ومصاريفك اليومية في مكان واحد.';
  static String get onBoardingSubTitle3 => _isEnglish
      ? 'Use the smart assistant for personalized financial tips.'
      : 'استخدم المساعد الذكي للحصول على نصائح مالية مخصصة.';
  static String get onBoardingSubTitle4 => _isEnglish
      ? 'Start today for better financial stability.'
      : 'ابدأ اليوم بخطتك المالية لتحقيق استقرار أفضل.';

  static String get skip => _isEnglish ? 'Skip' : 'تخطي';
  static String get title => _isEnglish ? 'Mudabbir' : 'مُدَبِّرٌ';
  static String get yourStat => _isEnglish ? 'Your insights' : 'تحليلاتك';

  static String get totalIncome => _isEnglish ? 'Total Income' : 'إجمالي الدخل';
  static String get totalExpense =>
      _isEnglish ? 'Total Expense' : 'إجمالي المصروف';
  static String get currentBalance =>
      _isEnglish ? 'Current Savings' : 'التوفير الحالي';

  static String get addExpense => _isEnglish ? 'Add Expense' : 'اضافة مصروف';
  static String get addIncome => _isEnglish ? 'Add Income' : 'اضافة دخل';
  static String get addChallenge => _isEnglish ? 'Add Challenge' : 'اضافة تحدي';
  static String get statisticsString => _isEnglish
      ? 'Tap here to view your analytics and statistics'
      : 'انقر هنا لاستعراض تحليلاتك والأطلاع عل الاحصائيات الخاصة بك';

  static String get homeText1 =>
      _isEnglish ? 'Welcome to Mudabbir' : 'أهلا بك في مدبر ';
  static String get homeText2 => _isEnglish
      ? 'Start your journey toward better money management'
      : 'ابدأ رحلتك نحو ادارة مالية أفضل معنا';

  static String get navHome => _isEnglish ? 'Home' : 'الرئيسية';
  static String get navStatistics => _isEnglish ? 'Statistics' : 'الإحصائيات';
  static String get navGoals => _isEnglish ? 'Goals' : 'الأهداف';
  static String get navBudget => _isEnglish ? 'Budgets' : 'الميزانية';

  static String get inviteFriend =>
      _isEnglish ? 'Invite a friend' : 'قم بدعوة صديق';

  // Auth - Login
  static String get loginWelcome =>
      _isEnglish ? 'Welcome back' : 'مرحباً بعودتك';
  static String get loginSubtitle =>
      _isEnglish ? 'Sign in to continue' : 'سجل دخولك للمتابعة';
  static String get emailLabel => _isEnglish ? 'Email' : 'البريد الإلكتروني';
  static String get emailHint =>
      _isEnglish ? 'Enter your email' : 'أدخل بريدك الإلكتروني';
  static String get passwordLabel => _isEnglish ? 'Password' : 'كلمة المرور';
  static String get passwordHint =>
      _isEnglish ? 'Enter your password' : 'أدخل كلمة المرور';
  static String get signIn => _isEnglish ? 'Sign In' : 'تسجيل الدخول';
  static String get noAccount =>
      _isEnglish ? "Don't have an account? " : 'ليس لديك حساب؟ ';
  static String get createOne => _isEnglish ? 'Create one' : 'أنشئ حساباً';

  // Auth - Register
  static String get createAccount =>
      _isEnglish ? 'Create Account' : 'إنشاء حساب جديد';
  static String get registerSubtitle => _isEnglish
      ? 'Enter your details to get started'
      : 'أدخل معلوماتك لإنشاء حساب جديد';
  static String get firstNameLabel => _isEnglish ? 'First name' : 'الاسم الأول';
  static String get firstNameHint =>
      _isEnglish ? 'Enter your first name' : 'أدخل اسمك الأول';
  static String get confirmPasswordLabel =>
      _isEnglish ? 'Confirm password' : 'تأكيد كلمة المرور';
  static String get confirmPasswordHint =>
      _isEnglish ? 'Re-enter your password' : 'أعد إدخال كلمة المرور';
  static String get createAccountButton =>
      _isEnglish ? 'Create Account' : 'إنشاء الحساب';
  static String get alreadyHaveAccount =>
      _isEnglish ? 'Already have an account? ' : 'لديك حساب بالفعل؟ ';
  static String get signInLink => _isEnglish ? 'Sign in' : 'سجل الدخول';

  // Goals / Budget
  static String get goalsEmptyTitle =>
      _isEnglish ? 'No financial goals yet' : 'لا توجد أهداف مالية';
  static String get goalsEmptySubtitle =>
      _isEnglish ? 'Start by adding a new goal' : 'ابدأ بإضافة هدف مالي جديد';
  static String get addNewGoal =>
      _isEnglish ? 'Add New Goal' : 'إضافة هدف جديد';
  static String get tapToAdd => _isEnglish ? 'Tap to add' : 'اضغط للإضافة';
  static String get fromAmount => _isEnglish ? 'of' : 'من';

  static String get noBudgetsYet => _isEnglish
      ? 'No budgets yet. Start managing your spending.'
      : 'لا يوجد ميزانيات، ابدأ بإدارة مصاريفك.';
  static String get addNewBudget =>
      _isEnglish ? 'Add a new budget' : 'قم بإضافة ميزانية جديدة';
  static String get addBudgetButton =>
      _isEnglish ? 'Add a New Budget' : 'إضافة ميزانية جديدة';

  // Home summary
  static String get financialStatus =>
      _isEnglish ? 'Financial Status' : 'الحالة المالية';
  static String get allTime => _isEnglish ? 'All time' : 'كل الأوقات';
  static String get thisMonth => _isEnglish ? 'This month' : 'هذا الشهر';
  static String get totalLabel => _isEnglish ? 'Total' : 'الإجمالي';
  static String get currentMonthLabel =>
      _isEnglish ? 'Current month' : 'الشهر الحالي';
  static String get financialHealth =>
      _isEnglish ? 'Financial health' : 'الصحة المالية';
  static String get nextMonthBudgetSuggestion => _isEnglish
      ? 'Next month budget suggestion'
      : 'اقتراح ميزانية الشهر القادم';
  static String get logout => _isEnglish ? 'Logout' : 'تسجيل الخروج';
  static String get success => _isEnglish ? 'Success' : 'نجح';
  static String get budgetDeleted =>
      _isEnglish ? 'Budget deleted successfully' : 'تم حذف الميزانية بنجاح';

  // Chatbot
  static String get chatbotTitle =>
      _isEnglish ? 'Mudabbir Assistant' : 'مساعد مدبر الذكي';
  static String get clearChat => _isEnglish ? 'Clear chat' : 'مسح المحادثة';
  static String get loading => _isEnglish ? 'Loading...' : 'جاري التحميل...';
  static String get typing => _isEnglish ? 'Typing' : 'جاري الكتابة';
  static String get chatHint =>
      _isEnglish ? 'Type your message...' : 'اكتب سؤالك هنا...';
  static String get emptyChatTitle =>
      _isEnglish ? 'Welcome to Mudabbir Assistant' : 'مرحباً بك في مساعد مدبر';
  static String get emptyChatSubtitle => _isEnglish
      ? 'Your smart finance assistant'
      : 'مساعدك الذكي لإدارة الأموال';

  static String get splashTagline =>
      _isEnglish ? 'Smart personal finance' : 'إدارة مالية ذكية';

  static String get chatWelcomeMessage => _isEnglish
      ? "Hi! I'm Mudabbir, your smart money assistant. How can I help you today?"
      : 'مرحباً! أنا مدبر، مساعدك الذكي في إدارة الأموال. كيف يمكنني مساعدتك اليوم؟';

  // Transaction popup
  static String get txLoadError =>
      _isEnglish ? 'Failed to load data' : 'خطأ في تحميل البيانات';
  static String get txSectionAmount => _isEnglish ? 'Amount' : 'المبلغ';
  static String get txSectionDate => _isEnglish ? 'Date' : 'التاريخ';
  static String get txSectionDetails => _isEnglish ? 'Details' : 'التفاصيل';
  static String get txSectionNotes =>
      _isEnglish ? 'Notes (optional)' : 'ملاحظات (اختياري)';
  static String get txAvailableBalance =>
      _isEnglish ? 'Available balance' : 'الرصيد المتاح';
  static String get txCancel => _isEnglish ? 'Cancel' : 'إلغاء';
  static String get txSaveIncome => _isEnglish ? 'Save income' : 'حفظ الدخل';
  static String get txSaveExpense =>
      _isEnglish ? 'Save expense' : 'حفظ المصروف';
  static String txSuccess(String type) => type == 'income'
      ? (_isEnglish
            ? 'Income added successfully! 🎉'
            : 'تم إضافة الدخل بنجاح! 🎉')
      : (_isEnglish
            ? 'Expense added successfully! 🎉'
            : 'تم إضافة المصروف بنجاح! 🎉');
  static String get txNoAccounts =>
      _isEnglish ? 'No accounts found.' : 'لا توجد حسابات.';
  static String txNoCategories(String type) =>
      _isEnglish ? 'No $type categories found.' : 'لا توجد فئات $type.';
  static String txLoadFailed(Object e) =>
      _isEnglish ? 'Failed to load data: $e' : 'فشل تحميل البيانات: $e';
  static String get txInsufficientTitle =>
      _isEnglish ? 'Insufficient balance' : 'رصيد غير كافٍ';
  static String get txInsufficientBody => _isEnglish
      ? 'The amount exceeds your available balance.'
      : 'المبلغ المدخل أكبر من الرصيد المتاح.';
  static String get txAvailableBalanceShort =>
      _isEnglish ? 'Available:' : 'الرصيد المتاح:';
  static String get txInsufficientHint => _isEnglish
      ? 'Enter an amount less than or equal to your available balance.'
      : 'الرجاء إدخال مبلغ أقل من أو يساوي الرصيد المتاح.';
  static String get txOk => _isEnglish ? 'OK' : 'حسناً';
  static String get labelAccount => _isEnglish ? 'Account' : 'الحساب';
  static String get labelCategory => _isEnglish ? 'Category' : 'الفئة';

  // Form fields (popup)
  static String get fieldAmount => _isEnglish ? 'Amount' : 'المبلغ';
  static String get fieldAmountRequired =>
      _isEnglish ? 'Amount is required' : 'المبلغ مطلوب';
  static String get fieldAmountInvalid =>
      _isEnglish ? 'Invalid number' : 'رقم غير صالح';
  static String get fieldAmountPositive => _isEnglish
      ? 'Amount must be greater than 0'
      : 'يجب أن يكون المبلغ أكبر من صفر';
  static String get fieldNotes =>
      _isEnglish ? 'Notes (optional)' : 'ملاحظات (اختياري)';
  static String get fieldNotesTooLong => _isEnglish
      ? 'Notes cannot exceed 500 characters'
      : 'الملاحظات لا تتجاوز 500 حرف';
  static String get fieldDate => _isEnglish ? 'Date' : 'التاريخ';

  static String get budgetExceeded => _isEnglish
      ? 'This would exceed your budget limit'
      : 'لقد قمت بتجاوز الحد الاقصى للميزانية';

  // Milestones
  static String get milestone25Title =>
      _isEnglish ? 'Great start! 🎯' : 'بداية رائعة! 🎯';
  static String get milestone25Body =>
      _isEnglish ? 'You reached 25% of your goal' : 'لقد أكملت 25% من هدفك';
  static String get milestone50Title =>
      _isEnglish ? 'Halfway there! 🔥' : 'في منتصف الطريق! 🔥';
  static String get milestone50Body =>
      _isEnglish ? 'You reached 50% of your goal' : 'لقد أكملت 50% من هدفك';
  static String get milestone75Title =>
      _isEnglish ? 'Almost there! ⚡' : 'أنت قريب جداً! ⚡';
  static String get milestone75Body =>
      _isEnglish ? 'You reached 75% of your goal' : 'لقد أكملت 75% من هدفك';
  static String get milestone100Title =>
      _isEnglish ? 'Goal achieved! 🏆' : 'مبروك! هدف محقق! 🏆';
  static String get milestone100Body => _isEnglish
      ? 'You completed your goal successfully'
      : 'لقد أكملت هدفك بنجاح';
  static String get milestoneAwesome => _isEnglish ? 'Awesome!' : 'رائع!';

  // Journey / progress copy
  static String journeyMotivation(double progress) {
    if (progress >= 1.0) {
      return _isEnglish
          ? 'Congratulations! 🎉 Goal reached!'
          : 'مبروك! 🎉 وصلت للهدف!';
    }
    if (progress >= 0.75) {
      return _isEnglish
          ? 'Amazing! 💪 You are so close!'
          : 'رائع! 💪 أنت قريب جداً!';
    }
    if (progress >= 0.5) {
      return _isEnglish
          ? 'Excellent! 🔥 Keep going!'
          : 'ممتاز! 🔥 استمر في التقدم!';
    }
    if (progress >= 0.25) {
      return _isEnglish
          ? 'Strong start! 🎯 Keep it up!'
          : 'بداية موفقة! 🎯 واصل التقدم!';
    }
    if (progress > 0) {
      return _isEnglish
          ? 'First step! 🌟 Keep going!'
          : 'خطوة أولى رائعة! 🌟 استمر!';
    }
    return _isEnglish
        ? 'Start your journey toward the goal! 🚀'
        : 'ابدأ رحلتك نحو الهدف! 🚀';
  }

  // Statistics
  static String get statsTitle =>
      _isEnglish ? 'Financial statistics' : 'الإحصائيات المالية';
  static String get statsIncomeExpense =>
      _isEnglish ? 'Income, expenses & balance' : 'الدخل والمصروفات والرصيد';
  static String get statsExpenseByCategory =>
      _isEnglish ? 'Spending by category' : 'المصروفات حسب الفئة';
  static String get statsIncomeByCategory =>
      _isEnglish ? 'Income by category' : 'الدخل حسب الفئة';
  static String get statsGoalsProgress =>
      _isEnglish ? 'Goals progress' : 'تقدم الأهداف';
  static String get statsBudgetsProgress =>
      _isEnglish ? 'Budgets progress' : 'تقدم الميزانيات';
  static String get statsAnalysisTitle =>
      _isEnglish ? 'Spending behavior insights' : 'تحليل سلوك المستخدم';
  static String get statsAnalysisSubtitle =>
      _isEnglish ? 'Smart financial insights' : 'رؤى مالية ذكية';

  static String goalLine(String name) =>
      _isEnglish ? 'Goal: $name' : 'الهدف: $name';
  static String challengeLine(String name) =>
      _isEnglish ? 'Challenge: $name' : 'التحدي: $name';

  static String get snackSuccessTitle => _isEnglish ? 'Success' : 'نجاح';
  static String get snackErrorTitle => _isEnglish ? 'Error' : 'خطأ';

  // Goals dialog
  static String get goalsAddAmountTitle =>
      _isEnglish ? 'Add to goal' : 'إضافة مبلغ للهدف';
  static String get goalsAmountLabel =>
      _isEnglish ? 'Amount to add' : 'المبلغ المراد إضافته';
  static String get goalsAmountHint =>
      _isEnglish ? 'Enter amount' : 'أدخل المبلغ';
  static String get goalsAddButton => _isEnglish ? 'Add' : 'إضافة';
  static String get goalsInvalidAmount =>
      _isEnglish ? 'Please enter a valid amount' : 'يرجى إدخال مبلغ صحيح';
  static String get goalsDeletedSuccess =>
      _isEnglish ? 'Goal deleted successfully' : 'تم حذف الهدف بنجاح';

  // Challenges dialog
  static String get challengesUpdateTitle =>
      _isEnglish ? 'Update challenge status' : 'تحديث حالة التحدي';
  static String get challengesUpdateButton => _isEnglish ? 'Update' : 'تحديث';
  static String get challengesUpdatedSuccess =>
      _isEnglish ? 'Challenge status updated' : 'تم تحديث حالة التحدي بنجاح';
  static String get challengesDeletedSuccess =>
      _isEnglish ? 'Challenge deleted successfully' : 'تم حذف التحدي بنجاح';
  static String get challengesStartLabel => _isEnglish ? 'Start' : 'البداية';
  static String get challengesEndLabel => _isEnglish ? 'End' : 'النهاية';
  static String get challengesAddNewButton =>
      _isEnglish ? 'Add new challenge' : 'إضافة تحدي جديد';

  static List<String> get barChartLabels => _isEnglish
      ? ['Income', 'Expenses', 'Balance']
      : ['الدخل', 'المصروفات', 'الرصيد'];

  static String get chartNoData =>
      _isEnglish ? 'No data available' : 'لا توجد بيانات متاحة';

  static String get loginSuccessBody =>
      _isEnglish ? 'Signed in successfully' : 'تم تسجيل الدخول بنجاح';
  static String get loginSessionError => _isEnglish
      ? 'Could not create a session. Please try again.'
      : 'لم يتم إنشاء جلسة تسجيل الدخول. حاول مرة أخرى.';
  static String get loginGenericError => _isEnglish
      ? 'Something went wrong while signing in. Try again.'
      : 'حدث خطأ أثناء تسجيل الدخول. حاول مرة أخرى.';
  static String get registerSuccessBody =>
      _isEnglish ? 'Account created successfully' : 'تم إنشاء الحساب بنجاح';
  static String get registerGenericError => _isEnglish
      ? 'Registration failed. Try again.'
      : 'فشل التسجيل. حاول مرة أخرى.';
  static String get registerCatchError => _isEnglish
      ? 'Something went wrong during registration. Try again.'
      : 'حدث خطأ أثناء التسجيل. حاول مرة أخرى.';

  // Analysis screen chrome
  static String get analysisBalanceTitle =>
      _isEnglish ? 'Balance status' : 'حالة الرصيد';
  static String get analysisSpendingTitle =>
      _isEnglish ? 'Spending analysis' : 'تحليل الإنفاق';
  static String get analysisSavingsBehaviorTitle =>
      _isEnglish ? 'Savings behavior' : 'سلوك الادخار';
  static String get analysisHealthScoreTitle =>
      _isEnglish ? 'Financial health score' : 'درجة الصحة المالية';
  static String get analysisSavingsRateLabel =>
      _isEnglish ? 'Savings rate:' : 'معدل الادخار:';
  static String get analysisCategoryInsightsTitle =>
      _isEnglish ? 'Category spending insights' : 'رؤى إنفاق الفئات';
  static String get analysisRecommendationsTitle =>
      _isEnglish ? 'Personal recommendations' : 'التوصيات الشخصية';

  // Appearance & language (home header pickers)
  static String get themeModeTooltip =>
      _isEnglish ? 'Theme mode' : 'وضع المظهر';
  static String get languageTooltip => _isEnglish ? 'Language' : 'اللغة';
  static String get themeSystem => _isEnglish ? 'System' : 'حسب النظام';
  static String get themeLight => _isEnglish ? 'Light' : 'فاتح';
  static String get themeDark => _isEnglish ? 'Dark' : 'داكن';
  static String get languageArabicOption => _isEnglish ? 'Arabic' : 'العربية';
  static String get languageEnglishOption =>
      _isEnglish ? 'English' : 'الإنجليزية';
}
