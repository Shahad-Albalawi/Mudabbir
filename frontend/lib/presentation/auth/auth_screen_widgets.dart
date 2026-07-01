import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/resources/font_manager.dart';
import 'package:mudabbir/presentation/widgets/app_brand_logo.dart';

abstract final class AuthScreenColors {
  static const lightBg = Color(0xFFFFFFFF);
  static const darkBg = Color(0xFF0A1628);
  static const lightInputBg = Color(0xFFF8FAFF);
  static const darkInputBg = Color(0xFF0F1E35);
  static const navy = Color(0xFF112E81);
  static const lightBorder = Color(0xFFE2E8F0);
  static const darkBorder = Color(0xFF1E3A5F);
  static const error = Color(0xFFEF4444);
  static const label = Color(0xFF64748B);
  static const iconMuted = Color(0xFF94A3B8);
  static const nameLight = Color(0xFF112E81);
  static const nameDark = Color(0xFFF1F5F9);
  static const subtitleLight = Color(0xFF64748B);
  static const subtitleDark = Color(0xFF94A3B8);
}

class AuthScreenPalette {
  const AuthScreenPalette({required this.isDark});

  final bool isDark;

  Color get background => isDark ? AuthScreenColors.darkBg : AuthScreenColors.lightBg;
  Color get inputBg => isDark ? AuthScreenColors.darkInputBg : AuthScreenColors.lightInputBg;
  Color get border => isDark ? AuthScreenColors.darkBorder : AuthScreenColors.lightBorder;
  Color get name => isDark ? AuthScreenColors.nameDark : AuthScreenColors.nameLight;
  Color get subtitle =>
      isDark ? AuthScreenColors.subtitleDark : AuthScreenColors.subtitleLight;
}

class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({super.key, required this.subtitle, required this.isDark});

  final String subtitle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final palette = AuthScreenPalette(isDark: isDark);
    final logo = MudabbirBrandAssets.forBrightness(isDark);

    return Column(
      children: [
        Image.asset(
          logo,
          width: 72,
          height: 72,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(height: 12),
        Text(
          AppStrings.authAppBrandName,
          style: TextStyle(
            fontFamily: FontConstants.fontFamily,
            fontFamilyFallback: FontConstants.fontFamilyFallback,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: palette.name,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            fontFamily: FontConstants.fontFamily,
            fontFamilyFallback: FontConstants.fontFamilyFallback,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: palette.subtitle,
          ),
        ),
      ],
    );
  }
}

class PremiumAuthField extends StatefulWidget {
  const PremiumAuthField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    required this.isDark,
    this.keyboardType,
    this.obscurable = false,
    this.textInputAction,
    this.focusNode,
    this.nextFocusNode,
    this.autofillHints,
    this.validator,
    this.onEditingComplete,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool isDark;
  final TextInputType? keyboardType;
  final bool obscurable;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final Iterable<String>? autofillHints;
  final String? Function(String value)? validator;
  final VoidCallback? onEditingComplete;

  @override
  State<PremiumAuthField> createState() => PremiumAuthFieldState();
}

class PremiumAuthFieldState extends State<PremiumAuthField> {
  late final FocusNode _focusNode;
  bool _ownsFocusNode = false;
  bool _obscure = true;
  String? _error;
  bool _blurred = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      setState(() {
        _blurred = true;
        _validate();
      });
      return;
    }
    setState(() {});
  }

  void _validate() {
    final error = widget.validator?.call(widget.controller.text);
    setState(() => _error = error);
  }

  bool validate() {
    _blurred = true;
    _validate();
    return _error == null;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AuthScreenPalette(isDark: widget.isDark);
    final focused = _focusNode.hasFocus;
    final hasError = _blurred && _error != null && _error!.isNotEmpty;

    Color borderColor = palette.border;
    if (hasError) {
      borderColor = AuthScreenColors.error;
    } else if (focused) {
      borderColor = AuthScreenColors.navy;
    }

    final iconColor = focused ? AuthScreenColors.navy : AuthScreenColors.iconMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontFamily: FontConstants.fontFamily,
            fontFamilyFallback: FontConstants.fontFamilyFallback,
            fontSize: 13,
            color: AuthScreenColors.label,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 52,
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscurable && _obscure,
            textInputAction: widget.textInputAction,
            autofillHints: widget.autofillHints,
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontFamilyFallback: FontConstants.fontFamilyFallback,
              fontSize: 16,
              color: palette.name,
            ),
            onEditingComplete: () {
              if (widget.nextFocusNode != null) {
                widget.nextFocusNode!.requestFocus();
              } else {
                widget.onEditingComplete?.call();
              }
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: palette.inputBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              prefixIcon: Icon(widget.icon, size: 20, color: iconColor),
              suffixIcon: widget.obscurable
                  ? IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: AuthScreenColors.iconMuted,
                      ),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: hasError ? AuthScreenColors.error : AuthScreenColors.navy,
                ),
              ),
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: hasError
              ? Padding(
                  key: ValueKey(_error),
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      fontFamily: FontConstants.fontFamily,
                      fontSize: 12,
                      color: AuthScreenColors.error,
                    ),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('no-error')),
        ),
      ],
    );
  }
}

class PasswordStrengthBar extends StatelessWidget {
  const PasswordStrengthBar({super.key, required this.password});

  final String password;

  int get _score {
    if (password.isEmpty) return 0;
    var score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Za-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;
    return score.clamp(0, 4);
  }

  @override
  Widget build(BuildContext context) {
    final score = _score;
    const colors = [
      Color(0xFFEF4444),
      Color(0xFFF59E0B),
      Color(0xFF10B981),
      Color(0xFF112E81),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: List.generate(4, (index) {
          final active = index < score;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsetsDirectional.only(end: index < 3 ? 6 : 0),
              decoration: BoxDecoration(
                color: active
                    ? colors[math.min(score - 1, 3)]
                    : AuthScreenColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class AuthPrimaryButton extends StatefulWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
    this.shakeTrigger = 0,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onPressed;
  final int shakeTrigger;

  @override
  State<AuthPrimaryButton> createState() => _AuthPrimaryButtonState();
}

class _AuthPrimaryButtonState extends State<AuthPrimaryButton>
    with TickerProviderStateMixin {
  late final AnimationController _pressController;
  late final AnimationController _shakeController;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 100),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scale = Tween<double>(begin: 1, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant AuthPrimaryButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shakeTrigger != oldWidget.shakeTrigger && widget.shakeTrigger > 0) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final shake = math.sin(_shakeController.value * math.pi * 4) * 6;
        return Transform.translate(
          offset: Offset(shake * (1 - _shakeController.value), 0),
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: widget.isLoading ? null : (_) => _pressController.forward(),
        onTapUp: widget.isLoading
            ? null
            : (_) {
                _pressController.reverse();
                widget.onPressed();
              },
        onTapCancel: () => _pressController.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AuthScreenColors.navy,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        widget.label,
                        style: const TextStyle(
                          fontFamily: FontConstants.fontFamily,
                          fontFamilyFallback: FontConstants.fontFamilyFallback,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthOutlineButton extends StatelessWidget {
  const AuthOutlineButton({
    super.key,
    required this.label,
    required this.isDark,
    required this.onPressed,
  });

  final String label;
  final bool isDark;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AuthScreenColors.label,
          side: BorderSide(
            color: isDark ? AuthScreenColors.darkBorder : AuthScreenColors.lightBorder,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: FontConstants.fontFamily,
            fontFamilyFallback: FontConstants.fontFamilyFallback,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AuthScreenColors.iconMuted, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            AppStrings.authOrDivider,
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontFamilyFallback: FontConstants.fontFamilyFallback,
              fontSize: 13,
              color: AuthScreenColors.iconMuted,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AuthScreenColors.iconMuted, height: 1)),
      ],
    );
  }
}

String? validateAuthEmail(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return AppStrings.validationEmailRequired;
  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(text)) {
    return AppStrings.validationEmailInvalid;
  }
  return null;
}

String? validateAuthPassword(String? value) {
  final text = value ?? '';
  if (text.isEmpty) return AppStrings.validationPasswordRequired;
  if (text.length < 8) return AppStrings.validationPasswordMinLength;
  return null;
}

String? validateAuthName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return AppStrings.authNameRequired;
  }
  return null;
}

String? validateAuthConfirmPassword(String? value, String password) {
  if (value == null || value.isEmpty) {
    return AppStrings.authConfirmPasswordRequired;
  }
  if (value != password) return AppStrings.validationPasswordMismatch;
  return null;
}
