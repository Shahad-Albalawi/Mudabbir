import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Chatbot copy and formatting helpers backed by [AppStrings].
class ChatbotCopyHelpers {
  ChatbotCopyHelpers._();

  static String get reduceCategoryHint => AppStrings.chatbotReduceCategoryHint;
  static String get undoNone => AppStrings.chatbotUndoNone;
  static String undoDone(String summary) => AppStrings.chatbotUndoDone(summary);
  static String get undoMissing => AppStrings.chatbotUndoMissing;
  static String get undoError => AppStrings.chatbotUndoError;
  static String get whatIfError => AppStrings.chatbotWhatIfError;
  static String get subsError => AppStrings.chatbotSubsError;
  static String get insightError => AppStrings.chatbotInsightError;
  static String get genericProcessError => AppStrings.chatbotGenericProcessError;
  static String get pendingHint => AppStrings.chatbotPendingHint;
  static String get pendingCancelled => AppStrings.chatbotPendingCancelled;
  static String goalCreatedSummary(String name) =>
      AppStrings.chatbotGoalCreatedSummary(name);
  static String goalCreatedOk(String name) => AppStrings.chatbotGoalCreatedOk(name);
  static String budgetCreatedSummary(String amount) =>
      AppStrings.chatbotBudgetCreatedSummary(amount);
  static String budgetCreatedOk(String amount) =>
      AppStrings.chatbotBudgetCreatedOk(amount);
  static String get needGoalAmount => AppStrings.chatbotNeedGoalAmount;
  static String previewGoal(String name, String amount, int months) =>
      AppStrings.chatbotPreviewGoal(name, amount, months);
  static String get needBudgetAmount => AppStrings.chatbotNeedBudgetAmount;
  static String get noAccountForBudget => AppStrings.chatbotNoAccountForBudget;
  static String previewBudget(String amount, String start, String end) =>
      AppStrings.chatbotPreviewBudget(amount, start, end);
  static String get defaultNewGoalName => AppStrings.chatbotDefaultNewGoalName;

  static String insightStatus(int score) =>
      AppStrings.chatbotInsightStatusLabel(score);

  static String insightBody(int score, String status, String alertBlock) =>
      AppStrings.chatbotInsightBody(score.toString(), status, alertBlock);
  static String get noSpendingAlerts => AppStrings.chatbotNoSpendingAlerts;
  static String get whatIfNeedAmount => AppStrings.chatbotWhatIfNeedAmount;
  static String get whatIfNoGoals => AppStrings.chatbotWhatIfNoGoals;
  static String get whatIfAllGoalsDone => AppStrings.chatbotWhatIfAllGoalsDone;
  static String get nextGoalFallback => AppStrings.chatbotNextGoalFallback;
  static String whatIfScenario(
    String amount,
    String name,
    String remaining,
    int months,
    String eta,
  ) =>
      AppStrings.chatbotWhatIfScenario(amount, name, remaining, months, eta);
  static String get optimizerNoGoals => AppStrings.chatbotOptimizerNoGoals;
  static String get optimizerNoSurplus => AppStrings.chatbotOptimizerNoSurplus;
  static String get defaultGoalWord => AppStrings.chatbotDefaultGoalWord;
  static String get optimizerGoalsDone => AppStrings.chatbotOptimizerGoalsDone;
  static String optimizerLine(String name, String perMonth, String remaining) =>
      AppStrings.chatbotOptimizerLine(name, perMonth, remaining);
  static String optimizerIntro(String monthly) =>
      AppStrings.chatbotOptimizerIntro(monthly);
  static String get alertExpenseOverIncome =>
      AppStrings.chatbotAlertExpenseOverIncome;
  static String alertSpendingGrowth(String pct) =>
      AppStrings.chatbotAlertSpendingGrowth(pct);
  static String get subsNone => AppStrings.chatbotSubsNone;
  static String subsLine(String name, String amount, int count) =>
      AppStrings.chatbotSubsLine(name, amount, count);
  static String subsSummary(String lines, String total) =>
      AppStrings.chatbotSubsSummary(lines, total);
  static String get unnamedRecurring => AppStrings.chatbotUnnamedRecurring;
  static String get pdfOk => AppStrings.chatbotPdfOk;
  static String get pdfFail => AppStrings.chatbotPdfFail;
  static String get dlgCreateGoalTitle => AppStrings.chatbotDlgCreateGoalTitle;
  static String get dlgGoalNameLabel => AppStrings.chatbotDlgGoalNameLabel;
  static String get dlgGoalTargetLabel => AppStrings.chatbotDlgGoalTargetLabel;
  static String get requiredField => AppStrings.chatbotRequiredField;
  static String get invalidNumber => AppStrings.chatbotInvalidNumber;
  static String get dlgCreate => AppStrings.chatbotDlgCreate;
  static String get dlgAdjustBudgetTitle => AppStrings.chatbotDlgAdjustBudgetTitle;
  static String get dlgMonthlyBudgetLabel => AppStrings.chatbotDlgMonthlyBudgetLabel;
  static String get dlgSave => AppStrings.chatbotDlgSave;
  static String get dlgCancel => AppStrings.chatbotDlgCancel;
  static String goalCreatedDialog(String name) =>
      AppStrings.chatbotGoalCreatedDialog(name);
  static String budgetCreatedDialog(String amount) =>
      AppStrings.chatbotBudgetCreatedDialog(amount);
  static String get whoAmI => AppStrings.chatbotWhoAmI;
  static String get greetBack => AppStrings.chatbotGreetBack;
  static String timeNow(int displayHour, String minute, bool isPm) =>
      AppStrings.chatbotTimeNow(displayHour, minute, isPm);
  static String dateToday(String day, int d, String month, int y) =>
      AppStrings.chatbotDateToday(day, d.toString(), month, y.toString());
  static List<String> get weekdays => AppStrings.chatbotWeekdays;
  static List<String> get months => AppStrings.chatbotMonths;
  static String get thanksReply => AppStrings.chatbotThanksReply;
  static String get howAreYouReply => AppStrings.chatbotHowAreYouReply;
  static String get jsonNoData => AppStrings.chatbotJsonNoData;
  static String get rateLimited => AppStrings.chatbotRateLimited;
  static String get server53 => AppStrings.chatbotServer53;
  static String httpError(int code) => AppStrings.chatbotHttpError(code);
  static String get requestTimeout => AppStrings.chatbotRequestTimeout;
  static String get noInternet => AppStrings.chatbotNoInternet;
  static String get assistantUnreachable => AppStrings.chatbotAssistantUnreachable;
  static String get parseResponseFail => AppStrings.chatbotParseResponseFail;
  static String get parseError => AppStrings.chatbotParseError;
  static String get chatCleared => AppStrings.chatbotChatCleared;
  static String get quickCreateGoal => AppStrings.chatbotQuickCreateGoal;
  static String get quickAdjustBudget => AppStrings.chatbotQuickAdjustBudget;
  static String get quickReduceCategory => AppStrings.chatbotQuickReduceCategory;
  static String get quickPdf => AppStrings.chatbotQuickPdf;
  static String get quickUndo => AppStrings.chatbotQuickUndo;
  static String get suggestBalanceTitle => AppStrings.chatbotSuggestBalanceTitle;
  static String get suggestBalanceSubtitle =>
      AppStrings.chatbotSuggestBalanceSubtitle;
  static String get suggestExpenseTitle => AppStrings.chatbotSuggestExpenseTitle;
  static String get suggestExpenseSubtitle =>
      AppStrings.chatbotSuggestExpenseSubtitle;
  static String get suggestGoalsTitle => AppStrings.chatbotSuggestGoalsTitle;
  static String get suggestGoalsSubtitle =>
      AppStrings.chatbotSuggestGoalsSubtitle;
  static String get suggestBalancePrompt => AppStrings.chatbotSuggestBalancePrompt;
  static String get suggestExpensePrompt => AppStrings.chatbotSuggestExpensePrompt;
  static String get suggestGoalsPrompt => AppStrings.chatbotSuggestGoalsPrompt;
  static String get clearDialogTitle => AppStrings.chatbotClearDialogTitle;
  static String get clearDialogBody => AppStrings.chatbotClearDialogBody;
  static String get clearDialogConfirm => AppStrings.chatbotClearDialogConfirm;
  static String get localFallbackQuotaNotice =>
      AppStrings.chatbotLocalFallbackQuotaNotice;
  static String get localFallbackOfflineNotice =>
      AppStrings.chatbotLocalFallbackOfflineNotice;
  static String localFallbackBalance(
    String income,
    String expense,
    String balance,
    int score,
    String status,
  ) =>
      AppStrings.chatbotLocalFallbackBalance(
        income,
        expense,
        balance,
        score,
        status,
      );
  static String localFallbackSnapshot(
    String income,
    String expense,
    String balance,
    int score,
    String status,
    String alerts,
    String topCategory,
    String goalsLine,
  ) =>
      AppStrings.chatbotLocalFallbackSnapshot(
        income,
        expense,
        balance,
        score,
        status,
        alerts,
        topCategory,
        goalsLine,
      );
  static String get localFallbackNoGoals => AppStrings.chatbotLocalFallbackNoGoals;
  static String localFallbackGoalLine(
    String name,
    String current,
    String target,
    String pct,
  ) =>
      AppStrings.chatbotLocalFallbackGoalLine(name, current, target, pct);
  static String localFallbackGoalsIntro(
    String lines,
    String surplus,
    String income,
  ) =>
      AppStrings.chatbotLocalFallbackGoalsIntro(lines, surplus, income);
  static String localFallbackNoBudget(String expense) =>
      AppStrings.chatbotLocalFallbackNoBudget(expense);
  static String localFallbackBudget(
    String budget,
    String spent,
    String remaining,
    String usedPct,
  ) =>
      AppStrings.chatbotLocalFallbackBudget(budget, spent, usedPct, remaining);
  static String get localFallbackNoExpenses =>
      AppStrings.chatbotLocalFallbackNoExpenses;
  static String localFallbackCategoryLine(
    String name,
    String amount,
    String share,
  ) =>
      AppStrings.chatbotLocalFallbackCategoryLine(name, amount, share);
  static String localFallbackExpenses(String total, String lines) =>
      AppStrings.chatbotLocalFallbackExpenses(total, lines);
  static String get localFallbackNoCategoryData =>
      AppStrings.chatbotLocalFallbackNoCategoryData;
  static String localFallbackTopCategory(String name, String amount) =>
      AppStrings.chatbotLocalFallbackTopCategory(name, amount);
  static String get localFallbackGoalsNone => AppStrings.chatbotLocalFallbackGoalsNone;
  static String localFallbackGoalsCount(int count) =>
      AppStrings.chatbotLocalFallbackGoalsCount(count);
  static String get localFallbackOtherCategory =>
      AppStrings.chatbotLocalFallbackOtherCategory;
  static String get screenTitle => AppStrings.chatbotScreenTitle;
  static String get suggestSavingsTitle => AppStrings.chatbotSuggestSavingsTitle;
  static String get suggestSavingsPrompt => AppStrings.chatbotSuggestSavingsPrompt;
  static String get assistantSubtitle => AppStrings.chatbotAssistantSubtitle;
  static String get assistantHeadline => AppStrings.chatbotAssistantHeadline;
  static String get suggestedQuestionsTitle =>
      AppStrings.chatbotSuggestedQuestionsTitle;
  static String get refreshSuggestionsTooltip =>
      AppStrings.chatbotRefreshSuggestionsTooltip;
  static String get inputHint => AppStrings.chatbotInputHint;
  static String get clearChatTitle => AppStrings.chatbotClearChatTitle;
  static String get clearChatMessage => AppStrings.chatbotClearChatMessage;
  static String get clearChatConfirm => AppStrings.chatbotClearChatConfirm;
  static List<String> get defaultSuggestions => AppStrings.chatbotDefaultSuggestions;
  static List<String> get alternateSuggestions =>
      AppStrings.chatbotAlternateSuggestions;
}

/// Backward-compatible alias used across chatbot services and UI.
typedef ChatbotUi = ChatbotCopyHelpers;
