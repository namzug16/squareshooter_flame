import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:square_shooter_flame/main.dart';
import 'package:square_shooter_flame/src/shooter.dart';

class Area<T extends BodyComponent> extends BodyComponent<SquareShooter>
    with ContactCallbacks {
  final Function(Set<Vector2> intersectionPoints, T other) callback;

  Area({
    required this.callback,
  });

  @override
  Body createBody() {
    paint = Paint()..color = Colors.pinkAccent.withOpacity(0.1);
    final shape = CircleShape()..radius = 10;
    final fixtureDef = FixtureDef(shape)
      ..restitution = 0.0
      ..density = 0.0
      ..friction = 0.0;
    final bodyDef = BodyDef()
      ..position = Vector2.zero()
      ..userData = this
      ..type = BodyType.static;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

//
// class Area extends PositionComponent with HasHitboxes, Collidable {
//   final String owner;
//   final Function(Set<Vector2> intersectionPoints) callback;
//
//   Area({required this.owner, required this.callback})
//       : super(
//           anchor: Anchor.center,
//           size: Vector2.all(100),
//           position: Vector2.zero(),
//         );
//
//   @override
//   Future<void>? onLoad() async {
//     await super.onLoad();
//     addHitbox(HitboxCircle(normalizedRadius: 2.5));
//     collidableType = CollidableType.active;
//   }
//
//   @override
//   render(Canvas canvas) {
//     // renderHitboxes(canvas);
//   }
//
//   void updatePosition(Vector2 newPosition) {
//     position = newPosition;
//   }
//
//   @override
//   void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
//     super.onCollision(intersectionPoints, other);
//     if (other is Bullet) {
//       if (owner != other.owner) {
//         callback.call(intersectionPoints);
//       }
//     }
//   }
// }
