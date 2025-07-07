import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:square_shooter_flame/main.dart';
import 'package:square_shooter_flame/src/helpers.dart';
import 'package:square_shooter_flame/src/shooter.dart';

class LaserComponent extends PositionComponent with HasGameRef<SquareShooter>, CollisionCallbacks {
  final Vector2 initialPosition;
  final Vector2 directionVector;
  final Color color;
  final Shooter owner;
  final double strokeWidth;

  LaserComponent({
    required this.initialPosition,
    required this.directionVector,
    required this.color,
    required this.owner,
    required this.strokeWidth,
  });

  bool activated = false;

  void detach() {
    activated = false;
    removeFromParent();
  }

  late final _t = Timer(
    0.5,
    onTick: () {
      activated = true;
    }
  );

  @override
  void update(double dt) {
    super.update(dt);
    _t.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.save();
    final start = initialPosition;
    final end = initialPosition + directionVector * (game.size.x * 2);
    final path = Path()
      ..moveTo(start.x, start.y)
      ..lineTo(end.x, end.y);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = inverseLerp(_t.progress, 0, strokeWidth)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }
}

// class Laser extends PositionComponent with HasHitboxes, Collidable {
//   final Color activatedColor = const Color.fromRGBO(244, 102, 71, 1);
//
//   final Color color;
//   final String owner;
//   final double dir;
//   final double time;
//   double _factor = 0;
//
//   Laser(
//       {required Vector2 position,
//       required this.color,
//       required this.dir,
//       required this.owner,
//       this.time = 40.0})
//       : super(
//           position: position,
//           size: Vector2(2000, 2 * pi),
//           anchor: Anchor.centerLeft,
//         );
//
//   @override
//   Future<void>? onLoad() async {
//     await super.onLoad();
//     addHitbox(HitboxRectangle(relation: Vector2.all(0.95)));
//     _factor = 2 * pi / time;
//     collidableType = CollidableType.active;
//     actualColor = color;
//     angle = dir - pi / 2;
//   }
//
//   Color actualColor = Colors.white;
//
//   @override
//   void render(Canvas canvas) {
//     super.render(canvas);
//     // ! hitboxes
//     // renderHitboxes(canvas);
//     canvas.save();
//     canvas.translate(55, 0);
//     canvas.drawRect(
//         Rect.fromLTWH(0, 0, width, sweepAngle), Paint()..color = actualColor);
//     canvas.restore();
//     canvas.drawArc(
//         Rect.fromCircle(center: Offset.zero, radius: 55),
//         0,
//         sweepAngle,
//         false,
//         Paint()
//           ..color = actualColor
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = sweepAngle);
//   }
//
//   double sweepAngle = 0.0;
//
//   @override
//   void update(double dt) {
//     super.update(dt);
//     if (sweepAngle < 2 * pi) sweepAngle += _factor;
//     isActivated();
//   }
//
//   bool isActivatedVar = false;
//
//   void isActivated() {
//     final v1 = sweepAngle.toString().substring(0, 10);
//     final v2 = (2 * pi).toString().substring(0, 10);
//
//     if (v1 == v2) {
//       actualColor = activatedColor;
//       isActivatedVar = true;
//     }
//   }
// }
