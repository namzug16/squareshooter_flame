import 'package:flame/components.dart';
import 'package:flutter/material.dart';

double inverseLerp(double value, double min, double max) {
  return mapValue(value, 0.0, 1.0, min, max);
}

double mapValue(double value, double minIn, double maxIn, double minOut, double maxOut) {
  final double finalValue = value.clamp(minIn, maxIn);

  double result = maxOut - ((maxIn - finalValue) / (maxIn - minIn)) * (maxOut - minOut);
  return result;
}

double angleFrom(Vector2 p1, Vector2 p2) {
  final x = p1.x;
  final y = p1.y;
  final translatedPoint = Vector2(p2.x - x, p2.y - y);

  return translatedPoint.screenAngle();
}

void drawText(
  Canvas canvas,
  String text,
  Offset offset, {
  TextStyle style = const TextStyle(color: Colors.pinkAccent, fontSize: 16),
  TextAlign textAlign = TextAlign.left,
  TextDirection textDirection = TextDirection.ltr,
}) {
  final textSpan = TextSpan(
    text: text,
    style: style,
  );

  final textPainter = TextPainter(
    text: textSpan,
    textAlign: textAlign,
    textDirection: textDirection,
  );

  textPainter.layout();
  textPainter.paint(canvas, offset);
}
