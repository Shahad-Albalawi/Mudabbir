import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @noRouteFound.
  ///
  /// In en, this message translates to:
  /// **'No route found'**
  String get noRouteFound;

  /// No description provided for @onBoardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Mudabbir'**
  String get onBoardingTitle1;

  /// No description provided for @onBoardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Track your budget easily'**
  String get onBoardingTitle2;

  /// No description provided for @onBoardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Your smart assistant for expense management'**
  String get onBoardingTitle3;

  /// No description provided for @onBoardingTitle4.
  ///
  /// In en, this message translates to:
  /// **'Achieve your financial goals'**
  String get onBoardingTitle4;

  /// No description provided for @onBoardingSubTitle1.
  ///
  /// In en, this message translates to:
  /// **'Mudabbir helps you organize spending and savings.'**
  String get onBoardingSubTitle1;

  /// No description provided for @onBoardingSubTitle2.
  ///
  /// In en, this message translates to:
  /// **'Track your income and expenses in one place.'**
  String get onBoardingSubTitle2;

  /// No description provided for @onBoardingSubTitle3.
  ///
  /// In en, this message translates to:
  /// **'Use the smart assistant for personalized financial tips.'**
  String get onBoardingSubTitle3;

  /// No description provided for @onBoardingSubTitle4.
  ///
  /// In en, this message translates to:
  /// **'Start today for better financial stability.'**
  String get onBoardingSubTitle4;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @themePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get themePickerTitle;

  /// No description provided for @languagePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languagePickerTitle;

  /// No description provided for @authShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get sendMessage;

  /// No description provided for @chatUserMessage.
  ///
  /// In en, this message translates to:
  /// **'You said'**
  String get chatUserMessage;

  /// No description provided for @chatAssistantMessage.
  ///
  /// In en, this message translates to:
  /// **'Assistant said'**
  String get chatAssistantMessage;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Mudabbir'**
  String get title;

  /// No description provided for @yourStat.
  ///
  /// In en, this message translates to:
  /// **'Your insights'**
  String get yourStat;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// No description provided for @totalExpense.
  ///
  /// In en, this message translates to:
  /// **'Total Expense'**
  String get totalExpense;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Savings'**
  String get currentBalance;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @addIncome.
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get addIncome;

  /// No description provided for @addChallenge.
  ///
  /// In en, this message translates to:
  /// **'Add Challenge'**
  String get addChallenge;

  /// No description provided for @statisticsString.
  ///
  /// In en, this message translates to:
  /// **'Tap here to view your analytics and statistics'**
  String get statisticsString;

  /// No description provided for @homeText1.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Mudabbir'**
  String get homeText1;

  /// No description provided for @homeText2.
  ///
  /// In en, this message translates to:
  /// **'Start your journey toward better money management'**
  String get homeText2;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get navStatistics;

  /// No description provided for @navGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get navGoals;

  /// No description provided for @navBudget.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get navBudget;

  /// No description provided for @inviteFriend.
  ///
  /// In en, this message translates to:
  /// **'Invite a friend'**
  String get inviteFriend;

  /// No description provided for @loginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginWelcome;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @createOne.
  ///
  /// In en, this message translates to:
  /// **'Create one'**
  String get createOne;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your details to get started'**
  String get registerSubtitle;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstNameLabel;

  /// No description provided for @firstNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get firstNameHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get confirmPasswordHint;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @signInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInLink;

  /// No description provided for @validationEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get validationPasswordMinLength;

  /// No description provided for @validationFirstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get validationFirstNameRequired;

  /// No description provided for @validationPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationPasswordMismatch;

  /// No description provided for @goalsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No financial goals yet'**
  String get goalsEmptyTitle;

  /// No description provided for @goalsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start by adding a new goal'**
  String get goalsEmptySubtitle;

  /// No description provided for @addNewGoal.
  ///
  /// In en, this message translates to:
  /// **'Add New Goal'**
  String get addNewGoal;

  /// No description provided for @tapToAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap to add'**
  String get tapToAdd;

  /// No description provided for @fromAmount.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get fromAmount;

  /// No description provided for @noBudgetsYet.
  ///
  /// In en, this message translates to:
  /// **'No budgets yet. Start managing your spending.'**
  String get noBudgetsYet;

  /// No description provided for @addNewBudget.
  ///
  /// In en, this message translates to:
  /// **'Add a new budget'**
  String get addNewBudget;

  /// No description provided for @addBudgetButton.
  ///
  /// In en, this message translates to:
  /// **'Add a New Budget'**
  String get addBudgetButton;

  /// No description provided for @financialStatus.
  ///
  /// In en, this message translates to:
  /// **'Financial Status'**
  String get financialStatus;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get allTime;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @currentMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Current month'**
  String get currentMonthLabel;

  /// No description provided for @financialHealth.
  ///
  /// In en, this message translates to:
  /// **'Financial health'**
  String get financialHealth;

  /// No description provided for @nextMonthBudgetSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Next month budget suggestion'**
  String get nextMonthBudgetSuggestion;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @budgetDeleted.
  ///
  /// In en, this message translates to:
  /// **'Budget deleted successfully'**
  String get budgetDeleted;

  /// No description provided for @chatbotTitle.
  ///
  /// In en, this message translates to:
  /// **'Mudabbir Assistant'**
  String get chatbotTitle;

  /// No description provided for @clearChat.
  ///
  /// In en, this message translates to:
  /// **'Clear chat'**
  String get clearChat;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @typing.
  ///
  /// In en, this message translates to:
  /// **'Typing'**
  String get typing;

  /// No description provided for @chatHint.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get chatHint;

  /// No description provided for @emptyChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Mudabbir Assistant'**
  String get emptyChatTitle;

  /// No description provided for @emptyChatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your smart finance assistant'**
  String get emptyChatSubtitle;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Smart personal finance'**
  String get splashTagline;

  /// No description provided for @chatWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'m Mudabbir, your smart money assistant. How can I help you today?'**
  String get chatWelcomeMessage;

  /// No description provided for @txLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get txLoadError;

  /// No description provided for @txSectionAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get txSectionAmount;

  /// No description provided for @txSectionDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get txSectionDate;

  /// No description provided for @txSectionDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get txSectionDetails;

  /// No description provided for @txSectionNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get txSectionNotes;

  /// No description provided for @txAvailableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available balance'**
  String get txAvailableBalance;

  /// No description provided for @txCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get txCancel;

  /// No description provided for @txSaveIncome.
  ///
  /// In en, this message translates to:
  /// **'Save income'**
  String get txSaveIncome;

  /// No description provided for @txSaveExpense.
  ///
  /// In en, this message translates to:
  /// **'Save expense'**
  String get txSaveExpense;

  /// No description provided for @txNoAccounts.
  ///
  /// In en, this message translates to:
  /// **'No accounts found.'**
  String get txNoAccounts;

  /// No description provided for @txInsufficientTitle.
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance'**
  String get txInsufficientTitle;

  /// No description provided for @txInsufficientBody.
  ///
  /// In en, this message translates to:
  /// **'The amount exceeds your available balance.'**
  String get txInsufficientBody;

  /// No description provided for @txAvailableBalanceShort.
  ///
  /// In en, this message translates to:
  /// **'Available:'**
  String get txAvailableBalanceShort;

  /// No description provided for @txInsufficientHint.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount less than or equal to your available balance.'**
  String get txInsufficientHint;

  /// No description provided for @txOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get txOk;

  /// No description provided for @labelAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get labelAccount;

  /// No description provided for @labelCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get labelCategory;

  /// No description provided for @fieldAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get fieldAmount;

  /// No description provided for @fieldAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get fieldAmountRequired;

  /// No description provided for @fieldAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get fieldAmountInvalid;

  /// No description provided for @fieldAmountPositive.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than 0'**
  String get fieldAmountPositive;

  /// No description provided for @fieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get fieldNotes;

  /// No description provided for @fieldNotesTooLong.
  ///
  /// In en, this message translates to:
  /// **'Notes cannot exceed 500 characters'**
  String get fieldNotesTooLong;

  /// No description provided for @fieldDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get fieldDate;

  /// No description provided for @budgetExceeded.
  ///
  /// In en, this message translates to:
  /// **'This would exceed your budget limit'**
  String get budgetExceeded;

  /// No description provided for @milestone25Title.
  ///
  /// In en, this message translates to:
  /// **'Great start! 🎯'**
  String get milestone25Title;

  /// No description provided for @milestone25Body.
  ///
  /// In en, this message translates to:
  /// **'You reached 25% of your goal'**
  String get milestone25Body;

  /// No description provided for @milestone50Title.
  ///
  /// In en, this message translates to:
  /// **'Halfway there! 🔥'**
  String get milestone50Title;

  /// No description provided for @milestone50Body.
  ///
  /// In en, this message translates to:
  /// **'You reached 50% of your goal'**
  String get milestone50Body;

  /// No description provided for @milestone75Title.
  ///
  /// In en, this message translates to:
  /// **'Almost there! ⚡'**
  String get milestone75Title;

  /// No description provided for @milestone75Body.
  ///
  /// In en, this message translates to:
  /// **'You reached 75% of your goal'**
  String get milestone75Body;

  /// No description provided for @milestone100Title.
  ///
  /// In en, this message translates to:
  /// **'Goal achieved! 🏆'**
  String get milestone100Title;

  /// No description provided for @milestone100Body.
  ///
  /// In en, this message translates to:
  /// **'You completed your goal successfully'**
  String get milestone100Body;

  /// No description provided for @milestoneAwesome.
  ///
  /// In en, this message translates to:
  /// **'Awesome!'**
  String get milestoneAwesome;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Financial statistics'**
  String get statsTitle;

  /// No description provided for @statsIncomeExpense.
  ///
  /// In en, this message translates to:
  /// **'Income, expenses & balance'**
  String get statsIncomeExpense;

  /// No description provided for @statsExpenseByCategory.
  ///
  /// In en, this message translates to:
  /// **'Spending by category'**
  String get statsExpenseByCategory;

  /// No description provided for @statsIncomeByCategory.
  ///
  /// In en, this message translates to:
  /// **'Income by category'**
  String get statsIncomeByCategory;

  /// No description provided for @statsGoalsProgress.
  ///
  /// In en, this message translates to:
  /// **'Goals progress'**
  String get statsGoalsProgress;

  /// No description provided for @statsBudgetsProgress.
  ///
  /// In en, this message translates to:
  /// **'Budgets progress'**
  String get statsBudgetsProgress;

  /// No description provided for @statsAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Financial analysis'**
  String get statsAnalysisTitle;

  /// No description provided for @statsAnalysisSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Smart insights and monthly comparisons'**
  String get statsAnalysisSubtitle;

  /// No description provided for @snackSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get snackSuccessTitle;

  /// No description provided for @snackErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get snackErrorTitle;

  /// No description provided for @snackWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get snackWarningTitle;

  /// No description provided for @snackInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get snackInfoTitle;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @goalsAddAmountTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to goal'**
  String get goalsAddAmountTitle;

  /// No description provided for @goalsAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount to add'**
  String get goalsAmountLabel;

  /// No description provided for @goalsAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get goalsAmountHint;

  /// No description provided for @goalsAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get goalsAddButton;

  /// No description provided for @goalsInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get goalsInvalidAmount;

  /// No description provided for @goalsDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Goal deleted successfully'**
  String get goalsDeletedSuccess;

  /// No description provided for @challengesUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update challenge status'**
  String get challengesUpdateTitle;

  /// No description provided for @challengesUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get challengesUpdateButton;

  /// No description provided for @challengesUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Challenge status updated'**
  String get challengesUpdatedSuccess;

  /// No description provided for @challengesDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Challenge deleted successfully'**
  String get challengesDeletedSuccess;

  /// No description provided for @challengesStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get challengesStartLabel;

  /// No description provided for @challengesEndLabel.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get challengesEndLabel;

  /// No description provided for @challengesAddNewButton.
  ///
  /// In en, this message translates to:
  /// **'Add new challenge'**
  String get challengesAddNewButton;

  /// No description provided for @chartNoData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get chartNoData;

  /// No description provided for @loginSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Signed in successfully'**
  String get loginSuccessBody;

  /// No description provided for @loginSessionError.
  ///
  /// In en, this message translates to:
  /// **'Could not create a session. Please try again.'**
  String get loginSessionError;

  /// No description provided for @loginGenericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while signing in. Try again.'**
  String get loginGenericError;

  /// No description provided for @registerSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get registerSuccessBody;

  /// No description provided for @registerGenericError.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Try again.'**
  String get registerGenericError;

  /// No description provided for @registerCatchError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong during registration. Try again.'**
  String get registerCatchError;

  /// No description provided for @analysisBalanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Balance status'**
  String get analysisBalanceTitle;

  /// No description provided for @analysisSpendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending analysis'**
  String get analysisSpendingTitle;

  /// No description provided for @analysisSavingsBehaviorTitle.
  ///
  /// In en, this message translates to:
  /// **'Savings behavior'**
  String get analysisSavingsBehaviorTitle;

  /// No description provided for @analysisHealthScoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Financial health score'**
  String get analysisHealthScoreTitle;

  /// No description provided for @analysisSavingsRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Savings rate:'**
  String get analysisSavingsRateLabel;

  /// No description provided for @analysisCategoryInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Category spending insights'**
  String get analysisCategoryInsightsTitle;

  /// No description provided for @analysisRecommendationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal recommendations'**
  String get analysisRecommendationsTitle;

  /// No description provided for @analysisBalanceCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical: You are in debt. Spending exceeds income by {amount}. Take action now.'**
  String analysisBalanceCritical(Object amount);

  /// No description provided for @analysisBalanceZero.
  ///
  /// In en, this message translates to:
  /// **'Warning: You break even with no savings buffer. Unexpected expenses are risky.'**
  String get analysisBalanceZero;

  /// No description provided for @analysisBalanceLow.
  ///
  /// In en, this message translates to:
  /// **'Alert: Low balance ({amount}). Build an emergency fund.'**
  String analysisBalanceLow(Object amount);

  /// No description provided for @analysisBalanceFair.
  ///
  /// In en, this message translates to:
  /// **'Fair: You have some savings ({amount}), but room to improve.'**
  String analysisBalanceFair(Object amount);

  /// No description provided for @analysisBalanceGreat.
  ///
  /// In en, this message translates to:
  /// **'Great: Healthy balance of {amount}. Keep it up!'**
  String analysisBalanceGreat(Object amount);

  /// No description provided for @analysisSpendingCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical: You spend {ratio}% of income — living beyond your means.'**
  String analysisSpendingCritical(Object ratio);

  /// No description provided for @analysisSpendingWarning90.
  ///
  /// In en, this message translates to:
  /// **'Warning: {ratio}% of income goes to expenses. Very little margin.'**
  String analysisSpendingWarning90(Object ratio);

  /// No description provided for @analysisSpendingAlert80.
  ///
  /// In en, this message translates to:
  /// **'Alert: {ratio}% of income. Consider cutting non-essentials.'**
  String analysisSpendingAlert80(Object ratio);

  /// No description provided for @analysisSpendingFair70.
  ///
  /// In en, this message translates to:
  /// **'Fair: {ratio}% of income. Acceptable but improvable.'**
  String analysisSpendingFair70(Object ratio);

  /// No description provided for @analysisSpendingGood50.
  ///
  /// In en, this message translates to:
  /// **'Good: {ratio}% of income. Healthy balance.'**
  String analysisSpendingGood50(Object ratio);

  /// No description provided for @analysisSpendingExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent: Only {ratio}% of income spent. Very disciplined!'**
  String analysisSpendingExcellent(Object ratio);

  /// No description provided for @analysisSavingsCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical: Negative savings ({rate}%). You spend more than you earn.'**
  String analysisSavingsCritical(Object rate);

  /// No description provided for @analysisSavingsWeak5.
  ///
  /// In en, this message translates to:
  /// **'Weak: {rate}% saved. Aim for at least 10–20%.'**
  String analysisSavingsWeak5(Object rate);

  /// No description provided for @analysisSavingsFair10.
  ///
  /// In en, this message translates to:
  /// **'Fair: {rate}% saved. Try to reach 10–20%.'**
  String analysisSavingsFair10(Object rate);

  /// No description provided for @analysisSavingsGood20.
  ///
  /// In en, this message translates to:
  /// **'Good: {rate}% saved. On the right track toward 20%.'**
  String analysisSavingsGood20(Object rate);

  /// No description provided for @analysisSavingsExcellent30.
  ///
  /// In en, this message translates to:
  /// **'Excellent: {rate}% saved. Great discipline!'**
  String analysisSavingsExcellent30(Object rate);

  /// No description provided for @analysisSavingsOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding: {rate}% saved. You are a savings champion!'**
  String analysisSavingsOutstanding(Object rate);

  /// No description provided for @analysisCategoryDominant40.
  ///
  /// In en, this message translates to:
  /// **'Alert: {percent}% — this category dominates spending. Consider alternatives or a budget.'**
  String analysisCategoryDominant40(Object percent);

  /// No description provided for @analysisCategoryHigh30.
  ///
  /// In en, this message translates to:
  /// **'High: {percent}% — a large share. Monitor closely.'**
  String analysisCategoryHigh30(Object percent);

  /// No description provided for @analysisCategoryMedium20.
  ///
  /// In en, this message translates to:
  /// **'Medium: {percent}% — reasonable level.'**
  String analysisCategoryMedium20(Object percent);

  /// No description provided for @analysisCategoryLow10.
  ///
  /// In en, this message translates to:
  /// **'Low: {percent}% — well controlled.'**
  String analysisCategoryLow10(Object percent);

  /// No description provided for @analysisCategoryVeryLow.
  ///
  /// In en, this message translates to:
  /// **'Very low: {percent}% — very disciplined here.'**
  String analysisCategoryVeryLow(Object percent);

  /// No description provided for @analysisHealthExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get analysisHealthExcellent;

  /// No description provided for @analysisHealthGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get analysisHealthGood;

  /// No description provided for @analysisHealthFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get analysisHealthFair;

  /// No description provided for @analysisHealthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get analysisHealthWeak;

  /// No description provided for @analysisHealthCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get analysisHealthCritical;

  /// No description provided for @analysisRecUrgentNegativeSavings.
  ///
  /// In en, this message translates to:
  /// **'🚨 Urgent: Build an emergency budget. Cut all non-essential spending now.'**
  String get analysisRecUrgentNegativeSavings;

  /// No description provided for @analysisRecExtraIncome.
  ///
  /// In en, this message translates to:
  /// **'💡 Consider extra income sources to cover the gap.'**
  String get analysisRecExtraIncome;

  /// No description provided for @analysisRecIncreaseSavings.
  ///
  /// In en, this message translates to:
  /// **'📊 Increase savings by trimming discretionary spending.'**
  String get analysisRecIncreaseSavings;

  /// No description provided for @analysisRecAim1020.
  ///
  /// In en, this message translates to:
  /// **'💰 Aim to save at least 10–20% of income.'**
  String get analysisRecAim1020;

  /// No description provided for @analysisRecPushTo20.
  ///
  /// In en, this message translates to:
  /// **'✨ You save well! Try pushing toward 20% for optimal financial health.'**
  String get analysisRecPushTo20;

  /// No description provided for @analysisRecDebtPayoff.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Make a debt payoff plan. Clear debt before other money goals.'**
  String get analysisRecDebtPayoff;

  /// No description provided for @analysisRecEmergencyFund.
  ///
  /// In en, this message translates to:
  /// **'🎯 Build an emergency fund covering 3–6 months of expenses.'**
  String get analysisRecEmergencyFund;

  /// No description provided for @analysisRecReviewCategories.
  ///
  /// In en, this message translates to:
  /// **'📉 Review spending in: {categories}. Set category budgets.'**
  String analysisRecReviewCategories(Object categories);

  /// No description provided for @analysisRecDiversifyIncome.
  ///
  /// In en, this message translates to:
  /// **'💼 Diversify income sources for more stability.'**
  String get analysisRecDiversifyIncome;

  /// No description provided for @analysisRecSetGoals.
  ///
  /// In en, this message translates to:
  /// **'🎯 Set financial goals to stay motivated and track progress.'**
  String get analysisRecSetGoals;

  /// No description provided for @analysisRecIncreaseContributions.
  ///
  /// In en, this message translates to:
  /// **'📈 Increase contributions toward: {goals}.'**
  String analysisRecIncreaseContributions(Object goals);

  /// No description provided for @analysisRecCreateBudgets.
  ///
  /// In en, this message translates to:
  /// **'📝 Create budgets per category to control spending better.'**
  String get analysisRecCreateBudgets;

  /// No description provided for @analysisRecGreatJob.
  ///
  /// In en, this message translates to:
  /// **'🌟 Great job managing your money. Keep it up!'**
  String get analysisRecGreatJob;

  /// No description provided for @analysisRecKeepTracking.
  ///
  /// In en, this message translates to:
  /// **'💡 Keep tracking expenses and stick to your savings plan.'**
  String get analysisRecKeepTracking;

  /// No description provided for @analysisRecReadInvesting.
  ///
  /// In en, this message translates to:
  /// **'📚 Read about investing strategies to grow wealth further.'**
  String get analysisRecReadInvesting;

  /// No description provided for @themeModeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get themeModeTooltip;

  /// No description provided for @languageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTooltip;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @languageArabicOption.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabicOption;

  /// No description provided for @languageEnglishOption.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglishOption;

  /// No description provided for @txSuccessIncome.
  ///
  /// In en, this message translates to:
  /// **'Income added successfully! 🎉'**
  String get txSuccessIncome;

  /// No description provided for @txSuccessExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense added successfully! 🎉'**
  String get txSuccessExpense;

  /// No description provided for @txNoCategories.
  ///
  /// In en, this message translates to:
  /// **'No {type} categories found.'**
  String txNoCategories(String type);

  /// No description provided for @txLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data: {error}'**
  String txLoadFailed(Object error);

  /// No description provided for @goalLine.
  ///
  /// In en, this message translates to:
  /// **'Goal: {name}'**
  String goalLine(String name);

  /// No description provided for @challengeLine.
  ///
  /// In en, this message translates to:
  /// **'Challenge: {name}'**
  String challengeLine(String name);

  /// No description provided for @barChartIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get barChartIncome;

  /// No description provided for @barChartExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get barChartExpenses;

  /// No description provided for @barChartBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get barChartBalance;

  /// No description provided for @journeyMotivationComplete.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! 🎉 Goal reached!'**
  String get journeyMotivationComplete;

  /// No description provided for @journeyMotivation75.
  ///
  /// In en, this message translates to:
  /// **'Amazing! 💪 You are so close!'**
  String get journeyMotivation75;

  /// No description provided for @journeyMotivation50.
  ///
  /// In en, this message translates to:
  /// **'Excellent! 🔥 Keep going!'**
  String get journeyMotivation50;

  /// No description provided for @journeyMotivation25.
  ///
  /// In en, this message translates to:
  /// **'Strong start! 🎯 Keep it up!'**
  String get journeyMotivation25;

  /// No description provided for @journeyMotivationStart.
  ///
  /// In en, this message translates to:
  /// **'First step! 🌟 Keep going!'**
  String get journeyMotivationStart;

  /// No description provided for @journeyMotivationZero.
  ///
  /// In en, this message translates to:
  /// **'Start your journey toward the goal! 🚀'**
  String get journeyMotivationZero;

  /// No description provided for @budgetPopupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create budget'**
  String get budgetPopupTitle;

  /// No description provided for @budgetPopupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set spending limits for a period'**
  String get budgetPopupSubtitle;

  /// No description provided for @budgetPopupAmountSection.
  ///
  /// In en, this message translates to:
  /// **'Budget amount'**
  String get budgetPopupAmountSection;

  /// No description provided for @budgetPopupPeriodSection.
  ///
  /// In en, this message translates to:
  /// **'Budget period'**
  String get budgetPopupPeriodSection;

  /// No description provided for @budgetPopupAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get budgetPopupAccountSection;

  /// No description provided for @fieldStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get fieldStartDate;

  /// No description provided for @fieldEndDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get fieldEndDate;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @fieldEndAfterStart.
  ///
  /// In en, this message translates to:
  /// **'Must be after start date'**
  String get fieldEndAfterStart;

  /// No description provided for @fieldSelectAccount.
  ///
  /// In en, this message translates to:
  /// **'Select account'**
  String get fieldSelectAccount;

  /// No description provided for @budgetCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Budget created successfully!'**
  String get budgetCreateSuccess;

  /// No description provided for @budgetCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create budget. Try again.'**
  String get budgetCreateFailed;

  /// No description provided for @budgetNoAccountsHint.
  ///
  /// In en, this message translates to:
  /// **'No accounts found. Add an account first.'**
  String get budgetNoAccountsHint;

  /// No description provided for @budgetDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete budget?'**
  String get budgetDeleteConfirmTitle;

  /// No description provided for @budgetDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This spending limit will be removed permanently.'**
  String get budgetDeleteConfirmBody;

  /// No description provided for @budgetSpentSummary.
  ///
  /// In en, this message translates to:
  /// **'{spent} of {limit} spent'**
  String budgetSpentSummary(String spent, String limit);

  /// No description provided for @budgetOfflineBanner.
  ///
  /// In en, this message translates to:
  /// **'Offline — showing cached budgets. Changes sync when you reconnect.'**
  String get budgetOfflineBanner;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @chatbotFabLabel.
  ///
  /// In en, this message translates to:
  /// **'Open financial assistant'**
  String get chatbotFabLabel;

  /// No description provided for @homeAlertSpendingExceedsIncome.
  ///
  /// In en, this message translates to:
  /// **'This month\'s spending exceeded your income.'**
  String get homeAlertSpendingExceedsIncome;

  /// No description provided for @homeAlertSpendingUp.
  ///
  /// In en, this message translates to:
  /// **'Spending is up {percent}% vs last month.'**
  String homeAlertSpendingUp(String percent);

  /// No description provided for @homePendingSyncBanner.
  ///
  /// In en, this message translates to:
  /// **'{count} changes waiting to sync when you\'re back online.'**
  String homePendingSyncBanner(int count);

  /// No description provided for @statsEmptyBarChart.
  ///
  /// In en, this message translates to:
  /// **'Add income or expenses to see your overview chart.'**
  String get statsEmptyBarChart;

  /// No description provided for @expenseDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete expense?'**
  String get expenseDeleteConfirmTitle;

  /// No description provided for @expenseDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get expenseDeleteConfirmBody;

  /// No description provided for @goalDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete goal?'**
  String get goalDeleteConfirmTitle;

  /// No description provided for @goalDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{goalName}\" permanently?'**
  String goalDeleteConfirmBody(String goalName);

  /// No description provided for @goalPopupCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create goal'**
  String get goalPopupCreateTitle;

  /// No description provided for @goalPopupCreateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set your savings target'**
  String get goalPopupCreateSubtitle;

  /// No description provided for @goalPickImage.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get goalPickImage;

  /// No description provided for @goalNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. New car, Emergency fund'**
  String get goalNameHint;

  /// No description provided for @goalTargetAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get goalTargetAmountLabel;

  /// No description provided for @goalCurrentAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Starting amount (optional)'**
  String get goalCurrentAmountLabel;

  /// No description provided for @goalTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal type'**
  String get goalTypeLabel;

  /// No description provided for @goalPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get goalPeriodLabel;

  /// No description provided for @goalNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get goalNameRequired;

  /// No description provided for @goalTargetRequired.
  ///
  /// In en, this message translates to:
  /// **'Target amount is required'**
  String get goalTargetRequired;

  /// No description provided for @goalTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Select a goal type'**
  String get goalTypeRequired;

  /// No description provided for @goalStartRequired.
  ///
  /// In en, this message translates to:
  /// **'Start date required'**
  String get goalStartRequired;

  /// No description provided for @goalEndRequired.
  ///
  /// In en, this message translates to:
  /// **'Target date required'**
  String get goalEndRequired;

  /// No description provided for @goalEndAfterStart.
  ///
  /// In en, this message translates to:
  /// **'Target date must be after start'**
  String get goalEndAfterStart;

  /// No description provided for @goalCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Goal created successfully!'**
  String get goalCreateSuccess;

  /// No description provided for @goalCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create goal. Try again.'**
  String get goalCreateFailed;

  /// No description provided for @goalEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit goal'**
  String get goalEditTitle;

  /// No description provided for @goalEditSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your savings target'**
  String get goalEditSubtitle;

  /// No description provided for @goalSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get goalSaveChanges;

  /// No description provided for @goalUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Goal updated successfully!'**
  String get goalUpdatedSuccess;

  /// No description provided for @expenseOfflineBanner.
  ///
  /// In en, this message translates to:
  /// **'Offline — showing cached expenses. Changes sync when you reconnect.'**
  String get expenseOfflineBanner;

  /// No description provided for @goalOfflineBanner.
  ///
  /// In en, this message translates to:
  /// **'Offline — showing cached goals. Changes will sync when you reconnect.'**
  String get goalOfflineBanner;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccountSection;

  /// No description provided for @settingsPreferencesSection.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferencesSection;

  /// No description provided for @settingsLegalSection.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get settingsLegalSection;

  /// No description provided for @settingsExportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF report'**
  String get settingsExportPdf;

  /// No description provided for @settingsExportPdfSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report ready to share'**
  String get settingsExportPdfSuccess;

  /// No description provided for @settingsExportPdfFail.
  ///
  /// In en, this message translates to:
  /// **'Could not generate report. Try again.'**
  String get settingsExportPdfFail;

  /// No description provided for @settingsLogoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get settingsLogoutConfirmTitle;

  /// No description provided for @settingsLogoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to access your data.'**
  String get settingsLogoutConfirmMessage;

  /// No description provided for @settingsOpenLabel.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get settingsOpenLabel;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyIntro.
  ///
  /// In en, this message translates to:
  /// **'Mudabbir (مدبر) is a personal finance app. This policy explains what we collect and how we use it.'**
  String get privacyPolicyIntro;

  /// No description provided for @privacyPolicyDataWeCollectTitle.
  ///
  /// In en, this message translates to:
  /// **'Data we collect'**
  String get privacyPolicyDataWeCollectTitle;

  /// No description provided for @privacyPolicyDataWeCollectBody.
  ///
  /// In en, this message translates to:
  /// **'Account email and name, financial records you enter (expenses, budgets, goals), and challenge participation. Data is stored on our server when you are signed in and cached on your device for offline use.'**
  String get privacyPolicyDataWeCollectBody;

  /// No description provided for @privacyPolicyHowWeUseTitle.
  ///
  /// In en, this message translates to:
  /// **'How we use data'**
  String get privacyPolicyHowWeUseTitle;

  /// No description provided for @privacyPolicyHowWeUseBody.
  ///
  /// In en, this message translates to:
  /// **'To sync your records across devices, show insights and statistics, run savings challenges, and power the in-app financial assistant when you ask questions.'**
  String get privacyPolicyHowWeUseBody;

  /// No description provided for @privacyPolicyThirdPartyTitle.
  ///
  /// In en, this message translates to:
  /// **'Third-party services'**
  String get privacyPolicyThirdPartyTitle;

  /// No description provided for @privacyPolicyThirdPartyBody.
  ///
  /// In en, this message translates to:
  /// **'The AI assistant sends your question and a summary of your financial context to our backend, which may call OpenAI or Google Gemini. We do not sell your data.'**
  String get privacyPolicyThirdPartyBody;

  /// No description provided for @privacyPolicySecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get privacyPolicySecurityTitle;

  /// No description provided for @privacyPolicySecurityBody.
  ///
  /// In en, this message translates to:
  /// **'Sign-in uses encrypted tokens stored in secure device storage. You can sign out at any time from Settings.'**
  String get privacyPolicySecurityBody;

  /// No description provided for @privacyPolicyContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get privacyPolicyContactTitle;

  /// No description provided for @privacyPolicyContactBody.
  ///
  /// In en, this message translates to:
  /// **'For privacy questions, contact the app developer through the Play Store listing or your course supervisor.'**
  String get privacyPolicyContactBody;

  /// No description provided for @exportPdfReport.
  ///
  /// In en, this message translates to:
  /// **'Export PDF report'**
  String get exportPdfReport;

  /// No description provided for @navChallenges.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get navChallenges;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @addTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'New transaction'**
  String get addTransactionTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmpty;

  /// No description provided for @homeActiveGoals.
  ///
  /// In en, this message translates to:
  /// **'Active goals'**
  String get homeActiveGoals;

  /// No description provided for @homeViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get homeViewAll;

  /// No description provided for @homeRecentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get homeRecentTransactions;

  /// No description provided for @homeFinancialHealthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View analysis dashboard'**
  String get homeFinancialHealthSubtitle;

  /// No description provided for @healthScoreExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get healthScoreExcellent;

  /// No description provided for @healthScoreGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get healthScoreGood;

  /// No description provided for @healthScoreFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get healthScoreFair;

  /// No description provided for @healthScoreWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get healthScoreWeak;

  /// No description provided for @homeQaExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get homeQaExpense;

  /// No description provided for @homeQaIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get homeQaIncome;

  /// No description provided for @homeQaPdfReport.
  ///
  /// In en, this message translates to:
  /// **'PDF report'**
  String get homeQaPdfReport;

  /// No description provided for @homeQaAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get homeQaAnalysis;

  /// No description provided for @homeBudgetManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get homeBudgetManage;

  /// No description provided for @homeBudgetEmptyCategories.
  ///
  /// In en, this message translates to:
  /// **'No categorized spending this month'**
  String get homeBudgetEmptyCategories;

  /// No description provided for @offlineSavedPendingSync.
  ///
  /// In en, this message translates to:
  /// **'Saved locally. Will sync when online.'**
  String get offlineSavedPendingSync;

  /// No description provided for @budgetLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load budgets.'**
  String get budgetLoadFailed;

  /// No description provided for @budgetSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Budget sync failed.'**
  String get budgetSyncFailed;

  /// No description provided for @budgetCardLabel.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budgetCardLabel;

  /// No description provided for @budgetStatusOverBudget.
  ///
  /// In en, this message translates to:
  /// **'Over budget'**
  String get budgetStatusOverBudget;

  /// No description provided for @budgetStatusNearLimit.
  ///
  /// In en, this message translates to:
  /// **'Near limit'**
  String get budgetStatusNearLimit;

  /// No description provided for @budgetStatusOnTrack.
  ///
  /// In en, this message translates to:
  /// **'On track'**
  String get budgetStatusOnTrack;

  /// No description provided for @budgetRemainingOfPrefix.
  ///
  /// In en, this message translates to:
  /// **'remaining of '**
  String get budgetRemainingOfPrefix;

  /// No description provided for @notificationBudgetWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget almost used'**
  String get notificationBudgetWarningTitle;

  /// No description provided for @notificationBudgetWarningBody.
  ///
  /// In en, this message translates to:
  /// **'You spent {spent} of {limit} ﷼ (80%+).'**
  String notificationBudgetWarningBody(String spent, String limit);

  /// No description provided for @notificationBudgetExceededTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget exceeded'**
  String get notificationBudgetExceededTitle;

  /// No description provided for @notificationBudgetExceededBody.
  ///
  /// In en, this message translates to:
  /// **'Spending {spent} ﷼ exceeds your {limit} ﷼ limit.'**
  String notificationBudgetExceededBody(String spent, String limit);

  /// No description provided for @goalNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal name'**
  String get goalNameLabel;

  /// No description provided for @goalChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get goalChangePhoto;

  /// No description provided for @goalLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load goals.'**
  String get goalLoadFailed;

  /// No description provided for @goalSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Goal sync failed.'**
  String get goalSyncFailed;

  /// No description provided for @goalDeadlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get goalDeadlineLabel;

  /// No description provided for @goalProjectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Expected completion'**
  String get goalProjectedLabel;

  /// No description provided for @goalRemainingLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get goalRemainingLabel;

  /// No description provided for @goalContributeHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to add contribution'**
  String get goalContributeHint;

  /// No description provided for @goalMonthlyNeeded.
  ///
  /// In en, this message translates to:
  /// **'Needed monthly to meet deadline'**
  String get goalMonthlyNeeded;

  /// No description provided for @goalAvgMonthly.
  ///
  /// In en, this message translates to:
  /// **'Your avg. monthly contributions'**
  String get goalAvgMonthly;

  /// No description provided for @goalStatusOnTrack.
  ///
  /// In en, this message translates to:
  /// **'On track'**
  String get goalStatusOnTrack;

  /// No description provided for @goalStatusBehind.
  ///
  /// In en, this message translates to:
  /// **'Behind schedule'**
  String get goalStatusBehind;

  /// No description provided for @goalStatusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Past deadline'**
  String get goalStatusOverdue;

  /// No description provided for @goalStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get goalStatusCompleted;

  /// No description provided for @goalStatusNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get goalStatusNotStarted;

  /// No description provided for @goalTypeSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get goalTypeSaving;

  /// No description provided for @goalTypeInvestment.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get goalTypeInvestment;

  /// No description provided for @goalTypeDebt.
  ///
  /// In en, this message translates to:
  /// **'Debt'**
  String get goalTypeDebt;

  /// No description provided for @goalTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get goalTypeOther;

  /// No description provided for @goalNotEnoughData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data'**
  String get goalNotEnoughData;

  /// No description provided for @goalContributionTitle.
  ///
  /// In en, this message translates to:
  /// **'Add contribution'**
  String get goalContributionTitle;

  /// No description provided for @goalAddContributionButton.
  ///
  /// In en, this message translates to:
  /// **'Add contribution'**
  String get goalAddContributionButton;

  /// No description provided for @goalContributionNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get goalContributionNote;

  /// No description provided for @goalContributionSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Contribution saved!'**
  String get goalContributionSuccessTitle;

  /// No description provided for @goalContributionSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Added {amount} to your goal.'**
  String goalContributionSuccessBody(String amount);

  /// No description provided for @goalContributionSnackbarAction.
  ///
  /// In en, this message translates to:
  /// **'Keep going!'**
  String get goalContributionSnackbarAction;

  /// No description provided for @goalJourneyMotivationTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap for encouragement'**
  String get goalJourneyMotivationTapHint;

  /// No description provided for @goalUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update goal'**
  String get goalUpdateFailed;

  /// No description provided for @goalCompletedAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal reached!'**
  String get goalCompletedAlertTitle;

  /// No description provided for @goalCompletedAlertBody.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You completed \"{name}\".'**
  String goalCompletedAlertBody(String name);

  /// No description provided for @goalContributeButtonShort.
  ///
  /// In en, this message translates to:
  /// **'Contribute'**
  String get goalContributeButtonShort;

  /// No description provided for @goalDetailsButton.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get goalDetailsButton;

  /// No description provided for @goalOfPrefix.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get goalOfPrefix;

  /// No description provided for @goalLeftLabel.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get goalLeftLabel;

  /// No description provided for @expensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesTitle;

  /// No description provided for @expensesAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get expensesAddButton;

  /// No description provided for @expensesEditButton.
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get expensesEditButton;

  /// No description provided for @expensesSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get expensesSaveButton;

  /// No description provided for @expensesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get expensesEmptyTitle;

  /// No description provided for @expensesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first expense to start tracking spending.'**
  String get expensesEmptySubtitle;

  /// No description provided for @expensesFilterMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get expensesFilterMonth;

  /// No description provided for @expensesFilterCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get expensesFilterCategory;

  /// No description provided for @expensesFilterType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get expensesFilterType;

  /// No description provided for @expensesFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get expensesFilterAll;

  /// No description provided for @expensesFilterRecurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring only'**
  String get expensesFilterRecurring;

  /// No description provided for @expensesRecurringMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly recurring'**
  String get expensesRecurringMonthly;

  /// No description provided for @expensesAmountTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Amount is too large.'**
  String get expensesAmountTooLarge;

  /// No description provided for @expensesDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Date is required.'**
  String get expensesDateRequired;

  /// No description provided for @expensesDateInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid date.'**
  String get expensesDateInvalid;

  /// No description provided for @expensesDateCannotBeFuture.
  ///
  /// In en, this message translates to:
  /// **'Date cannot be in the future.'**
  String get expensesDateCannotBeFuture;

  /// No description provided for @expensesAccountRequired.
  ///
  /// In en, this message translates to:
  /// **'Select an account.'**
  String get expensesAccountRequired;

  /// No description provided for @expensesCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Select a category.'**
  String get expensesCategoryRequired;

  /// No description provided for @expensesTextTooLong.
  ///
  /// In en, this message translates to:
  /// **'Text is too long (max 255 characters).'**
  String get expensesTextTooLong;

  /// No description provided for @expensesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load expenses.'**
  String get expensesLoadFailed;

  /// No description provided for @expensesSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Expense sync failed.'**
  String get expensesSyncFailed;

  /// No description provided for @expensesSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save expense.'**
  String get expensesSaveFailed;

  /// No description provided for @expensesUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update expense.'**
  String get expensesUpdateFailed;

  /// No description provided for @expensesDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete expense.'**
  String get expensesDeleteFailed;

  /// No description provided for @expensesSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Expense saved.'**
  String get expensesSavedSuccess;

  /// No description provided for @expensesUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Expense updated.'**
  String get expensesUpdatedSuccess;

  /// No description provided for @expensesDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted.'**
  String get expensesDeletedSuccess;

  /// No description provided for @expensesBudgetExceeded.
  ///
  /// In en, this message translates to:
  /// **'This expense exceeds the remaining budget ({remaining}).'**
  String expensesBudgetExceeded(String remaining);

  /// No description provided for @expensesBudgetLinked.
  ///
  /// In en, this message translates to:
  /// **'Budget link: spent {spent} / {budget} — remaining {remaining}.'**
  String expensesBudgetLinked(String spent, String budget, String remaining);

  /// No description provided for @expensesViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all expenses'**
  String get expensesViewAll;

  /// No description provided for @expensesTotalFiltered.
  ///
  /// In en, this message translates to:
  /// **'Filtered total'**
  String get expensesTotalFiltered;

  /// No description provided for @expensesRecurringBadge.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get expensesRecurringBadge;

  /// No description provided for @statsScreenLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load statistics. Pull to refresh or tap retry.'**
  String get statsScreenLoadFailed;

  /// No description provided for @statsAnalysisLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not build your financial analysis.'**
  String get statsAnalysisLoadFailed;

  /// No description provided for @statsHomeLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load your financial summary.'**
  String get statsHomeLoadFailed;

  /// No description provided for @statsScreenEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No financial data yet'**
  String get statsScreenEmptyTitle;

  /// No description provided for @statsScreenEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add income or expenses to see statistics and insights.'**
  String get statsScreenEmptySubtitle;

  /// No description provided for @statsSpendingTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending trend'**
  String get statsSpendingTrendTitle;

  /// No description provided for @statsCategoryBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending by category'**
  String get statsCategoryBreakdownTitle;

  /// No description provided for @statsQuickInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick insights'**
  String get statsQuickInsightsTitle;

  /// No description provided for @statsTotalExpenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Total spending'**
  String get statsTotalExpenseLabel;

  /// No description provided for @statsTotalIncomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Total income'**
  String get statsTotalIncomeLabel;

  /// No description provided for @statsNetSavingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Net savings'**
  String get statsNetSavingsLabel;

  /// No description provided for @statsSavingsRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Savings rate'**
  String get statsSavingsRateLabel;

  /// No description provided for @statsDailyAverageLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily average'**
  String get statsDailyAverageLabel;

  /// No description provided for @statsHighestExpenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Highest expense'**
  String get statsHighestExpenseLabel;

  /// No description provided for @statsTransactionCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get statsTransactionCountLabel;

  /// No description provided for @statsChartTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get statsChartTotalLabel;

  /// No description provided for @statsNoDataForPeriod.
  ///
  /// In en, this message translates to:
  /// **'No data for this period'**
  String get statsNoDataForPeriod;

  /// No description provided for @statsNoCategoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get statsNoCategoriesYet;

  /// No description provided for @statsTopCategoryInsight.
  ///
  /// In en, this message translates to:
  /// **'{name} accounts for {percent}% of your spending.'**
  String statsTopCategoryInsight(String name, String percent);

  /// No description provided for @statsSpendingUpInsight.
  ///
  /// In en, this message translates to:
  /// **'Spending is up {percent}% vs the previous period.'**
  String statsSpendingUpInsight(String percent);

  /// No description provided for @statsSpendingDownInsight.
  ///
  /// In en, this message translates to:
  /// **'Spending is down {percent}% vs the previous period.'**
  String statsSpendingDownInsight(String percent);

  /// No description provided for @statsSteadySpendingInsight.
  ///
  /// In en, this message translates to:
  /// **'Spending is steady compared to the previous period.'**
  String get statsSteadySpendingInsight;

  /// No description provided for @statsPeriodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get statsPeriodWeek;

  /// No description provided for @statsPeriodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get statsPeriodMonth;

  /// No description provided for @statsPeriodQuarter.
  ///
  /// In en, this message translates to:
  /// **'3 mo'**
  String get statsPeriodQuarter;

  /// No description provided for @statsPeriodYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get statsPeriodYear;

  /// No description provided for @statsChartWeekday0.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get statsChartWeekday0;

  /// No description provided for @statsChartWeekday1.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get statsChartWeekday1;

  /// No description provided for @statsChartWeekday2.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get statsChartWeekday2;

  /// No description provided for @statsChartWeekday3.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get statsChartWeekday3;

  /// No description provided for @statsChartWeekday4.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get statsChartWeekday4;

  /// No description provided for @statsChartWeekday5.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get statsChartWeekday5;

  /// No description provided for @statsChartWeekday6.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get statsChartWeekday6;

  /// No description provided for @statsChartMonth0.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get statsChartMonth0;

  /// No description provided for @statsChartMonth1.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get statsChartMonth1;

  /// No description provided for @statsChartMonth2.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get statsChartMonth2;

  /// No description provided for @statsChartMonth3.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get statsChartMonth3;

  /// No description provided for @statsChartMonth4.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get statsChartMonth4;

  /// No description provided for @statsChartMonth5.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get statsChartMonth5;

  /// No description provided for @statsChartMonth6.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get statsChartMonth6;

  /// No description provided for @statsChartMonth7.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get statsChartMonth7;

  /// No description provided for @statsChartMonth8.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get statsChartMonth8;

  /// No description provided for @statsChartMonth9.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get statsChartMonth9;

  /// No description provided for @statsChartMonth10.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get statsChartMonth10;

  /// No description provided for @statsChartMonth11.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get statsChartMonth11;

  /// No description provided for @txSheetCatShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get txSheetCatShopping;

  /// No description provided for @txSheetCatTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get txSheetCatTransport;

  /// No description provided for @txSheetCatRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get txSheetCatRestaurants;

  /// No description provided for @txSheetCatHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get txSheetCatHealth;

  /// No description provided for @txSheetCatEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get txSheetCatEntertainment;

  /// No description provided for @txSheetCatHousing.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get txSheetCatHousing;

  /// No description provided for @txSheetCatSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get txSheetCatSalary;

  /// No description provided for @txSheetCatOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get txSheetCatOther;

  /// No description provided for @entityCatSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get entityCatSalary;

  /// No description provided for @entityCatBonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get entityCatBonus;

  /// No description provided for @entityCatGift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get entityCatGift;

  /// No description provided for @entityCatOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get entityCatOther;

  /// No description provided for @entityCatFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get entityCatFood;

  /// No description provided for @entityCatTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get entityCatTransport;

  /// No description provided for @entityCatShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get entityCatShopping;

  /// No description provided for @entityCatBills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get entityCatBills;

  /// No description provided for @entityCatHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get entityCatHealth;

  /// No description provided for @entityCatEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get entityCatEntertainment;

  /// No description provided for @entityAccountCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get entityAccountCash;

  /// No description provided for @entityAccountBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get entityAccountBank;

  /// No description provided for @homeGreetingHello.
  ///
  /// In en, this message translates to:
  /// **'Hello 👋'**
  String get homeGreetingHello;

  /// No description provided for @homeGreetingNamed.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name} 👋'**
  String homeGreetingNamed(Object name);

  /// No description provided for @homeMonthlyReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly report'**
  String get homeMonthlyReportTitle;

  /// No description provided for @goalDeadlinePassed.
  ///
  /// In en, this message translates to:
  /// **'Deadline passed'**
  String get goalDeadlinePassed;

  /// No description provided for @goalDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String goalDaysLeft(Object days);

  /// No description provided for @goalMilestoneComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get goalMilestoneComplete;

  /// No description provided for @goalMotivationBannerStart.
  ///
  /// In en, this message translates to:
  /// **'Start your journey! Every riyal brings you closer'**
  String get goalMotivationBannerStart;

  /// No description provided for @goalMotivationBannerEarly.
  ///
  /// In en, this message translates to:
  /// **'{percent}% — great first step! Keep going'**
  String goalMotivationBannerEarly(Object percent);

  /// No description provided for @goalMotivationBannerHalf.
  ///
  /// In en, this message translates to:
  /// **'Halfway there! You are ahead of most savers'**
  String get goalMotivationBannerHalf;

  /// No description provided for @goalMotivationBannerNear.
  ///
  /// In en, this message translates to:
  /// **'So close! The finish line is within reach'**
  String get goalMotivationBannerNear;

  /// No description provided for @goalMotivationBannerDone.
  ///
  /// In en, this message translates to:
  /// **'Well done! You reached your goal'**
  String get goalMotivationBannerDone;

  /// No description provided for @behavioralScoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Financial analysis'**
  String get behavioralScoreTitle;

  /// No description provided for @behavioralScoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick snapshot of your spending health this month'**
  String get behavioralScoreSubtitle;

  /// No description provided for @behavioralViewDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Detailed analysis'**
  String get behavioralViewDetailsLabel;

  /// No description provided for @behavioralViewDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Comparisons, patterns & tips'**
  String get behavioralViewDetailsHint;

  /// No description provided for @behavioralMonthComparisonTitle.
  ///
  /// In en, this message translates to:
  /// **'Month-over-month comparison'**
  String get behavioralMonthComparisonTitle;

  /// No description provided for @behavioralAnomaliesTitle.
  ///
  /// In en, this message translates to:
  /// **'Unusual spending patterns'**
  String get behavioralAnomaliesTitle;

  /// No description provided for @behavioralNoAnomalies.
  ///
  /// In en, this message translates to:
  /// **'No unusual patterns detected this month. Keep it up!'**
  String get behavioralNoAnomalies;

  /// No description provided for @behavioralWeekdayPatternTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending by day'**
  String get behavioralWeekdayPatternTitle;

  /// No description provided for @behavioralPersonalizedRecsTitle.
  ///
  /// In en, this message translates to:
  /// **'Personalized tips'**
  String get behavioralPersonalizedRecsTitle;

  /// No description provided for @behavioralPreviousMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get behavioralPreviousMonthLabel;

  /// No description provided for @behavioralTrailingAvgLabel.
  ///
  /// In en, this message translates to:
  /// **'3-month avg'**
  String get behavioralTrailingAvgLabel;

  /// No description provided for @behavioralNoWeekdayData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data to analyze daily patterns yet.'**
  String get behavioralNoWeekdayData;

  /// No description provided for @behavioralRatingExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get behavioralRatingExcellent;

  /// No description provided for @behavioralRatingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get behavioralRatingGood;

  /// No description provided for @behavioralRatingFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get behavioralRatingFair;

  /// No description provided for @behavioralRatingNeedsWork.
  ///
  /// In en, this message translates to:
  /// **'Needs work'**
  String get behavioralRatingNeedsWork;

  /// No description provided for @behavioralRatingAtRisk.
  ///
  /// In en, this message translates to:
  /// **'At risk'**
  String get behavioralRatingAtRisk;

  /// No description provided for @behavioralMonthlySpikeTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly spending spike'**
  String get behavioralMonthlySpikeTitle;

  /// No description provided for @behavioralOverspendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending exceeds income'**
  String get behavioralOverspendingTitle;

  /// No description provided for @behavioralCategorySpikeTitle.
  ///
  /// In en, this message translates to:
  /// **'Category surge'**
  String get behavioralCategorySpikeTitle;

  /// No description provided for @behavioralLargeTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Large transaction'**
  String get behavioralLargeTransactionTitle;

  /// No description provided for @behavioralWeekendSplurgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekend spending'**
  String get behavioralWeekendSplurgeTitle;

  /// No description provided for @behavioralSpendingBurstTitle.
  ///
  /// In en, this message translates to:
  /// **'High transaction frequency'**
  String get behavioralSpendingBurstTitle;

  /// No description provided for @behavioralUnusualPatternTitle.
  ///
  /// In en, this message translates to:
  /// **'Unusual pattern'**
  String get behavioralUnusualPatternTitle;

  /// No description provided for @behavioralMonthlySpikeMessage.
  ///
  /// In en, this message translates to:
  /// **'This month is {pct}% above your 3-month average ({amount}).'**
  String behavioralMonthlySpikeMessage(String pct, String amount);

  /// No description provided for @behavioralOverspendingMessage.
  ///
  /// In en, this message translates to:
  /// **'You overspent by {amount} this month.'**
  String behavioralOverspendingMessage(String amount);

  /// No description provided for @behavioralCategorySpikeMessage.
  ///
  /// In en, this message translates to:
  /// **'{category} rose {pct}% vs last month.'**
  String behavioralCategorySpikeMessage(String category, String pct);

  /// No description provided for @behavioralLargeTransactionMessage.
  ///
  /// In en, this message translates to:
  /// **'A single expense of {amount} stands out.'**
  String behavioralLargeTransactionMessage(String amount);

  /// No description provided for @behavioralWeekendSplurgeMessage.
  ///
  /// In en, this message translates to:
  /// **'{pct}% of spending happens on weekends.'**
  String behavioralWeekendSplurgeMessage(String pct);

  /// No description provided for @behavioralSpendingBurstMessage.
  ///
  /// In en, this message translates to:
  /// **'{count} expense transactions this month — review small daily purchases.'**
  String behavioralSpendingBurstMessage(String count);

  /// No description provided for @behavioralReviewPattern.
  ///
  /// In en, this message translates to:
  /// **'Review this pattern.'**
  String get behavioralReviewPattern;

  /// No description provided for @behavioralMonthCompareNoHistory.
  ///
  /// In en, this message translates to:
  /// **'This month: {amount}. Add more history for comparisons.'**
  String behavioralMonthCompareNoHistory(String amount);

  /// No description provided for @behavioralMonthCompareUp.
  ///
  /// In en, this message translates to:
  /// **'You spent {pct}% more than last month ({current} vs {previous}).'**
  String behavioralMonthCompareUp(String pct, String current, String previous);

  /// No description provided for @behavioralMonthCompareDown.
  ///
  /// In en, this message translates to:
  /// **'You spent {pct}% less than last month. Great discipline!'**
  String behavioralMonthCompareDown(String pct);

  /// No description provided for @behavioralMonthCompareStable.
  ///
  /// In en, this message translates to:
  /// **'Spending is stable vs last month ({current} vs {previous}).'**
  String behavioralMonthCompareStable(String current, String previous);

  /// No description provided for @behavioralMonthCompareTrailing.
  ///
  /// In en, this message translates to:
  /// **'This month: {current} vs 3-month avg {avg}.'**
  String behavioralMonthCompareTrailing(String current, String avg);

  /// No description provided for @behavioralWeekdayInsight.
  ///
  /// In en, this message translates to:
  /// **'You spend most on {day} ({amount} this month).'**
  String behavioralWeekdayInsight(String day, String amount);

  /// No description provided for @behavioralRecReduceVsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'📊 Spending rose vs last month — review subscriptions and dining out.'**
  String get behavioralRecReduceVsLastMonth;

  /// No description provided for @behavioralRecKeepDiscipline.
  ///
  /// In en, this message translates to:
  /// **'✨ You are below your 3-month average. Maintain this pace!'**
  String get behavioralRecKeepDiscipline;

  /// No description provided for @behavioralRecIncreaseSavings.
  ///
  /// In en, this message translates to:
  /// **'💰 Try saving at least 10% of income this month.'**
  String get behavioralRecIncreaseSavings;

  /// No description provided for @behavioralRecSetGoals.
  ///
  /// In en, this message translates to:
  /// **'🎯 Set a savings goal to stay motivated.'**
  String get behavioralRecSetGoals;

  /// No description provided for @behavioralRecCreateBudget.
  ///
  /// In en, this message translates to:
  /// **'📝 Add category budgets to control spending.'**
  String get behavioralRecCreateBudget;

  /// No description provided for @behavioralRecGreatScore.
  ///
  /// In en, this message translates to:
  /// **'🌟 Strong financial behavior this month!'**
  String get behavioralRecGreatScore;

  /// No description provided for @behavioralRecDefault.
  ///
  /// In en, this message translates to:
  /// **'💡 Keep logging expenses to sharpen your insights.'**
  String get behavioralRecDefault;

  /// No description provided for @behavioralRecMonthlySpike.
  ///
  /// In en, this message translates to:
  /// **'📉 Set a weekly spending cap to bring this month back in line.'**
  String get behavioralRecMonthlySpike;

  /// No description provided for @behavioralRecOverspending.
  ///
  /// In en, this message translates to:
  /// **'🚨 Pause non-essential purchases until income covers expenses.'**
  String get behavioralRecOverspending;

  /// No description provided for @behavioralRecCategorySpike.
  ///
  /// In en, this message translates to:
  /// **'🎯 Create a category budget for {category}.'**
  String behavioralRecCategorySpike(String category);

  /// No description provided for @behavioralRecLargeTransaction.
  ///
  /// In en, this message translates to:
  /// **'🔍 Confirm large purchases were planned; split future ones if possible.'**
  String get behavioralRecLargeTransaction;

  /// No description provided for @behavioralRecWeekendSplurge.
  ///
  /// In en, this message translates to:
  /// **'📅 Plan weekend activities with a fixed budget beforehand.'**
  String get behavioralRecWeekendSplurge;

  /// No description provided for @behavioralRecSpendingBurst.
  ///
  /// In en, this message translates to:
  /// **'☕ Track small daily expenses — they add up quickly.'**
  String get behavioralRecSpendingBurst;

  /// No description provided for @authAppBrandName.
  ///
  /// In en, this message translates to:
  /// **'Mudabbir'**
  String get authAppBrandName;

  /// No description provided for @authOrDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOrDivider;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authForgotPasswordSoon.
  ///
  /// In en, this message translates to:
  /// **'Password recovery is coming soon'**
  String get authForgotPasswordSoon;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get authLoginTitle;

  /// No description provided for @authLoginTagline.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your money'**
  String get authLoginTagline;

  /// No description provided for @authRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterTagline.
  ///
  /// In en, this message translates to:
  /// **'Start your smart money journey'**
  String get authRegisterTagline;

  /// No description provided for @authSignUpNow.
  ///
  /// In en, this message translates to:
  /// **'Sign up now'**
  String get authSignUpNow;

  /// No description provided for @authRegisterSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authRegisterSubmit;

  /// No description provided for @authFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get authFullNameLabel;

  /// No description provided for @authFullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get authFullNameRequired;

  /// No description provided for @authNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get authNameRequired;

  /// No description provided for @authEmailFormatInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get authEmailFormatInvalid;

  /// No description provided for @authConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get authConfirmPasswordRequired;

  /// No description provided for @authTermsAcceptRequired.
  ///
  /// In en, this message translates to:
  /// **'You must accept the terms and conditions'**
  String get authTermsAcceptRequired;

  /// No description provided for @authTermsCheckboxLabel.
  ///
  /// In en, this message translates to:
  /// **'I agree to the terms of service and privacy policy'**
  String get authTermsCheckboxLabel;

  /// No description provided for @authContinueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get authContinueAsGuest;

  /// No description provided for @authNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection'**
  String get authNetworkError;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password'**
  String get authInvalidCredentials;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsNotificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotificationsLabel;

  /// No description provided for @settingsTermsLink.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get settingsTermsLink;

  /// No description provided for @settingsTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTermsTitle;

  /// No description provided for @settingsEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get settingsEditProfile;

  /// No description provided for @settingsProfileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get settingsProfileNameLabel;

  /// No description provided for @settingsProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get settingsProfileSaved;

  /// No description provided for @settingsVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsVersionLabel(String version);

  /// No description provided for @settingsTermsIntro.
  ///
  /// In en, this message translates to:
  /// **'By using Mudabbir you agree to these terms. The app helps you track personal finances; it does not provide regulated financial advice.'**
  String get settingsTermsIntro;

  /// No description provided for @settingsTermsUseTitle.
  ///
  /// In en, this message translates to:
  /// **'Acceptable use'**
  String get settingsTermsUseTitle;

  /// No description provided for @settingsTermsUseBody.
  ///
  /// In en, this message translates to:
  /// **'Use the app lawfully. Do not attempt to access other users\' data or disrupt the service.'**
  String get settingsTermsUseBody;

  /// No description provided for @settingsTermsDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get settingsTermsDataTitle;

  /// No description provided for @settingsTermsDataBody.
  ///
  /// In en, this message translates to:
  /// **'You own the financial data you enter. Export or delete it by contacting support or removing your account.'**
  String get settingsTermsDataBody;

  /// No description provided for @settingsTermsChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Changes'**
  String get settingsTermsChangesTitle;

  /// No description provided for @settingsTermsChangesBody.
  ///
  /// In en, this message translates to:
  /// **'We may update these terms. Continued use after changes means you accept the updated terms.'**
  String get settingsTermsChangesBody;

  /// No description provided for @chatbotReduceCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'To cut spending in a category, try: \"analyze food category\" or \"how do I reduce transport spending?\".'**
  String get chatbotReduceCategoryHint;

  /// No description provided for @chatbotUndoNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing recent to undo.'**
  String get chatbotUndoNone;

  /// No description provided for @chatbotUndoDone.
  ///
  /// In en, this message translates to:
  /// **'Undone: {summary} ↩️'**
  String chatbotUndoDone(String summary);

  /// No description provided for @chatbotUndoMissing.
  ///
  /// In en, this message translates to:
  /// **'Could not undo — record not found.'**
  String get chatbotUndoMissing;

  /// No description provided for @chatbotUndoError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while undoing.'**
  String get chatbotUndoError;

  /// No description provided for @chatbotWhatIfError.
  ///
  /// In en, this message translates to:
  /// **'Could not run the what-if scenario. Try again.'**
  String get chatbotWhatIfError;

  /// No description provided for @chatbotSubsError.
  ///
  /// In en, this message translates to:
  /// **'Could not analyze subscriptions right now. Try later.'**
  String get chatbotSubsError;

  /// No description provided for @chatbotInsightError.
  ///
  /// In en, this message translates to:
  /// **'Could not compute financial indicators now. Try again shortly.'**
  String get chatbotInsightError;

  /// No description provided for @chatbotGenericProcessError.
  ///
  /// In en, this message translates to:
  /// **'Sorry, something went wrong processing your request. Please try again.'**
  String get chatbotGenericProcessError;

  /// No description provided for @chatbotPendingHint.
  ///
  /// In en, this message translates to:
  /// **'You have a pending action. Type \"confirm\" to run or \"cancel\" to abort.'**
  String get chatbotPendingHint;

  /// No description provided for @chatbotPendingCancelled.
  ///
  /// In en, this message translates to:
  /// **'Pending action cancelled.'**
  String get chatbotPendingCancelled;

  /// No description provided for @chatbotGoalCreatedSummary.
  ///
  /// In en, this message translates to:
  /// **'Create goal {name}'**
  String chatbotGoalCreatedSummary(String name);

  /// No description provided for @chatbotGoalCreatedOk.
  ///
  /// In en, this message translates to:
  /// **'Goal \"{name}\" created successfully.'**
  String chatbotGoalCreatedOk(String name);

  /// No description provided for @chatbotBudgetCreatedSummary.
  ///
  /// In en, this message translates to:
  /// **'Create budget {amount} ﷼'**
  String chatbotBudgetCreatedSummary(String amount);

  /// No description provided for @chatbotBudgetCreatedOk.
  ///
  /// In en, this message translates to:
  /// **'Next month\'s budget created: {amount} ﷼.'**
  String chatbotBudgetCreatedOk(String amount);

  /// No description provided for @chatbotNeedGoalAmount.
  ///
  /// In en, this message translates to:
  /// **'To create a goal I need an amount. Example: create goal car 25000 in 12 months.'**
  String get chatbotNeedGoalAmount;

  /// No description provided for @chatbotNeedBudgetAmount.
  ///
  /// In en, this message translates to:
  /// **'I need a budget amount. Example: create budget 3000 next month.'**
  String get chatbotNeedBudgetAmount;

  /// No description provided for @chatbotNoAccountForBudget.
  ///
  /// In en, this message translates to:
  /// **'No account available to attach this budget.'**
  String get chatbotNoAccountForBudget;

  /// No description provided for @chatbotDefaultNewGoalName.
  ///
  /// In en, this message translates to:
  /// **'My new goal'**
  String get chatbotDefaultNewGoalName;

  /// No description provided for @chatbotInsightBody.
  ///
  /// In en, this message translates to:
  /// **'Financial health score: {score}/100\\nStatus: {status}\\n\\n{alertBlock}'**
  String chatbotInsightBody(String score, String status, String alertBlock);

  /// No description provided for @chatbotNoSpendingAlerts.
  ///
  /// In en, this message translates to:
  /// **'No unusual spending alerts right now.'**
  String get chatbotNoSpendingAlerts;

  /// No description provided for @chatbotWhatIfNeedAmount.
  ///
  /// In en, this message translates to:
  /// **'For a what-if scenario, include an amount. Example: if I save 300 a month when do I reach my goal?'**
  String get chatbotWhatIfNeedAmount;

  /// No description provided for @chatbotWhatIfNoGoals.
  ///
  /// In en, this message translates to:
  /// **'You have no saved goals yet. Add a goal first, then run a what-if.'**
  String get chatbotWhatIfNoGoals;

  /// No description provided for @chatbotWhatIfAllGoalsDone.
  ///
  /// In en, this message translates to:
  /// **'Great — it looks like you\'ve completed your current goals.'**
  String get chatbotWhatIfAllGoalsDone;

  /// No description provided for @chatbotNextGoalFallback.
  ///
  /// In en, this message translates to:
  /// **'Your next goal'**
  String get chatbotNextGoalFallback;

  /// No description provided for @chatbotOptimizerNoGoals.
  ///
  /// In en, this message translates to:
  /// **'No goals yet. Add goals first so I can suggest a savings split.'**
  String get chatbotOptimizerNoGoals;

  /// No description provided for @chatbotOptimizerNoSurplus.
  ///
  /// In en, this message translates to:
  /// **'No clear monthly surplus yet. Reduce expenses first for a precise goal plan.'**
  String get chatbotOptimizerNoSurplus;

  /// No description provided for @chatbotDefaultGoalWord.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get chatbotDefaultGoalWord;

  /// No description provided for @chatbotOptimizerGoalsDone.
  ///
  /// In en, this message translates to:
  /// **'Great — your current goals are nearly complete.'**
  String get chatbotOptimizerGoalsDone;

  /// No description provided for @chatbotOptimizerLine.
  ///
  /// In en, this message translates to:
  /// **'- {name}: {perMonth} ﷼/month (remaining {remaining} ﷼)'**
  String chatbotOptimizerLine(String name, String perMonth, String remaining);

  /// No description provided for @chatbotOptimizerIntro.
  ///
  /// In en, this message translates to:
  /// **'Goal optimizer\\nBased on your monthly surplus ({monthly} ﷼), suggested split:\\n'**
  String chatbotOptimizerIntro(String monthly);

  /// No description provided for @chatbotAlertExpenseOverIncome.
  ///
  /// In en, this message translates to:
  /// **'This month\'s spending is higher than income.'**
  String get chatbotAlertExpenseOverIncome;

  /// No description provided for @chatbotAlertSpendingGrowth.
  ///
  /// In en, this message translates to:
  /// **'Spending rose about {pct}% vs last month.'**
  String chatbotAlertSpendingGrowth(String pct);

  /// No description provided for @chatbotSubsNone.
  ///
  /// In en, this message translates to:
  /// **'I didn\'t find clear recurring subscriptions in your transactions.'**
  String get chatbotSubsNone;

  /// No description provided for @chatbotSubsLine.
  ///
  /// In en, this message translates to:
  /// **'- {name}: ~{amount} ﷼ (repeated {count} times)'**
  String chatbotSubsLine(String name, String amount, int count);

  /// No description provided for @chatbotSubsSummary.
  ///
  /// In en, this message translates to:
  /// **'Recurring patterns found 📌\\n{lines}\\n\\nApprox. monthly total: {total} ﷼'**
  String chatbotSubsSummary(String lines, String total);

  /// No description provided for @chatbotUnnamedRecurring.
  ///
  /// In en, this message translates to:
  /// **'Unnamed recurring expense'**
  String get chatbotUnnamedRecurring;

  /// No description provided for @chatbotPdfOk.
  ///
  /// In en, this message translates to:
  /// **'Monthly PDF report generated and share sheet opened.'**
  String get chatbotPdfOk;

  /// No description provided for @chatbotPdfFail.
  ///
  /// In en, this message translates to:
  /// **'Could not create the PDF report. Ensure you have data and try again.'**
  String get chatbotPdfFail;

  /// No description provided for @chatbotDlgCreateGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick create goal'**
  String get chatbotDlgCreateGoalTitle;

  /// No description provided for @chatbotDlgGoalNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal name'**
  String get chatbotDlgGoalNameLabel;

  /// No description provided for @chatbotDlgGoalTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get chatbotDlgGoalTargetLabel;

  /// No description provided for @chatbotRequiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get chatbotRequiredField;

  /// No description provided for @chatbotInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get chatbotInvalidNumber;

  /// No description provided for @chatbotDlgCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get chatbotDlgCreate;

  /// No description provided for @chatbotDlgAdjustBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick budget'**
  String get chatbotDlgAdjustBudgetTitle;

  /// No description provided for @chatbotDlgMonthlyBudgetLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget amount'**
  String get chatbotDlgMonthlyBudgetLabel;

  /// No description provided for @chatbotDlgSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get chatbotDlgSave;

  /// No description provided for @chatbotDlgCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get chatbotDlgCancel;

  /// No description provided for @chatbotGoalCreatedDialog.
  ///
  /// In en, this message translates to:
  /// **'Goal \"{name}\" created successfully.'**
  String chatbotGoalCreatedDialog(String name);

  /// No description provided for @chatbotBudgetCreatedDialog.
  ///
  /// In en, this message translates to:
  /// **'Next month\'s budget set to {amount} ﷼.'**
  String chatbotBudgetCreatedDialog(String amount);

  /// No description provided for @chatbotWhoAmI.
  ///
  /// In en, this message translates to:
  /// **'I\'m Mudabbir, your smart assistant for personal finance.'**
  String get chatbotWhoAmI;

  /// No description provided for @chatbotGreetBack.
  ///
  /// In en, this message translates to:
  /// **'Hello! How can I help you manage your money today?'**
  String get chatbotGreetBack;

  /// No description provided for @chatbotDateToday.
  ///
  /// In en, this message translates to:
  /// **'Today is {day}, {d} {month} {y}.'**
  String chatbotDateToday(String day, String d, String month, String y);

  /// No description provided for @chatbotThanksReply.
  ///
  /// In en, this message translates to:
  /// **'You\'re welcome — happy to help anytime.'**
  String get chatbotThanksReply;

  /// No description provided for @chatbotHowAreYouReply.
  ///
  /// In en, this message translates to:
  /// **'I\'m doing well, thanks for asking. How can I help with your finances?'**
  String get chatbotHowAreYouReply;

  /// No description provided for @chatbotJsonNoData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get chatbotJsonNoData;

  /// No description provided for @chatbotRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Sorry, rate limit reached. Try again later.'**
  String get chatbotRateLimited;

  /// No description provided for @chatbotServer53.
  ///
  /// In en, this message translates to:
  /// **'Smart service unavailable (server error 53). Try again shortly.'**
  String get chatbotServer53;

  /// No description provided for @chatbotHttpError.
  ///
  /// In en, this message translates to:
  /// **'Connection error (code: {code}).'**
  String chatbotHttpError(int code);

  /// No description provided for @chatbotRequestTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request took too long. Check your connection and try again.'**
  String get chatbotRequestTimeout;

  /// No description provided for @chatbotNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network.'**
  String get chatbotNoInternet;

  /// No description provided for @chatbotAssistantUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the assistant service. Try again later.'**
  String get chatbotAssistantUnreachable;

  /// No description provided for @chatbotParseResponseFail.
  ///
  /// In en, this message translates to:
  /// **'Sorry, I couldn\'t parse the response.'**
  String get chatbotParseResponseFail;

  /// No description provided for @chatbotParseError.
  ///
  /// In en, this message translates to:
  /// **'Sorry, an error occurred while reading the response.'**
  String get chatbotParseError;

  /// No description provided for @chatbotChatCleared.
  ///
  /// In en, this message translates to:
  /// **'Chat cleared. How can I help?'**
  String get chatbotChatCleared;

  /// No description provided for @chatbotQuickCreateGoal.
  ///
  /// In en, this message translates to:
  /// **'Create goal'**
  String get chatbotQuickCreateGoal;

  /// No description provided for @chatbotQuickAdjustBudget.
  ///
  /// In en, this message translates to:
  /// **'Adjust budget'**
  String get chatbotQuickAdjustBudget;

  /// No description provided for @chatbotQuickReduceCategory.
  ///
  /// In en, this message translates to:
  /// **'Cut category spend'**
  String get chatbotQuickReduceCategory;

  /// No description provided for @chatbotQuickPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF report'**
  String get chatbotQuickPdf;

  /// No description provided for @chatbotQuickUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo last action'**
  String get chatbotQuickUndo;

  /// No description provided for @chatbotSuggestBalanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask about your balance'**
  String get chatbotSuggestBalanceTitle;

  /// No description provided for @chatbotSuggestBalanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your accounts'**
  String get chatbotSuggestBalanceSubtitle;

  /// No description provided for @chatbotSuggestExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending analysis'**
  String get chatbotSuggestExpenseTitle;

  /// No description provided for @chatbotSuggestExpenseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review transactions and budgets'**
  String get chatbotSuggestExpenseSubtitle;

  /// No description provided for @chatbotSuggestGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Track goals'**
  String get chatbotSuggestGoalsTitle;

  /// No description provided for @chatbotSuggestGoalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See progress toward your goals'**
  String get chatbotSuggestGoalsSubtitle;

  /// No description provided for @chatbotSuggestBalancePrompt.
  ///
  /// In en, this message translates to:
  /// **'What is my balance this month?'**
  String get chatbotSuggestBalancePrompt;

  /// No description provided for @chatbotSuggestExpensePrompt.
  ///
  /// In en, this message translates to:
  /// **'Analyze my spending this month'**
  String get chatbotSuggestExpensePrompt;

  /// No description provided for @chatbotSuggestGoalsPrompt.
  ///
  /// In en, this message translates to:
  /// **'How are my savings goals progressing?'**
  String get chatbotSuggestGoalsPrompt;

  /// No description provided for @chatbotClearDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear chat'**
  String get chatbotClearDialogTitle;

  /// No description provided for @chatbotClearDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Start a new chat? All current messages will be removed.'**
  String get chatbotClearDialogBody;

  /// No description provided for @chatbotClearDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get chatbotClearDialogConfirm;

  /// No description provided for @chatbotLocalFallbackQuotaNotice.
  ///
  /// In en, this message translates to:
  /// **'Smart coach is temporarily busy — here is an answer from your saved data:'**
  String get chatbotLocalFallbackQuotaNotice;

  /// No description provided for @chatbotLocalFallbackOfflineNotice.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the cloud coach — here is an answer from your saved data:'**
  String get chatbotLocalFallbackOfflineNotice;

  /// No description provided for @chatbotLocalFallbackNoGoals.
  ///
  /// In en, this message translates to:
  /// **'You have no saved goals yet. Add one from the Goals tab or say \"create goal\".'**
  String get chatbotLocalFallbackNoGoals;

  /// No description provided for @chatbotLocalFallbackGoalLine.
  ///
  /// In en, this message translates to:
  /// **'- {name}: {current} / {target} ﷼ ({pct}%)'**
  String chatbotLocalFallbackGoalLine(
    String name,
    String current,
    String target,
    String pct,
  );

  /// No description provided for @chatbotLocalFallbackGoalsIntro.
  ///
  /// In en, this message translates to:
  /// **'Your goals:\\n{lines}\\n\\nMonthly surplus: {surplus} ﷼ (income {income} ﷼).'**
  String chatbotLocalFallbackGoalsIntro(
    String lines,
    String surplus,
    String income,
  );

  /// No description provided for @chatbotLocalFallbackNoBudget.
  ///
  /// In en, this message translates to:
  /// **'No active budget found. This month\'s spending so far: {expense} ﷼.'**
  String chatbotLocalFallbackNoBudget(String expense);

  /// No description provided for @chatbotLocalFallbackNoExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expense transactions recorded this month yet.'**
  String get chatbotLocalFallbackNoExpenses;

  /// No description provided for @chatbotLocalFallbackCategoryLine.
  ///
  /// In en, this message translates to:
  /// **'- {name}: {amount} ﷼ ({share}%)'**
  String chatbotLocalFallbackCategoryLine(
    String name,
    String amount,
    String share,
  );

  /// No description provided for @chatbotLocalFallbackExpenses.
  ///
  /// In en, this message translates to:
  /// **'This month\'s spending: {total} ﷼\\nTop categories:\\n{lines}'**
  String chatbotLocalFallbackExpenses(String total, String lines);

  /// No description provided for @chatbotLocalFallbackNoCategoryData.
  ///
  /// In en, this message translates to:
  /// **'No category spending data this month.'**
  String get chatbotLocalFallbackNoCategoryData;

  /// No description provided for @chatbotLocalFallbackTopCategory.
  ///
  /// In en, this message translates to:
  /// **'Top category: {name} ({amount} ﷼)'**
  String chatbotLocalFallbackTopCategory(String name, String amount);

  /// No description provided for @chatbotLocalFallbackGoalsNone.
  ///
  /// In en, this message translates to:
  /// **'No active goals in progress.'**
  String get chatbotLocalFallbackGoalsNone;

  /// No description provided for @chatbotLocalFallbackGoalsCount.
  ///
  /// In en, this message translates to:
  /// **'Active goals: {count}'**
  String chatbotLocalFallbackGoalsCount(int count);

  /// No description provided for @chatbotLocalFallbackOtherCategory.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get chatbotLocalFallbackOtherCategory;

  /// No description provided for @chatbotScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Mudabbir AI'**
  String get chatbotScreenTitle;

  /// No description provided for @chatbotSuggestSavingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Save more'**
  String get chatbotSuggestSavingsTitle;

  /// No description provided for @chatbotSuggestSavingsPrompt.
  ///
  /// In en, this message translates to:
  /// **'How can I save more?'**
  String get chatbotSuggestSavingsPrompt;

  /// No description provided for @chatbotAssistantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask about your budget, goals, and spending'**
  String get chatbotAssistantSubtitle;

  /// No description provided for @chatbotAssistantHeadline.
  ///
  /// In en, this message translates to:
  /// **'Your smart financial coach'**
  String get chatbotAssistantHeadline;

  /// No description provided for @chatbotSuggestedQuestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggested questions'**
  String get chatbotSuggestedQuestionsTitle;

  /// No description provided for @chatbotRefreshSuggestionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'New suggestions'**
  String get chatbotRefreshSuggestionsTooltip;

  /// No description provided for @chatbotInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about your budget...'**
  String get chatbotInputHint;

  /// No description provided for @chatbotClearChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear conversation'**
  String get chatbotClearChatTitle;

  /// No description provided for @chatbotClearChatMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete all messages in this chat?'**
  String get chatbotClearChatMessage;

  /// No description provided for @chatbotClearChatConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get chatbotClearChatConfirm;

  /// No description provided for @challengeUnexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get challengeUnexpectedError;

  /// No description provided for @challengeUnexpectedErrorLater.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again later.'**
  String get challengeUnexpectedErrorLater;

  /// No description provided for @challengeLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load challenges.'**
  String get challengeLoadFailed;

  /// No description provided for @challengeSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not sync challenge data.'**
  String get challengeSyncFailed;

  /// No description provided for @challengeChallengeCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Challenge created successfully'**
  String get challengeChallengeCreatedSuccess;

  /// No description provided for @challengeChallengeUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Challenge updated successfully'**
  String get challengeChallengeUpdatedSuccess;

  /// No description provided for @challengeChallengeDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Challenge deleted successfully'**
  String get challengeChallengeDeletedSuccess;

  /// No description provided for @challengeUserInvitedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent successfully'**
  String get challengeUserInvitedSuccess;

  /// No description provided for @challengeParticipantRemovedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Participant removed successfully'**
  String get challengeParticipantRemovedSuccess;

  /// No description provided for @challengeChallengeMarkedAchieved.
  ///
  /// In en, this message translates to:
  /// **'Challenge marked as achieved! 🎉'**
  String get challengeChallengeMarkedAchieved;

  /// No description provided for @challengeChallengeMarkedNotAchieved.
  ///
  /// In en, this message translates to:
  /// **'Challenge marked as not achieved'**
  String get challengeChallengeMarkedNotAchieved;

  /// No description provided for @challengeInvitationAccepted.
  ///
  /// In en, this message translates to:
  /// **'Challenge accepted! 🎉'**
  String get challengeInvitationAccepted;

  /// No description provided for @challengeInvitationRejected.
  ///
  /// In en, this message translates to:
  /// **'Invitation declined'**
  String get challengeInvitationRejected;

  /// No description provided for @challengeServerMaintenanceHint.
  ///
  /// In en, this message translates to:
  /// **'The server may be under maintenance. Try again shortly.'**
  String get challengeServerMaintenanceHint;

  /// No description provided for @challengeRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get challengeRetry;

  /// No description provided for @challengeInviteAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Share the app'**
  String get challengeInviteAppBarTitle;

  /// No description provided for @challengeInviteFriendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite friends'**
  String get challengeInviteFriendsTitle;

  /// No description provided for @challengeInviteFriendsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share the app with friends and earn rewards together!'**
  String get challengeInviteFriendsSubtitle;

  /// No description provided for @challengeInviteShareButton.
  ///
  /// In en, this message translates to:
  /// **'Share app'**
  String get challengeInviteShareButton;

  /// No description provided for @challengeInviteShareMessage.
  ///
  /// In en, this message translates to:
  /// **'Join me on Mudabbir! Use my invite link to get started: {link}'**
  String challengeInviteShareMessage(String link);

  /// No description provided for @challengeInviteShareSubject.
  ///
  /// In en, this message translates to:
  /// **'Try Mudabbir!'**
  String get challengeInviteShareSubject;

  /// No description provided for @challengeLocalPopupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create challenge'**
  String get challengeLocalPopupTitle;

  /// No description provided for @challengeLocalPopupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set a new money challenge'**
  String get challengeLocalPopupSubtitle;

  /// No description provided for @challengeLocalNameSection.
  ///
  /// In en, this message translates to:
  /// **'Challenge name'**
  String get challengeLocalNameSection;

  /// No description provided for @challengeLocalNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter challenge name'**
  String get challengeLocalNameHint;

  /// No description provided for @challengeLocalNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get challengeLocalNameRequired;

  /// No description provided for @challengeLocalStatusSection.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get challengeLocalStatusSection;

  /// No description provided for @challengeLocalStatusHint.
  ///
  /// In en, this message translates to:
  /// **'Select status'**
  String get challengeLocalStatusHint;

  /// No description provided for @challengeLocalStatusRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a status'**
  String get challengeLocalStatusRequired;

  /// No description provided for @challengeLocalPeriodSection.
  ///
  /// In en, this message translates to:
  /// **'Challenge period'**
  String get challengeLocalPeriodSection;

  /// No description provided for @challengeLocalStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get challengeLocalStartDate;

  /// No description provided for @challengeLocalEndDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get challengeLocalEndDate;

  /// No description provided for @challengeLocalStartRequired.
  ///
  /// In en, this message translates to:
  /// **'Start date is required'**
  String get challengeLocalStartRequired;

  /// No description provided for @challengeLocalEndRequired.
  ///
  /// In en, this message translates to:
  /// **'End date is required'**
  String get challengeLocalEndRequired;

  /// No description provided for @challengeLocalEndAfterStart.
  ///
  /// In en, this message translates to:
  /// **'End date must be after start date'**
  String get challengeLocalEndAfterStart;

  /// No description provided for @challengeLocalCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get challengeLocalCancel;

  /// No description provided for @challengeLocalCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create challenge'**
  String get challengeLocalCreateButton;

  /// No description provided for @challengeLocalCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Challenge created! 🎉'**
  String get challengeLocalCreateSuccess;

  /// No description provided for @challengeLocalCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create challenge: {e}'**
  String challengeLocalCreateFailed(String e);

  /// No description provided for @challengeListTitle.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get challengeListTitle;

  /// No description provided for @challengeNewChallengeFab.
  ///
  /// In en, this message translates to:
  /// **'New challenge'**
  String get challengeNewChallengeFab;

  /// No description provided for @challengeTabActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get challengeTabActive;

  /// No description provided for @challengeTabUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get challengeTabUpcoming;

  /// No description provided for @challengeTabCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get challengeTabCompleted;

  /// No description provided for @challengeTabInvitations.
  ///
  /// In en, this message translates to:
  /// **'Invitations'**
  String get challengeTabInvitations;

  /// No description provided for @challengeTabExpired.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get challengeTabExpired;

  /// No description provided for @challengeEmptyActive.
  ///
  /// In en, this message translates to:
  /// **'No active challenges'**
  String get challengeEmptyActive;

  /// No description provided for @challengeEmptyActiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a challenge and invite friends to save together.'**
  String get challengeEmptyActiveSubtitle;

  /// No description provided for @challengeEmptyUpcoming.
  ///
  /// In en, this message translates to:
  /// **'No upcoming challenges'**
  String get challengeEmptyUpcoming;

  /// No description provided for @challengeEmptyUpcomingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scheduled challenges will appear here.'**
  String get challengeEmptyUpcomingSubtitle;

  /// No description provided for @challengeEmptyCompleted.
  ///
  /// In en, this message translates to:
  /// **'No completed challenges'**
  String get challengeEmptyCompleted;

  /// No description provided for @challengeEmptyCompletedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Finished challenges are listed here.'**
  String get challengeEmptyCompletedSubtitle;

  /// No description provided for @challengeEmptyExpired.
  ///
  /// In en, this message translates to:
  /// **'No ended challenges'**
  String get challengeEmptyExpired;

  /// No description provided for @challengeEmptyExpiredSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Expired challenges without completion appear here.'**
  String get challengeEmptyExpiredSubtitle;

  /// No description provided for @challengeEmptyInvitations.
  ///
  /// In en, this message translates to:
  /// **'No pending invitations'**
  String get challengeEmptyInvitations;

  /// No description provided for @challengeEmptyInvitationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When friends invite you to a challenge, it appears here.'**
  String get challengeEmptyInvitationsSubtitle;

  /// No description provided for @challengeDailyCheckInStripTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily check-in'**
  String get challengeDailyCheckInStripTitle;

  /// No description provided for @challengeCheckInForChallenge.
  ///
  /// In en, this message translates to:
  /// **'Check in — {name}'**
  String challengeCheckInForChallenge(String name);

  /// No description provided for @challengeCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create challenge'**
  String get challengeCreateTitle;

  /// No description provided for @challengeSectionDetails.
  ///
  /// In en, this message translates to:
  /// **'Challenge details'**
  String get challengeSectionDetails;

  /// No description provided for @challengeSectionSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get challengeSectionSchedule;

  /// No description provided for @challengeFieldChallengeName.
  ///
  /// In en, this message translates to:
  /// **'Challenge name'**
  String get challengeFieldChallengeName;

  /// No description provided for @challengeHintChallengeName.
  ///
  /// In en, this message translates to:
  /// **'e.g. Save 1,000 SAR this month'**
  String get challengeHintChallengeName;

  /// No description provided for @challengeValNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get challengeValNameRequired;

  /// No description provided for @challengeValNameMin.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 characters'**
  String get challengeValNameMin;

  /// No description provided for @challengeFieldTargetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get challengeFieldTargetAmount;

  /// No description provided for @challengeHintTargetAmount.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1000'**
  String get challengeHintTargetAmount;

  /// No description provided for @challengeCurrencyAmountPrefix.
  ///
  /// In en, this message translates to:
  /// **'SAR '**
  String get challengeCurrencyAmountPrefix;

  /// No description provided for @challengeValAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter target amount'**
  String get challengeValAmountRequired;

  /// No description provided for @challengeValAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get challengeValAmountInvalid;

  /// No description provided for @challengePickStartDate.
  ///
  /// In en, this message translates to:
  /// **'Please pick a start date'**
  String get challengePickStartDate;

  /// No description provided for @challengePickEndDate.
  ///
  /// In en, this message translates to:
  /// **'Please pick an end date'**
  String get challengePickEndDate;

  /// No description provided for @challengeChooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose date'**
  String get challengeChooseDate;

  /// No description provided for @challengeCreateSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create challenge'**
  String get challengeCreateSubmit;

  /// No description provided for @challengeDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Challenge details'**
  String get challengeDetailTitle;

  /// No description provided for @challengeStartDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get challengeStartDateLabel;

  /// No description provided for @challengeEndDateLabel.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get challengeEndDateLabel;

  /// No description provided for @challengeStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get challengeStatusLabel;

  /// No description provided for @challengeTargetAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get challengeTargetAmountLabel;

  /// No description provided for @challengeCurrentAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Current amount'**
  String get challengeCurrentAmountLabel;

  /// No description provided for @challengeCreatorTargetLine.
  ///
  /// In en, this message translates to:
  /// **'Target amount: \${amount}'**
  String challengeCreatorTargetLine(String amount);

  /// No description provided for @challengeProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get challengeProgressLabel;

  /// No description provided for @challengeDaysUntilStart.
  ///
  /// In en, this message translates to:
  /// **'Starts in {days} days'**
  String challengeDaysUntilStart(int days);

  /// No description provided for @challengeDaysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String challengeDaysRemaining(int days);

  /// No description provided for @challengeUpdateAmountAchieved.
  ///
  /// In en, this message translates to:
  /// **'Goal reached'**
  String get challengeUpdateAmountAchieved;

  /// No description provided for @challengeUpdateAmountButton.
  ///
  /// In en, this message translates to:
  /// **'Update amount'**
  String get challengeUpdateAmountButton;

  /// No description provided for @challengeAddAmountTitle.
  ///
  /// In en, this message translates to:
  /// **'Add amount'**
  String get challengeAddAmountTitle;

  /// No description provided for @challengeAddAmountSubmit.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get challengeAddAmountSubmit;

  /// No description provided for @challengeAddAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount to add'**
  String get challengeAddAmountLabel;

  /// No description provided for @challengeAddAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get challengeAddAmountHint;

  /// No description provided for @challengeGoalCongrats.
  ///
  /// In en, this message translates to:
  /// **'🎉 Congratulations! Goal reached'**
  String get challengeGoalCongrats;

  /// No description provided for @challengeAddedAmountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Added \${amount} successfully'**
  String challengeAddedAmountSuccess(String amount);

  /// No description provided for @challengeInvalidAmountSnack.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get challengeInvalidAmountSnack;

  /// No description provided for @challengeParticipantsTitle.
  ///
  /// In en, this message translates to:
  /// **'Participants ({n})'**
  String challengeParticipantsTitle(int n);

  /// No description provided for @challengeInviteButton.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get challengeInviteButton;

  /// No description provided for @challengeInviteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite user'**
  String get challengeInviteDialogTitle;

  /// No description provided for @challengeInviteEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get challengeInviteEmailLabel;

  /// No description provided for @challengeInviteEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter user email'**
  String get challengeInviteEmailHint;

  /// No description provided for @challengeInviteInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email.'**
  String get challengeInviteInvalidEmail;

  /// No description provided for @challengeRemoveParticipantTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove participant'**
  String get challengeRemoveParticipantTitle;

  /// No description provided for @challengeRemoveParticipantBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this participant?'**
  String get challengeRemoveParticipantBody;

  /// No description provided for @challengeRemoveButton.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get challengeRemoveButton;

  /// No description provided for @challengeCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get challengeCancel;

  /// No description provided for @challengeCardCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get challengeCardCompleted;

  /// No description provided for @challengeCardExpired.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get challengeCardExpired;

  /// No description provided for @challengeCardActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get challengeCardActive;

  /// No description provided for @challengeActiveSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get challengeActiveSectionTitle;

  /// No description provided for @challengeQuickTemplatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick start'**
  String get challengeQuickTemplatesTitle;

  /// No description provided for @challengeLogButton.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get challengeLogButton;

  /// No description provided for @challengeStreakFire.
  ///
  /// In en, this message translates to:
  /// **'🔥 {days} days'**
  String challengeStreakFire(int days);

  /// No description provided for @challengeCardUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get challengeCardUpcoming;

  /// No description provided for @challengeGoalAmount.
  ///
  /// In en, this message translates to:
  /// **'Goal: \${amount}'**
  String challengeGoalAmount(String amount);

  /// No description provided for @challengeAcceptedCount.
  ///
  /// In en, this message translates to:
  /// **'{n} accepted'**
  String challengeAcceptedCount(int n);

  /// No description provided for @challengePendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending invitations'**
  String get challengePendingTitle;

  /// No description provided for @challengePendingEmpty.
  ///
  /// In en, this message translates to:
  /// **'No pending invitations'**
  String get challengePendingEmpty;

  /// No description provided for @challengePendingEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'When someone invites you to a challenge, it appears here.'**
  String get challengePendingEmptySubtitle;

  /// No description provided for @challengePendingStatus.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get challengePendingStatus;

  /// No description provided for @challengeFromCreator.
  ///
  /// In en, this message translates to:
  /// **'From: {name}'**
  String challengeFromCreator(String name);

  /// No description provided for @challengeTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total amount: \${amount}'**
  String challengeTotalAmount(String amount);

  /// No description provided for @challengeAcceptedBeforeInvite.
  ///
  /// In en, this message translates to:
  /// **'{n} participant(s) joined before the invite'**
  String challengeAcceptedBeforeInvite(int n);

  /// No description provided for @challengeSplitHint.
  ///
  /// In en, this message translates to:
  /// **'If you accept, the amount will be split evenly among all participants.'**
  String get challengeSplitHint;

  /// No description provided for @challengeDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get challengeDecline;

  /// No description provided for @challengeAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get challengeAccept;

  /// No description provided for @challengeRoleCreator.
  ///
  /// In en, this message translates to:
  /// **'Creator'**
  String get challengeRoleCreator;

  /// No description provided for @challengeInviteAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get challengeInviteAccepted;

  /// No description provided for @challengeInvitePendingStatus.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get challengeInvitePendingStatus;

  /// No description provided for @challengeInviteDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get challengeInviteDeclined;

  /// No description provided for @challengeTemplatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready-made challenges'**
  String get challengeTemplatesTitle;

  /// No description provided for @challengeTemplatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start a popular challenge in one tap'**
  String get challengeTemplatesSubtitle;

  /// No description provided for @challengeUseTemplate.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get challengeUseTemplate;

  /// No description provided for @challengeTemplateDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String challengeTemplateDays(int days);

  /// No description provided for @challengeStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily streak'**
  String get challengeStreakTitle;

  /// No description provided for @challengeStreakDays.
  ///
  /// In en, this message translates to:
  /// **'{days} day streak'**
  String challengeStreakDays(int days);

  /// No description provided for @challengeCheckInButton.
  ///
  /// In en, this message translates to:
  /// **'Check in today'**
  String get challengeCheckInButton;

  /// No description provided for @challengeAlreadyCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Already checked in today'**
  String get challengeAlreadyCheckedIn;

  /// No description provided for @challengeLeaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get challengeLeaderboardTitle;

  /// No description provided for @challengeLeaderboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'No participants yet'**
  String get challengeLeaderboardEmpty;

  /// No description provided for @challengeRankLabel.
  ///
  /// In en, this message translates to:
  /// **'#{rank}'**
  String challengeRankLabel(int rank);

  /// No description provided for @challengeBadge7Title.
  ///
  /// In en, this message translates to:
  /// **'7-day streak'**
  String get challengeBadge7Title;

  /// No description provided for @challengeBadge30Title.
  ///
  /// In en, this message translates to:
  /// **'30-day streak'**
  String get challengeBadge30Title;

  /// No description provided for @challengeBadge7Earned.
  ///
  /// In en, this message translates to:
  /// **'You earned the 7-day badge!'**
  String get challengeBadge7Earned;

  /// No description provided for @challengeBadge30Earned.
  ///
  /// In en, this message translates to:
  /// **'You earned the 30-day badge!'**
  String get challengeBadge30Earned;

  /// No description provided for @challengeCheckInSuccess.
  ///
  /// In en, this message translates to:
  /// **'Checked in successfully'**
  String get challengeCheckInSuccess;

  /// No description provided for @challengeTemplateCreated.
  ///
  /// In en, this message translates to:
  /// **'Challenge started from template'**
  String get challengeTemplateCreated;

  /// No description provided for @challengeOfflineBanner.
  ///
  /// In en, this message translates to:
  /// **'Offline — showing saved data. Changes will sync when you reconnect.'**
  String get challengeOfflineBanner;

  /// No description provided for @challengeProgressSaved.
  ///
  /// In en, this message translates to:
  /// **'Progress saved'**
  String get challengeProgressSaved;

  /// No description provided for @challengeProgressQueuedOffline.
  ///
  /// In en, this message translates to:
  /// **'Saved locally — will sync when online'**
  String get challengeProgressQueuedOffline;

  /// No description provided for @challengeCreateRequiresOnline.
  ///
  /// In en, this message translates to:
  /// **'Creating a challenge requires an internet connection. Connect and try again.'**
  String get challengeCreateRequiresOnline;

  /// No description provided for @challengeWriteRequiresOnline.
  ///
  /// In en, this message translates to:
  /// **'This action requires an internet connection. Connect and try again.'**
  String get challengeWriteRequiresOnline;

  /// No description provided for @chatbotPreviewGoal.
  ///
  /// In en, this message translates to:
  /// **'Review 🧾\n- Action: Create goal\n- Name: {name}\n- Target: {amount} ﷼\n- Duration: {months} months\n\nType \"confirm\" to apply or \"cancel\" to abort.'**
  String chatbotPreviewGoal(String name, String amount, int months);

  /// No description provided for @chatbotPreviewBudget.
  ///
  /// In en, this message translates to:
  /// **'Review 🧾\n- Action: Create budget\n- Amount: {amount} ﷼\n- Period: {start} to {end}\n\nType \"confirm\" to apply or \"cancel\" to abort.'**
  String chatbotPreviewBudget(String amount, String start, String end);

  /// No description provided for @chatbotWhatIfScenario.
  ///
  /// In en, this message translates to:
  /// **'What-if scenario 💡\n- If you save {amount} ﷼ / month\n- Goal: {name}\n- Remaining: {remaining} ﷼\n- Estimated time: ~{months} months\n- Estimated finish date: {eta}'**
  String chatbotWhatIfScenario(
    String amount,
    String name,
    String remaining,
    int months,
    String eta,
  );

  /// No description provided for @chatbotTimeNow.
  ///
  /// In en, this message translates to:
  /// **'The time is {displayHour}:{minute} {period}.'**
  String chatbotTimeNow(int displayHour, String minute, String period);

  /// No description provided for @chatbotLocalFallbackBalance.
  ///
  /// In en, this message translates to:
  /// **'This month:\n• Income: {income} ﷼\n• Expenses: {expense} ﷼\n• Balance: {balance} ﷼\n• Health score: {score}/100 ({status})'**
  String chatbotLocalFallbackBalance(
    String income,
    String expense,
    String balance,
    int score,
    String status,
  );

  /// No description provided for @chatbotLocalFallbackSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Quick snapshot 📊\n• Income: {income} ﷼ | Expenses: {expense} ﷼ | Balance: {balance} ﷼\n• Health score: {score}/100 ({status})\n• Alerts: {alerts}\n• {topCategory}\n• {goalsLine}'**
  String chatbotLocalFallbackSnapshot(
    String income,
    String expense,
    String balance,
    int score,
    String status,
    String alerts,
    String topCategory,
    String goalsLine,
  );

  /// No description provided for @chatbotLocalFallbackBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget: {budget} ﷼\nSpent: {spent} ﷼ ({usedPct}%)\nRemaining: {remaining} ﷼'**
  String chatbotLocalFallbackBudget(
    String budget,
    String spent,
    String usedPct,
    String remaining,
  );

  /// No description provided for @chatbotInsightStatusStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get chatbotInsightStatusStrong;

  /// No description provided for @chatbotInsightStatusGood.
  ///
  /// In en, this message translates to:
  /// **'Good with room to improve'**
  String get chatbotInsightStatusGood;

  /// No description provided for @chatbotInsightStatusNeeds.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get chatbotInsightStatusNeeds;

  /// No description provided for @chatbotTimePeriodAm.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get chatbotTimePeriodAm;

  /// No description provided for @chatbotTimePeriodPm.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get chatbotTimePeriodPm;

  /// No description provided for @challengeStatusActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get challengeStatusActiveLabel;

  /// No description provided for @challengeStatusCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get challengeStatusCompletedLabel;

  /// No description provided for @challengeStatusCancelledLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get challengeStatusCancelledLabel;

  /// No description provided for @challengeParticipantCountOne.
  ///
  /// In en, this message translates to:
  /// **'1 participant'**
  String get challengeParticipantCountOne;

  /// No description provided for @challengeParticipantCountMany.
  ///
  /// In en, this message translates to:
  /// **'{n} participants'**
  String challengeParticipantCountMany(int n);

  /// No description provided for @chatbotWeekday0.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get chatbotWeekday0;

  /// No description provided for @chatbotWeekday1.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get chatbotWeekday1;

  /// No description provided for @chatbotWeekday2.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get chatbotWeekday2;

  /// No description provided for @chatbotWeekday3.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get chatbotWeekday3;

  /// No description provided for @chatbotWeekday4.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get chatbotWeekday4;

  /// No description provided for @chatbotWeekday5.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get chatbotWeekday5;

  /// No description provided for @chatbotWeekday6.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get chatbotWeekday6;

  /// No description provided for @chatbotMonth0.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get chatbotMonth0;

  /// No description provided for @chatbotMonth1.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get chatbotMonth1;

  /// No description provided for @chatbotMonth2.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get chatbotMonth2;

  /// No description provided for @chatbotMonth3.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get chatbotMonth3;

  /// No description provided for @chatbotMonth4.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get chatbotMonth4;

  /// No description provided for @chatbotMonth5.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get chatbotMonth5;

  /// No description provided for @chatbotMonth6.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get chatbotMonth6;

  /// No description provided for @chatbotMonth7.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get chatbotMonth7;

  /// No description provided for @chatbotMonth8.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get chatbotMonth8;

  /// No description provided for @chatbotMonth9.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get chatbotMonth9;

  /// No description provided for @chatbotMonth10.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get chatbotMonth10;

  /// No description provided for @chatbotMonth11.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get chatbotMonth11;

  /// No description provided for @chatbotDefaultSuggestion0.
  ///
  /// In en, this message translates to:
  /// **'How can I save more?'**
  String get chatbotDefaultSuggestion0;

  /// No description provided for @chatbotDefaultSuggestion1.
  ///
  /// In en, this message translates to:
  /// **'Analyze my spending'**
  String get chatbotDefaultSuggestion1;

  /// No description provided for @chatbotDefaultSuggestion2.
  ///
  /// In en, this message translates to:
  /// **'Monthly savings plan'**
  String get chatbotDefaultSuggestion2;

  /// No description provided for @chatbotAlternateSuggestion0.
  ///
  /// In en, this message translates to:
  /// **'Where do I spend the most?'**
  String get chatbotAlternateSuggestion0;

  /// No description provided for @chatbotAlternateSuggestion1.
  ///
  /// In en, this message translates to:
  /// **'How do I fix my budget?'**
  String get chatbotAlternateSuggestion1;

  /// No description provided for @chatbotAlternateSuggestion2.
  ///
  /// In en, this message translates to:
  /// **'Tips to cut expenses'**
  String get chatbotAlternateSuggestion2;

  /// No description provided for @chatbotAlternateSuggestion3.
  ///
  /// In en, this message translates to:
  /// **'When will I reach my goal?'**
  String get chatbotAlternateSuggestion3;

  /// No description provided for @chatbotAlternateSuggestion4.
  ///
  /// In en, this message translates to:
  /// **'Compare to last month'**
  String get chatbotAlternateSuggestion4;

  /// No description provided for @chatbotAlternateSuggestion5.
  ///
  /// In en, this message translates to:
  /// **'Best money tip for today?'**
  String get chatbotAlternateSuggestion5;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
