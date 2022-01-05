import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:square_shooter_flame/src/bullet.dart';

class Area extends PositionComponent with HasHitboxes, Collidable {
  final String owner;
  final Function(Set<Vector2> intersectionPoints) callback;

  Area({required this.owner, required this.callback})
      : super(
          anchor: Anchor.center,
          size: Vector2.all(100),
          position: Vector2.zero(),
        );

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    addHitbox(HitboxCircle(normalizedRadius: 2.5));
    collidableType = CollidableType.active;
  }

  @override
  render(Canvas canvas) {
    // renderHitboxes(canvas);
  }

  void updatePosition(Vector2 newPosition) {
    position = newPosition;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollision(intersectionPoints, other);
    if (other is Bullet) {
      if (owner != other.owner) {
        callback.call(intersectionPoints);
      }
    }
  }
}
