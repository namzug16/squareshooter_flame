import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';

class Laser extends PositionComponent with Hitbox, Collidable{

  final Color activatedColor = const Color.fromRGBO(244, 102, 71, 1);

  final Color color;
  final String owner;
  final double dir;
  final double time;
  double _factor = 0;
  Laser({
    required Vector2 position,
    required this.color,
    required this.dir,
    required this.owner,
    this.time = 40.0
})
      : super(
    position: position,
    size: Vector2(2000, 2 * pi),
    anchor: Anchor.centerLeft,
  );

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    addHitbox(HitboxRectangle(relation: Vector2.all(0.95)));
    _factor = 2 * pi / time;
    collidableType = CollidableType.active;
    actualColor = color;
    angle = dir - pi / 2;
  }

  Color actualColor = Colors.white;
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // ! hitboxes
    // renderHitboxes(canvas);
    canvas.save();
    canvas.translate(55, 0);
    canvas.drawRect(
        Rect.fromLTWH(0, 0, width, sweepAngle), Paint()..color = actualColor);
    canvas.restore();
    canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: 55),
        0,
        sweepAngle,
        false,
        Paint()
          ..color = actualColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = sweepAngle);
  }

  double sweepAngle = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    if (sweepAngle < 2 * pi) sweepAngle += _factor;
    isActivated();
  }

  bool isActivatedVar = false;
  void isActivated(){
    final v1 = sweepAngle.toString().substring(0, 10);
    final v2 = (2*pi).toString().substring(0, 10);

    if ( v1 == v2){
      actualColor = activatedColor;
      isActivatedVar = true;
    }
  }
}
