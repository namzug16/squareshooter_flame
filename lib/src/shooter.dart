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
    double size = 3,
  }) : bodyColor = color, super(size: Vector2.all(size));

  Color bodyColor;

  void resetColor() => bodyColor = color;

  /// Used to check if the game has started or no
  bool isActive = true;

  bool isDead = false;

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

  bool get isAttacking => bulletCreator.timer.isRunning();

  Vector2 getDirectionVectorToTarget() {
    final targetPosition = target?.position ?? Vector2.zero();
    return (targetPosition - position).normalized();
  }

  void _createBullet() {
    if (target == null) return;

    final dv = getDirectionVectorToTarget();

    final padding = size.x * 1.8;

    final bullet = Bullet(
      owner: this,
      color: color,
      size: size.x * 0.3,
      /// initial position will be the center of the shooter
      /// plus the size plus a padding towards the target position
      initialPosition: position + (dv * padding),
      dir: dv,
    );

    game.add(bullet);
  }

  bool attack(double dt) {
    bodyColor = color;
    // setVelocityLimit(0.5);
    if (!bulletCreator.timer.isRunning()) {
      bulletCreator.timer.start();
    }
    return true;
  }

  bool stopAttack(double dt) {
    bulletCreator.timer.stop();
    return true;
  }

  //}}}

  Shooter? target;

  /// Bullet logic should have been inside the
  /// [ShooterAttackStateShoot] state but
  /// because I wanted to create only once the bulletCreator
  /// I decided to put it here
  late TimerComponent bulletCreator;

  // Rect area() {
  //   final size = this.size * 2;
  //   return Rect.fromLTWH(
  //     body.worldCenter.x - size,
  //     body.worldCenter.y - size,
  //     size * 2,
  //     size * 2,
  //   );
  // }

  Paint _paint = Paint()..color = Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // debugMode = true;
    bulletCreator = TimerComponent(
      period: 0.3,
      repeat: true,
      autoStart: false,
      onTick: _createBullet,
    );
    add(bulletCreator);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // ! hitboxes
    // renderHitboxes(canvas);
    // canvas.translate(size.x * 0.5, size.x * 0.5);

    canvas.save();
    canvas.rotate(rotation);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCircle(
          center: Offset.zero,
          radius: size.x,
        ),
        const Radius.circular(1),
      ),
      Paint()..color = bodyColor,
    );
    canvas.restore();
  }

  static const double _rotationFactor = 0.09;
  double rotation = 0;

  void _updateRotation() {
    rotation += _rotationFactor;
  }

  void _limiPositionInsideOfScreen() {
    final bottomRight = game.screenToWorld(game.camera.viewport.effectiveSize);
    body.setTransform(
      Vector2(
        body.position.x.clamp(0.0, bottomRight.x),
        body.position.y.clamp(0.0, bottomRight.y),
      ),
      body.angle,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateRotation();
    _limiPositionInsideOfScreen();
  }

  /// Velocity values are set as methods so that they can be
  // /// overridden by different types of shooters
  // double get velocityLimit => _velocityLimit;
  //
  // static const double _baseMaxVelocity = 1.5;
  //
  // double _velocityLimit = _baseMaxVelocity;
  //
  // void setVelocityLimit(double? limit) {
  //   if (limit == null) {
  //     _velocityLimit = maxVelocity();
  //     return;
  //   }
  //   _velocityLimit = limit;
  // }

  // double maxVelocity() => _baseMaxVelocity;

  // double acceleration() => 0.1;
  //
  // double deceleration() => 0.05;
  //
  // Vector2 vel = Vector2(0, 0);
  //
  // void updateVelocity(bool isDecelerating) {
  //   vel = (isDecelerating ? vel - Vector2.all(deceleration()) : vel + Vector2.all(acceleration()))..clamp(Vector2.zero(), Vector2.all(velocityLimit));
  // }

  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);
    if (other is LaserComponent && other.owner != this && other.activated) {
      isDead = true;
      return;
    }
    if (other is Bullet && other.owner != this) {
      isStunned = true;
    }
  }

  //NOTE: MOVEMENT {{{
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

    final speed = 10;
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
