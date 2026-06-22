import 'package:flutter/material.dart';
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

  static String goalDeleteConfirmBody(String goalName) =>
      _t.goalDeleteConfirmBody(goalName);

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

  static String journeyMotivation(double progress) {
    if (progress >= 1.0) return _t.journeyMotivationComplete;
    if (progress >= 0.75) return _t.journeyMotivation75;
    if (progress >= 0.5) return _t.journeyMotivation50;
    if (progress >= 0.25) return _t.journeyMotivation25;
    if (progress > 0) return _t.journeyMotivationStart;
    return _t.journeyMotivationZero;
  }
}
