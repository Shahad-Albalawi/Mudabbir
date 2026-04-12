import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/presentation/resources/color_manager.dart';
import 'package:mudabbir/presentation/resources/server_challenge_strings.dart';
import 'package:mudabbir/presentation/resources/font_manager.dart';
import 'package:mudabbir/presentation/resources/styles_manager.dart';
import 'package:mudabbir/presentation/server_challenges/providers/challenge_provider.dart';
import 'package:mudabbir/presentation/server_challenges/providers/challenge_state.dart';
import 'package:intl/intl.dart';

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
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
        Navigator.pop(context);
      } else if (next is ChallengeOperationError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: ColorManager.error,
          ),
        );
      }
    });

    final operationState = ref.watch(challengeOperationProvider);
    final isLoading = operationState is ChallengeOperationLoading;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ColorManager.primary,
              ColorManager.primary.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(
                            ServerChallengeStrings.sectionDetails,
                          ),
                          const SizedBox(height: 16),
                          _buildNameField(),
                          const SizedBox(height: 16),
                          _buildAmountField(),
                          const SizedBox(height: 24),
                          _buildSectionTitle(
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            ServerChallengeStrings.createTitle,
            style: getBoldStyle(fontSize: FontSize.s24, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: getBoldStyle(fontSize: FontSize.s16, color: ColorManager.darkGrey),
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
          style: date != null
              ? getRegularStyle(
                  fontSize: FontSize.s16,
                  color: ColorManager.darkGrey,
                )
              : getRegularStyle(
                  fontSize: FontSize.s16,
                  color: ColorManager.grey,
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
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorManager.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleCreate,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(ServerChallengeStrings.createSubmit),
      ),
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
          backgroundColor: ColorManager.error,
        ),
      );
      return;
    }

    if (_endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ServerChallengeStrings.pickEndDate),
          backgroundColor: ColorManager.error,
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
