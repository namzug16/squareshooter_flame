import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:square_shooter_flame/src/helpers.dart';

class CountDownTimer extends TimerComponent {
  final Function callback;
  final Vector2 position;

  CountDownTimer({
    required this.callback,
    required this.position,
  }) : super(
          period: 3,
          removeOnFinish: true,
          onTick: () {
            callback.call();
          },
        );

  double sweepAngle = 0;
  int time = 0;
  final paint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5.0
    ..strokeCap = StrokeCap.round;

  static const double size = 30;

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(position.x - size / 2, position.y - size / 2);
    canvas.drawArc(Vector2.all(size).toRect(), 0, sweepAngle, false, paint);
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: time.toString(),
        style: const TextStyle(fontSize: size, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(size / 2 - tp.width / 2, size / 2 - tp.height / 2));
    canvas.restore();
  }

  @override
  void update(double dt) {
    super.update(dt);
    sweepAngle = inverseLerp(timer.progress, 0.0, 2 * pi);
    time = inverseLerp(timer.progress, 0.0, 3.0).floor();
  }
}
