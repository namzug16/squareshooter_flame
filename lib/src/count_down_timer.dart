import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:square_shooter_flame/main.dart';
import 'package:square_shooter_flame/src/helpers.dart';

class CountDownTimer extends TimerComponent with HasGameReference<SquareShooterGame> {
  final Function callback;
  final Vector2 position;

  CountDownTimer({
    required this.callback,
    required this.position,
  }) : super(period: 5, removeOnFinish: true, onTick: () => callback.call());

  double _sweepAngle = 0;
  int _time = 0;
  double _size = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _size = game.size.x * 0.15;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    canvas.save();
    canvas.translate(position.x, position.y);
    canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: _size), 0, _sweepAngle, false, paint);
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: _time.toString(),
        style: TextStyle(fontSize: _size, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(- tp.width / 2, - tp.height / 2));
    canvas.restore();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _sweepAngle = inverseLerp(timer.progress, 0.0, 2 * pi);
    _time = inverseLerp(timer.progress, 5.0, 0.0).floor() + 1;
  }
}
