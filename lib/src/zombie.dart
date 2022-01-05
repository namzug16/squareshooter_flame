
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:square_shooter_flame/src/bullet.dart';
import 'package:square_shooter_flame/src/square_component.dart';

class Zombie extends SquareComponent {
  Zombie() : super(
    uniqueColor: Colors.white,
    name: 'Zombie',
  );

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other){
    if(other is Bullet){
      setState(MS.stun, ms);
    }
  }

}
