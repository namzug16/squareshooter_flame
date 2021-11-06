

import 'package:flame/components.dart';

double inverseLerp(double value, double min, double max){
  return mapValue(value, 0.0, 1.0, min, max);
}

double mapValue(double value, double minIn, double maxIn, double minOut, double maxOut){

  final double finalValue = value.clamp(minIn, maxIn);

  double result = maxOut -
      ((maxIn - finalValue) / (maxIn - minIn)) *
          (maxOut - minOut);
  return result;
}

double angleFrom(Vector2 p1, Vector2 p2){
  final x = p1.x;
  final y = p1.y;
  final translatedPoint = Vector2(p2.x - x, p2.y - y);

  return translatedPoint.screenAngle();
}