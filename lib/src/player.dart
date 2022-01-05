import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:square_shooter_flame/src/square_component.dart';

class Player extends SquareComponent {
  Player()
      : super(
            uniqueColor: const Color.fromRGBO(83, 230, 168, 1), name: 'PLAYER');

  KeyEventResult keyboardInput(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (ls == LS.alive) {
      if (keysPressed.isEmpty) {
        dir = Vector2.zero();
        setState(AS.none, as);
      }
      if (keysPressed.isNotEmpty) {
        final keyLabels = keysPressed.map((e) => e.keyLabel).toList();
        final attackKeys = keyLabels
            .where((element) => element == "K" || element == "L")
            .toList();
        final movementKeys = keyLabels
          ..removeWhere((element) => element == "K" || element == "L");

        if (as != AS.laser) {
          if (movementKeys.contains("A")) dir = Vector2(-1, dir.y);
          if (!movementKeys.contains("A") && dir.x == -1) {
            dir = Vector2(0, dir.y);
          }
          if (movementKeys.contains("W")) dir = Vector2(dir.x, -1);
          if (!movementKeys.contains("W") && dir.y == -1) {
            dir = Vector2(dir.x, 0);
          }
          if (movementKeys.contains("D")) dir = Vector2(1, dir.y);
          if (!movementKeys.contains("D") && dir.x == 1) {
            dir = Vector2(0, dir.y);
          }
          if (movementKeys.contains("S")) dir = Vector2(dir.x, 1);
          if (!movementKeys.contains("S") && dir.y == 1) {
            dir = Vector2(dir.x, 0);
          }
          if (movementKeys.isEmpty) dir = Vector2.zero();
          if (dir != Vector2.zero()) oldDir = dir;
        }

        if (attackKeys.isEmpty) setState(AS.none, as);
        if (attackKeys.length == 1) {
          if (attackKeys.contains("K")) setState(AS.shoot, as);
          if (attackKeys.contains("L")) setState(AS.laser, as);
        } else {
          setState(AS.none, as);
        }
      }
    }
    return KeyEventResult.ignored;
  }

  Vector2 dir = Vector2.zero();
  Vector2 oldDir = Vector2.zero();
  double deAcc = 0.3;

  @override
  void handleMovement() {
    if (dir == Vector2.zero() && (vel.x > 0 || vel.y > 0)) {
      vel = (vel - Vector2.all(deAcc))
        ..clamp(Vector2.zero(), Vector2.all(maxVelocity));
      position += (Vector2(vel.x * oldDir.x, vel.y * oldDir.y))
        ..clamp(Vector2(-maxVelocity, -maxVelocity),
            Vector2(maxVelocity, maxVelocity));
    } else {
      vel = (vel + Vector2.all(acc))
        ..clamp(Vector2.zero(), Vector2.all(maxVelocity));
      position += (Vector2(vel.x * dir.x, vel.y * dir.y))
        ..clamp(Vector2(-maxVelocity, -maxVelocity),
            Vector2(maxVelocity, maxVelocity));
    }
  }

  // ! =============================== Finite State Machine

  @override
  void stateLogic() {
    if (ls == LS.alive) {
      if (enemy.ls == LS.alive) {
        if (ms == MS.move) {
          if (as == AS.shoot) {
            vel.clamp(Vector2.zero(), Vector2.all(shootingVelocity));
          } else if (as == AS.laser) {
            vel = Vector2.zero();
          }
        } else if (ms == MS.stun) {
          vel.clamp(Vector2.zero(), Vector2.all(stunnedVelocity));
        }
      } else {
        color = SquareComponent.primaryColor;
        cancelShoot();
        deactivateLaser();
        vel = Vector2.zero();
      }
    } else {
      cancelShoot();
      deactivateLaser();
    }
  }
}
