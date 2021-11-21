import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:square_shooter_flame/src/bullet.dart';

class Area extends PositionComponent with Hitbox, Collidable {
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
    addHitbox(HitboxCircle(definition: 2.5));
    collidableType = CollidableType.active;
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
