import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/server_challenge_strings.dart';
import 'package:mudabbir/presentation/server_challenges/providers/challenge_provider.dart';
import 'package:mudabbir/presentation/server_challenges/providers/challenge_state.dart';
import 'package:intl/intl.dart';
import 'package:mudabbir/presentation/widgets/app_grouped_scaffold.dart';
import 'package:mudabbir/presentation/widgets/app_loading_button.dart';

class CreateChallengeScreen extends ConsumerStatefulWidget {
  const CreateChallengeScreen({super.key});

  @override
  ConsumerState<CreateChallengeScreen> createState() =>
      _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends ConsumerState<CreateChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ChallengeOperationState>(challengeOperationProvider, (
      previous,
      next,
    ) {
      if (next is ChallengeOperationSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else if (next is ChallengeOperationError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    final operationState = ref.watch(challengeOperationProvider);
    final isLoading = operationState is ChallengeOperationLoading;

    return AppGroupedScaffold(
      onBackPressed: () => Navigator.pop(context),
      titleText: ServerChallengeStrings.createTitle,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppLayout.pageGutter),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(
                context,
                ServerChallengeStrings.sectionDetails,
              ),
              const SizedBox(height: 16),
              _buildNameField(),
              const SizedBox(height: 16),
              _buildAmountField(),
              const SizedBox(height: 24),
              _buildSectionTitle(
                context,
                ServerChallengeStrings.sectionSchedule,
              ),
              const SizedBox(height: 16),
              _buildDateFields(context),
              const SizedBox(height: 40),
              _buildCreateButton(isLoading),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.textMuted,
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: ServerChallengeStrings.fieldChallengeName,
        hintText: ServerChallengeStrings.hintChallengeName,
        prefixIcon: const Icon(Icons.flag),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return ServerChallengeStrings.valNameRequired;
        }
        if (value.length < 3) {
          return ServerChallengeStrings.valNameMin;
        }
        return null;
      },
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: InputDecoration(
        labelText: ServerChallengeStrings.fieldTargetAmount,
        hintText: ServerChallengeStrings.hintTargetAmount,
        prefixIcon: const Icon(Icons.currency_exchange),
        prefix: Text(ServerChallengeStrings.currencyAmountPrefix),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return ServerChallengeStrings.valAmountRequired;
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return ServerChallengeStrings.valAmountInvalid;
        }
        return null;
      },
    );
  }

  Widget _buildDateFields(BuildContext context) {
    return Column(
      children: [
        _buildDateField(
          context: context,
          label: ServerChallengeStrings.startDateLabel,
          icon: Icons.calendar_today,
          date: _startDate,
          onTap: () => _selectDate(context, isStartDate: true),
        ),
        const SizedBox(height: 16),
        _buildDateField(
          context: context,
          label: ServerChallengeStrings.endDateLabel,
          icon: Icons.event,
          date: _endDate,
          onTap: () => _selectDate(context, isStartDate: false),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required IconData icon,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMMM d, yyyy');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          date != null
              ? dateFormat.format(date)
              : ServerChallengeStrings.chooseDate,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: date != null
                    ? scheme.onSurface
                    : scheme.textMuted,
              ),
        ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isStartDate,
  }) async {
    final initialDate = isStartDate
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());

    final firstDate = isStartDate
        ? DateTime.now()
        : (_startDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        final scheme = Theme.of(context).colorScheme;
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: scheme),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Reset end date if it's before new start date
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Widget _buildCreateButton(bool isLoading) {
    return AppLoadingButton(
      isLoading: isLoading,
      label: ServerChallengeStrings.createSubmit,
      onPressed: _handleCreate,
    );
  }

  void _handleCreate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ServerChallengeStrings.pickStartDate),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ServerChallengeStrings.pickEndDate),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final amount = double.parse(_amountController.text.trim());

    ref
        .read(challengeOperationProvider.notifier)
        .createChallenge(
          name: _nameController.text.trim(),
          amount: amount,
          startDate: _startDate!,
          endDate: _endDate!,
        );
  }
}
