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
