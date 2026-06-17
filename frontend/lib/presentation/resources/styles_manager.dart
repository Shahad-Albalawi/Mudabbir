import 'package:mudabbir/presentation/resources/font_manager.dart';
import 'package:flutter/material.dart';

TextStyle _getStyle(double fontSize, FontWeight fontWeight, Color color) {
  return TextStyle(
    fontFamily: FontConstants.thmanyahFamily,
    fontFamilyFallback: FontConstants.fontFamilyFallback,
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: 1.4,
    letterSpacing: 0.15,
  );
}

// regular style
TextStyle getRegularStyle({
  double fontSize = FontSize.s12,
  required Color color,
}) {
  return _getStyle(fontSize, FontWeightManager.regular, color);
}

// medium style
TextStyle getMediumStyle({
  double fontSize = FontSize.s12,
  required Color color,
}) {
  return _getStyle(fontSize, FontWeightManager.medium, color);
}

// bold style
TextStyle getBoldStyle({double fontSize = FontSize.s12, required Color color}) {
  return _getStyle(fontSize, FontWeightManager.bold, color);
}

// semi bold
TextStyle getSemiBoldStyle({
  double fontSize = FontSize.s12,
  required Color color,
}) {
  return _getStyle(fontSize, FontWeightManager.semibold, color);
}

// light style
TextStyle getLightStyle({
  double fontSize = FontSize.s12,
  required Color color,
}) {
  return _getStyle(fontSize, FontWeightManager.light, color);
}
