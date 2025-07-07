import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:square_shooter_flame/main.dart';
import 'package:square_shooter_flame/src/bullet.dart';
import 'package:square_shooter_flame/src/progress_component.dart';

enum ShooterState { idle, stunned, shooting, killing }

class Shooter extends PositionComponent
    with HasGameReference<SquareShooter>, CollisionCallbacks {
  static const Color stunnedColor = Color.fromRGBO(244, 102, 71, 1);

  final Color color;

  final Vector2 initialPosition;

  Shooter(
      {required this.color, required this.initialPosition, double size = 60})
      : bodyColor = color,
        super(
            size: Vector2.all(size),
            anchor: Anchor.center,
            position: initialPosition);

  Color bodyColor;

  /// Used to check if the game has started or no
  bool isActive = true;

  bool isDead = false;

  ShooterState state = ShooterState.idle;

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
    add(CircleHitbox.relative(1.0,
        parentSize: size, anchor: anchor, position: size * 0.5));
  }

  //NOTE: State Machines {{{

  bool? Function(double dt) transitionStateFromBT(ShooterState newState) {
    return (_) {
      transitionState(newState);
      return true;
    };
  }

  void transitionState(ShooterState newState) {
    onExitState();
    state = newState;
    onEnterBaseState();
  }

  void onExitState() {
    switch (state) {
      case ShooterState.idle:
      case ShooterState.stunned:
        resetMovementStepLimit();
        resetColor();
      case ShooterState.shooting:
        resetMovementStepLimit();
      case ShooterState.killing:
        resetMovementStepLimit();
    }
  }

  void onEnterBaseState() {
    switch (state) {
      case ShooterState.idle:
      case ShooterState.stunned:
        setStunnedColor();
        setMovementStepLimitOnStunned();
      case ShooterState.shooting:
        setMovementStepLimitOnShooting();
      case ShooterState.killing:
        setMovementStepLimitOnKilling();
    }
  }
  //}}}

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _renderAim(canvas);
    canvas.save();
    canvas.translate(size.x * 0.5, size.x * 0.5);
    canvas.rotate(_rotation);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCircle(center: Offset.zero, radius: size.x / 2),
            const Radius.circular(10)),
        Paint()..color = bodyColor);
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
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    // if (other is LaserComponent && other.owner != this && other.activated) {
    //   isDead = true;
    //   return;
    // }

    if (other is Bullet && other.owner != this) {
      transitionState(ShooterState.stunned);
    }
  }

  void resetColor() {
    bodyColor = color;
  }

  //NOTE: Stun {{{

  TimerComponent? _stunTimer;

  void setStunnedColor() {
    bodyColor = stunnedColor;
  }

  bool? tickStunTimer(double dt) {
    if (_stunTimer == null) {
      _stunTimer = TimerComponent(period: 1, removeOnFinish: true);
      add(_stunTimer!);
      add(ProgressComponent(
          lowerBound: 0, upperBound: 0.8, period: 1, onTick: () {}));
      return null;
    }

    if (_stunTimer?.isRemoved ?? false) {
      _stunTimer = null;
      transitionState(ShooterState.idle);
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
        (dv * startAimSize).toOffset(), (dv * aimSize).toOffset(), aimPaint);
    canvas.restore();
    canvas.save();
    canvas.translate(size.x * 0.5, size.x * 0.5);
    canvas.rotate(signedAngle);
    canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: size.x),
        13 * math.pi / 8, 3 * math.pi / 4, false, aimPaint);
    canvas.restore();
  }

  Vector2 getDirectionVectorToTarget() {
    final targetPosition = target?.position ?? Vector2.zero();
    return (targetPosition - position).normalized();
  }

  Bullet _createBullet() {
    final dv = getDirectionVectorToTarget();

    final padding = size.x * 1.5;

    final bullet = Bullet(
        owner: this,
        color: color,
        size: size.x * 0.4,
        initialPosition: position + (dv * padding),
        dir: dv);

    return bullet;
  }

  bool attack(double dt) {
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

  bool canAttack() => (target?.distance(this) ?? 0) > size.x * 3;

  void resetMovementStepLimit() {
    movementStepLimit = null;
  }

  void _setMovementStepLimit(double step) {
    movementStepLimit = step;
  }

  void setMovementStepLimitOnShooting() {
    _setMovementStepLimit(0.03);
  }

  void setMovementStepLimitOnKilling() {
    _setMovementStepLimit(0);
  }

  void setMovementStepLimitOnStunned() {
    _setMovementStepLimit(0.01);
  }

  final speed = 130;
  //}}}
}
