import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:square_shooter_flame/main.dart';
import 'package:square_shooter_flame/src/effects.dart';
import 'package:square_shooter_flame/src/shooter.dart';

class Bullet extends PositionComponent with HasGameReference<SquareShooter>, CollisionCallbacks {
  Bullet({
    required this.color,
    required this.owner,
    required this.dir,
    required Vector2 initialPosition,
    required double size,
  }) : super(size: Vector2.all(size), anchor: Anchor.center, position: initialPosition);

  final Shooter owner;

  final Color color;

  final Vector2 dir;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    debugMode = gameDebugMode;
    add(CircleHitbox.relative(1, parentSize: size));
  }

  final _speed = 1000.0;

  @override
  void update(double dt) {
    super.update(dt);
    position += (dir * _speed * dt);
    if (position.y > game.size.y || position.y < 0 || position.x > game.size.x || position.x < 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset(size.x * 0.5, size.y * 0.5), size.x * 0.5, Paint()..color = color);
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
    }
  }
}
