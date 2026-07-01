import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mudabbir/core/theme/app_theme.dart';
import 'package:mudabbir/core/widgets/riyal_text.dart';

/// Navy gradient hero card — balance, income, and expenses.
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expenses,
    this.lastUpdated,
  });

  final double balance;
  final double income;
  final double expenses;
  final DateTime? lastUpdated;

  static const _offWhite = Color(0xFFF5F6FA);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      decoration: AppTheme.navyGradient(),
      child: Column(
        children: [
          Text(
            'إجمالي الرصيد',
            style: AppText.regular(
              11.5,
              color: Colors.white.withValues(alpha: 0.62),
            ),
          ),
          const SizedBox(height: 5),
          RiyalText(
            amount: balance,
            fontSize: 34,
            color: _offWhite,
            bold: true,
          ),
          const SizedBox(height: 3),
          Text(
            _formatDate(context),
            style: AppText.regular(
              11,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.14),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildBalanceCol(
                  label: 'الدخل',
                  amount: income,
                  icon: Icons.arrow_upward_rounded,
                  iconColor: AppColors.success,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: Colors.white.withValues(alpha: 0.14),
              ),
              Expanded(
                child: _buildBalanceCol(
                  label: 'المصروف',
                  amount: expenses,
                  icon: Icons.arrow_downward_rounded,
                  iconColor: AppColors.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCol({
    required String label,
    required double amount,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
            Text(
              label,
              style: AppText.regular(
                10,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 2),
            RiyalText(
              amount: amount,
              fontSize: 15,
              color: _offWhite,
              bold: true,
            ),
          ],
          ),
        ),
        const SizedBox(width: 9),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.97),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
      ],
    );
  }

  String _formatDate(BuildContext context) {
    final now = lastUpdated ?? DateTime.now();
    final month = DateFormat('MMMM', 'ar').format(now);
    return '$month ${now.year} · محدّث الآن';
  }
}
