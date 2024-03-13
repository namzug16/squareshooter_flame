import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class Boundary extends BodyComponent {
  final Vector2 start;
  final Vector2 end;

  Boundary(this.start, this.end);

  @override
  Body createBody() {
    paint = Paint()..color = Colors.transparent;
    final shape = EdgeShape()..set(start, end);
    final fixtureDef = FixtureDef(shape, friction: 0.3);
    final bodyDef = BodyDef(
      userData: this, // To be able to determine object in collision
      position: Vector2.zero(),
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
