import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/currency_formatter.dart';
import 'package:mudabbir/l10n/app_localizations.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/language/app_language_controller.dart';

/// Backward-compatible facade over generated [AppLocalizations].
/// Prefer `context.l10n` / [AppLocalizations.of] in new UI code.
class AppStrings {
  static AppLocalizations? _bound;

  /// Called from [MaterialApp.builder] so non-widget code can read strings.
  static void bind(AppLocalizations l10n) => _bound = l10n;

  static AppLocalizations get _t {
    final cached = _bound;
    if (cached != null) return cached;
    try {
      return lookupAppLocalizations(getIt<AppLanguageController>().locale);
    } catch (_) {
      return lookupAppLocalizations(const Locale('ar'));
    }
  }

  /// Use for display helpers that are not widgets (e.g. DB label mapping).
  static bool get isEnglishLocale => _t.localeName.startsWith('en');

  static String get noRouteFound => _t.noRouteFound;
  static String get onBoardingTitle1 => _t.onBoardingTitle1;
  static String get onBoardingTitle2 => _t.onBoardingTitle2;
  static String get onBoardingTitle3 => _t.onBoardingTitle3;
  static String get onBoardingTitle4 => _t.onBoardingTitle4;
  static String get onBoardingSubTitle1 => _t.onBoardingSubTitle1;
  static String get onBoardingSubTitle2 => _t.onBoardingSubTitle2;
  static String get onBoardingSubTitle3 => _t.onBoardingSubTitle3;
  static String get onBoardingSubTitle4 => _t.onBoardingSubTitle4;
  static String get skip => _t.skip;
  static String get onboardingGetStarted => _t.onboardingGetStarted;
  static String get themePickerTitle => _t.themePickerTitle;
  static String get languagePickerTitle => _t.languagePickerTitle;
  static String get authShowPassword => _t.authShowPassword;
  static String get authHidePassword => _t.authHidePassword;
  static String get sendMessage => _t.sendMessage;
  static String get chatUserMessage => _t.chatUserMessage;
  static String get chatAssistantMessage => _t.chatAssistantMessage;
  static String get title => _t.title;
  static String get yourStat => _t.yourStat;
  static String get totalIncome => _t.totalIncome;
  static String get totalExpense => _t.totalExpense;
  static String get currentBalance => _t.currentBalance;
  static String get addExpense => _t.addExpense;
  static String get addIncome => _t.addIncome;
  static String get addChallenge => _t.addChallenge;
  static String get statisticsString => _t.statisticsString;
  static String get homeText1 => _t.homeText1;
  static String get homeText2 => _t.homeText2;
  static String get navHome => _t.navHome;
  static String get navStatistics => _t.navStatistics;
  static String get navGoals => _t.navGoals;
  static String get navChallenges => _t.navChallenges;
  static String get navBudget => _t.navBudget;
  static String get inviteFriend => _t.inviteFriend;
  static String get loginWelcome => _t.loginWelcome;
  static String get loginSubtitle => _t.loginSubtitle;
  static String get emailLabel => _t.emailLabel;
  static String get emailHint => _t.emailHint;
  static String get passwordLabel => _t.passwordLabel;
  static String get passwordHint => _t.passwordHint;
  static String get signIn => _t.signIn;
  static String get noAccount => _t.noAccount;
  static String get createOne => _t.createOne;
  static String get createAccount => _t.createAccount;
  static String get registerSubtitle => _t.registerSubtitle;
  static String get firstNameLabel => _t.firstNameLabel;
  static String get firstNameHint => _t.firstNameHint;
  static String get confirmPasswordLabel => _t.confirmPasswordLabel;
  static String get confirmPasswordHint => _t.confirmPasswordHint;
  static String get createAccountButton => _t.createAccountButton;
  static String get alreadyHaveAccount => _t.alreadyHaveAccount;
  static String get signInLink => _t.signInLink;
  static String get validationEmailRequired => _t.validationEmailRequired;
  static String get validationEmailInvalid => _t.validationEmailInvalid;
  static String get validationPasswordRequired => _t.validationPasswordRequired;
  static String get validationPasswordMinLength => _t.validationPasswordMinLength;
  static String get validationFirstNameRequired => _t.validationFirstNameRequired;
  static String get validationPasswordMismatch => _t.validationPasswordMismatch;
  static String get goalsEmptyTitle => _t.goalsEmptyTitle;
  static String get goalsEmptySubtitle => _t.goalsEmptySubtitle;
  static String get addNewGoal => _t.addNewGoal;
  static String get tapToAdd => _t.tapToAdd;
  static String get fromAmount => _t.fromAmount;
  static String get noBudgetsYet => _t.noBudgetsYet;
  static String get addNewBudget => _t.addNewBudget;
  static String get addBudgetButton => _t.addBudgetButton;
  static String get financialStatus => _t.financialStatus;
  static String get allTime => _t.allTime;
  static String get thisMonth => _t.thisMonth;
  static String get totalLabel => _t.totalLabel;
  static String get currentMonthLabel => _t.currentMonthLabel;
  static String get financialHealth => _t.financialHealth;
  static String get nextMonthBudgetSuggestion => _t.nextMonthBudgetSuggestion;
  static String get logout => _t.logout;
  static String get success => _t.success;
  static String get budgetDeleted => _t.budgetDeleted;
  static String get chatbotTitle => _t.chatbotTitle;
  static String get clearChat => _t.clearChat;
  static String get loading => _t.loading;
  static String get typing => _t.typing;
  static String get chatHint => _t.chatHint;
  static String get emptyChatTitle => _t.emptyChatTitle;
  static String get emptyChatSubtitle => _t.emptyChatSubtitle;
  static String get splashTagline => _t.splashTagline;
  static String get chatWelcomeMessage => _t.chatWelcomeMessage;
  static String get txLoadError => _t.txLoadError;
  static String get txSectionAmount => _t.txSectionAmount;
  static String get txSectionDate => _t.txSectionDate;
  static String get txSectionDetails => _t.txSectionDetails;
  static String get txSectionNotes => _t.txSectionNotes;
  static String get txAvailableBalance => _t.txAvailableBalance;
  static String get txCancel => _t.txCancel;
  static String get txSaveIncome => _t.txSaveIncome;
  static String get txSaveExpense => _t.txSaveExpense;
  static String get txNoAccounts => _t.txNoAccounts;
  static String get txInsufficientTitle => _t.txInsufficientTitle;
  static String get txInsufficientBody => _t.txInsufficientBody;
  static String get txAvailableBalanceShort => _t.txAvailableBalanceShort;
  static String get txInsufficientHint => _t.txInsufficientHint;
  static String get txOk => _t.txOk;
  static String get labelAccount => _t.labelAccount;
  static String get labelCategory => _t.labelCategory;
  static String get fieldAmount => _t.fieldAmount;
  static String get fieldAmountRequired => _t.fieldAmountRequired;
  static String get fieldAmountInvalid => _t.fieldAmountInvalid;
  static String get fieldAmountPositive => _t.fieldAmountPositive;
  static String get fieldNotes => _t.fieldNotes;
  static String get fieldNotesTooLong => _t.fieldNotesTooLong;
  static String get fieldDate => _t.fieldDate;
  static String get budgetExceeded => _t.budgetExceeded;
  static String get milestone25Title => _t.milestone25Title;
  static String get milestone25Body => _t.milestone25Body;
  static String get milestone50Title => _t.milestone50Title;
  static String get milestone50Body => _t.milestone50Body;
  static String get milestone75Title => _t.milestone75Title;
  static String get milestone75Body => _t.milestone75Body;
  static String get milestone100Title => _t.milestone100Title;
  static String get milestone100Body => _t.milestone100Body;
  static String get milestoneAwesome => _t.milestoneAwesome;
  static String get statsTitle => _t.statsTitle;
  static String get statsIncomeExpense => _t.statsIncomeExpense;
  static String get statsExpenseByCategory => _t.statsExpenseByCategory;
  static String get statsIncomeByCategory => _t.statsIncomeByCategory;
  static String get statsGoalsProgress => _t.statsGoalsProgress;
  static String get statsBudgetsProgress => _t.statsBudgetsProgress;
  static String get statsAnalysisTitle => _t.statsAnalysisTitle;
  static String get statsAnalysisSubtitle => _t.statsAnalysisSubtitle;
  static String get snackSuccessTitle => _t.snackSuccessTitle;
  static String get snackErrorTitle => _t.snackErrorTitle;
  static String get snackWarningTitle => _t.snackWarningTitle;
  static String get snackInfoTitle => _t.snackInfoTitle;
  static String get retry => _t.retry;
  static String get goalsAddAmountTitle => _t.goalsAddAmountTitle;
  static String get goalsAmountLabel => _t.goalsAmountLabel;
  static String get goalsAmountHint => _t.goalsAmountHint;
  static String get goalsAddButton => _t.goalsAddButton;
  static String get goalsInvalidAmount => _t.goalsInvalidAmount;
  static String get goalsDeletedSuccess => _t.goalsDeletedSuccess;
  static String get challengesUpdateTitle => _t.challengesUpdateTitle;
  static String get challengesUpdateButton => _t.challengesUpdateButton;
  static String get challengesUpdatedSuccess => _t.challengesUpdatedSuccess;
  static String get challengesDeletedSuccess => _t.challengesDeletedSuccess;
  static String get challengesStartLabel => _t.challengesStartLabel;
  static String get challengesEndLabel => _t.challengesEndLabel;
  static String get challengesAddNewButton => _t.challengesAddNewButton;
  static String get chartNoData => _t.chartNoData;
  static String get loginSuccessBody => _t.loginSuccessBody;
  static String get loginSessionError => _t.loginSessionError;
  static String get loginGenericError => _t.loginGenericError;
  static String get registerSuccessBody => _t.registerSuccessBody;
  static String get registerGenericError => _t.registerGenericError;
  static String get registerCatchError => _t.registerCatchError;
  static String get analysisBalanceTitle => _t.analysisBalanceTitle;
  static String get analysisSpendingTitle => _t.analysisSpendingTitle;
  static String get analysisSavingsBehaviorTitle => _t.analysisSavingsBehaviorTitle;
  static String get analysisHealthScoreTitle => _t.analysisHealthScoreTitle;
  static String get analysisSavingsRateLabel => _t.analysisSavingsRateLabel;
  static String get analysisCategoryInsightsTitle => _t.analysisCategoryInsightsTitle;
  static String get analysisRecommendationsTitle => _t.analysisRecommendationsTitle;
  static String analysisBalanceCritical(String amount) =>
      _t.analysisBalanceCritical(amount);
  static String get analysisBalanceZero => _t.analysisBalanceZero;
  static String analysisBalanceLow(String amount) => _t.analysisBalanceLow(amount);
  static String analysisBalanceFair(String amount) => _t.analysisBalanceFair(amount);
  static String analysisBalanceGreat(String amount) =>
      _t.analysisBalanceGreat(amount);
  static String analysisSpendingCritical(String ratio) =>
      _t.analysisSpendingCritical(ratio);
  static String analysisSpendingWarning90(String ratio) =>
      _t.analysisSpendingWarning90(ratio);
  static String analysisSpendingAlert80(String ratio) =>
      _t.analysisSpendingAlert80(ratio);
  static String analysisSpendingFair70(String ratio) =>
      _t.analysisSpendingFair70(ratio);
  static String analysisSpendingGood50(String ratio) =>
      _t.analysisSpendingGood50(ratio);
  static String analysisSpendingExcellent(String ratio) =>
      _t.analysisSpendingExcellent(ratio);
  static String analysisSavingsCritical(String rate) =>
      _t.analysisSavingsCritical(rate);
  static String analysisSavingsWeak5(String rate) => _t.analysisSavingsWeak5(rate);
  static String analysisSavingsFair10(String rate) => _t.analysisSavingsFair10(rate);
  static String analysisSavingsGood20(String rate) => _t.analysisSavingsGood20(rate);
  static String analysisSavingsExcellent30(String rate) =>
      _t.analysisSavingsExcellent30(rate);
  static String analysisSavingsOutstanding(String rate) =>
      _t.analysisSavingsOutstanding(rate);
  static String analysisCategoryDominant40(String percent) =>
      _t.analysisCategoryDominant40(percent);
  static String analysisCategoryHigh30(String percent) =>
      _t.analysisCategoryHigh30(percent);
  static String analysisCategoryMedium20(String percent) =>
      _t.analysisCategoryMedium20(percent);
  static String analysisCategoryLow10(String percent) =>
      _t.analysisCategoryLow10(percent);
  static String analysisCategoryVeryLow(String percent) =>
      _t.analysisCategoryVeryLow(percent);
  static String get analysisHealthExcellent => _t.analysisHealthExcellent;
  static String get analysisHealthGood => _t.analysisHealthGood;
  static String get analysisHealthFair => _t.analysisHealthFair;
  static String get analysisHealthWeak => _t.analysisHealthWeak;
  static String get analysisHealthCritical => _t.analysisHealthCritical;
  static String get analysisRecUrgentNegativeSavings =>
      _t.analysisRecUrgentNegativeSavings;
  static String get analysisRecExtraIncome => _t.analysisRecExtraIncome;
  static String get analysisRecIncreaseSavings => _t.analysisRecIncreaseSavings;
  static String get analysisRecAim1020 => _t.analysisRecAim1020;
  static String get analysisRecPushTo20 => _t.analysisRecPushTo20;
  static String get analysisRecDebtPayoff => _t.analysisRecDebtPayoff;
  static String get analysisRecEmergencyFund => _t.analysisRecEmergencyFund;
  static String analysisRecReviewCategories(String categories) =>
      _t.analysisRecReviewCategories(categories);
  static String get analysisRecDiversifyIncome => _t.analysisRecDiversifyIncome;
  static String get analysisRecSetGoals => _t.analysisRecSetGoals;
  static String analysisRecIncreaseContributions(String goals) =>
      _t.analysisRecIncreaseContributions(goals);
  static String get analysisRecCreateBudgets => _t.analysisRecCreateBudgets;
  static String get analysisRecGreatJob => _t.analysisRecGreatJob;
  static String get analysisRecKeepTracking => _t.analysisRecKeepTracking;
  static String get analysisRecReadInvesting => _t.analysisRecReadInvesting;
  static String get themeModeTooltip => _t.themeModeTooltip;
  static String get languageTooltip => _t.languageTooltip;
  static String get themeSystem => _t.themeSystem;
  static String get themeLight => _t.themeLight;
  static String get themeDark => _t.themeDark;
  static String get languageArabicOption => _t.languageArabicOption;
  static String get languageEnglishOption => _t.languageEnglishOption;
  static String get budgetPopupTitle => _t.budgetPopupTitle;
  static String get budgetPopupSubtitle => _t.budgetPopupSubtitle;
  static String get budgetPopupAmountSection => _t.budgetPopupAmountSection;
  static String get budgetPopupPeriodSection => _t.budgetPopupPeriodSection;
  static String get budgetPopupAccountSection => _t.budgetPopupAccountSection;
  static String get fieldStartDate => _t.fieldStartDate;
  static String get fieldEndDate => _t.fieldEndDate;
  static String get fieldRequired => _t.fieldRequired;
  static String get fieldEndAfterStart => _t.fieldEndAfterStart;
  static String get fieldSelectAccount => _t.fieldSelectAccount;
  static String get budgetCreateSuccess => _t.budgetCreateSuccess;
  static String get budgetCreateFailed => _t.budgetCreateFailed;
  static String get budgetNoAccountsHint => _t.budgetNoAccountsHint;
  static String get budgetDeleteConfirmTitle => _t.budgetDeleteConfirmTitle;
  static String get budgetDeleteConfirmBody => _t.budgetDeleteConfirmBody;
  static String get budgetOfflineBanner => _t.budgetOfflineBanner;
  static String get delete => _t.delete;
  static String get chatbotFabLabel => _t.chatbotFabLabel;
  static String get homeAlertSpendingExceedsIncome =>
      _t.homeAlertSpendingExceedsIncome;
  static String get statsEmptyBarChart => _t.statsEmptyBarChart;
  static String get expenseDeleteConfirmTitle => _t.expenseDeleteConfirmTitle;
  static String get expenseDeleteConfirmBody => _t.expenseDeleteConfirmBody;
  static String get goalDeleteConfirmTitle => _t.goalDeleteConfirmTitle;
  static String get goalPopupCreateTitle => _t.goalPopupCreateTitle;
  static String get goalPopupCreateSubtitle => _t.goalPopupCreateSubtitle;
  static String get goalPickImage => _t.goalPickImage;
  static String get goalNameHint => _t.goalNameHint;
  static String get goalTargetAmountLabel => _t.goalTargetAmountLabel;
  static String get goalCurrentAmountLabel => _t.goalCurrentAmountLabel;
  static String get goalTypeLabel => _t.goalTypeLabel;
  static String get goalPeriodLabel => _t.goalPeriodLabel;
  static String get goalNameRequired => _t.goalNameRequired;
  static String get goalTargetRequired => _t.goalTargetRequired;
  static String get goalTypeRequired => _t.goalTypeRequired;
  static String get goalStartRequired => _t.goalStartRequired;
  static String get goalEndRequired => _t.goalEndRequired;
  static String get goalEndAfterStart => _t.goalEndAfterStart;
  static String get goalCreateSuccess => _t.goalCreateSuccess;
  static String get goalCreateFailed => _t.goalCreateFailed;
  static String get goalEditTitle => _t.goalEditTitle;
  static String get goalEditSubtitle => _t.goalEditSubtitle;
  static String get goalSaveChanges => _t.goalSaveChanges;
  static String get goalUpdatedSuccess => _t.goalUpdatedSuccess;
  static String get expenseOfflineBanner => _t.expenseOfflineBanner;
  static String get goalOfflineBanner => _t.goalOfflineBanner;
  static String get settingsTitle => _t.settingsTitle;
  static String get settingsAccountSection => _t.settingsAccountSection;
  static String get settingsPreferencesSection => _t.settingsPreferencesSection;
  static String get settingsLegalSection => _t.settingsLegalSection;
  static String get settingsExportPdf => _t.settingsExportPdf;
  static String get settingsExportPdfSuccess => _t.settingsExportPdfSuccess;
  static String get settingsExportPdfFail => _t.settingsExportPdfFail;
  static String get settingsLogoutConfirmTitle => _t.settingsLogoutConfirmTitle;
  static String get settingsLogoutConfirmMessage => _t.settingsLogoutConfirmMessage;
  static String get settingsOpenLabel => _t.settingsOpenLabel;
  static String get notificationsTitle => _t.notificationsTitle;
  static String get addTransactionTitle => _t.addTransactionTitle;
  static String get notificationsEmpty => _t.notificationsEmpty;
  static String get homeActiveGoals => _t.homeActiveGoals;
  static String get homeViewAll => _t.homeViewAll;
  static String get homeRecentTransactions => _t.homeRecentTransactions;
  static String get homeFinancialHealthSubtitle => _t.homeFinancialHealthSubtitle;
  static String get healthScoreExcellent => _t.healthScoreExcellent;
  static String get healthScoreGood => _t.healthScoreGood;
  static String get healthScoreFair => _t.healthScoreFair;
  static String get healthScoreWeak => _t.healthScoreWeak;
  static String get homeQaExpense => _t.homeQaExpense;
  static String get homeQaIncome => _t.homeQaIncome;
  static String get homeQaPdfReport => _t.homeQaPdfReport;
  static String get homeQaAnalysis => _t.homeQaAnalysis;
  static String get homeBudgetManage => _t.homeBudgetManage;
  static String get homeBudgetEmptyCategories => _t.homeBudgetEmptyCategories;
  static String get offlineSavedPendingSync => _t.offlineSavedPendingSync;
  static String get budgetLoadFailed => _t.budgetLoadFailed;
  static String get budgetSyncFailed => _t.budgetSyncFailed;
  static String get budgetCardLabel => _t.budgetCardLabel;
  static String get budgetStatusOverBudget => _t.budgetStatusOverBudget;
  static String get budgetStatusNearLimit => _t.budgetStatusNearLimit;
  static String get budgetStatusOnTrack => _t.budgetStatusOnTrack;
  static String get budgetRemainingOfPrefix => _t.budgetRemainingOfPrefix;
  static String get notificationBudgetWarningTitle =>
      _t.notificationBudgetWarningTitle;
  static String get notificationBudgetExceededTitle =>
      _t.notificationBudgetExceededTitle;
  static String get goalNameLabel => _t.goalNameLabel;
  static String get goalChangePhoto => _t.goalChangePhoto;
  static String get goalLoadFailed => _t.goalLoadFailed;
  static String get goalSyncFailed => _t.goalSyncFailed;
  static String get goalDeadlineLabel => _t.goalDeadlineLabel;
  static String get goalProjectedLabel => _t.goalProjectedLabel;
  static String get goalRemainingLabel => _t.goalRemainingLabel;
  static String get goalContributeHint => _t.goalContributeHint;
  static String get goalMonthlyNeeded => _t.goalMonthlyNeeded;
  static String get goalAvgMonthly => _t.goalAvgMonthly;
  static String get goalStatusOnTrack => _t.goalStatusOnTrack;
  static String get goalStatusBehind => _t.goalStatusBehind;
  static String get goalStatusOverdue => _t.goalStatusOverdue;
  static String get goalStatusCompleted => _t.goalStatusCompleted;
  static String get goalStatusNotStarted => _t.goalStatusNotStarted;
  static String get goalTypeSaving => _t.goalTypeSaving;
  static String get goalTypeInvestment => _t.goalTypeInvestment;
  static String get goalTypeDebt => _t.goalTypeDebt;
  static String get goalTypeOther => _t.goalTypeOther;
  static String get goalNotEnoughData => _t.goalNotEnoughData;
  static String get goalContributionTitle => _t.goalContributionTitle;
  static String get goalAddContributionButton => _t.goalAddContributionButton;
  static String get goalContributionNote => _t.goalContributionNote;
  static String get goalContributionSuccessTitle =>
      _t.goalContributionSuccessTitle;
  static String get goalContributionSnackbarAction =>
      _t.goalContributionSnackbarAction;
  static String get goalJourneyMotivationTapHint =>
      _t.goalJourneyMotivationTapHint;
  static String get goalUpdateFailed => _t.goalUpdateFailed;
  static String get goalCompletedAlertTitle => _t.goalCompletedAlertTitle;
  static String get goalContributeButtonShort => _t.goalContributeButtonShort;
  static String get goalDetailsButton => _t.goalDetailsButton;
  static String get goalOfPrefix => _t.goalOfPrefix;
  static String get goalLeftLabel => _t.goalLeftLabel;
  static List<String> get goalTypeOptions => [
        goalTypeSaving,
        goalTypeInvestment,
        goalTypeDebt,
        goalTypeOther,
      ];
  static String get expensesTitle => _t.expensesTitle;
  static String get expensesAddButton => _t.expensesAddButton;
  static String get expensesEditButton => _t.expensesEditButton;
  static String get expensesSaveButton => _t.expensesSaveButton;
  static String get expensesEmptyTitle => _t.expensesEmptyTitle;
  static String get expensesEmptySubtitle => _t.expensesEmptySubtitle;
  static String get expensesFilterMonth => _t.expensesFilterMonth;
  static String get expensesFilterCategory => _t.expensesFilterCategory;
  static String get expensesFilterType => _t.expensesFilterType;
  static String get expensesFilterAll => _t.expensesFilterAll;
  static String get expensesFilterRecurring => _t.expensesFilterRecurring;
  static String get expensesRecurringMonthly => _t.expensesRecurringMonthly;
  static String get expensesAmountTooLarge => _t.expensesAmountTooLarge;
  static String get expensesDateRequired => _t.expensesDateRequired;
  static String get expensesDateInvalid => _t.expensesDateInvalid;
  static String get expensesDateCannotBeFuture => _t.expensesDateCannotBeFuture;
  static String get expensesAccountRequired => _t.expensesAccountRequired;
  static String get expensesCategoryRequired => _t.expensesCategoryRequired;
  static String get expensesTextTooLong => _t.expensesTextTooLong;
  static String get expensesLoadFailed => _t.expensesLoadFailed;
  static String get expensesSyncFailed => _t.expensesSyncFailed;
  static String get expensesSaveFailed => _t.expensesSaveFailed;
  static String get expensesUpdateFailed => _t.expensesUpdateFailed;
  static String get expensesDeleteFailed => _t.expensesDeleteFailed;
  static String get expensesSavedSuccess => _t.expensesSavedSuccess;
  static String get expensesUpdatedSuccess => _t.expensesUpdatedSuccess;
  static String get expensesDeletedSuccess => _t.expensesDeletedSuccess;
  static String get expensesViewAll => _t.expensesViewAll;
  static String get expensesTotalFiltered => _t.expensesTotalFiltered;
  static String get expensesRecurringBadge => _t.expensesRecurringBadge;
  static String get statsScreenLoadFailed => _t.statsScreenLoadFailed;
  static String get statsAnalysisLoadFailed => _t.statsAnalysisLoadFailed;
  static String get statsHomeLoadFailed => _t.statsHomeLoadFailed;
  static String get statsScreenEmptyTitle => _t.statsScreenEmptyTitle;
  static String get statsScreenEmptySubtitle => _t.statsScreenEmptySubtitle;
  static String get statsSpendingTrendTitle => _t.statsSpendingTrendTitle;
  static String get statsCategoryBreakdownTitle => _t.statsCategoryBreakdownTitle;
  static String get statsQuickInsightsTitle => _t.statsQuickInsightsTitle;
  static String get statsTotalExpenseLabel => _t.statsTotalExpenseLabel;
  static String get statsTotalIncomeLabel => _t.statsTotalIncomeLabel;
  static String get statsNetSavingsLabel => _t.statsNetSavingsLabel;
  static String get statsSavingsRateLabel => _t.statsSavingsRateLabel;
  static String get statsDailyAverageLabel => _t.statsDailyAverageLabel;
  static String get statsHighestExpenseLabel => _t.statsHighestExpenseLabel;
  static String get statsTransactionCountLabel => _t.statsTransactionCountLabel;
  static String get statsChartTotalLabel => _t.statsChartTotalLabel;
  static String get statsNoDataForPeriod => _t.statsNoDataForPeriod;
  static String get statsNoCategoriesYet => _t.statsNoCategoriesYet;
  static String get statsSteadySpendingInsight => _t.statsSteadySpendingInsight;
  static String get statsPeriodWeek => _t.statsPeriodWeek;
  static String get statsPeriodMonth => _t.statsPeriodMonth;
  static String get statsPeriodQuarter => _t.statsPeriodQuarter;
  static String get statsPeriodYear => _t.statsPeriodYear;
  static List<String> get statsChartWeekdays => [
        _t.statsChartWeekday0,
        _t.statsChartWeekday1,
        _t.statsChartWeekday2,
        _t.statsChartWeekday3,
        _t.statsChartWeekday4,
        _t.statsChartWeekday5,
        _t.statsChartWeekday6,
      ];
  static List<String> get statsChartMonthsShort => [
        _t.statsChartMonth0,
        _t.statsChartMonth1,
        _t.statsChartMonth2,
        _t.statsChartMonth3,
        _t.statsChartMonth4,
        _t.statsChartMonth5,
        _t.statsChartMonth6,
        _t.statsChartMonth7,
        _t.statsChartMonth8,
        _t.statsChartMonth9,
        _t.statsChartMonth10,
        _t.statsChartMonth11,
      ];
  static String get txSheetCatShopping => _t.txSheetCatShopping;
  static String get txSheetCatTransport => _t.txSheetCatTransport;
  static String get txSheetCatRestaurants => _t.txSheetCatRestaurants;
  static String get txSheetCatHealth => _t.txSheetCatHealth;
  static String get txSheetCatEntertainment => _t.txSheetCatEntertainment;
  static String get txSheetCatHousing => _t.txSheetCatHousing;
  static String get txSheetCatSalary => _t.txSheetCatSalary;
  static String get txSheetCatOther => _t.txSheetCatOther;
  static String get entityCatSalary => _t.entityCatSalary;
  static String get entityCatBonus => _t.entityCatBonus;
  static String get entityCatGift => _t.entityCatGift;
  static String get entityCatOther => _t.entityCatOther;
  static String get entityCatFood => _t.entityCatFood;
  static String get entityCatTransport => _t.entityCatTransport;
  static String get entityCatShopping => _t.entityCatShopping;
  static String get entityCatBills => _t.entityCatBills;
  static String get entityCatHealth => _t.entityCatHealth;
  static String get entityCatEntertainment => _t.entityCatEntertainment;
  static String get entityAccountCash => _t.entityAccountCash;
  static String get entityAccountBank => _t.entityAccountBank;
  static String get homeGreetingHello => _t.homeGreetingHello;
  static String homeGreetingNamed(String name) => _t.homeGreetingNamed(name);
  static String get homeMonthlyReportTitle => _t.homeMonthlyReportTitle;
  static String get goalDeadlinePassed => _t.goalDeadlinePassed;
  static String goalDaysLeft(int days) => _t.goalDaysLeft(days);
  static String get goalMilestoneComplete => _t.goalMilestoneComplete;
  static String get goalMotivationBannerStart => _t.goalMotivationBannerStart;
  static String goalMotivationBannerEarly(String percent) =>
      _t.goalMotivationBannerEarly(percent);
  static String get goalMotivationBannerHalf => _t.goalMotivationBannerHalf;
  static String get goalMotivationBannerNear => _t.goalMotivationBannerNear;
  static String get goalMotivationBannerDone => _t.goalMotivationBannerDone;
  static String get behavioralScoreTitle => _t.behavioralScoreTitle;
  static String get behavioralScoreSubtitle => _t.behavioralScoreSubtitle;
  static String get behavioralViewDetailsLabel => _t.behavioralViewDetailsLabel;
  static String get behavioralViewDetailsHint => _t.behavioralViewDetailsHint;
  static String get behavioralMonthComparisonTitle =>
      _t.behavioralMonthComparisonTitle;
  static String get behavioralAnomaliesTitle => _t.behavioralAnomaliesTitle;
  static String get behavioralNoAnomalies => _t.behavioralNoAnomalies;
  static String get behavioralWeekdayPatternTitle =>
      _t.behavioralWeekdayPatternTitle;
  static String get behavioralPersonalizedRecsTitle =>
      _t.behavioralPersonalizedRecsTitle;
  static String get behavioralPreviousMonthLabel =>
      _t.behavioralPreviousMonthLabel;
  static String get behavioralTrailingAvgLabel => _t.behavioralTrailingAvgLabel;
  static String get behavioralNoWeekdayData => _t.behavioralNoWeekdayData;
  static String get behavioralRatingExcellent => _t.behavioralRatingExcellent;
  static String get behavioralRatingGood => _t.behavioralRatingGood;
  static String get behavioralRatingFair => _t.behavioralRatingFair;
  static String get behavioralRatingNeedsWork => _t.behavioralRatingNeedsWork;
  static String get behavioralRatingAtRisk => _t.behavioralRatingAtRisk;
  static String get behavioralMonthlySpikeTitle => _t.behavioralMonthlySpikeTitle;
  static String get behavioralOverspendingTitle => _t.behavioralOverspendingTitle;
  static String get behavioralCategorySpikeTitle => _t.behavioralCategorySpikeTitle;
  static String get behavioralLargeTransactionTitle =>
      _t.behavioralLargeTransactionTitle;
  static String get behavioralWeekendSplurgeTitle =>
      _t.behavioralWeekendSplurgeTitle;
  static String get behavioralSpendingBurstTitle => _t.behavioralSpendingBurstTitle;
  static String get behavioralUnusualPatternTitle =>
      _t.behavioralUnusualPatternTitle;
  static String get behavioralReviewPattern => _t.behavioralReviewPattern;
  static String get behavioralRecReduceVsLastMonth =>
      _t.behavioralRecReduceVsLastMonth;
  static String get behavioralRecKeepDiscipline => _t.behavioralRecKeepDiscipline;
  static String get behavioralRecIncreaseSavings => _t.behavioralRecIncreaseSavings;
  static String get behavioralRecSetGoals => _t.behavioralRecSetGoals;
  static String get behavioralRecCreateBudget => _t.behavioralRecCreateBudget;
  static String get behavioralRecGreatScore => _t.behavioralRecGreatScore;
  static String get behavioralRecDefault => _t.behavioralRecDefault;
  static String get behavioralRecMonthlySpike => _t.behavioralRecMonthlySpike;
  static String get behavioralRecOverspending => _t.behavioralRecOverspending;
  static String get behavioralRecLargeTransaction =>
      _t.behavioralRecLargeTransaction;
  static String get behavioralRecWeekendSplurge => _t.behavioralRecWeekendSplurge;
  static String get behavioralRecSpendingBurst => _t.behavioralRecSpendingBurst;
  static String get authAppBrandName => _t.authAppBrandName;
  static String get authOrDivider => _t.authOrDivider;
  static String get authForgotPassword => _t.authForgotPassword;
  static String get authForgotPasswordSoon => _t.authForgotPasswordSoon;
  static String get authLoginTitle => _t.authLoginTitle;
  static String get authLoginTagline => _t.authLoginTagline;
  static String get authRegisterTitle => _t.authRegisterTitle;
  static String get authRegisterTagline => _t.authRegisterTagline;
  static String get authSignUpNow => _t.authSignUpNow;
  static String get authRegisterSubmit => _t.authRegisterSubmit;
  static String get authFullNameLabel => _t.authFullNameLabel;
  static String get authFullNameRequired => _t.authFullNameRequired;
  static String get authNameRequired => _t.authNameRequired;
  static String get authEmailFormatInvalid => _t.authEmailFormatInvalid;
  static String get authConfirmPasswordRequired => _t.authConfirmPasswordRequired;
  static String get authTermsAcceptRequired => _t.authTermsAcceptRequired;
  static String get authTermsCheckboxLabel => _t.authTermsCheckboxLabel;
  static String get authContinueAsGuest => _t.authContinueAsGuest;
  static String get authNetworkError => _t.authNetworkError;
  static String get authInvalidCredentials => _t.authInvalidCredentials;
  static String get settingsAppearance => _t.settingsAppearance;
  static String get settingsNotificationsLabel => _t.settingsNotificationsLabel;
  static String get settingsTermsLink => _t.settingsTermsLink;
  static String get settingsTermsTitle => _t.settingsTermsTitle;
  static String get settingsEditProfile => _t.settingsEditProfile;
  static String get settingsProfileNameLabel => _t.settingsProfileNameLabel;
  static String get settingsProfileSaved => _t.settingsProfileSaved;
  static String get settingsTermsIntro => _t.settingsTermsIntro;
  static String get settingsTermsUseTitle => _t.settingsTermsUseTitle;
  static String get settingsTermsUseBody => _t.settingsTermsUseBody;
  static String get settingsTermsDataTitle => _t.settingsTermsDataTitle;
  static String get settingsTermsDataBody => _t.settingsTermsDataBody;
  static String get settingsTermsChangesTitle => _t.settingsTermsChangesTitle;
  static String get settingsTermsChangesBody => _t.settingsTermsChangesBody;
  static String get settingsPrivacyPolicy => _t.settingsPrivacyPolicy;
  static String get privacyPolicyTitle => _t.privacyPolicyTitle;
  static String get privacyPolicyIntro => _t.privacyPolicyIntro;
  static String get privacyPolicyDataWeCollectTitle =>
      _t.privacyPolicyDataWeCollectTitle;
  static String get privacyPolicyDataWeCollectBody =>
      _t.privacyPolicyDataWeCollectBody;
  static String get privacyPolicyHowWeUseTitle => _t.privacyPolicyHowWeUseTitle;
  static String get privacyPolicyHowWeUseBody => _t.privacyPolicyHowWeUseBody;
  static String get privacyPolicyThirdPartyTitle =>
      _t.privacyPolicyThirdPartyTitle;
  static String get privacyPolicyThirdPartyBody =>
      _t.privacyPolicyThirdPartyBody;
  static String get privacyPolicySecurityTitle => _t.privacyPolicySecurityTitle;
  static String get privacyPolicySecurityBody => _t.privacyPolicySecurityBody;
  static String get privacyPolicyContactTitle => _t.privacyPolicyContactTitle;
  static String get privacyPolicyContactBody => _t.privacyPolicyContactBody;
  static String get exportPdfReport => _t.exportPdfReport;

  // --- Chatbot & challenge (generated) ---
  static String get challengeAccept => _t.challengeAccept;
  static String challengeAcceptedBeforeInvite(int n) => _t.challengeAcceptedBeforeInvite(n);
  static String challengeAcceptedCount(int n) => _t.challengeAcceptedCount(n);
  static String get challengeActiveSectionTitle => _t.challengeActiveSectionTitle;
  static String get challengeAddAmountHint => _t.challengeAddAmountHint;
  static String get challengeAddAmountLabel => _t.challengeAddAmountLabel;
  static String get challengeAddAmountSubmit => _t.challengeAddAmountSubmit;
  static String get challengeAddAmountTitle => _t.challengeAddAmountTitle;
  static String challengeAddedAmountSuccess(String amount) => _t.challengeAddedAmountSuccess(amount);
  static String get challengeAlreadyCheckedIn => _t.challengeAlreadyCheckedIn;
  static String get challengeBadge30Earned => _t.challengeBadge30Earned;
  static String get challengeBadge30Title => _t.challengeBadge30Title;
  static String get challengeBadge7Earned => _t.challengeBadge7Earned;
  static String get challengeBadge7Title => _t.challengeBadge7Title;
  static String get challengeCancel => _t.challengeCancel;
  static String get challengeCardActive => _t.challengeCardActive;
  static String get challengeCardCompleted => _t.challengeCardCompleted;
  static String get challengeCardExpired => _t.challengeCardExpired;
  static String get challengeCardUpcoming => _t.challengeCardUpcoming;
  static String get challengeChallengeCreatedSuccess => _t.challengeChallengeCreatedSuccess;
  static String get challengeChallengeDeletedSuccess => _t.challengeChallengeDeletedSuccess;
  static String get challengeChallengeMarkedAchieved => _t.challengeChallengeMarkedAchieved;
  static String get challengeChallengeMarkedNotAchieved => _t.challengeChallengeMarkedNotAchieved;
  static String get challengeChallengeUpdatedSuccess => _t.challengeChallengeUpdatedSuccess;
  static String get challengeCheckInButton => _t.challengeCheckInButton;
  static String challengeCheckInForChallenge(String name) => _t.challengeCheckInForChallenge(name);
  static String get challengeCheckInSuccess => _t.challengeCheckInSuccess;
  static String get challengeChooseDate => _t.challengeChooseDate;
  static String get challengeCreateRequiresOnline => _t.challengeCreateRequiresOnline;
  static String get challengeCreateSubmit => _t.challengeCreateSubmit;
  static String get challengeCreateTitle => _t.challengeCreateTitle;
  static String challengeCreatorTargetLine(String amount) => _t.challengeCreatorTargetLine(amount);
  static String get challengeCurrencyAmountPrefix => _t.challengeCurrencyAmountPrefix;
  static String get challengeCurrentAmountLabel => _t.challengeCurrentAmountLabel;
  static String get challengeDailyCheckInStripTitle => _t.challengeDailyCheckInStripTitle;
  static String challengeDaysRemaining(int days) => _t.challengeDaysRemaining(days);
  static String challengeDaysUntilStart(int days) => _t.challengeDaysUntilStart(days);
  static String get challengeDecline => _t.challengeDecline;
  static String get challengeDetailTitle => _t.challengeDetailTitle;
  static String get challengeEmptyActive => _t.challengeEmptyActive;
  static String get challengeEmptyActiveSubtitle => _t.challengeEmptyActiveSubtitle;
  static String get challengeEmptyCompleted => _t.challengeEmptyCompleted;
  static String get challengeEmptyCompletedSubtitle => _t.challengeEmptyCompletedSubtitle;
  static String get challengeEmptyExpired => _t.challengeEmptyExpired;
  static String get challengeEmptyExpiredSubtitle => _t.challengeEmptyExpiredSubtitle;
  static String get challengeEmptyInvitations => _t.challengeEmptyInvitations;
  static String get challengeEmptyInvitationsSubtitle => _t.challengeEmptyInvitationsSubtitle;
  static String get challengeEmptyUpcoming => _t.challengeEmptyUpcoming;
  static String get challengeEmptyUpcomingSubtitle => _t.challengeEmptyUpcomingSubtitle;
  static String get challengeEndDateLabel => _t.challengeEndDateLabel;
  static String get challengeFieldChallengeName => _t.challengeFieldChallengeName;
  static String get challengeFieldTargetAmount => _t.challengeFieldTargetAmount;
  static String challengeFromCreator(String name) => _t.challengeFromCreator(name);
  static String challengeGoalAmount(String amount) => _t.challengeGoalAmount(amount);
  static String get challengeGoalCongrats => _t.challengeGoalCongrats;
  static String get challengeHintChallengeName => _t.challengeHintChallengeName;
  static String get challengeHintTargetAmount => _t.challengeHintTargetAmount;
  static String get challengeInvalidAmountSnack => _t.challengeInvalidAmountSnack;
  static String get challengeInvitationAccepted => _t.challengeInvitationAccepted;
  static String get challengeInvitationRejected => _t.challengeInvitationRejected;
  static String get challengeInviteAccepted => _t.challengeInviteAccepted;
  static String get challengeInviteAppBarTitle => _t.challengeInviteAppBarTitle;
  static String get challengeInviteButton => _t.challengeInviteButton;
  static String get challengeInviteDeclined => _t.challengeInviteDeclined;
  static String get challengeInviteDialogTitle => _t.challengeInviteDialogTitle;
  static String get challengeInviteEmailHint => _t.challengeInviteEmailHint;
  static String get challengeInviteEmailLabel => _t.challengeInviteEmailLabel;
  static String get challengeInviteFriendsSubtitle => _t.challengeInviteFriendsSubtitle;
  static String get challengeInviteFriendsTitle => _t.challengeInviteFriendsTitle;
  static String get challengeInviteInvalidEmail => _t.challengeInviteInvalidEmail;
  static String get challengeInvitePendingStatus => _t.challengeInvitePendingStatus;
  static String get challengeInviteShareButton => _t.challengeInviteShareButton;
  static String challengeInviteShareMessage(String link) => _t.challengeInviteShareMessage(link);
  static String get challengeInviteShareSubject => _t.challengeInviteShareSubject;
  static String get challengeLeaderboardEmpty => _t.challengeLeaderboardEmpty;
  static String get challengeLeaderboardTitle => _t.challengeLeaderboardTitle;
  static String get challengeListTitle => _t.challengeListTitle;
  static String get challengeLoadFailed => _t.challengeLoadFailed;
  static String get challengeLocalCancel => _t.challengeLocalCancel;
  static String get challengeLocalCreateButton => _t.challengeLocalCreateButton;
  static String challengeLocalCreateFailed(String e) => _t.challengeLocalCreateFailed(e);
  static String get challengeLocalCreateSuccess => _t.challengeLocalCreateSuccess;
  static String get challengeLocalEndAfterStart => _t.challengeLocalEndAfterStart;
  static String get challengeLocalEndDate => _t.challengeLocalEndDate;
  static String get challengeLocalEndRequired => _t.challengeLocalEndRequired;
  static String get challengeLocalNameHint => _t.challengeLocalNameHint;
  static String get challengeLocalNameRequired => _t.challengeLocalNameRequired;
  static String get challengeLocalNameSection => _t.challengeLocalNameSection;
  static String get challengeLocalPeriodSection => _t.challengeLocalPeriodSection;
  static String get challengeLocalPopupSubtitle => _t.challengeLocalPopupSubtitle;
  static String get challengeLocalPopupTitle => _t.challengeLocalPopupTitle;
  static String get challengeLocalStartDate => _t.challengeLocalStartDate;
  static String get challengeLocalStartRequired => _t.challengeLocalStartRequired;
  static String get challengeLocalStatusHint => _t.challengeLocalStatusHint;
  static String get challengeLocalStatusRequired => _t.challengeLocalStatusRequired;
  static String get challengeLocalStatusSection => _t.challengeLocalStatusSection;
  static String get challengeLogButton => _t.challengeLogButton;
  static String get challengeNewChallengeFab => _t.challengeNewChallengeFab;
  static String get challengeOfflineBanner => _t.challengeOfflineBanner;
  static String challengeParticipantCountMany(int n) => _t.challengeParticipantCountMany(n);
  static String get challengeParticipantCountOne => _t.challengeParticipantCountOne;
  static String get challengeParticipantRemovedSuccess => _t.challengeParticipantRemovedSuccess;
  static String challengeParticipantsTitle(int n) => _t.challengeParticipantsTitle(n);
  static String get challengePendingEmpty => _t.challengePendingEmpty;
  static String get challengePendingEmptySubtitle => _t.challengePendingEmptySubtitle;
  static String get challengePendingStatus => _t.challengePendingStatus;
  static String get challengePendingTitle => _t.challengePendingTitle;
  static String get challengePickEndDate => _t.challengePickEndDate;
  static String get challengePickStartDate => _t.challengePickStartDate;
  static String get challengeProgressLabel => _t.challengeProgressLabel;
  static String get challengeProgressQueuedOffline => _t.challengeProgressQueuedOffline;
  static String get challengeProgressSaved => _t.challengeProgressSaved;
  static String get challengeQuickTemplatesTitle => _t.challengeQuickTemplatesTitle;
  static String challengeRankLabel(int rank) => _t.challengeRankLabel(rank);
  static String get challengeRemoveButton => _t.challengeRemoveButton;
  static String get challengeRemoveParticipantBody => _t.challengeRemoveParticipantBody;
  static String get challengeRemoveParticipantTitle => _t.challengeRemoveParticipantTitle;
  static String get challengeRetry => _t.challengeRetry;
  static String get challengeRoleCreator => _t.challengeRoleCreator;
  static String get challengeSectionDetails => _t.challengeSectionDetails;
  static String get challengeSectionSchedule => _t.challengeSectionSchedule;
  static String get challengeServerMaintenanceHint => _t.challengeServerMaintenanceHint;
  static String get challengeSplitHint => _t.challengeSplitHint;
  static String get challengeStartDateLabel => _t.challengeStartDateLabel;
  static String get challengeStatusActiveLabel => _t.challengeStatusActiveLabel;
  static String get challengeStatusCancelledLabel => _t.challengeStatusCancelledLabel;
  static String get challengeStatusCompletedLabel => _t.challengeStatusCompletedLabel;
  static String get challengeStatusLabel => _t.challengeStatusLabel;
  static String challengeStreakDays(int days) => _t.challengeStreakDays(days);
  static String challengeStreakFire(int days) => _t.challengeStreakFire(days);
  static String get challengeStreakTitle => _t.challengeStreakTitle;
  static String get challengeSyncFailed => _t.challengeSyncFailed;
  static String get challengeTabActive => _t.challengeTabActive;
  static String get challengeTabCompleted => _t.challengeTabCompleted;
  static String get challengeTabExpired => _t.challengeTabExpired;
  static String get challengeTabInvitations => _t.challengeTabInvitations;
  static String get challengeTabUpcoming => _t.challengeTabUpcoming;
  static String get challengeTargetAmountLabel => _t.challengeTargetAmountLabel;
  static String get challengeTemplateCreated => _t.challengeTemplateCreated;
  static String challengeTemplateDays(int days) => _t.challengeTemplateDays(days);
  static String get challengeTemplatesSubtitle => _t.challengeTemplatesSubtitle;
  static String get challengeTemplatesTitle => _t.challengeTemplatesTitle;
  static String challengeTotalAmount(String amount) => _t.challengeTotalAmount(amount);
  static String get challengeUnexpectedError => _t.challengeUnexpectedError;
  static String get challengeUnexpectedErrorLater => _t.challengeUnexpectedErrorLater;
  static String get challengeUpdateAmountAchieved => _t.challengeUpdateAmountAchieved;
  static String get challengeUpdateAmountButton => _t.challengeUpdateAmountButton;
  static String get challengeUseTemplate => _t.challengeUseTemplate;
  static String get challengeUserInvitedSuccess => _t.challengeUserInvitedSuccess;
  static String get challengeValAmountInvalid => _t.challengeValAmountInvalid;
  static String get challengeValAmountRequired => _t.challengeValAmountRequired;
  static String get challengeValNameMin => _t.challengeValNameMin;
  static String get challengeValNameRequired => _t.challengeValNameRequired;
  static String get challengeWriteRequiresOnline => _t.challengeWriteRequiresOnline;
  static String get chatbotAlertExpenseOverIncome => _t.chatbotAlertExpenseOverIncome;
  static String chatbotAlertSpendingGrowth(String pct) => _t.chatbotAlertSpendingGrowth(pct);
  static String get chatbotAssistantHeadline => _t.chatbotAssistantHeadline;
  static String get chatbotAssistantSubtitle => _t.chatbotAssistantSubtitle;
  static String get chatbotAssistantUnreachable => _t.chatbotAssistantUnreachable;
  static String chatbotBudgetCreatedDialog(String amount) => _t.chatbotBudgetCreatedDialog(amount);
  static String chatbotBudgetCreatedOk(String amount) => _t.chatbotBudgetCreatedOk(amount);
  static String chatbotBudgetCreatedSummary(String amount) => _t.chatbotBudgetCreatedSummary(amount);
  static String get chatbotChatCleared => _t.chatbotChatCleared;
  static String get chatbotClearChatConfirm => _t.chatbotClearChatConfirm;
  static String get chatbotClearChatMessage => _t.chatbotClearChatMessage;
  static String get chatbotClearChatTitle => _t.chatbotClearChatTitle;
  static String get chatbotClearDialogBody => _t.chatbotClearDialogBody;
  static String get chatbotClearDialogConfirm => _t.chatbotClearDialogConfirm;
  static String get chatbotClearDialogTitle => _t.chatbotClearDialogTitle;
  static String chatbotDateToday(String day, String d, String month, String y) => _t.chatbotDateToday(day, d, month, y);
  static String get chatbotDefaultGoalWord => _t.chatbotDefaultGoalWord;
  static String get chatbotDefaultNewGoalName => _t.chatbotDefaultNewGoalName;
  static String get chatbotDlgAdjustBudgetTitle => _t.chatbotDlgAdjustBudgetTitle;
  static String get chatbotDlgCancel => _t.chatbotDlgCancel;
  static String get chatbotDlgCreate => _t.chatbotDlgCreate;
  static String get chatbotDlgCreateGoalTitle => _t.chatbotDlgCreateGoalTitle;
  static String get chatbotDlgGoalNameLabel => _t.chatbotDlgGoalNameLabel;
  static String get chatbotDlgGoalTargetLabel => _t.chatbotDlgGoalTargetLabel;
  static String get chatbotDlgMonthlyBudgetLabel => _t.chatbotDlgMonthlyBudgetLabel;
  static String get chatbotDlgSave => _t.chatbotDlgSave;
  static String get chatbotGenericProcessError => _t.chatbotGenericProcessError;
  static String chatbotGoalCreatedDialog(String name) => _t.chatbotGoalCreatedDialog(name.trim());
  static String chatbotGoalCreatedOk(String name) => _t.chatbotGoalCreatedOk(name);
  static String chatbotGoalCreatedSummary(String name) => _t.chatbotGoalCreatedSummary(name);
  static String get chatbotGreetBack => _t.chatbotGreetBack;
  static String get chatbotHowAreYouReply => _t.chatbotHowAreYouReply;
  static String chatbotHttpError(int code) => _t.chatbotHttpError(code);
  static String get chatbotInputHint => _t.chatbotInputHint;
  static String chatbotInsightBody(String score, String status, String alertBlock) => _t.chatbotInsightBody(score, status, alertBlock);
  static String get chatbotInsightError => _t.chatbotInsightError;
  static String get chatbotInsightStatusGood => _t.chatbotInsightStatusGood;
  static String get chatbotInsightStatusNeeds => _t.chatbotInsightStatusNeeds;
  static String get chatbotInsightStatusStrong => _t.chatbotInsightStatusStrong;
  static String get chatbotInvalidNumber => _t.chatbotInvalidNumber;
  static String get chatbotJsonNoData => _t.chatbotJsonNoData;
  static String chatbotLocalFallbackBalance(String income, String expense, String balance, int score, String status) => _t.chatbotLocalFallbackBalance(income, expense, balance, score, status);
  static String chatbotLocalFallbackBudget(String budget, String spent, String usedPct, String remaining) => _t.chatbotLocalFallbackBudget(budget, spent, usedPct, remaining);
  static String chatbotLocalFallbackCategoryLine(String name, String amount, String share) => _t.chatbotLocalFallbackCategoryLine(name, amount, share);
  static String chatbotLocalFallbackExpenses(String total, String lines) => _t.chatbotLocalFallbackExpenses(total, lines);
  static String chatbotLocalFallbackGoalLine(String name, String current, String target, String pct) => _t.chatbotLocalFallbackGoalLine(name, current, target, pct);
  static String chatbotLocalFallbackGoalsCount(int count) => _t.chatbotLocalFallbackGoalsCount(count);
  static String chatbotLocalFallbackGoalsIntro(String lines, String surplus, String income) => _t.chatbotLocalFallbackGoalsIntro(lines, surplus, income);
  static String get chatbotLocalFallbackGoalsNone => _t.chatbotLocalFallbackGoalsNone;
  static String chatbotLocalFallbackNoBudget(String expense) => _t.chatbotLocalFallbackNoBudget(expense);
  static String get chatbotLocalFallbackNoCategoryData => _t.chatbotLocalFallbackNoCategoryData;
  static String get chatbotLocalFallbackNoExpenses => _t.chatbotLocalFallbackNoExpenses;
  static String get chatbotLocalFallbackNoGoals => _t.chatbotLocalFallbackNoGoals;
  static String get chatbotLocalFallbackOfflineNotice => _t.chatbotLocalFallbackOfflineNotice;
  static String get chatbotLocalFallbackOtherCategory => _t.chatbotLocalFallbackOtherCategory;
  static String get chatbotLocalFallbackQuotaNotice => _t.chatbotLocalFallbackQuotaNotice;
  static String chatbotLocalFallbackSnapshot(String income, String expense, String balance, int score, String status, String alerts, String topCategory, String goalsLine) => _t.chatbotLocalFallbackSnapshot(income, expense, balance, score, status, alerts, topCategory, goalsLine);
  static String chatbotLocalFallbackTopCategory(String name, String amount) => _t.chatbotLocalFallbackTopCategory(name, amount);
  static String get chatbotNeedBudgetAmount => _t.chatbotNeedBudgetAmount;
  static String get chatbotNeedGoalAmount => _t.chatbotNeedGoalAmount;
  static String get chatbotNextGoalFallback => _t.chatbotNextGoalFallback;
  static String get chatbotNoAccountForBudget => _t.chatbotNoAccountForBudget;
  static String get chatbotNoInternet => _t.chatbotNoInternet;
  static String get chatbotNoSpendingAlerts => _t.chatbotNoSpendingAlerts;
  static String get chatbotOptimizerGoalsDone => _t.chatbotOptimizerGoalsDone;
  static String chatbotOptimizerIntro(String monthly) => _t.chatbotOptimizerIntro(monthly);
  static String chatbotOptimizerLine(String name, String perMonth, String remaining) => _t.chatbotOptimizerLine(name, perMonth, remaining);
  static String get chatbotOptimizerNoGoals => _t.chatbotOptimizerNoGoals;
  static String get chatbotOptimizerNoSurplus => _t.chatbotOptimizerNoSurplus;
  static String get chatbotParseError => _t.chatbotParseError;
  static String get chatbotParseResponseFail => _t.chatbotParseResponseFail;
  static String get chatbotPdfFail => _t.chatbotPdfFail;
  static String get chatbotPdfOk => _t.chatbotPdfOk;
  static String get chatbotPendingCancelled => _t.chatbotPendingCancelled;
  static String get chatbotPendingHint => _t.chatbotPendingHint;
  static String chatbotPreviewBudget(String amount, String start, String end) => _t.chatbotPreviewBudget(amount, start, end);
  static String chatbotPreviewGoal(String name, String amount, int months) => _t.chatbotPreviewGoal(name, amount, months);
  static String get chatbotQuickAdjustBudget => _t.chatbotQuickAdjustBudget;
  static String get chatbotQuickCreateGoal => _t.chatbotQuickCreateGoal;
  static String get chatbotQuickPdf => _t.chatbotQuickPdf;
  static String get chatbotQuickReduceCategory => _t.chatbotQuickReduceCategory;
  static String get chatbotQuickUndo => _t.chatbotQuickUndo;
  static String get chatbotRateLimited => _t.chatbotRateLimited;
  static String get chatbotReduceCategoryHint => _t.chatbotReduceCategoryHint;
  static String get chatbotRefreshSuggestionsTooltip => _t.chatbotRefreshSuggestionsTooltip;
  static String get chatbotRequestTimeout => _t.chatbotRequestTimeout;
  static String get chatbotRequiredField => _t.chatbotRequiredField;
  static String get chatbotScreenTitle => _t.chatbotScreenTitle;
  static String get chatbotServer53 => _t.chatbotServer53;
  static String get chatbotSubsError => _t.chatbotSubsError;
  static String chatbotSubsLine(String name, String amount, int count) => _t.chatbotSubsLine(name, amount, count);
  static String get chatbotSubsNone => _t.chatbotSubsNone;
  static String chatbotSubsSummary(String lines, String total) => _t.chatbotSubsSummary(lines, total);
  static String get chatbotSuggestBalancePrompt => _t.chatbotSuggestBalancePrompt;
  static String get chatbotSuggestBalanceSubtitle => _t.chatbotSuggestBalanceSubtitle;
  static String get chatbotSuggestBalanceTitle => _t.chatbotSuggestBalanceTitle;
  static String get chatbotSuggestExpensePrompt => _t.chatbotSuggestExpensePrompt;
  static String get chatbotSuggestExpenseSubtitle => _t.chatbotSuggestExpenseSubtitle;
  static String get chatbotSuggestExpenseTitle => _t.chatbotSuggestExpenseTitle;
  static String get chatbotSuggestGoalsPrompt => _t.chatbotSuggestGoalsPrompt;
  static String get chatbotSuggestGoalsSubtitle => _t.chatbotSuggestGoalsSubtitle;
  static String get chatbotSuggestGoalsTitle => _t.chatbotSuggestGoalsTitle;
  static String get chatbotSuggestSavingsPrompt => _t.chatbotSuggestSavingsPrompt;
  static String get chatbotSuggestSavingsTitle => _t.chatbotSuggestSavingsTitle;
  static String get chatbotSuggestedQuestionsTitle => _t.chatbotSuggestedQuestionsTitle;
  static String get chatbotThanksReply => _t.chatbotThanksReply;
  static String get chatbotTimePeriodAm => _t.chatbotTimePeriodAm;
  static String get chatbotTimePeriodPm => _t.chatbotTimePeriodPm;
  static String chatbotUndoDone(String summary) => _t.chatbotUndoDone(summary);
  static String get chatbotUndoError => _t.chatbotUndoError;
  static String get chatbotUndoMissing => _t.chatbotUndoMissing;
  static String get chatbotUndoNone => _t.chatbotUndoNone;
  static String get chatbotUnnamedRecurring => _t.chatbotUnnamedRecurring;
  static String get chatbotWhatIfAllGoalsDone => _t.chatbotWhatIfAllGoalsDone;
  static String get chatbotWhatIfError => _t.chatbotWhatIfError;
  static String get chatbotWhatIfNeedAmount => _t.chatbotWhatIfNeedAmount;
  static String get chatbotWhatIfNoGoals => _t.chatbotWhatIfNoGoals;
  static String chatbotWhatIfScenario(String amount, String name, String remaining, int months, String eta) => _t.chatbotWhatIfScenario(amount, name, remaining, months, eta);
  static String get chatbotWhoAmI => _t.chatbotWhoAmI;

  static List<String> get chatbotWeekdays => [
    _t.chatbotWeekday0,
    _t.chatbotWeekday1,
    _t.chatbotWeekday2,
    _t.chatbotWeekday3,
    _t.chatbotWeekday4,
    _t.chatbotWeekday5,
    _t.chatbotWeekday6,
  ];

  static List<String> get chatbotMonths => [
    _t.chatbotMonth0,
    _t.chatbotMonth1,
    _t.chatbotMonth2,
    _t.chatbotMonth3,
    _t.chatbotMonth4,
    _t.chatbotMonth5,
    _t.chatbotMonth6,
    _t.chatbotMonth7,
    _t.chatbotMonth8,
    _t.chatbotMonth9,
    _t.chatbotMonth10,
    _t.chatbotMonth11,
  ];

  static List<String> get chatbotDefaultSuggestions => [
    _t.chatbotDefaultSuggestion0,
    _t.chatbotDefaultSuggestion1,
    _t.chatbotDefaultSuggestion2,
  ];

  static List<String> get chatbotAlternateSuggestions => [
    _t.chatbotAlternateSuggestion0,
    _t.chatbotAlternateSuggestion1,
    _t.chatbotAlternateSuggestion2,
    _t.chatbotAlternateSuggestion3,
    _t.chatbotAlternateSuggestion4,
    _t.chatbotAlternateSuggestion5,
  ];

  static String chatbotTimeNow(int displayHour, String minute, bool isPm) =>
      _t.chatbotTimeNow(
        displayHour,
        minute,
        isPm ? _t.chatbotTimePeriodPm : _t.chatbotTimePeriodAm,
      );

  static String chatbotInsightStatusLabel(int score) {
    if (score >= 75) return chatbotInsightStatusStrong;
    if (score >= 50) return chatbotInsightStatusGood;
    return chatbotInsightStatusNeeds;
  }

  static String challengeParticipantCountLabel(int n) =>
      n == 1 ? challengeParticipantCountOne : challengeParticipantCountMany(n);

  static String goalDeleteConfirmBody(String goalName) =>
      _t.goalDeleteConfirmBody(goalName);

  static String notificationBudgetWarningBody(double spent, double limit) =>
      _t.notificationBudgetWarningBody(
        spent.toStringAsFixed(0),
        limit.toStringAsFixed(0),
      );

  static String notificationBudgetExceededBody(double spent, double limit) =>
      _t.notificationBudgetExceededBody(
        spent.toStringAsFixed(0),
        limit.toStringAsFixed(0),
      );

  static String goalContributionSuccessBody(double amount) =>
      _t.goalContributionSuccessBody(amount.toStringAsFixed(2));

  static String goalCompletedAlertBody(String name) =>
      _t.goalCompletedAlertBody(name);

  static String expensesBudgetExceeded(double remaining) =>
      _t.expensesBudgetExceeded(AppCurrency.format(remaining));

  static String expensesBudgetLinked(
    double spent,
    double budget,
    double remaining,
  ) =>
      _t.expensesBudgetLinked(
        AppCurrency.format(spent),
        AppCurrency.format(budget),
        AppCurrency.format(remaining),
      );

  static String statsTopCategoryInsight(String name, String percent) =>
      _t.statsTopCategoryInsight(name, percent);

  static String statsSpendingChangeInsight(String percent, bool increased) =>
      increased
          ? _t.statsSpendingUpInsight(percent)
          : _t.statsSpendingDownInsight(percent);

  static String behavioralCategorySpikeMessage(String category, String pct) =>
      _t.behavioralCategorySpikeMessage(category, pct);

  static String behavioralRecCategorySpike(String category) =>
      _t.behavioralRecCategorySpike(category);

  static String behavioralMonthCompareNoHistory(String amount) =>
      _t.behavioralMonthCompareNoHistory(amount);

  static String behavioralMonthCompareUp(
    String pct,
    String current,
    String previous,
  ) =>
      _t.behavioralMonthCompareUp(pct, current, previous);

  static String behavioralMonthCompareDown(String pct) =>
      _t.behavioralMonthCompareDown(pct);

  static String behavioralMonthCompareStable(String current, String previous) =>
      _t.behavioralMonthCompareStable(current, previous);

  static String behavioralMonthCompareTrailing(String current, String avg) =>
      _t.behavioralMonthCompareTrailing(current, avg);

  static String behavioralWeekdayInsight(String day, String amount) =>
      _t.behavioralWeekdayInsight(day, amount);

  static String behavioralMonthlySpikeMessage(String pct, String amount) =>
      _t.behavioralMonthlySpikeMessage(pct, amount);

  static String behavioralOverspendingMessage(String amount) =>
      _t.behavioralOverspendingMessage(amount);

  static String behavioralLargeTransactionMessage(String amount) =>
      _t.behavioralLargeTransactionMessage(amount);

  static String behavioralWeekendSplurgeMessage(String pct) =>
      _t.behavioralWeekendSplurgeMessage(pct);

  static String behavioralSpendingBurstMessage(String count) =>
      _t.behavioralSpendingBurstMessage(count);

  static String settingsVersionLabel(String version) =>
      _t.settingsVersionLabel(version);

  static String homeAlertSpendingUp(String percent) =>
      _t.homeAlertSpendingUp(percent);
  static String homePendingSyncBanner(int count) =>
      _t.homePendingSyncBanner(count);

  static String budgetSpentSummary(String spent, String limit) =>
      _t.budgetSpentSummary(spent, limit);

  static String txSuccess(String type) => type == 'income'
      ? _t.txSuccessIncome
      : _t.txSuccessExpense;

  static String txNoCategories(String type) => _t.txNoCategories(type);

  static String txLoadFailed(Object e) => _t.txLoadFailed(e);

  static String goalLine(String name) => _t.goalLine(name);

  static String challengeLine(String name) => _t.challengeLine(name);

  static List<String> get barChartLabels => [
        _t.barChartIncome,
        _t.barChartExpenses,
        _t.barChartBalance,
      ];

  static String healthScoreLabel(int score) {
    if (score >= 75) return healthScoreExcellent;
    if (score >= 60) return healthScoreGood;
    if (score >= 40) return healthScoreFair;
    return healthScoreWeak;
  }

  static String journeyMotivation(double progress) {
    if (progress >= 1.0) return _t.journeyMotivationComplete;
    if (progress >= 0.75) return _t.journeyMotivation75;
    if (progress >= 0.5) return _t.journeyMotivation50;
    if (progress >= 0.25) return _t.journeyMotivation25;
    if (progress > 0) return _t.journeyMotivationStart;
    return _t.journeyMotivationZero;
  }
}
