import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/navigation_service.dart';

class PopupWidgets {
  static Widget textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) =>
      TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      );

  static Widget amountField(TextEditingController ctrl) => TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: AppStrings.fieldAmount,
          prefixIcon: const Icon(Icons.attach_money),
        ),
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: false,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        ],
        validator: (val) {
          if (val?.isEmpty ?? true) return AppStrings.fieldAmountRequired;
          final num? n = num.tryParse(val!);
          if (n == null) return AppStrings.fieldAmountInvalid;
          if (n <= 0) return AppStrings.fieldAmountPositive;
          return null;
        },
      );

  static Widget notesField(TextEditingController ctrl) => TextFormField(
        controller: ctrl,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: AppStrings.fieldNotes,
          prefixIcon: const Icon(Icons.note),
        ),
        validator: (val) {
          if (val != null && val.length > 500) {
            return AppStrings.fieldNotesTooLong;
          }
          return null;
        },
      );

  static Widget dateField(
    TextEditingController ctrl,
    BuildContext ctx, {
    String? label,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label ?? AppStrings.fieldDate,
        prefixIcon: const Icon(Icons.calendar_today),
      ),
      validator: validator,
      onTap: () async {
        final date = await showDatePicker(
          context: ctx,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) ctrl.text = date.toIso8601String().split('T')[0];
      },
    );
  }

  /// [formatItemLabel] maps DB `name` to a localized display string.
  static Widget dropdownField<T>({
    required T? value,
    required String label,
    required List<dynamic> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
    String Function(String rawName)? formatItemLabel,
    String Function(T value)? itemLabel,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: items.map((i) {
        if (i is Map<String, dynamic>) {
          final raw = i['name']?.toString() ?? '';
          final display = formatItemLabel != null ? formatItemLabel(raw) : raw;
          return DropdownMenuItem<T>(
            value: i['id'] as T,
            child: Text(display),
          );
        }
        final v = i as T;
        final text = itemLabel != null ? itemLabel(v) : v.toString();
        return DropdownMenuItem<T>(value: v, child: Text(text));
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  static Widget dialogTitle(String text, String type) => Row(
        children: [
          Icon(
            type == 'income'
                ? Icons.add_circle
                : type == 'expense'
                    ? Icons.remove_circle
                    : Icons.flag,
            color: type == 'income'
                ? Colors.green
                : type == 'expense'
                    ? Colors.red
                    : const Color(0xFF1F7A54),
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      );

  static void showSuccessSnackBar(BuildContext ctx, String msg) =>
      getIt<NavigationService>().showSuccessSnackbar(
        title: AppStrings.snackSuccessTitle,
        body: msg,
      );

  static void showErrorSnackBar(BuildContext ctx, String msg) =>
      getIt<NavigationService>().showErrorSnackbar(
        title: AppStrings.snackErrorTitle,
        body: msg,
      );
}
