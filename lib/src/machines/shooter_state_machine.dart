import 'package:flutter/material.dart';
import 'package:square_shooter_flame/finite_state_machina/finite_state_machina.dart';
import 'package:square_shooter_flame/src/effects.dart';
import 'package:square_shooter_flame/src/shooter.dart';

// ignore: missing_override_of_must_be_overridden
sealed class ShooterState extends MachineState<Shooter> {}

/// IDLE
final class ShooterStateIdle extends ShooterState {
  @override
  void enterState(ShooterState oldState) {
    parent.bodyColor = Colors.white;
  }

  @override
  void exitState(ShooterState newState) {}

  @override
  void render(Canvas canvas) {}

  @override
  void stateLogic(double dt) {}

  @override
  ShooterState? transition(double dt) {
    if (parent.isActive) {
      return ShooterStateMove();
    }
    return null;
  }
}

/// MOVE
///
/// BASE because player and npc have different movement logic
// ignore: missing_override_of_must_be_overridden
base class ShooterStateMove extends ShooterState {}

/// DEAD
final class ShooterStateDead extends ShooterState {
  @override
  void enterState(ShooterState oldState) {
    parent.bodyColor = Colors.transparent;
    // parent.setVelocityLimit(0);
    parent.game.add(
      Explosion(
        position: parent.position,
        color: parent.color,
        amountParticles: 30,
        maxRadius: 50,
        minRadius: 10,
        particleSize: 2,
      ),
    );
    parent.game.add(
      ShockWave(
        position: parent.position,
        color: parent.color,
        maxRadius: 50,
      ),
    );
    parent.removeFromParent();
  }
}
