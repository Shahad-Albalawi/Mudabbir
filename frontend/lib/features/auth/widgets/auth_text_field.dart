import 'package:flutter/material.dart';
import 'package:mudabbir/core/theme/app_colors.dart';
import 'package:mudabbir/core/theme/app_theme.dart';

/// حقل إدخال RTL — أيقونة زخرفية على اليسار البصري، ارتفاع 50، حواف 13px.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onFieldSubmitted,
    this.validator,
    this.trailing,
  });

  static const double fieldHeight = 50;
  static const double fieldRadius = 13;

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onFieldSubmitted;
  final String? Function(String?)? validator;
  final Widget? trailing;

  InputBorder _border(Color color, {double width = 1}) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadius),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onFieldSubmitted: onFieldSubmitted,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      validator: validator,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colors.textPrimary,
          ),
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        hintText: label,
        isDense: true,
        contentPadding: const EdgeInsetsDirectional.only(
          start: 14,
          end: 44,
          top: 14,
          bottom: 14,
        ),
        constraints: const BoxConstraints(minHeight: fieldHeight),
        filled: true,
        fillColor: isDark ? colors.surfaceElevated : colors.surface,
        suffixIcon: Padding(
          padding: const EdgeInsetsDirectional.only(start: 12, end: 4),
          child: Icon(icon, size: 20, color: colors.textTertiary),
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        prefixIcon: trailing,
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        enabledBorder: _border(colors.border),
        focusedBorder: _border(AppColors.navy1, width: 1.5),
        errorBorder: _border(AppColors.red),
        focusedErrorBorder: _border(AppColors.red, width: 1.5),
        errorStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.red,
              fontSize: 12,
              height: 1.3,
            ),
        errorMaxLines: 2,
      ),
    );
  }
}
