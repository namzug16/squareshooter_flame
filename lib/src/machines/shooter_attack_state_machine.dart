// // ignore: missing_override_of_must_be_overridden
// import 'dart:math';
//
// import 'package:flame/components.dart';
// import 'package:flame_forge2d/flame_forge2d.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/painting.dart';
// import 'package:square_shooter_flame/finite_state_machina/finite_state_machina.dart';
// import 'package:square_shooter_flame/src/helpers.dart';
// import 'package:square_shooter_flame/src/laser.dart';
// import 'package:square_shooter_flame/src/machines/shooter_state_machine.dart';
// import 'package:square_shooter_flame/src/progress_component.dart';
// import 'package:square_shooter_flame/src/shooter.dart';
//
// sealed class ShooterAttackState extends MachineState<Shooter> {
//   @override
//   @mustCallSuper
//   MachineState<Shooter>? transition(double dt) {
//     if (parent.isDead || parent.target == null || parent.target!.isDead) {
//       return ShooterAttackStateNone();
//     }
//     if (parent.target!.isStunned &&
//         this is! ShooterAttackStateStun &&
//         this is! ShooterAttackStateLaser) {
//       return ShooterAttackStateLaser();
//     }
//     return super.transition(dt);
//   }
// }
//
// /// NONE
// base class ShooterAttackStateNone extends ShooterAttackState {}
//
// /// STUN
// final class ShooterAttackStateStun extends ShooterAttackState {
//   bool isStunned = false;
//
//   /// Reentry is allowed because the stun timer/state is reset
//   /// every time the user is hit by a bullet.
//   @override
//   bool acceptsReentry() => true;
//
//   late ProgressComponent progressComponent;
//
//   final _stunnedTime = 1.0;
//
//   double progress = 0.8;
//
//   @override
//   void enterState(ShooterAttackState oldState) {
//     parent.bodyColor = Shooter.stunnedColor;
//     isStunned = true;
//     parent.setVelocityLimit(0.1);
//     progressComponent = ProgressComponent(
//         lowerBound: 0,
//         upperBound: 0.8,
//         period: _stunnedTime,
//         updateProgress: (progress) {
//           this.progress = 0.8 - progress;
//         },
//         onTick: () {
//           isStunned = false;
//         });
//     parent.game.add(
//       progressComponent,
//     );
//   }
//
//   @override
//   void exitState(ShooterAttackState newState) {
//     parent.bodyColor = Shooter.primaryColor;
//     parent.setVelocityLimit(null);
//     if (isStunned) {
//       parent.game.remove(progressComponent);
//     }
//   }
//
//   @override
//   void render(Canvas canvas) {
//     final paint = Paint()
//       ..color = Shooter.stunnedColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = progress;
//
//     final size = parent.size * 2;
//
//     canvas.drawCircle(
//       Offset.zero,
//       size,
//       paint,
//     );
//   }
// }
//
// /// SHOOT
// base class ShooterAttackStateShoot extends ShooterAttackState {
//   @override
//   bool acceptsForcedStateFrom(MachineState<Shooter> state) {
//     // if (parent.baseFSM.state is ShooterStateDead ||
//     //     parent.target == null ||
//     //     parent.target!.baseFSM.state is ShooterStateDead) {
//     //   return false;
//     // }
//     return true;
//   }
//
//   @override
//   void enterState(ShooterAttackState oldState) {
//     parent.bodyColor = parent.color;
//     parent.setVelocityLimit(0.5);
//     parent.startFire();
//   }
//
//   @override
//   void exitState(ShooterAttackState newState) {
//     parent.bodyColor = Shooter.primaryColor;
//     parent.setVelocityLimit(null);
//     parent.stopFire();
//   }
//
//   @override
//   void render(Canvas canvas) {
//     final size = parent.size;
//     final angle = parent.getAngleBetweenTarget();
//     final aimSize = size * 3;
//     final startAimSize = size * 2;
//     final aimPaint = Paint()
//       ..color = parent.color
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 0.3
//       ..strokeCap = StrokeCap.round;
//     canvas.drawLine(
//       Offset(startAimSize * sin(angle), startAimSize * -cos(angle)),
//       Offset(aimSize * sin(angle), aimSize * -cos(angle)),
//       aimPaint,
//     );
//     canvas.save();
//     canvas.rotate(angle - pi / 2);
//     canvas.drawArc(
//       Rect.fromCircle(center: Offset.zero, radius: size * 2),
//       0,
//       -pi / 4,
//       false,
//       aimPaint,
//     );
//     canvas.drawArc(
//       Rect.fromCircle(center: Offset.zero, radius: size * 2),
//       0,
//       pi / 4,
//       false,
//       aimPaint,
//     );
//     canvas.restore();
//   }
// }
//
// /// LASER
// base class ShooterAttackStateLaser extends ShooterAttackState {
//   late ProgressComponent _laserProgress;
//
//   double _laserProgressValue = 0;
//   double _laserProgressWidth = 0.2;
//
//   /// Laser will be shot after the charging time
//   /// has finished
//   bool _shootingLaser = false;
//
//   double _angleBetweenWhenActivated = 0;
//
//   @override
//   void enterState(ShooterAttackState oldState) {
//     parent.bodyColor = parent.color;
//     parent.setVelocityLimit(0.0);
//     _laserProgress = ProgressComponent(
//       period: 0.5,
//       lowerBound: 0,
//       upperBound: pi * 1.7,
//       updateProgress: (progress) {
//         _laserProgressValue = progress / 2;
//         _laserProgressWidth = mapValue(
//           progress,
//           0,
//           pi * 2,
//           0.2,
//           1,
//         );
//       },
//       onTick: () {
//         _shootingLaser = true;
//         _angleBetweenWhenActivated = parent.getAngleBetweenTarget();
//       },
//     );
//     parent.add(_laserProgress);
//   }
//
//   @override
//   void exitState(ShooterAttackState newState) {
//     parent.setVelocityLimit(null);
//     parent.bodyColor = Shooter.primaryColor;
//     _removeLaser();
//   }
//
//   @override
//   void render(Canvas canvas) {
//     canvas.save();
//     canvas.rotate(parent.getAngleBetweenTarget() + pi / 2);
//     final circleDisplacement = parent.size * 2;
//     canvas.drawCircle(
//       Offset(-circleDisplacement, 0),
//       mapValue(
//         _laserProgressValue * 2,
//         0,
//         pi * 1.7,
//         0.1,
//         1.3,
//       ),
//       Paint()..color = parent.color,
//     );
//     canvas.drawArc(
//       Rect.fromCircle(center: Offset.zero, radius: parent.size * 2),
//       0,
//       -_laserProgressValue,
//       false,
//       Paint()
//         ..color = parent.color
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = _laserProgressWidth
//         ..strokeCap = StrokeCap.round,
//     );
//     canvas.drawArc(
//       Rect.fromCircle(center: Offset.zero, radius: parent.size * 2),
//       0,
//       _laserProgressValue,
//       false,
//       Paint()
//         ..color = parent.color
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = _laserProgressWidth
//         ..strokeCap = StrokeCap.round,
//     );
//     canvas.restore();
//   }
//
//   int _laserPartsAdded = 0;
//   final List<LaserComponent> _laserParts = [];
//
//   @override
//   void stateLogic(double dt) {
//     if (_shootingLaser && _laserPartsAdded < 20) {
//       _laserPartsAdded++;
//       final laserPart = LaserComponent(
//         owner: parent,
//         color: parent.color,
//         initialPosition: Vector2(
//           parent.body.worldCenter.x +
//               (((LaserComponent.width * 2 * _laserPartsAdded) + parent.size) *
//                   sin(_angleBetweenWhenActivated)),
//           parent.body.worldCenter.y +
//               (((LaserComponent.width * 2 * _laserPartsAdded) + parent.size) *
//                   -cos(_angleBetweenWhenActivated)),
//         ),
//         rotation: _angleBetweenWhenActivated,
//       );
//       _laserParts.add(laserPart);
//       parent.game.add(
//         laserPart,
//       );
//     }
//   }
//
//   void _removeLaser() {
//     for (int i = 0; i < _laserParts.length; i++) {
//       _laserParts[i].deactivate();
//     }
//   }
//
//   @override
//   ShooterAttackState? transition(double dt) {
//     // if (parent.baseFSM.state is ShooterStateDead) {
//     //   return ShooterAttackStateNone();
//     // }
//     return super.transition(dt) as ShooterAttackState?;
//   }
// }
