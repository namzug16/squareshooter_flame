import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';
import 'package:square_shooter_flame/main.dart';
import 'package:square_shooter_flame/src/bullet.dart';
import 'package:square_shooter_flame/src/effects.dart';
import 'package:square_shooter_flame/src/helpers.dart';
import 'package:square_shooter_flame/src/laser.dart';
// Attack States
enum AS { shoot, laser, none }
// Life States
enum LS { alive, dead }
// Movement States
enum MS { move, stun }

class SquareComponent extends PositionComponent
    with HasGameRef<SquareShooter>, HasHitboxes,Collidable {
  static const Color primaryColor = Color(0xFFFFFFFF);
  static const Color stunnedColor = Color.fromRGBO(244, 102, 71, 1);
  final Color uniqueColor;
  final String name;
  Color color = const Color(0xFFFFFFFF);
  late SquareComponent enemy;
  late BulletPool bulletPool;

  AS as = AS.none;
  LS ls = LS.dead;
  MS ms = MS.move;

  SquareComponent({
    required this.uniqueColor,
    required this.name,
  }) : super(
          anchor: Anchor.center,
          size: Vector2.all(60),
          position: Vector2.all(500),
        );

  void init(SquareComponent e, Vector2 initialPos, BulletPool bPool) {
    enemy = e;
    position = initialPos;
    bulletPool = bPool;
  }

  void activate() {
    ls = LS.alive;
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    super.render(canvas);
    // ! hitboxes
    // renderHitboxes(canvas);
    canvas.drawRRect(
        RRect.fromRectAndRadius(size.toRect(), const Radius.circular(5)),
        Paint()..color = color);
    canvas.restore();
    canvas.save();
    renderAim(canvas);
    canvas.restore();
    renderStun(canvas);
    // ? render area
    // canvas.save();
    // canvas.drawRect(area, Paint()..color=Colors.blue.withOpacity(0.3));
    // canvas.restore();
  }

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    addHitbox(HitboxRectangle(relation: Vector2.all(1)));
  }

  Rect area = Rect.fromCenter(
    center: Offset.zero,
    width: 10,
    height: 10,
  );

  void updateArea() {
    final s = size.x * 6;
    area = Rect.fromCenter(center: center.toOffset(), width: s, height: s);
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateRotation();
    if (ls == LS.alive && enemy.ls == LS.alive) {
      stateLogic();
      handleMovement();
      updateAim();
      stunHandler();
      shootTimer?.update(dt);

      if (ms == MS.stun) {
        vel.clamp(Vector2.zero(), Vector2.all(stunnedVelocity));
      }
      updateArea();
      position.clamp(Vector2.zero(), gameRef.size);
    }
  }

  final double maxVelocity = 12;
  final double shootingVelocity = 6;
  final double stunnedVelocity = 2;
  final double acc = 0.5;
  Vector2 vel = Vector2(0, 0);

  void handleMovement() {}

  double rotation = 0.02;

  void updateRotation() {
    angle += rotation + rotation * (vel.x > vel.y ? vel.x : vel.y);
  }

  Timer? shootTimer;
  bool isShooting = false;

  void shoot() {
    shootTimer ??= Timer(0.4,
        onTick: () => bulletPool.shoot(uniqueColor, position, aimAngle, name),
        repeat: true)
      ..start();
    if (!shootTimer!.isRunning()) shootTimer!.start();
    isShooting = true;
  }

  void cancelShoot() {
    shootTimer?.stop();
    isShooting = false;
  }

  static const startAimSize = 60;
  static const aimSize = startAimSize + 30;

  void renderAim(Canvas c) {
    if (isShooting) {
      final aimPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;

      c.drawLine(
          center.toOffset() +
              Offset(
                  startAimSize * sin(aimAngle), startAimSize * -cos(aimAngle)),
          center.toOffset() +
              Offset(aimSize * sin(aimAngle), aimSize * -cos(aimAngle)),
          aimPaint);
      c.save();
      c.translate(position.x, position.y);
      c.rotate(aimAngle - pi / 2);
      c.drawArc(Rect.fromCircle(center: Offset.zero, radius: 60), 0, -pi / 4,
          false, aimPaint);
      c.drawArc(Rect.fromCircle(center: Offset.zero, radius: 60), 0, pi / 4,
          false, aimPaint);
      c.restore();
    }
  }

  double aimAngle = 0;

  void updateAim() {
    aimAngle = angleFrom(position, enemy.position);
  }

  bool isLaserActivated = false;
  Laser? laser;

  void activateLaser() {
    if (name == 'PLAYER') {
      laser =
          Laser(position: position, color: color, dir: aimAngle, owner: name);
      gameRef.add(laser!);
    } else {
      laser = Laser(
          position: position,
          color: color,
          dir: aimAngle,
          // time: 45.0,
          owner: name);
      gameRef.add(laser!);
    }
  }

  void deactivateLaser() {
    if (laser != null) {
      isLaserActivated = false;
      gameRef.remove(laser!);
      laser = null;
    }
  }

  int framesLeftStun = 0;
  static const int framesStun = 90;

  void stunHandler() {
    if (framesLeftStun > 0) {
      framesLeftStun--;
      if (framesLeftStun == 0) {
        setState(MS.move, ms);
      }
    }
  }

  void renderStun(Canvas c) {
    if (ms == MS.stun) {
      final value = mapValue(
          framesLeftStun.toDouble(), 0, framesStun.toDouble(), 0.0, 2 * pi);
      final stunnedPaint = Paint()
        ..color = stunnedColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = value;
      c.save();
      c.drawArc(
          Rect.fromCenter(
              center: center.toOffset(), width: width * 2, height: height * 2),
          0,
          2 * pi,
          false,
          stunnedPaint);
      c.restore();
    }
  }

  void stateLogic() {}

  void setState(dynamic newState, [dynamic oldState]) {
    // TODO fix stunned state change color
    if (newState.runtimeType == MS) {
      switch (newState) {
        case MS.move:
          color = primaryColor;
          ms = newState;
          break;
        case MS.stun:
          if (oldState != MS.stun) {
            framesLeftStun = framesStun;
            setState(AS.none, as);
            color = stunnedColor;
            ms = newState;
          }
          break;
      }
    } else if (newState.runtimeType == AS) {
      if (ms != MS.stun) {
        switch (newState) {
          case AS.shoot:
            color = uniqueColor;
            switch (oldState) {
              case AS.laser:
                deactivateLaser();
                shoot();
                as = newState;
                break;
              case AS.none:
                as = newState;
                shoot();
                break;
            }
            break;
          case AS.laser:
            color = stunnedColor;
            switch (oldState) {
              case AS.shoot:
                as = newState;
                cancelShoot();
                activateLaser();
                break;
              case AS.none:
                as = newState;
                activateLaser();
                break;
            }
            break;
          case AS.none:
            switch (oldState) {
              case AS.laser:
                color = primaryColor;
                deactivateLaser();
                as = newState;
                break;
              case AS.shoot:
                color = primaryColor;
                cancelShoot();
                as = newState;
                break;
            }
            break;
        }
      }
    } else if (newState.runtimeType == LS) {
      ls = newState;
      if (ls == LS.dead) {
        setState(MS.move, ms);
        setState(AS.none, as);
      }
    }
  }

  void destroy() {
    color = Colors.black;
    gameRef.add(
        Explosion(position: center, color: stunnedColor, amountParticles: 60));
    gameRef
        .add(ShockWave(position: center, color: stunnedColor, maxRadius: 1000));
    gameRef.endGame();
  }

  bool insideEnemyLaserAim = false;

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollision(intersectionPoints, other);
    if (other is Laser && other.owner != name) {
      insideEnemyLaserAim = true;
      if (other.isActivatedVar) {
        setState(LS.dead);
        gameRef.longShake();
        destroy();
      }
    } else if (other is Bullet && other.owner != name) {
      setState(MS.stun, ms);
    }
  }

  @override
  void onCollisionEnd(Collidable other) {
    super.onCollisionEnd(other);
    if (other is Laser) {
      insideEnemyLaserAim = false;
    }
  }
}
