import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/presentation/resources/assets_manager.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';

/// Marketing landing page for Flutter Web / iframe embed.
class LandingPage extends StatelessWidget {
  const LandingPage({
    super.key,
    this.onGetStarted,
  });

  final VoidCallback? onGetStarted;

  static const _features = <_FeatureItem>[
    _FeatureItem(
      icon: Icons.account_balance_wallet_outlined,
      title: 'تتبّع مصروفاتك',
      description: 'سجّل دخلك ومصاريفك وراقب رصيدك الشهري بلمحة واحدة.',
      tint: Color(0xFFEEF2FF),
    ),
    _FeatureItem(
      icon: Icons.flag_outlined,
      title: 'أهداف ادخار ذكية',
      description: 'حدّد أهدافك وتابع تقدّمك مع تنبيهات وتحفيز مستمر.',
      tint: Color(0xFFECFDF5),
    ),
    _FeatureItem(
      icon: Icons.auto_awesome_outlined,
      title: 'مساعد مالي بالذكاء الاصطناعي',
      description: 'اسأل مُدَبِّر عن ميزانيتك واحصل على نصائح مخصّصة لك.',
      tint: Color(0xFFF0F9FF),
    ),
  ];

  static const _screenshots = <_ScreenshotItem>[
    _ScreenshotItem(
      asset: 'assets/marketing/home.png',
      label: 'الرئيسية',
    ),
    _ScreenshotItem(
      asset: 'assets/marketing/statistics.png',
      label: 'الإحصائيات',
    ),
    _ScreenshotItem(
      asset: 'assets/marketing/goals.png',
      label: 'الأهداف',
    ),
    _ScreenshotItem(
      asset: 'assets/marketing/chatbot.png',
      label: 'المساعد الذكي',
    ),
  ];

  void _handleGetStarted(BuildContext context) {
    if (onGetStarted != null) {
      onGetStarted!();
      return;
    }
    context.go(AppRoutes.register);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isMobile = width < 640;
            final isTablet = width >= 640 && width < 1024;
            final hPad = isMobile ? AppSpacing.md : (isTablet ? 32.0 : 48.0);
            final maxContent = isMobile ? width : 1080.0;

            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContent + hPad * 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HeroSection(
                        isMobile: isMobile,
                        horizontalPadding: hPad,
                        onGetStarted: () => _handleGetStarted(context),
                      ),
                      _FeaturesSection(
                        features: _features,
                        isMobile: isMobile,
                        horizontalPadding: hPad,
                      ),
                      _ScreenshotsSection(
                        items: _screenshots,
                        isMobile: isMobile,
                        horizontalPadding: hPad,
                      ),
                      _CtaSection(
                        isMobile: isMobile,
                        horizontalPadding: hPad,
                        onGetStarted: () => _handleGetStarted(context),
                      ),
                      SizedBox(height: isMobile ? AppSpacing.lg : AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero
// ---------------------------------------------------------------------------

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.isMobile,
    required this.horizontalPadding,
    required this.onGetStarted,
  });

  final bool isMobile;
  final double horizontalPadding;
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        isMobile ? 48 : 72,
        horizontalPadding,
        isMobile ? 40 : 64,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.navy, AppColors.navyLight],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: isMobile ? 72 : 88,
            height: isMobile ? 72 : 88,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfLight,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: AppShadows.lg(),
            ),
            child: Image.asset(
              ImageAssets.logoLight,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: isMobile ? AppSpacing.lg : AppSpacing.xl),
          Text(
            'مُدَبِّر — تحكّم في مالك',
            textAlign: TextAlign.center,
            style: AppTypography.headlineMedium(AppColors.onPrimary).copyWith(
              fontSize: isMobile ? 28 : 36,
              fontWeight: AppFontWeights.bold,
              height: 1.25,
            ),
          ),
          const SizedBox(height: AppSpacing.sm + 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              'تطبيق عربي لإدارة أموالك الشخصية — ميزانية، أهداف، تحليلات، ومساعد ذكي.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge(
                AppColors.onPrimary.withValues(alpha: 0.85),
              ).copyWith(height: 1.55),
            ),
          ),
          SizedBox(height: isMobile ? AppSpacing.lg : AppSpacing.xl),
          _PrimaryButton(
            label: 'ابدأ مجاناً',
            onPressed: onGetStarted,
            large: !isMobile,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Features
// ---------------------------------------------------------------------------

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection({
    required this.features,
    required this.isMobile,
    required this.horizontalPadding,
  });

  final List<_FeatureItem> features;
  final bool isMobile;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        isMobile ? AppSpacing.xl : 56,
        horizontalPadding,
        isMobile ? AppSpacing.lg : AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'لماذا مُدَبِّر؟',
            textAlign: TextAlign.center,
            style: AppTypography.headlineSmall(AppColors.navy).copyWith(
              fontWeight: AppFontWeights.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'كل ما تحتاجه لإدارة أموالك في مكان واحد',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium(AppColors.textSecondaryLight),
          ),
          SizedBox(height: isMobile ? AppSpacing.lg : AppSpacing.xl),
          isMobile
              ? Column(
                  children: [
                    for (var i = 0; i < features.length; i++) ...[
                      _FeatureCard(item: features[i]),
                      if (i < features.length - 1)
                        const SizedBox(height: AppSpacing.md),
                    ],
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < features.length; i++) ...[
                      Expanded(child: _FeatureCard(item: features[i])),
                      if (i < features.length - 1)
                        const SizedBox(width: AppSpacing.md),
                    ],
                  ],
                ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.item});

  final _FeatureItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 4),
      decoration: BoxDecoration(
        color: AppColors.surfLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppShadows.sm(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: item.tint,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(item.icon, color: AppColors.navy, size: 26),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            item.title,
            style: AppTypography.titleMedium(AppColors.navy).copyWith(
              fontWeight: AppFontWeights.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            item.description,
            style: AppTypography.bodySmall(AppColors.textSecondaryLight).copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Screenshots
// ---------------------------------------------------------------------------

class _ScreenshotsSection extends StatelessWidget {
  const _ScreenshotsSection({
    required this.items,
    required this.isMobile,
    required this.horizontalPadding,
  });

  final List<_ScreenshotItem> items;
  final bool isMobile;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final cardWidth = isMobile ? 220.0 : 240.0;
    final cardHeight = isMobile ? 420.0 : 460.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        isMobile ? AppSpacing.lg : AppSpacing.xl,
        horizontalPadding,
        isMobile ? AppSpacing.lg : AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'شاهد التطبيق',
            textAlign: TextAlign.center,
            style: AppTypography.headlineSmall(AppColors.navy).copyWith(
              fontWeight: AppFontWeights.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'واجهة عربية أنيقة على iOS و Android والويب',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium(AppColors.textSecondaryLight),
          ),
          SizedBox(height: isMobile ? AppSpacing.lg : AppSpacing.xl),
          SizedBox(
            height: cardHeight + 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                return _ScreenshotCard(
                  item: items[index],
                  width: cardWidth,
                  height: cardHeight,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ScreenshotCard extends StatelessWidget {
  const _ScreenshotCard({
    required this.item,
    required this.width,
    required this.height,
  });

  final _ScreenshotItem item;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          Container(
            height: height,
            decoration: BoxDecoration(
              color: AppColors.surfLight,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: AppShadows.md(),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              item.asset,
              fit: BoxFit.cover,
              width: width,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.gray100,
                alignment: Alignment.center,
                child: Icon(
                  Icons.smartphone_outlined,
                  size: 48,
                  color: AppColors.navy.withValues(alpha: 0.35),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            item.label,
            style: AppTypography.labelLarge(AppColors.navy).copyWith(
              fontWeight: AppFontWeights.medium,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CTA
// ---------------------------------------------------------------------------

class _CtaSection extends StatelessWidget {
  const _CtaSection({
    required this.isMobile,
    required this.horizontalPadding,
    required this.onGetStarted,
  });

  final bool isMobile;
  final double horizontalPadding;
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? AppSpacing.md : AppSpacing.xl,
          vertical: isMobile ? AppSpacing.lg : 40,
        ),
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.lg(),
        ),
        child: Column(
          children: [
            Text(
              'ابدأ رحلتك المالية اليوم',
              textAlign: TextAlign.center,
              style: AppTypography.titleLarge(AppColors.onPrimary).copyWith(
                fontWeight: AppFontWeights.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'مجاني — بدون التزام. سجّل في دقيقة وتحكّم بأموالك.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium(
                AppColors.onPrimary.withValues(alpha: 0.82),
              ),
            ),
            SizedBox(height: isMobile ? AppSpacing.md : AppSpacing.lg),
            _PrimaryButton(
              label: 'ابدأ مجاناً',
              onPressed: onGetStarted,
              inverted: true,
              large: !isMobile,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared button
// ---------------------------------------------------------------------------

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.inverted = false,
    this.large = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool inverted;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final bg = inverted ? AppColors.surfLight : AppColors.onPrimary;
    final fg = inverted ? AppColors.navy : AppColors.navy;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      elevation: 0,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: large ? 36 : 28,
            vertical: large ? 16 : 14,
          ),
          child: Text(
            label,
            style: AppTypography.labelLarge(fg).copyWith(
              fontWeight: AppFontWeights.bold,
              fontSize: large ? 16 : 15,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

class _FeatureItem {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.tint,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color tint;
}

class _ScreenshotItem {
  const _ScreenshotItem({
    required this.asset,
    required this.label,
  });

  final String asset;
  final String label;
}
