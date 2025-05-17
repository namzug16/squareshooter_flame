// import 'package:flame_forge2d/flame_forge2d.dart';
// import 'package:flutter/material.dart';
// import 'package:square_shooter_flame/main.dart';
// import 'package:square_shooter_flame/src/progress_component.dart';
// import 'package:square_shooter_flame/src/shooter.dart';
//
// class LaserComponent extends BodyComponent<SquareShooter> {
//   static const double width = 8;
//   static const double height = 0.5;
//
//   final Vector2 initialPosition;
//   final double rotation;
//   final Color color;
//   final Shooter owner;
//
//   LaserComponent({
//     required this.initialPosition,
//     required this.rotation,
//     required this.color,
//     required this.owner,
//   }) {
//     paint = Paint()..color = Colors.transparent;
//   }
//
//   double _paintLaserStrokeWidth = LaserComponent.height * 2;
//
//   bool get activated => _activated;
//   bool _activated = true;
//
//   void deactivate() {
//     game.add(
//       ProgressComponent(
//         lowerBound: 0,
//         upperBound: LaserComponent.height * 2,
//         period: 0.5,
//         updateProgress: (progress) {
//           _paintLaserStrokeWidth = (LaserComponent.height * 2) - progress;
//         },
//         onTick: () {
//           removeFromParent();
//         },
//       ),
//     );
//     _activated = false;
//   }
//
//   @override
//   Body createBody() {
//     final shape = PolygonShape()
//       ..setAsBox(
//         LaserComponent.height,
//         LaserComponent.width,
//         Vector2.zero(),
//         rotation,
//       );
//     final fixtureDef = FixtureDef(shape)
//       ..restitution = 0.0
//       ..density = 0.0
//       ..friction = 0.0
//       ..isSensor = true;
//     final bodyDef = BodyDef()
//       ..position = initialPosition
//       ..userData = this
//       ..type = BodyType.dynamic;
//     return world.createBody(bodyDef)..createFixture(fixtureDef);
//   }
//
//   @override
//   void render(Canvas canvas) {
//     super.render(canvas);
//     canvas.save();
//     canvas.rotate(rotation);
//     final path = Path()
//       ..moveTo(0, -LaserComponent.width)
//       ..lineTo(0, LaserComponent.width);
//     canvas.drawPath(
//       path,
//       Paint()
//         ..color = color
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = _paintLaserStrokeWidth
//         ..strokeCap = StrokeCap.round
//         ..strokeJoin = StrokeJoin.round,
//     );
//     canvas.restore();
//   }
// }
//
// // class Laser extends PositionComponent with HasHitboxes, Collidable {
// //   final Color activatedColor = const Color.fromRGBO(244, 102, 71, 1);
// //
// //   final Color color;
// //   final String owner;
// //   final double dir;
// //   final double time;
// //   double _factor = 0;
// //
// //   Laser(
// //       {required Vector2 position,
// //       required this.color,
// //       required this.dir,
// //       required this.owner,
// //       this.time = 40.0})
// //       : super(
// //           position: position,
// //           size: Vector2(2000, 2 * pi),
// //           anchor: Anchor.centerLeft,
// //         );
// //
// //   @override
// //   Future<void>? onLoad() async {
// //     await super.onLoad();
// //     addHitbox(HitboxRectangle(relation: Vector2.all(0.95)));
// //     _factor = 2 * pi / time;
// //     collidableType = CollidableType.active;
// //     actualColor = color;
// //     angle = dir - pi / 2;
// //   }
// //
// //   Color actualColor = Colors.white;
// //
// //   @override
// //   void render(Canvas canvas) {
// //     super.render(canvas);
// //     // ! hitboxes
// //     // renderHitboxes(canvas);
// //     canvas.save();
// //     canvas.translate(55, 0);
// //     canvas.drawRect(
// //         Rect.fromLTWH(0, 0, width, sweepAngle), Paint()..color = actualColor);
// //     canvas.restore();
// //     canvas.drawArc(
// //         Rect.fromCircle(center: Offset.zero, radius: 55),
// //         0,
// //         sweepAngle,
// //         false,
// //         Paint()
// //           ..color = actualColor
// //           ..style = PaintingStyle.stroke
// //           ..strokeWidth = sweepAngle);
// //   }
// //
// //   double sweepAngle = 0.0;
// //
// //   @override
// //   void update(double dt) {
// //     super.update(dt);
// //     if (sweepAngle < 2 * pi) sweepAngle += _factor;
// //     isActivated();
// //   }
// //
// //   bool isActivatedVar = false;
// //
// //   void isActivated() {
// //     final v1 = sweepAngle.toString().substring(0, 10);
// //     final v2 = (2 * pi).toString().substring(0, 10);
// //
// //     if (v1 == v2) {
// //       actualColor = activatedColor;
// //       isActivatedVar = true;
// //     }
// //   }
// // }
