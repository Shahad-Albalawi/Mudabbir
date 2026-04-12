import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/domain/repository/planner_repository/planner_repository.dart';
import 'package:mudabbir/persentation/home/home_viewmodel.dart';
import 'package:mudabbir/persentation/resources/color_manager.dart';
import 'package:mudabbir/persentation/resources/planner_strings.dart';
import 'package:mudabbir/persentation/resources/values_manager.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/planner/planner_budget_suggester.dart';

/// Planner hub: category budgets, notes, tasks, income/currency (Hive).
class PlannerHubView extends ConsumerStatefulWidget {
  const PlannerHubView({super.key});

  @override
  ConsumerState<PlannerHubView> createState() => _PlannerHubViewState();
}

class _PlannerHubViewState extends ConsumerState<PlannerHubView> {
  final _repo = getIt<PlannerRepository>();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: scheme.surfaceContainerHigh,
            child: TabBar(
              isScrollable: true,
              labelColor: ColorManager.primary,
              unselectedLabelColor: ColorManager.grey1,
              indicatorColor: ColorManager.primary,
              tabs: [
                Tab(text: PlannerStrings.tabBudget),
                Tab(text: PlannerStrings.tabNotes),
                Tab(text: PlannerStrings.tabTasks),
                Tab(text: PlannerStrings.tabIncome),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _BudgetTab(repo: _repo, onSaved: _notifyHomeReload),
                _NotesTab(repo: _repo, onChanged: _notifyHomeReload),
                _TasksTab(repo: _repo, onChanged: _notifyHomeReload),
                _IncomeTab(onSaved: _notifyHomeReload),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _notifyHomeReload() {
    ref.read(homeProvider.notifier).reload();
  }
}

class _BudgetTab extends StatefulWidget {
  const _BudgetTab({required this.repo, required this.onSaved});

  final PlannerRepository repo;
  final VoidCallback onSaved;

  @override
  State<_BudgetTab> createState() => _BudgetTabState();
}

class _BudgetTabState extends State<_BudgetTab> {
  bool _loading = true;
  List<Map<String, dynamic>> _cats = [];
  final Map<int, TextEditingController> _limitControllers = {};
  final Map<int, double> _spent = {};
  late int _y;
  late int _m;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _y = n.year;
    _m = n.month;
    _load();
  }

  @override
  void dispose() {
    for (final c in _limitControllers.values) {
      c.dispose();
    }
    _limitControllers.clear();
    super.dispose();
  }

  void _disposeLimitControllers() {
    for (final c in _limitControllers.values) {
      c.dispose();
    }
    _limitControllers.clear();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final cats = await widget.repo.getExpenseCategories();
      final spent = <int, double>{};
      if (mounted) {
        _disposeLimitControllers();
      }
      for (final c in cats) {
        final id = c['id'] as int;
        spent[id] = await widget.repo.getSpentForCategoryInMonth(
          categoryId: id,
          year: _y,
          month: _m,
        );
        final lim = await widget.repo.getCategoryBudgetLimit(
          categoryId: id,
          year: _y,
          month: _m,
        );
        final text = lim != null && lim > 0 ? lim.toStringAsFixed(0) : '';
        _limitControllers[id] = TextEditingController(text: text);
      }
      if (mounted) {
        setState(() {
          _cats = cats;
          _spent
            ..clear()
            ..addAll(spent);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveRow(int categoryId) async {
    final raw = _limitControllers[categoryId]?.text.trim() ?? '';
    final v = double.tryParse(raw.replaceAll(',', '.'));
    if (v == null || v < 0) return;
    HapticService.light();
    await widget.repo.upsertCategoryBudget(
      categoryId: categoryId,
      amountLimit: v,
      year: _y,
      month: _m,
    );
    widget.onSaved();
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(PlannerStrings.saved)),
      );
    }
  }

  Future<void> _openSuggestSheet() async {
    final hive = getIt<HiveService>();
    final planned = hive.getValue(HiveConstants.plannerMonthlyIncome);
    double income = planned is num ? planned.toDouble() : 0;
    if (income <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(PlannerStrings.incomeSubtitle)),
      );
      return;
    }
    final suggester = PlannerBudgetSuggester(widget.repo);
    final map = await suggester.suggestForMonth(
      now: DateTime.now(),
      monthlyIncome: income,
    );
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppPadding.p16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  PlannerStrings.aiSuggestTitle,
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSize.s8),
                Text(
                  PlannerStrings.aiSuggestBody,
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSize.s12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(ctx).size.height * 0.45,
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: _cats.map((c) {
                      final id = c['id'] as int;
                      final name = c['name']?.toString() ?? '';
                      final sug = map[id] ?? 0;
                      return ListTile(
                        title: Text(name),
                        subtitle: Text(sug.toStringAsFixed(0)),
                        trailing: TextButton(
                          onPressed: () {
                            _limitControllers[id]?.text = sug.toStringAsFixed(0);
                            setState(() {});
                            Navigator.pop(ctx);
                          },
                          child: Text(PlannerStrings.applySuggestion),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CupertinoActivityIndicator());
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppPadding.p16,
          AppPadding.p16,
          AppPadding.p16,
          AppSize.s100,
        ),
        children: [
          Text(
            PlannerStrings.budgetTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSize.s8),
          Text(
            PlannerStrings.budgetSubtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSize.s12),
          OutlinedButton.icon(
            onPressed: _openSuggestSheet,
            icon: const Icon(CupertinoIcons.sparkles, size: 18),
            label: Text(PlannerStrings.aiSuggestTitle),
          ),
          const SizedBox(height: AppSize.s16),
          ..._cats.map((c) {
            final id = c['id'] as int;
            final name = c['name']?.toString() ?? '';
            final spent = _spent[id] ?? 0;
            final ctrl = _limitControllers[id];
            final lim = double.tryParse(
              (ctrl?.text ?? '').replaceAll(',', '.'),
            );
            final remaining = lim != null ? lim - spent : null;
            return Card(
              margin: const EdgeInsets.only(bottom: AppSize.s12),
              child: Padding(
                padding: const EdgeInsets.all(AppPadding.p12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: AppSize.s8),
                    TextField(
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      decoration: InputDecoration(
                        labelText: PlannerStrings.limitHint,
                        isDense: true,
                      ),
                      controller: ctrl,
                    ),
                    const SizedBox(height: AppSize.s8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${PlannerStrings.spentLabel}: ${spent.toStringAsFixed(0)}',
                          ),
                        ),
                        if (remaining != null)
                          Expanded(
                            child: Text(
                              '${PlannerStrings.remainingLabel}: ${remaining.toStringAsFixed(0)}',
                              textAlign: TextAlign.end,
                            ),
                          ),
                      ],
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: () => _saveRow(id),
                        child: Text(PlannerStrings.saveIncome),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _NotesTab extends StatefulWidget {
  const _NotesTab({required this.repo, required this.onChanged});

  final PlannerRepository repo;
  final VoidCallback onChanged;

  @override
  State<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<_NotesTab> {
  bool _loading = true;
  List<Map<String, dynamic>> _rows = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _rows = await widget.repo.getNotes();
    } catch (_) {
      _rows = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _addNote() async {
    final title = TextEditingController();
    final body = TextEditingController();
    var financial = false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) {
          return AlertDialog(
            title: Text(PlannerStrings.noteNew),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: title,
                    decoration: InputDecoration(
                      labelText: PlannerStrings.noteTitleHint,
                    ),
                  ),
                  TextField(
                    controller: body,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: PlannerStrings.noteBodyHint,
                    ),
                  ),
                  CheckboxListTile(
                    value: financial,
                    onChanged: (v) => setD(() => financial = v ?? false),
                    title: Text(PlannerStrings.noteFinancialIdea),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(PlannerStrings.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(PlannerStrings.saveIncome),
              ),
            ],
          );
        },
      ),
    );
    if (ok == true && title.text.trim().isNotEmpty) {
      await widget.repo.insertNote(
        title: title.text.trim(),
        body: body.text.trim(),
        isFinancial: financial,
      );
      widget.onChanged();
      await _load();
    }
  }

  Future<void> _toTask(Map<String, dynamic> row) async {
    final id = row['id'] as int;
    final t = row['title']?.toString() ?? '';
    final b = row['body']?.toString() ?? '';
    await widget.repo.insertTask(title: t, body: b);
    widget.onChanged();
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(PlannerStrings.noteToTask)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CupertinoActivityIndicator());
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppPadding.p12),
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilledButton.icon(
              onPressed: _addNote,
              icon: const Icon(Icons.add, size: 20),
              label: Text(PlannerStrings.noteNew),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: _rows.isEmpty
                ? ListView(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                      Center(child: Text(PlannerStrings.notesTitle)),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: AppSize.s100),
                    itemCount: _rows.length,
                    itemBuilder: (ctx, i) {
                      final r = _rows[i];
                      final id = r['id'] as int;
                      return Dismissible(
                        key: ValueKey('note_$id'),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) async {
                          await widget.repo.deleteNote(id);
                          widget.onChanged();
                          return true;
                        },
                        onDismissed: (_) => _load(),
                        background: Container(
                          color: Colors.red.shade700,
                          alignment: Alignment.centerEnd,
                          padding: const EdgeInsets.all(16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: ListTile(
                          title: Text(r['title']?.toString() ?? ''),
                          subtitle: Text(r['body']?.toString() ?? ''),
                          trailing: IconButton(
                            icon: const Icon(CupertinoIcons.arrow_right_circle),
                            onPressed: () => _toTask(r),
                            tooltip: PlannerStrings.noteToTask,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _TasksTab extends StatefulWidget {
  const _TasksTab({required this.repo, required this.onChanged});

  final PlannerRepository repo;
  final VoidCallback onChanged;

  @override
  State<_TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<_TasksTab> {
  bool _loading = true;
  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> _cats = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _tasks = await widget.repo.getTasks();
      _cats = await widget.repo.getExpenseCategories();
    } catch (_) {
      _tasks = [];
      _cats = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _addTask() async {
    final title = TextEditingController();
    final body = TextEditingController();
    int? catId;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) {
          return AlertDialog(
            title: Text(PlannerStrings.taskNew),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: title,
                    decoration: InputDecoration(
                      labelText: PlannerStrings.noteTitleHint,
                    ),
                  ),
                  TextField(
                    controller: body,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: PlannerStrings.noteBodyHint,
                    ),
                  ),
                  DropdownButtonFormField<int?>(
                    value: catId,
                    decoration: InputDecoration(
                      labelText: PlannerStrings.taskLinkBudget,
                    ),
                    items: [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text(PlannerStrings.none),
                      ),
                      ..._cats.map(
                        (c) => DropdownMenuItem<int?>(
                          value: c['id'] as int,
                          child: Text(c['name']?.toString() ?? ''),
                        ),
                      ),
                    ],
                    onChanged: (v) => setD(() => catId = v),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(PlannerStrings.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(PlannerStrings.saveIncome),
              ),
            ],
          );
        },
      ),
    );
    if (ok == true && title.text.trim().isNotEmpty) {
      await widget.repo.insertTask(
        title: title.text.trim(),
        body: body.text.trim(),
        categoryId: catId,
      );
      widget.onChanged();
      await _load();
    }
  }

  String _catName(int? id) {
    if (id == null) return '';
    for (final c in _cats) {
      if (c['id'] == id) return c['name']?.toString() ?? '';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CupertinoActivityIndicator());
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppPadding.p12),
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilledButton.icon(
              onPressed: _addTask,
              icon: const Icon(Icons.add, size: 20),
              label: Text(PlannerStrings.taskNew),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: AppSize.s100),
              itemCount: _tasks.length,
              itemBuilder: (ctx, i) {
                final t = _tasks[i];
                final id = t['id'] as int;
                final done = t['status']?.toString() == 'done';
                final cid = t['category_id'] as int?;
                final link = _catName(cid);
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppPadding.p12,
                    vertical: AppSize.s6,
                  ),
                  child: ListTile(
                    leading: Checkbox(
                      value: done,
                      onChanged: (_) async {
                        await widget.repo.updateTaskStatus(
                          id,
                          done ? 'pending' : 'done',
                        );
                        widget.onChanged();
                        await _load();
                      },
                    ),
                    title: Text(t['title']?.toString() ?? ''),
                    subtitle: Text(
                      [
                        if (link.isNotEmpty) link,
                        t['body']?.toString() ?? '',
                      ].where((e) => e.isNotEmpty).join('\n'),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        await widget.repo.deleteTask(id);
                        widget.onChanged();
                        await _load();
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _IncomeTab extends StatefulWidget {
  const _IncomeTab({required this.onSaved});

  final VoidCallback onSaved;

  @override
  State<_IncomeTab> createState() => _IncomeTabState();
}

class _IncomeTabState extends State<_IncomeTab> {
  final _income = TextEditingController();
  final _currency = TextEditingController();

  @override
  void initState() {
    super.initState();
    final hive = getIt<HiveService>();
    final inc = hive.getValue(HiveConstants.plannerMonthlyIncome);
    final cur = hive.getValue(HiveConstants.plannerCurrencyCode);
    if (inc is num) _income.text = inc.toString();
    if (cur is String && cur.isNotEmpty) {
      _currency.text = cur;
    } else {
      _currency.text = 'SAR';
    }
  }

  @override
  void dispose() {
    _income.dispose();
    _currency.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final v = double.tryParse(_income.text.replaceAll(',', '.'));
    final cur = _currency.text.trim().toUpperCase();
    final hive = getIt<HiveService>();
    if (v != null && v >= 0) {
      await hive.setValue(HiveConstants.plannerMonthlyIncome, v);
    }
    if (cur.isNotEmpty) {
      await hive.setValue(HiveConstants.plannerCurrencyCode, cur);
    }
    HapticService.light();
    widget.onSaved();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(PlannerStrings.saved)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppPadding.p20,
        AppPadding.p20,
        AppPadding.p20,
        AppSize.s100,
      ),
      children: [
        Text(
          PlannerStrings.incomeTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSize.s8),
        Text(
          PlannerStrings.incomeSubtitle,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSize.s20),
        TextField(
          controller: _income,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: PlannerStrings.incomeAmountLabel,
          ),
        ),
        const SizedBox(height: AppSize.s12),
        TextField(
          controller: _currency,
          decoration: InputDecoration(
            labelText: PlannerStrings.currencyLabel,
            hintText: PlannerStrings.currencyHint,
          ),
        ),
        const SizedBox(height: AppSize.s24),
        FilledButton(
          onPressed: _save,
          child: Text(PlannerStrings.saveIncome),
        ),
      ],
    );
  }
}
