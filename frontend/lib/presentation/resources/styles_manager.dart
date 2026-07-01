import 'package:mudabbir/presentation/resources/design_tokens.dart';
import 'package:mudabbir/presentation/resources/font_manager.dart';
import 'package:flutter/material.dart';

TextStyle _getStyle(
  double fontSize,
  FontWeight fontWeight,
  Color color, {
  double height = AppTypographyScale.bodyHeight,
  double letterSpacing = AppTypographyScale.bodyTracking,
}) {
  return TextStyle(
    inherit: false,
    fontFamily: FontConstants.fontFamily,
    fontFamilyFallback: FontConstants.fontFamilyFallback,
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
    textBaseline: TextBaseline.alphabetic,
  );
}

TextStyle getRegularStyle({
  double fontSize = FontSize.s12,
  required Color color,
  double? height,
  double? letterSpacing,
}) {
  return _getStyle(
    fontSize,
    FontWeightManager.regular,
    color,
    height: height ?? AppTypographyScale.bodyHeight,
    letterSpacing: letterSpacing ?? AppTypographyScale.bodyTracking,
  );
}

TextStyle getMediumStyle({
  double fontSize = FontSize.s12,
  required Color color,
  double? height,
  double? letterSpacing,
}) {
  return _getStyle(
    fontSize,
    FontWeightManager.medium,
    color,
    height: height ?? AppTypographyScale.bodyHeight,
    letterSpacing: letterSpacing ?? AppTypographyScale.bodyTracking,
  );
}

TextStyle getBoldStyle({
  double fontSize = FontSize.s12,
  required Color color,
  double? height,
  double? letterSpacing,
}) {
  return _getStyle(
    fontSize,
    FontWeightManager.medium,
    color,
    height: height ?? AppTypographyScale.titleHeight,
    letterSpacing: letterSpacing ?? AppTypographyScale.titleTracking,
  );
}

TextStyle getSemiBoldStyle({
  double fontSize = FontSize.s12,
  required Color color,
  double? height,
  double? letterSpacing,
}) {
  return _getStyle(
    fontSize,
    FontWeightManager.medium,
    color,
    height: height ?? AppTypographyScale.titleHeight,
    letterSpacing: letterSpacing ?? AppTypographyScale.titleTracking,
  );
}

TextStyle getLightStyle({
  double fontSize = FontSize.s12,
  required Color color,
  double? height,
  double? letterSpacing,
}) {
  return _getStyle(
    fontSize,
    FontWeightManager.regular,
    color,
    height: height ?? AppTypographyScale.bodyHeight,
    letterSpacing: letterSpacing ?? AppTypographyScale.bodyTracking,
  );
}
