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
    required this.initialPosition,
    required this.dir,
    required double size,
  }) : super(
          size: Vector2.all(size),
          anchor: Anchor.center,
        );

  /// Used in order to know if the bullet is hitting
  /// its owner or a different component
  final Shooter owner;

  final Color color;

  final Vector2 initialPosition;

  final Vector2 dir;

  // @override
  // Body createBody() {
  //   final shape = CircleShape()..radius = size;
  //   final fixtureDef = FixtureDef(shape)
  //     ..restitution = 0.0
  //     ..density = 0.0
  //     ..friction = 0.0;
  //   final bodyDef = BodyDef()
  //     ..position = initialPosition
  //     ..userData = this
  //     ..type = BodyType.dynamic
  //     ..bullet = true;
  //   return world.createBody(bodyDef)..createFixture(fixtureDef);
  // }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox.relative(1, parentSize: size));
  }

  final _speed = 120.0;

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
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(5)),
      Paint()..color = color,
    );
    // renderHitboxes(canvas);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other != owner && (other is Shooter || other is Bullet)) {
      game.add(
        ShockWave(
          position: position,
          color: color,
          maxRadius: 10,
        ),
      );
      game.add(
        Explosion(
          position: position,
          color: color,
          amountParticles: 15,
        ),
      );
      removeFromParent();
    }
  }
}

//
//
// class BulletPool extends Component with HasGameRef<SquareShooter> {
//   final List<Bullet> bullets = [];
//
//   @override
//   Future<void>? onLoad() async {
//     await super.onLoad();
//     for (var i = 0; i < 20; i++) {
//       final bullet = Bullet();
//       children.add(bullet);
//       bullets.add(bullet);
//     }
//   }
//
//   void shoot(Color color, Vector2 position, double angle, String owner) {
//     bullets
//         .firstWhere((element) => !element.isActive)
//         .shoot(color, position, angle, owner);
//   }
//
//   void explode(Vector2 position, Color color) {
//     const int amountParticles = 10;
//     gameRef.add(
//       Explosion(
//           position: position,
//           color: color,
//           amountParticles: amountParticles,
//           maxRadius: 150.0,
//           minRadius: 50.0,
//           particleSize: 10),
//     );
//     gameRef.add(
//       ShockWave(
//         position: position,
//         color: color,
//         maxRadius: 550,
//       ),
//     );
//   }
// }
//
// class Bullet extends PositionComponent
//     with HasGameRef<SquareShooter>, HasHitboxes, Collidable {
//   Color _color = Colors.white;
//   bool isActive = false;
//   String owner = '';
//
//   Bullet() : super(size: Vector2(40, 8), anchor: Anchor.center);
//
//   static const double vel = 30;
//
//   @override
//   void render(Canvas canvas) {
//     if(isActive) {
//       canvas.drawRRect(
//         RRect.fromRectAndRadius(size.toRect(), const Radius.circular(5)),
//         Paint()..color = _color,
//       );
//       // renderHitboxes(canvas);
//     }
//   }
//
//   @override
//   void update(double dt) {
//     if (isActive) {
//       super.update(dt);
//       position += Vector2(vel * sin(_angle), vel * -cos(_angle));
//       checkState();
//     }
//   }
//
//   @override
//   Future<void>? onLoad() async {
//     await super.onLoad();
//     addHitbox(HitboxRectangle(relation: Vector2.all(1)));
//     collidableType = CollidableType.inactive;
//   }
//
//   void activate(String o) {
//     isActive = true;
//     owner = o;
//     collidableType = CollidableType.active;
//   }
//
//   void deActivate(bool shouldExplode) {
//     isActive = false;
//     collidableType = CollidableType.inactive;
//     owner = '';
//     if (shouldExplode) {
//       (parent! as BulletPool).explode(position.clone(), _color);
//     }
//   }
//
//   double _angle = 0;
//
//   void shoot(Color color, Vector2 initialPos, double a, String owner) {
//     _color = color;
//     position = initialPos;
//     _angle = a;
//     angle = a - pi / 2;
//     activate(owner);
//   }
//
//   void checkState() {
//     if (position.x < 0 ||
//         position.x > gameRef.size.x ||
//         position.y < 0 ||
//         position.y > gameRef.size.y) {
//       deActivate(false);
//     }
//   }
//
//   @override
//   void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
//     if (isActive) {
//       if (other is Shooter && other.identifier != owner) {
//         gameRef.shake();
//         deActivate(true);
//       } else if (other is Bullet && other.owner != owner) {
//         gameRef.shake();
//         deActivate(true);
//       }
//     }
//   }
// }
