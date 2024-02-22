import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:square_shooter_flame/finite_state_machina/finite_state_machina.dart';
import 'package:square_shooter_flame/main.dart';
import 'package:square_shooter_flame/src/bullet.dart';
import 'package:square_shooter_flame/src/helpers.dart';
import 'package:square_shooter_flame/src/laser.dart';
import 'package:square_shooter_flame/src/machines/shooter_attack_state_machine.dart';
import 'package:square_shooter_flame/src/machines/shooter_state_machine.dart';

class Shooter extends BodyComponent<SquareShooter>
    with ContactCallbacks, HasFiniteStateMachines<Shooter> {
  /// When shooter is just moving
  static const Color primaryColor = Color(0xFFFFFFFF);

  /// When shooter is stunned
  static const Color stunnedColor = Color.fromRGBO(244, 102, 71, 1);

  /// When shooter is attacking
  final Color color;

  /// Actual color of the body
  ///
  /// Used to change the color of the body when stunned, moving or attacking
  late Color bodyColor;

  final double size;

  final Vector2 initialPosition;

  /// Can be intended as "isAlive"
  /// Used to check if the game has started or no
  bool isActive = true;

  final FiniteStateMachine<Shooter> attackFSM;

  final FiniteStateMachine<Shooter> baseFSM;

  Shooter({
    required this.color,
    required this.initialPosition,
    this.size = 3,
    required this.attackFSM,
    required this.baseFSM,
  });

  Shooter? target;

  void registerTarget(Shooter t) {
    target = t;
  }

  /// So that we do not have the reference of the target when
  /// it has been destroyed
  void unregisterTarget() {
    target = null;
  }

  /// Bullet logic should have been inside the
  /// [ShooterAttackStateShoot] state but
  /// because I wanted to create only once the bulletCreator
  /// I decided to put it here
  late TimerComponent bulletCreator;

  Rect area() {
    final size = this.size * 2;
    return Rect.fromLTWH(
      body.worldCenter.x - size,
      body.worldCenter.y - size,
      size * 2,
      size * 2,
    );
  }

  bool get isStunned => attackFSM.state is ShooterAttackStateStun;

  bool get isDead => baseFSM.state is ShooterStateDead;

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
    paint = Paint()..color = Colors.transparent;
    bodyColor = primaryColor;

    /// EACH FSM HAS A LEVEL OF PRIORITY
    registerFSM(baseFSM);
    registerFSM(attackFSM);
  }

  @override
  Body createBody() {
    final shape = CircleShape()..radius = size;
    final fixtureDef = FixtureDef(shape)
      ..userData = this
      ..restitution = 0.0
      ..density = 0.0
      ..friction = 0.0;

    final bodyDef = BodyDef()
      ..position = initialPosition
      ..type = BodyType.static;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
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
          radius: size,
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
    rotation +=
        _rotationFactor + _rotationFactor * (vel.x > vel.y ? vel.x : vel.y);
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
  /// overridden by different types of shooters
  double get velocityLimit => _velocityLimit;

  static const double _baseMaxVelocity = 1.5;

  double _velocityLimit = _baseMaxVelocity;

  void setVelocityLimit(double? limit) {
    if (limit == null) {
      _velocityLimit = maxVelocity();
      return;
    }
    _velocityLimit = limit;
  }

  double maxVelocity() => _baseMaxVelocity;

  double acceleration() => 0.1;

  double deceleration() => 0.05;

  /// Actual velocity of the shooter
  Vector2 vel = Vector2(0, 0);

  void updateVelocity(bool isDecelerating) {
    vel = (isDecelerating
        ? vel - Vector2.all(deceleration())
        : vel + Vector2.all(acceleration()))
      ..clamp(Vector2.zero(), Vector2.all(velocityLimit));
  }

  double getAngleBetweenTarget() {
    final targetPosition = target?.body.position ?? Vector2.zero();
    return angleFrom(body.position, targetPosition);
  }

  void _createBullet() {
    if (target == null) return;

    final angleBetween = getAngleBetweenTarget();

    final padding = size * 1.8;

    final bullet = Bullet(
      owner: this,
      color: color,
      size: size * 0.4,

      /// initial position will be the center of the shooter
      /// plus the size plus a padding towards the target position
      initialPosition: body.position +
          Vector2(padding * sin(angleBetween), padding * -cos(angleBetween)),
      targetPosition: target!.body.position,
    );
    gameRef.add(bullet);
  }

  void startFire() => bulletCreator.timer.start();

  void stopFire() => bulletCreator.timer.stop();

  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);
    if (other is LaserComponent && other.owner != this && other.activated) {
      baseFSM.setState(ShooterStateDead());
      other.owner.unregisterTarget();
      return;
    }
    if (other is Bullet && other.owner != this) {
      attackFSM.setState(ShooterAttackStateStun());
    }
  }
}
