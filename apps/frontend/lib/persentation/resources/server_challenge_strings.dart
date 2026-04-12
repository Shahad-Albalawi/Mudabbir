import 'package:mudabbir/persentation/resources/strings_manager.dart';

/// Bilingual copy for server challenges, invite share, and local challenge popup.
class ServerChallengeStrings {
  ServerChallengeStrings._();

  static bool get _e => AppStrings.isEnglishLocale;

  // —— Unexpected / operations ——
  static String get unexpectedError => _e
      ? 'Something went wrong. Please try again.'
      : 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';

  static String get unexpectedErrorLater => _e
      ? 'Something went wrong. Please try again later.'
      : 'حدث خطأ غير متوقع. يرجى المحاولة لاحقاً.';

  static String get challengeCreatedSuccess => _e
      ? 'Challenge created successfully'
      : 'تم إنشاء التحدي بنجاح';

  static String get challengeUpdatedSuccess => _e
      ? 'Challenge updated successfully'
      : 'تم تحديث التحدي بنجاح';

  static String get challengeDeletedSuccess => _e
      ? 'Challenge deleted successfully'
      : 'تم حذف التحدي بنجاح';

  static String get userInvitedSuccess => _e
      ? 'Invitation sent successfully'
      : 'تم إرسال الدعوة بنجاح';

  static String get participantRemovedSuccess => _e
      ? 'Participant removed successfully'
      : 'تم إزالة المشارك بنجاح';

  static String get challengeMarkedAchieved => _e
      ? 'Challenge marked as achieved! 🎉'
      : 'تم تسجيل إنجاز التحدي! 🎉';

  static String get challengeMarkedNotAchieved => _e
      ? 'Challenge marked as not achieved'
      : 'تم إلغاء تسجيل الإنجاز';

  static String get invitationAccepted => _e
      ? 'Challenge accepted! 🎉'
      : 'تم قبول التحدي! 🎉';

  static String get invitationRejected => _e
      ? 'Invitation declined'
      : 'تم رفض الدعوة';

  static String get serverMaintenanceHint => _e
      ? 'The server may be under maintenance. Try again shortly.'
      : 'قد يكون الخادم قيد الصيانة. جرّب مرة أخرى بعد قليل.';

  static String get retry => _e ? 'Retry' : 'إعادة المحاولة';

  // —— Invite (share app) ——
  static String get inviteAppBarTitle =>
      _e ? 'Share the app' : 'شارك التطبيق';

  static String get inviteFriendsTitle =>
      _e ? 'Invite friends' : 'ادعُ أصدقاءك';

  static String get inviteFriendsSubtitle => _e
      ? 'Share the app with friends and earn rewards together!'
      : 'شارك التطبيق مع أصدقائك واربحوا المكافآت معًا!';

  static String get inviteShareButton =>
      _e ? 'Share app' : 'مشاركة التطبيق';

  static String inviteShareMessage(String link) => _e
      ? 'Join me on Mudabbir! Use my invite link to get started: $link'
      : 'انضم إليّ في تطبيق مدبر! استخدم رابط الدعوة للبدء: $link';

  static String get inviteShareSubject =>
      _e ? 'Try Mudabbir!' : 'جرّب تطبيق مدبر!';

  // —— Local challenge popup (SQLite) ——
  static String get localPopupTitle =>
      _e ? 'Create challenge' : 'إنشاء تحدي';

  static String get localPopupSubtitle => _e
      ? 'Set a new money challenge'
      : 'حدد تحدي مالي جديد';

  static String get localNameSection =>
      _e ? 'Challenge name' : 'اسم التحدي';

  static String get localNameHint => _e
      ? 'Enter challenge name'
      : 'أدخل اسم التحدي';

  static String get localNameRequired =>
      _e ? 'Name is required' : 'الاسم مطلوب';

  static String get localStatusSection =>
      _e ? 'Status' : 'حالة التحدي';

  static String get localStatusHint =>
      _e ? 'Select status' : 'اختر الحالة';

  static String get localStatusRequired =>
      _e ? 'Please select a status' : 'يرجى اختيار حالة';

  static String get localPeriodSection =>
      _e ? 'Challenge period' : 'فترة التحدي';

  static String get localStartDate =>
      _e ? 'Start date' : 'تاريخ البداية';

  static String get localEndDate =>
      _e ? 'End date' : 'تاريخ النهاية';

  static String get localStartRequired =>
      _e ? 'Start date is required' : 'تاريخ البداية مطلوب';

  static String get localEndRequired =>
      _e ? 'End date is required' : 'تاريخ النهاية مطلوب';

  static String get localEndAfterStart => _e
      ? 'End date must be after start date'
      : 'يجب أن تكون النهاية بعد البداية';

  static String get localCancel => _e ? 'Cancel' : 'إلغاء';

  static String get localCreateButton =>
      _e ? 'Create challenge' : 'إنشاء التحدي';

  static String get localCreateSuccess =>
      _e ? 'Challenge created! 🎉' : 'تم إنشاء التحدي بنجاح! 🎉';

  static String localCreateFailed(Object e) => _e
      ? 'Could not create challenge: $e'
      : 'فشل في إنشاء التحدي: $e';

  /// Stored in local DB (matches existing [challanges_view] keys).
  static const String statusActiveKey = 'نشط';
  static const String statusCompletedKey = 'مكتمل';
  static const String statusCancelledKey = 'ملغي';

  static List<String> get localStatusStorageValues => [
        statusActiveKey,
        statusCompletedKey,
        statusCancelledKey,
      ];

  static String localStatusLabel(String stored) {
    switch (stored) {
      case statusActiveKey:
        return _e ? 'Active' : 'نشط';
      case statusCompletedKey:
        return _e ? 'Completed' : 'مكتمل';
      case statusCancelledKey:
        return _e ? 'Cancelled' : 'ملغي';
      default:
        return stored;
    }
  }

  // —— List screen ——
  static String get listTitle => _e ? 'Challenges' : 'التحديات';

  static String get newChallengeFab =>
      _e ? 'New challenge' : 'تحدي جديد';

  static String get tabActive => _e ? 'Active' : 'نشط';

  static String get tabUpcoming => _e ? 'Upcoming' : 'قادم';

  static String get tabCompleted => _e ? 'Completed' : 'مكتمل';

  static String get tabExpired => _e ? 'Ended' : 'منتهي';

  static String get emptyActive =>
      _e ? 'No active challenges' : 'لا توجد تحديات نشطة';

  static String get emptyUpcoming =>
      _e ? 'No upcoming challenges' : 'لا توجد تحديات قادمة';

  static String get emptyCompleted =>
      _e ? 'No completed challenges' : 'لا توجد تحديات مكتملة';

  static String get emptyExpired =>
      _e ? 'No ended challenges' : 'لا توجد تحديات منتهية';

  // —— Create screen ——
  static String get createTitle =>
      _e ? 'Create challenge' : 'إنشاء تحدي';

  static String get sectionDetails =>
      _e ? 'Challenge details' : 'تفاصيل التحدي';

  static String get sectionSchedule =>
      _e ? 'Schedule' : 'الجدول الزمني';

  static String get fieldChallengeName =>
      _e ? 'Challenge name' : 'اسم التحدي';

  static String get hintChallengeName => _e
      ? 'e.g. Save 1,000 SAR this month'
      : 'مثال: ادخار 1000 ريال هذا الشهر';

  static String get valNameRequired =>
      _e ? 'Please enter a name' : 'الرجاء إدخال اسم التحدي';

  static String get valNameMin =>
      _e ? 'Name must be at least 3 characters' : 'يجب أن يكون الاسم 3 أحرف على الأقل';

  static String get fieldTargetAmount =>
      _e ? 'Target amount' : 'المبلغ المستهدف';

  static String get hintTargetAmount =>
      _e ? 'e.g. 1000' : 'مثال: 1000';

  /// Shown before the amount field (localized currency hint).
  static String get currencyAmountPrefix => _e ? 'SAR ' : '﷼ ';

  static String get valAmountRequired =>
      _e ? 'Please enter target amount' : 'الرجاء إدخال المبلغ المستهدف';

  static String get valAmountInvalid =>
      _e ? 'Please enter a valid amount' : 'الرجاء إدخال مبلغ صحيح';

  static String get pickStartDate =>
      _e ? 'Please pick a start date' : 'الرجاء اختيار تاريخ البداية';

  static String get pickEndDate =>
      _e ? 'Please pick an end date' : 'الرجاء اختيار تاريخ النهاية';

  static String get chooseDate =>
      _e ? 'Choose date' : 'اختر التاريخ';

  static String get createSubmit =>
      _e ? 'Create challenge' : 'إنشاء التحدي';

  // —— Detail screen ——
  static String get detailTitle =>
      _e ? 'Challenge details' : 'تفاصيل التحدي';

  static String get startDateLabel =>
      _e ? 'Start date' : 'تاريخ البداية';

  static String get endDateLabel =>
      _e ? 'End date' : 'تاريخ النهاية';

  static String get statusLabel =>
      _e ? 'Status' : 'الحالة';

  static String get targetAmountLabel =>
      _e ? 'Target amount' : 'المبلغ المستهدف';

  static String get currentAmountLabel =>
      _e ? 'Current amount' : 'المبلغ الحالي';

  static String creatorTargetLine(String amount) => _e
      ? 'Target amount: \$$amount'
      : 'المبلغ المستهدف: \$$amount';

  static String get progressLabel =>
      _e ? 'Progress' : 'التقدم';

  static String daysUntilStart(int days) =>
      _e ? 'Starts in $days days' : 'يبدأ خلال $days يوم';

  static String daysRemaining(int days) =>
      _e ? '$days days left' : 'متبقي $days يوم';

  static String get updateAmountAchieved =>
      _e ? 'Goal reached' : 'تم تحقيق الهدف';

  static String get updateAmountButton =>
      _e ? 'Update amount' : 'تحديث المبلغ';

  static String get addAmountTitle =>
      _e ? 'Add amount' : 'إضافة مبلغ';

  static String get addAmountSubmit => _e ? 'Add' : 'إضافة';

  static String get addAmountLabel =>
      _e ? 'Amount to add' : 'المبلغ المراد إضافته';

  static String get addAmountHint =>
      _e ? 'Enter amount' : 'أدخل المبلغ';

  static String get goalCongrats =>
      _e ? '🎉 Congratulations! Goal reached' : '🎉 تهانينا! لقد حققت الهدف';

  static String addedAmountSuccess(String amount) => _e
      ? 'Added \$$amount successfully'
      : 'تم إضافة \$$amount بنجاح';

  static String get invalidAmountSnack =>
      _e ? 'Please enter a valid amount' : 'الرجاء إدخال مبلغ صحيح';

  static String participantsTitle(int n) =>
      _e ? 'Participants ($n)' : 'المشاركون ($n)';

  static String get inviteButton =>
      _e ? 'Invite' : 'دعوة';

  static String get inviteDialogTitle =>
      _e ? 'Invite user' : 'دعوة مستخدم';

  static String get inviteEmailLabel =>
      _e ? 'Email' : 'البريد الإلكتروني';

  static String get inviteEmailHint => _e
      ? 'Enter user email'
      : 'أدخل البريد الإلكتروني للمستخدم';

  static String get inviteInvalidEmail =>
      _e ? 'Please enter a valid email.' : 'الرجاء إدخال بريد إلكتروني صحيح.';

  static String get removeParticipantTitle =>
      _e ? 'Remove participant' : 'إزالة مشارك';

  static String get removeParticipantBody => _e
      ? 'Are you sure you want to remove this participant?'
      : 'هل أنت متأكد من إزالة هذا المشارك؟';

  static String get removeButton =>
      _e ? 'Remove' : 'إزالة';

  static String get cancel => _e ? 'Cancel' : 'إلغاء';

  // —— Server challenge card ——
  static String get cardCompleted =>
      _e ? 'Completed' : 'مكتمل';

  static String get cardExpired =>
      _e ? 'Ended' : 'منتهي';

  static String get cardActive =>
      _e ? 'Active' : 'نشط';

  static String get cardUpcoming =>
      _e ? 'Upcoming' : 'قادم';

  static String goalAmount(double amount) =>
      _e ? 'Goal: \$${amount.toStringAsFixed(2)}' : 'الهدف: \$${amount.toStringAsFixed(2)}';

  static String acceptedCount(int n) =>
      _e ? '$n accepted' : '$n قبلوا';

  static String participantCount(int n) =>
      n == 1 ? (_e ? '1 participant' : 'مشارك واحد') : (_e ? '$n participants' : '$n مشاركين');

  // —— Pending invitations ——
  static String get pendingTitle =>
      _e ? 'Pending invitations' : 'الدعوات المعلقة';

  static String get pendingEmpty =>
      _e ? 'No pending invitations' : 'لا توجد دعوات معلقة';

  static String get pendingStatus =>
      _e ? 'Pending' : 'معلق';

  static String fromCreator(String name) =>
      _e ? 'From: $name' : 'من: $name';

  static String totalAmount(double amount) => _e
      ? 'Total amount: \$${amount.toStringAsFixed(2)}'
      : 'المبلغ الإجمالي: \$${amount.toStringAsFixed(2)}';

  static String acceptedBeforeInvite(int n) => _e
      ? '$n participant(s) joined before the invite'
      : '$n مشارك قبل الدعوة';

  static String get splitHint => _e
      ? 'If you accept, the amount will be split evenly among all participants.'
      : 'إذا قبلت، سيتم تقسيم المبلغ بالتساوي بين جميع المشاركين';

  static String get decline =>
      _e ? 'Decline' : 'رفض';

  static String get accept =>
      _e ? 'Accept' : 'قبول';

  // —— Participant row ——
  static String get roleCreator =>
      _e ? 'Creator' : 'المنشئ';

  static String get inviteAccepted =>
      _e ? 'Accepted' : 'مقبول';

  static String get invitePendingStatus =>
      _e ? 'Pending' : 'معلق';

  static String get inviteDeclined =>
      _e ? 'Declined' : 'مرفوض';
}
