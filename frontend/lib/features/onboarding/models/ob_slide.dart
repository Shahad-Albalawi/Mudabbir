import 'package:flutter/material.dart';

class OBSlide {
  const OBSlide({
    required this.icon,
    required this.bg,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color bg;
  final Color color;
  final String title;
  final String body;
}
