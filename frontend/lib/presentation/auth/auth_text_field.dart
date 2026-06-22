import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/resources/design_tokens.dart';
import 'package:mudabbir/service/haptic_service.dart';

/// Shared labeled field for login and registration forms.
class AuthTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscurable;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final Iterable<String>? autofillHints;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.obscurable = false,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autofillHints,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Semantics(
      textField: true,
      label: widget.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: scheme.onSurface,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscurable && _obscure,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onFieldSubmitted,
            autofillHints: widget.autofillHints,
            textAlign: isRtl ? TextAlign.right : TextAlign.left,
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: _fieldIcon(scheme),
              suffixIcon: widget.obscurable
                  ? IconButton(
                      tooltip: _obscure
                          ? AppStrings.authShowPassword
                          : AppStrings.authHidePassword,
                      onPressed: () {
                        HapticService.selection();
                        setState(() => _obscure = !_obscure);
                      },
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: scheme.textMuted,
                        size: 20,
                      ),
                    )
                  : null,
            ),
            validator: widget.validator,
          ),
        ],
      ),
    );
  }

  Widget _fieldIcon(ColorScheme scheme) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: scheme.chromeIconFill,
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Icon(widget.icon, color: scheme.chromeIcon, size: 20),
    );
  }
}
