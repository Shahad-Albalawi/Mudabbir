import 'package:mudabbir/presentation/resources/currency_formatter.dart';
import 'package:mudabbir/presentation/resources/entity_localizations.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Server challenge copy and formatting helpers backed by [AppStrings].
class ChallengeCopyHelpers {
  ChallengeCopyHelpers._();

  static bool get isArabic => !AppStrings.isEnglishLocale;

  static String get unexpectedError => AppStrings.challengeUnexpectedError;
  static String get unexpectedErrorLater => AppStrings.challengeUnexpectedErrorLater;
  static String get loadFailed => AppStrings.challengeLoadFailed;
  static String get syncFailed => AppStrings.challengeSyncFailed;
  static String get challengeCreatedSuccess =>
      AppStrings.challengeChallengeCreatedSuccess;
  static String get challengeUpdatedSuccess =>
      AppStrings.challengeChallengeUpdatedSuccess;
  static String get challengeDeletedSuccess =>
      AppStrings.challengeChallengeDeletedSuccess;
  static String get userInvitedSuccess => AppStrings.challengeUserInvitedSuccess;
  static String get participantRemovedSuccess =>
      AppStrings.challengeParticipantRemovedSuccess;
  static String get challengeMarkedAchieved =>
      AppStrings.challengeChallengeMarkedAchieved;
  static String get challengeMarkedNotAchieved =>
      AppStrings.challengeChallengeMarkedNotAchieved;
  static String get invitationAccepted => AppStrings.challengeInvitationAccepted;
  static String get invitationRejected => AppStrings.challengeInvitationRejected;
  static String get serverMaintenanceHint =>
      AppStrings.challengeServerMaintenanceHint;
  static String get retry => AppStrings.challengeRetry;
  static String get inviteAppBarTitle => AppStrings.challengeInviteAppBarTitle;
  static String get inviteFriendsTitle => AppStrings.challengeInviteFriendsTitle;
  static String get inviteFriendsSubtitle =>
      AppStrings.challengeInviteFriendsSubtitle;
  static String get inviteShareButton => AppStrings.challengeInviteShareButton;
  static String inviteShareMessage(String link) =>
      AppStrings.challengeInviteShareMessage(link);
  static String get inviteShareSubject => AppStrings.challengeInviteShareSubject;
  static String get localPopupTitle => AppStrings.challengeLocalPopupTitle;
  static String get localPopupSubtitle => AppStrings.challengeLocalPopupSubtitle;
  static String get localNameSection => AppStrings.challengeLocalNameSection;
  static String get localNameHint => AppStrings.challengeLocalNameHint;
  static String get localNameRequired => AppStrings.challengeLocalNameRequired;
  static String get localStatusSection => AppStrings.challengeLocalStatusSection;
  static String get localStatusHint => AppStrings.challengeLocalStatusHint;
  static String get localStatusRequired => AppStrings.challengeLocalStatusRequired;
  static String get localPeriodSection => AppStrings.challengeLocalPeriodSection;
  static String get localStartDate => AppStrings.challengeLocalStartDate;
  static String get localEndDate => AppStrings.challengeLocalEndDate;
  static String get localStartRequired => AppStrings.challengeLocalStartRequired;
  static String get localEndRequired => AppStrings.challengeLocalEndRequired;
  static String get localEndAfterStart => AppStrings.challengeLocalEndAfterStart;
  static String get localCancel => AppStrings.challengeLocalCancel;
  static String get localCreateButton => AppStrings.challengeLocalCreateButton;
  static String get localCreateSuccess => AppStrings.challengeLocalCreateSuccess;
  static String localCreateFailed(Object e) =>
      AppStrings.challengeLocalCreateFailed(e.toString());

  static const String statusActiveKey =
      EntityLocalizations.challengeStatusActiveKey;
  static const String statusCompletedKey =
      EntityLocalizations.challengeStatusCompletedKey;
  static const String statusCancelledKey =
      EntityLocalizations.challengeStatusCancelledKey;

  static List<String> get localStatusStorageValues => const [
        statusActiveKey,
        statusCompletedKey,
        statusCancelledKey,
      ];

  static String localStatusLabel(String stored) {
    switch (stored) {
      case statusActiveKey:
        return AppStrings.challengeStatusActiveLabel;
      case statusCompletedKey:
        return AppStrings.challengeStatusCompletedLabel;
      case statusCancelledKey:
        return AppStrings.challengeStatusCancelledLabel;
      default:
        return stored;
    }
  }

  static String get listTitle => AppStrings.challengeListTitle;
  static String get newChallengeFab => AppStrings.challengeNewChallengeFab;
  static String get tabActive => AppStrings.challengeTabActive;
  static String get tabUpcoming => AppStrings.challengeTabUpcoming;
  static String get tabCompleted => AppStrings.challengeTabCompleted;
  static String get tabInvitations => AppStrings.challengeTabInvitations;
  static String get tabExpired => AppStrings.challengeTabExpired;
  static String get emptyActive => AppStrings.challengeEmptyActive;
  static String get emptyActiveSubtitle => AppStrings.challengeEmptyActiveSubtitle;
  static String get emptyUpcoming => AppStrings.challengeEmptyUpcoming;
  static String get emptyUpcomingSubtitle =>
      AppStrings.challengeEmptyUpcomingSubtitle;
  static String get emptyCompleted => AppStrings.challengeEmptyCompleted;
  static String get emptyCompletedSubtitle =>
      AppStrings.challengeEmptyCompletedSubtitle;
  static String get emptyExpired => AppStrings.challengeEmptyExpired;
  static String get emptyExpiredSubtitle => AppStrings.challengeEmptyExpiredSubtitle;
  static String get emptyInvitations => AppStrings.challengeEmptyInvitations;
  static String get emptyInvitationsSubtitle =>
      AppStrings.challengeEmptyInvitationsSubtitle;
  static String get dailyCheckInStripTitle =>
      AppStrings.challengeDailyCheckInStripTitle;
  static String checkInForChallenge(String name) =>
      AppStrings.challengeCheckInForChallenge(name);

  static String medalEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
    }
  }

  static String get createTitle => AppStrings.challengeCreateTitle;
  static String get sectionDetails => AppStrings.challengeSectionDetails;
  static String get sectionSchedule => AppStrings.challengeSectionSchedule;
  static String get fieldChallengeName => AppStrings.challengeFieldChallengeName;
  static String get hintChallengeName => AppStrings.challengeHintChallengeName;
  static String get valNameRequired => AppStrings.challengeValNameRequired;
  static String get valNameMin => AppStrings.challengeValNameMin;
  static String get fieldTargetAmount => AppStrings.challengeFieldTargetAmount;
  static String get hintTargetAmount => AppStrings.challengeHintTargetAmount;
  static String get currencyAmountPrefix => AppStrings.challengeCurrencyAmountPrefix;
  static String get valAmountRequired => AppStrings.challengeValAmountRequired;
  static String get valAmountInvalid => AppStrings.challengeValAmountInvalid;
  static String get pickStartDate => AppStrings.challengePickStartDate;
  static String get pickEndDate => AppStrings.challengePickEndDate;
  static String get chooseDate => AppStrings.challengeChooseDate;
  static String get createSubmit => AppStrings.challengeCreateSubmit;
  static String get detailTitle => AppStrings.challengeDetailTitle;
  static String get startDateLabel => AppStrings.challengeStartDateLabel;
  static String get endDateLabel => AppStrings.challengeEndDateLabel;
  static String get statusLabel => AppStrings.challengeStatusLabel;
  static String get targetAmountLabel => AppStrings.challengeTargetAmountLabel;
  static String get currentAmountLabel => AppStrings.challengeCurrentAmountLabel;
  static String creatorTargetLine(String amount) =>
      AppStrings.challengeCreatorTargetLine(amount);
  static String get progressLabel => AppStrings.challengeProgressLabel;
  static String daysUntilStart(int days) =>
      AppStrings.challengeDaysUntilStart(days);
  static String daysRemaining(int days) => AppStrings.challengeDaysRemaining(days);
  static String get updateAmountAchieved => AppStrings.challengeUpdateAmountAchieved;
  static String get updateAmountButton => AppStrings.challengeUpdateAmountButton;
  static String get addAmountTitle => AppStrings.challengeAddAmountTitle;
  static String get addAmountSubmit => AppStrings.challengeAddAmountSubmit;
  static String get addAmountLabel => AppStrings.challengeAddAmountLabel;
  static String get addAmountHint => AppStrings.challengeAddAmountHint;
  static String get goalCongrats => AppStrings.challengeGoalCongrats;
  static String addedAmountSuccess(String amount) =>
      AppStrings.challengeAddedAmountSuccess(amount);
  static String get invalidAmountSnack => AppStrings.challengeInvalidAmountSnack;
  static String participantsTitle(int n) =>
      AppStrings.challengeParticipantsTitle(n);
  static String get inviteButton => AppStrings.challengeInviteButton;
  static String get inviteDialogTitle => AppStrings.challengeInviteDialogTitle;
  static String get inviteEmailLabel => AppStrings.challengeInviteEmailLabel;
  static String get inviteEmailHint => AppStrings.challengeInviteEmailHint;
  static String get inviteInvalidEmail => AppStrings.challengeInviteInvalidEmail;
  static String get removeParticipantTitle =>
      AppStrings.challengeRemoveParticipantTitle;
  static String get removeParticipantBody =>
      AppStrings.challengeRemoveParticipantBody;
  static String get removeButton => AppStrings.challengeRemoveButton;
  static String get cancel => AppStrings.challengeCancel;
  static String get cardCompleted => AppStrings.challengeCardCompleted;
  static String get cardExpired => AppStrings.challengeCardExpired;
  static String get cardActive => AppStrings.challengeCardActive;
  static String get activeSectionTitle => AppStrings.challengeActiveSectionTitle;
  static String get quickTemplatesTitle => AppStrings.challengeQuickTemplatesTitle;
  static String get logButton => AppStrings.challengeLogButton;
  static String streakFire(int days) => AppStrings.challengeStreakFire(days);
  static String get cardUpcoming => AppStrings.challengeCardUpcoming;
  static String goalAmount(double amount) =>
      AppStrings.challengeGoalAmount(amount.toStringAsFixed(2));
  static String acceptedCount(int n) => AppStrings.challengeAcceptedCount(n);
  static String participantCount(int n) =>
      AppStrings.challengeParticipantCountLabel(n);
  static String get pendingTitle => AppStrings.challengePendingTitle;
  static String get pendingEmpty => AppStrings.challengePendingEmpty;
  static String get pendingEmptySubtitle =>
      AppStrings.challengePendingEmptySubtitle;
  static String get pendingStatus => AppStrings.challengePendingStatus;
  static String fromCreator(String name) => AppStrings.challengeFromCreator(name);
  static String totalAmount(double amount) =>
      AppStrings.challengeTotalAmount(amount.toStringAsFixed(2));
  static String acceptedBeforeInvite(int n) =>
      AppStrings.challengeAcceptedBeforeInvite(n);
  static String get splitHint => AppStrings.challengeSplitHint;
  static String get decline => AppStrings.challengeDecline;
  static String get accept => AppStrings.challengeAccept;
  static String get roleCreator => AppStrings.challengeRoleCreator;
  static String get inviteAccepted => AppStrings.challengeInviteAccepted;
  static String get invitePendingStatus => AppStrings.challengeInvitePendingStatus;
  static String get inviteDeclined => AppStrings.challengeInviteDeclined;
  static String get templatesTitle => AppStrings.challengeTemplatesTitle;
  static String get templatesSubtitle => AppStrings.challengeTemplatesSubtitle;
  static String get useTemplate => AppStrings.challengeUseTemplate;
  static String templateDays(int days) => AppStrings.challengeTemplateDays(days);
  static String get streakTitle => AppStrings.challengeStreakTitle;
  static String streakDays(int days) => AppStrings.challengeStreakDays(days);
  static String get checkInButton => AppStrings.challengeCheckInButton;
  static String get alreadyCheckedIn => AppStrings.challengeAlreadyCheckedIn;
  static String get leaderboardTitle => AppStrings.challengeLeaderboardTitle;
  static String get leaderboardEmpty => AppStrings.challengeLeaderboardEmpty;
  static String rankLabel(int rank) => AppStrings.challengeRankLabel(rank);
  static String get badge7Title => AppStrings.challengeBadge7Title;
  static String get badge30Title => AppStrings.challengeBadge30Title;
  static String get badge7Earned => AppStrings.challengeBadge7Earned;
  static String get badge30Earned => AppStrings.challengeBadge30Earned;
  static String get checkInSuccess => AppStrings.challengeCheckInSuccess;
  static String get templateCreated => AppStrings.challengeTemplateCreated;
  static String formatAmount(double amount) => AppCurrency.format(amount);
  static String get offlineBanner => AppStrings.challengeOfflineBanner;
  static String get progressSaved => AppStrings.challengeProgressSaved;
  static String get progressQueuedOffline =>
      AppStrings.challengeProgressQueuedOffline;
  static String get createRequiresOnline =>
      AppStrings.challengeCreateRequiresOnline;
  static String get writeRequiresOnline => AppStrings.challengeWriteRequiresOnline;
}

/// Backward-compatible alias used across challenge screens and providers.
typedef ServerChallengeStrings = ChallengeCopyHelpers;
