import 'package:flutter/material.dart';
import 'package:mudabbir/constants/app_theme.dart';

/// Backward-compatible accessors — prefer [AppTheme.light] / [AppTheme.dark].
ThemeData getApplicationTheme() => AppTheme.light;

ThemeData getApplicationDarkTheme() => AppTheme.dark;
