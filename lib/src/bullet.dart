import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:square_shooter_flame/main.dart';
import 'package:square_shooter_flame/src/effects.dart';
import 'package:square_shooter_flame/src/shooter.dart';

const _bulletSpeed = 1300.0;

class Bullet extends PositionComponent with HasGameReference<SquareShooter>, CollisionCallbacks {
  Bullet({
    required this.color,
    required this.owner,
    required this.dir,
    required Vector2 initialPosition,
    required double size,
  }) : super(size: Vector2(size, 5), anchor: Anchor.center, position: initialPosition, angle: math.atan2(dir.y, dir.x));

  final Shooter owner;

  final Color color;

  final Vector2 dir;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    debugMode = gameDebugMode;
    add(RectangleHitbox.relative(Vector2(1, 1), parentSize: size));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += (dir * _bulletSpeed * dt);
    if (position.y > game.size.y || position.y < 0 || position.x > game.size.x || position.x < 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.save();
    final path = Path()
      ..moveTo(0, size.y * 0.5)
      ..lineTo(size.x, size.y * 0.5);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.y
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if ((other is Bullet && other.owner != owner) || (other is Shooter && other != owner)) {
      game.add(
        ShockWave(
          position: position,
          color: color,
          maxRadius: size.x * 4,
        ),
      );
      game.add(
        Explosion(
          position: position,
          color: color,
          amountParticles: 15,
          particleSize: size.x * 0.3,
          maxRadius: size.x * 4,
          minRadius: size.x,
        ),
      );
      removeFromParent();
      game.lightShake();
    }
  }
}
