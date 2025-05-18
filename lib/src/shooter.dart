import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:square_shooter_flame/main.dart';
import 'package:square_shooter_flame/src/behavior_tree/behavior_tree_stateless.dart';
import 'package:square_shooter_flame/src/bullet.dart';
import 'package:square_shooter_flame/src/progress_component.dart';

class Shooter extends PositionComponent with HasGameReference<SquareShooter>, CollisionCallbacks {
  static const Color stunnedColor = Color.fromRGBO(244, 102, 71, 1);

  final Color color;

  final Vector2 initialPosition;

  Shooter({
    required this.color,
    required this.initialPosition,
    double size = 60,
  })  : bodyColor = color,
        super(size: Vector2.all(size), anchor: Anchor.center, position: initialPosition);

  Color bodyColor;

  void resetColor() => bodyColor = color;

  /// Used to check if the game has started or no
  bool isActive = true;

  bool isDead = false;

  late SpawnComponent bulletSpawner;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    debugMode = gameDebugMode;
    bulletSpawner = SpawnComponent(
      period: 0.2,
      selfPositioning: true,
      factory: (index) {
        return _createBullet();
      },
      autoStart: false,
    );
    game.add(bulletSpawner);
    add(CircleHitbox.relative(
      1.0,
      parentSize: size,
      anchor: anchor,
      position: size * 0.5,
    ));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    //FIX: render aim when shooting
    _renderAim(canvas);
    canvas.save();
    canvas.translate(size.x * 0.5, size.x * 0.5);
    canvas.rotate(_rotation);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCircle(
          center: Offset.zero,
          radius: size.x / 2,
        ),
        const Radius.circular(10),
      ),
      Paint()..color = bodyColor,
    );
    canvas.restore();
  }

  static const double _rotationFactor = 0.09;
  double _rotation = 0;

  void _updateRotation() {
    _rotation += _rotationFactor;
  }

  void _limiPositionInsideOfScreen() {
    final gs = game.size;
    final newPos = Vector2(position.x, position.y)..clamp(Vector2(0, 0), gs);
    position = newPos;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateRotation();
    _limiPositionInsideOfScreen();
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    // if (other is LaserComponent && other.owner != this && other.activated) {
    //   isDead = true;
    //   return;
    // }

    if (other is Bullet && other.owner != this) {
      isStunned = true;
    }
  }

  //NOTE: Stun {{{

  bool hasCollidedWithBullet = false;

  bool isStunned = false;

  TimerComponent? _stunTimer;

  bool setStunnedValues(double dt) {
    bodyColor = stunnedColor;
    // setVelocityLimit(0.1);
    return true;
  }

  bool? tickStunTimer(double dt) {
    if (_stunTimer == null) {
      _stunTimer = TimerComponent(
        period: 1,
        removeOnFinish: true,
      );
      add(_stunTimer!);
      add(ProgressComponent(lowerBound: 0, upperBound: 0.8, period: 1, onTick: () {}));
      return null;
    }

    if (_stunTimer?.isRemoved ?? false) {
      _stunTimer = null;
      isStunned = false;
      return true;
    }

    return null;
  }

  //}}}

  //NOTE: Attack {{{

  Shooter? target;

  bool get isAttacking => bulletSpawner.timer.isRunning();

  void _renderAim(Canvas canvas) {
    if (!isAttacking) return;
    final dv = getDirectionVectorToTarget();
    final fv = Vector2(1, 0).normalized();
    final angle = math.acos(fv.dot(dv));
    final sign = fv.cross(dv) >= 0 ? 1.0 : -1.0;
    final signedAngle = angle * sign;
    final aimSize = size.x * 2.2;
    final startAimSize = size.x * 1.2;
    final aimPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(size.x * 0.5, size.x * 0.5);
    canvas.drawLine(
      (dv * startAimSize).toOffset(),
      (dv * aimSize).toOffset(),
      aimPaint,
    );
    canvas.restore();
    canvas.save();
    canvas.translate(size.x * 0.5, size.x * 0.5);
    canvas.rotate(signedAngle);
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: size.x),
      13 * math.pi / 8,
      3 * math.pi / 4,
      false,
      aimPaint,
    );
    canvas.restore();
  }

  Vector2 getDirectionVectorToTarget() {
    final targetPosition = target?.position ?? Vector2.zero();
    return (targetPosition - position).normalized();
  }

  Bullet _createBullet() {
    final dv = getDirectionVectorToTarget();

    final padding = size.x * 0.5;

    final bullet = Bullet(
      owner: this,
      color: color,
      size: size.x * 0.4,
      initialPosition: position + (dv * padding),
      dir: dv,
    );

    return bullet;
  }

  bool attack(double dt) {
    bodyColor = color;
    // setVelocityLimit(0.5);
    if (!bulletSpawner.timer.isRunning()) {
      bulletSpawner.timer.start();
    }
    return true;
  }

  bool stopAttack(double dt) {
    bulletSpawner.timer.stop();
    return true;
  }

  //}}}

  //NOTE: Movement {{{
  double? movementStepLimit;

  bool? resetMovementStepLimit(double dt) {
    movementStepLimit = null;
    return true;
  }

  BTNode setMovementStepLimit(double step) {
    return (_) {
      movementStepLimit = step;
      return true;
    };
  }

  final speed = 130;
  //}}}
}

// void render(Canvas canvas) {
//   final size = parent.size;
//   final angle = parent.getAngleBetweenTarget();
//   final aimSize = size * 3;
//   final startAimSize = size * 2;
//   final aimPaint = Paint()
//     ..color = parent.color
//     ..style = PaintingStyle.stroke
//     ..strokeWidth = 0.3
//     ..strokeCap = StrokeCap.round;
//   canvas.drawLine(
//     Offset(startAimSize * sin(angle), startAimSize * -cos(angle)),
//     Offset(aimSize * sin(angle), aimSize * -cos(angle)),
//     aimPaint,
//   );
//   canvas.save();
//   canvas.rotate(angle - pi / 2);
//   canvas.drawArc(
//     Rect.fromCircle(center: Offset.zero, radius: size * 2),
//     0,
//     -pi / 4,
//     false,
//     aimPaint,
//   );
//   canvas.drawArc(
//     Rect.fromCircle(center: Offset.zero, radius: size * 2),
//     0,
//     pi / 4,
//     false,
//     aimPaint,
//   );
//   canvas.restore();
// }

//NOTE: better movement for components
// // Example in C#
// float speed = 5.0f; // speed in units per second
// float distance = Vector2.Distance(pv1, pv2);
// float duration = distance / speed;
//
// // Within your Update or coroutine:
// elapsedTime += Time.deltaTime;
// float t = Mathf.Clamp01(elapsedTime / duration);
//
// // Using SmoothStep for easing (acceleration then deceleration)
// float easedT = Mathf.SmoothStep(0f, 1f, t);
//
// // Interpolate position using the eased value
// Vector2 newPosition = Vector2.Lerp(pv1, pv2, easedT);
// transform.position = new Vector3(newPosition.x, newPosition.y, transform.position.z);
//
// float EaseInOutQuad(float t) {
//     return t < 0.5f ? 2 * t * t : -1 + (4 - 2 * t) * t;
// }
//
// // Then use it similarly:
// float easedT = EaseInOutQuad(t);
// Vector2 newPosition = Vector2.Lerp(pv1, pv2, easedT);
