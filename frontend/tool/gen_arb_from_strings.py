#!/usr/bin/env python3
"""One-off helper: extract AppStrings getters into ARB templates."""
import json
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "tool/strings_source.dart")

text = open(SRC, encoding="utf-8").read()
pairs = []
pattern = re.compile(
    r"static String get (\w+) =>\s*_isEnglish\s*\?\s*(?:'((?:\\'|[^'])*)'|\"((?:\\\"|[^\"])*)\")\s*:\s*(?:'((?:\\'|[^'])*)'|\"((?:\\\"|[^\"])*)\")\s*;",
    re.MULTILINE,
)
multiline_pattern = re.compile(
    r"static String get (\w+) => _isEnglish\s*\n\s*\?\s*(?:'((?:\\'|[^'])*)'|\"((?:\\\"|[^\"])*)\")\s*\n\s*:\s*(?:'((?:\\'|[^'])*)'|\"((?:\\\"|[^\"])*)\")\s*;",
    re.MULTILINE,
)

def _pick_pair(m):
    en = (m.group(2) or m.group(3) or '').replace("\\'", "'").replace('\\"', '"')
    ar = (m.group(4) or m.group(5) or '').replace("\\'", "'").replace('\\"', '"')
    return en, ar

for m in pattern.finditer(text):
    key = m.group(1)
    en, ar = _pick_pair(m)
    pairs.append((key, en, ar))
for m in multiline_pattern.finditer(text):
    key = m.group(1)
    if any(p[0] == key for p in pairs):
        continue
    en, ar = _pick_pair(m)
    pairs.append((key, en, ar))

en = {"@@locale": "en"}
ar = {"@@locale": "ar"}
for key, e, a in pairs:
    en[key] = e
    ar[key] = a

extras_en = {
    "txSuccessIncome": "Income added successfully! 🎉",
    "txSuccessExpense": "Expense added successfully! 🎉",
    "txNoCategories": "No {type} categories found.",
    "txLoadFailed": "Failed to load data: {error}",
    "goalLine": "Goal: {name}",
    "challengeLine": "Challenge: {name}",
    "barChartIncome": "Income",
    "barChartExpenses": "Expenses",
    "barChartBalance": "Balance",
    "journeyMotivationComplete": "Congratulations! 🎉 Goal reached!",
    "journeyMotivation75": "Amazing! 💪 You are so close!",
    "journeyMotivation50": "Excellent! 🔥 Keep going!",
    "journeyMotivation25": "Strong start! 🎯 Keep it up!",
    "journeyMotivationStart": "First step! 🌟 Keep going!",
    "journeyMotivationZero": "Start your journey toward the goal! 🚀",
    "chatWelcomeMessage": "Hi! I'm Mudabbir, your smart money assistant. How can I help you today?",
}
extras_ar = {
    "txSuccessIncome": "تم إضافة الدخل بنجاح! 🎉",
    "txSuccessExpense": "تم إضافة المصروف بنجاح! 🎉",
    "txNoCategories": "لا توجد فئات {type}.",
    "txLoadFailed": "فشل تحميل البيانات: {error}",
    "goalLine": "الهدف: {name}",
    "challengeLine": "التحدي: {name}",
    "barChartIncome": "الدخل",
    "barChartExpenses": "المصروفات",
    "barChartBalance": "الرصيد",
    "journeyMotivationComplete": "مبروك! 🎉 وصلت للهدف!",
    "journeyMotivation75": "رائع! 💪 أنت قريب جداً!",
    "journeyMotivation50": "ممتاز! 🔥 استمر في التقدم!",
    "journeyMotivation25": "بداية موفقة! 🎯 واصل التقدم!",
    "journeyMotivationStart": "خطوة أولى رائعة! 🌟 استمر!",
    "journeyMotivationZero": "ابدأ رحلتك نحو الهدف! 🚀",
    "chatWelcomeMessage": "مرحباً! أنا مدبر، مساعدك الذكي في إدارة الأموال. كيف يمكنني مساعدتك اليوم؟",
}
en.update(extras_en)
ar.update(extras_ar)

for key in ("txNoCategories", "txLoadFailed", "goalLine", "challengeLine"):
    placeholder = {
        "txNoCategories": {"type": {"type": "String"}},
        "txLoadFailed": {"error": {"type": "Object"}},
        "goalLine": {"name": {"type": "String"}},
        "challengeLine": {"name": {"type": "String"}},
    }[key]
    en[f"@{key}"] = {"placeholders": placeholder}

out_dir = os.path.join(ROOT, "lib/l10n")
os.makedirs(out_dir, exist_ok=True)
with open(os.path.join(out_dir, "app_en.arb"), "w", encoding="utf-8") as f:
    json.dump(en, f, ensure_ascii=False, indent=2)
with open(os.path.join(out_dir, "app_ar.arb"), "w", encoding="utf-8") as f:
    json.dump(ar, f, ensure_ascii=False, indent=2)

skip = {
    "txSuccessIncome",
    "txSuccessExpense",
    "txNoCategories",
    "txLoadFailed",
    "goalLine",
    "challengeLine",
    "barChartIncome",
    "barChartExpenses",
    "barChartBalance",
    "journeyMotivationComplete",
    "journeyMotivation75",
    "journeyMotivation50",
    "journeyMotivation25",
    "journeyMotivationStart",
    "journeyMotivationZero",
}
keys = [k for k in en if not k.startswith("@") and k != "@@locale" and k not in skip]
getter_lines = "\n".join(f"  static String get {k} => _t.{k};" for k in keys)

facade = f'''import 'package:flutter/material.dart';
import 'package:mudabbir/l10n/app_localizations.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/language/app_language_controller.dart';

/// Backward-compatible facade over generated [AppLocalizations].
/// Prefer `context.l10n` / [AppLocalizations.of] in new UI code.
class AppStrings {{
  static AppLocalizations? _bound;

  /// Called from [MaterialApp.builder] so non-widget code can read strings.
  static void bind(AppLocalizations l10n) => _bound = l10n;

  static AppLocalizations get _t {{
    final cached = _bound;
    if (cached != null) return cached;
    try {{
      return lookupAppLocalizations(getIt<AppLanguageController>().locale);
    }} catch (_) {{
      return lookupAppLocalizations(const Locale('ar'));
    }}
  }}

  /// Use for display helpers that are not widgets (e.g. DB label mapping).
  static bool get isEnglishLocale => _t.localeName.startsWith('en');

{getter_lines}

  static String txSuccess(String type) => type == 'income'
      ? _t.txSuccessIncome
      : _t.txSuccessExpense;

  static String txNoCategories(String type) => _t.txNoCategories(type);

  static String txLoadFailed(Object e) => _t.txLoadFailed(e);

  static String goalLine(String name) => _t.goalLine(name);

  static String challengeLine(String name) => _t.challengeLine(name);

  static List<String> get barChartLabels => [
        _t.barChartIncome,
        _t.barChartExpenses,
        _t.barChartBalance,
      ];

  static String journeyMotivation(double progress) {{
    if (progress >= 1.0) return _t.journeyMotivationComplete;
    if (progress >= 0.75) return _t.journeyMotivation75;
    if (progress >= 0.5) return _t.journeyMotivation50;
    if (progress >= 0.25) return _t.journeyMotivation25;
    if (progress > 0) return _t.journeyMotivationStart;
    return _t.journeyMotivationZero;
  }}
}}
'''
facade_path = os.path.join(ROOT, "lib/presentation/resources/strings_manager.dart")
with open(facade_path, "w", encoding="utf-8", newline="\n") as f:
    f.write(facade)

print(f"Wrote {len(en)-1} EN keys from {len(pairs)} getters; facade {len(keys)} getters")

