import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:square_shooter_flame/src/shooter.dart';

class Player extends Shooter {
  Player({
    required super.color,
    required super.initialPosition,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    game.add(
      KeyboardListenerComponent(
        keyDown: {
          LogicalKeyboardKey.keyA: (keysPressed) {
            mDir(-1, null);
            return true;
          },
          LogicalKeyboardKey.keyD: (keysPressed) {
            mDir(1, null);
            return true;
          },
          LogicalKeyboardKey.keyW: (keysPressed) {
            mDir(null, -1);
            return true;
          },
          LogicalKeyboardKey.keyS: (keysPressed) {
            mDir(null, 1);
            return true;
          },
          LogicalKeyboardKey.keyK: (keysPressed) {
            transitionState(ShooterState.shooting);
            return true;
          },
          LogicalKeyboardKey.keyL: (keysPressed) {
            transitionState(ShooterState.killing);
            return true;
          },
        },
        keyUp: {
          LogicalKeyboardKey.keyA: (keysPressed) {
            if (_mDir.x == -1) mDir(0, null);
            return true;
          },
          LogicalKeyboardKey.keyD: (keysPressed) {
            if (_mDir.x == 1) mDir(0, null);
            return true;
          },
          LogicalKeyboardKey.keyW: (keysPressed) {
            if (_mDir.y == -1) mDir(null, 0);
            return true;
          },
          LogicalKeyboardKey.keyS: (keysPressed) {
            if (_mDir.y == 1) mDir(null, 0);
            return true;
          },
          LogicalKeyboardKey.keyK: (keysPressed) {
            transitionState(ShooterState.idle);
            return true;
          },
          LogicalKeyboardKey.keyL: (keysPressed) {
            transitionState(ShooterState.idle);
            return true;
          },
        },
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += _mDir * (movementStepLimit ?? 1) * speed;
  }

  Vector2 _mDir = Vector2.zero();

  void mDir(double? x, double? y) => _mDir = Vector2(x ?? _mDir.x, y ?? _mDir.y);

  @override
  void onExitState() {
    switch (state) {
      case ShooterState.idle:
        break;
      case ShooterState.stunned:
        resetMovementStepLimit();
        resetColor();
      case ShooterState.shooting:
        resetMovementStepLimit();
        stopAttack(0);
      case ShooterState.killing:
        resetMovementStepLimit();
        cancelKilling();
    }
  }

  @override
  void onEnterBaseState() {
    switch (state) {
      case ShooterState.idle:
        break;
      case ShooterState.stunned:
        setStunnedColor();
        setMovementStepLimitOnStunned();
      case ShooterState.shooting:
        setMovementStepLimitOnShooting();
        attack(0);
      case ShooterState.killing:
        setMovementStepLimitOnKilling();
        tryKillTarget();
    }
  }
}

// import 'package:flame/input.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:square_shooter_flame/finite_state_machina/finite_state_machina.dart';
// import 'package:square_shooter_flame/src/machines/shooter_attack_state_machine.dart';
// import 'package:square_shooter_flame/src/machines/shooter_state_machine.dart';
// import 'package:square_shooter_flame/src/shooter.dart';
//
// /// MOVEMENT STATES
//
// final class PlayerMovementStateMove extends ShooterStateMove {
//   @override
//   void stateLogic(double dt) {
//     final dir = (parent as Player).direction;
//
//     final oldDir = (parent as Player).oldDirection;
//
//     Vector2 vel = parent.vel;
//
//     late Vector2 pos;
//
//     final maxVel = parent.maxVelocity();
//
//     if (dir == Vector2.zero() && (vel.x > 0 || vel.y > 0)) {
//       parent.updateVelocity(true);
//       vel = parent.vel;
//       pos = parent.body.position +
//           Vector2(
//             (vel.x * oldDir.x).clamp(-maxVel, maxVel),
//             (vel.y * oldDir.y).clamp(-maxVel, maxVel),
//           );
//     } else {
//       parent.updateVelocity(false);
//       vel = parent.vel;
//       pos = parent.body.position +
//           Vector2(
//             (vel.x * dir.x).clamp(-maxVel, maxVel),
//             (vel.y * dir.y).clamp(-maxVel, maxVel),
//           );
//     }
//
//     parent.body.setTransform(
//       pos,
//       parent.body.angle,
//     );
//   }
//
//   @override
//   ShooterState? transition(double dt) {
//     return null;
//   }
// }
//
// class Player extends Shooter {
//   Player({
//     required super.initialPosition,
//   }) : super(
//           color: Colors.greenAccent,
//           // attackFSM: FiniteStateMachine(
//           //   ShooterAttackStateNone(),
//           // ),
//           // baseFSM: FiniteStateMachine(
//           //   ShooterStateIdle(),
//           //   overriddenStates: {
//           //     ShooterStateMove: PlayerMovementStateMove(),
//           //   },
//           // ),
//         );
//
//   final Vector2 direction = Vector2.zero();
//
//   /// Used in order to know where the user was going before the
//   /// keyboard input stopped
//   final Vector2 oldDirection = Vector2.zero();
//
//   /// Updates only the direction, and various checks not the FSMs.
//   void keyboardInput(
//     RawKeyEvent event,
//     Set<LogicalKeyboardKey> keysPressed,
//   ) {
//     final isKeyDown = event is RawKeyDownEvent;
//
//     if (!event.repeat) {
//       /// ATTACK INPUT
//
//       if (event.logicalKey == LogicalKeyboardKey.keyK) {
//         // attackFSM.setState(
//         //   isKeyDown ? ShooterAttackStateShoot() : ShooterAttackStateNone(),
//         // );
//       }
//
//       if (event.logicalKey == LogicalKeyboardKey.keyL) {
//         // attackFSM.setState(
//         //   isKeyDown ? ShooterAttackStateLaser() : ShooterAttackStateNone(),
//         // );
//       }
//
//       /// MOVEMENT INPUT
//
//       oldDirection.setFrom(direction);
//
//       if (event.logicalKey == LogicalKeyboardKey.keyA) {
//         direction.x += isKeyDown ? -1 : 1;
//       } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
//         direction.x += isKeyDown ? 1 : -1;
//       } else if (event.logicalKey == LogicalKeyboardKey.keyW) {
//         direction.y += isKeyDown ? -1 : 1;
//       } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
//         direction.y += isKeyDown ? 1 : -1;
//       }
//     }
//   }
// }
//
// // class Player extends Shooter {
// //   Player()
// //       : super(
// //             bodyColor: const Color.fromRGBO(83, 230, 168, 1), identifier: 'PLAYER');
// //
// //   KeyEventResult keyboardInput(
// //     RawKeyEvent event,
// //     Set<LogicalKeyboardKey> keysPressed,
// //   ) {
// //     if (ls == LS.alive) {
// //       if (keysPressed.isEmpty) {
// //         dir = Vector2.zero();
// //         setState(AS.none, as);
// //       }
// //       if (keysPressed.isNotEmpty) {
// //         final keyLabels = keysPressed.map((e) => e.keyLabel).toList();
// //         final attackKeys = keyLabels
// //             .where((element) => element == "K" || element == "L")
// //             .toList();
// //         final movementKeys = keyLabels
// //           ..removeWhere((element) => element == "K" || element == "L");
// //
// //         if (as != AS.laser) {
// //           if (movementKeys.contains("A")) dir = Vector2(-1, dir.y);
// //           if (!movementKeys.contains("A") && dir.x == -1) {
// //             dir = Vector2(0, dir.y);
// //           }
// //           if (movementKeys.contains("W")) dir = Vector2(dir.x, -1);
// //           if (!movementKeys.contains("W") && dir.y == -1) {
// //             dir = Vector2(dir.x, 0);
// //           }
// //           if (movementKeys.contains("D")) dir = Vector2(1, dir.y);
// //           if (!movementKeys.contains("D") && dir.x == 1) {
// //             dir = Vector2(0, dir.y);
// //           }
// //           if (movementKeys.contains("S")) dir = Vector2(dir.x, 1);
// //           if (!movementKeys.contains("S") && dir.y == 1) {
// //             dir = Vector2(dir.x, 0);
// //           }
// //           if (movementKeys.isEmpty) dir = Vector2.zero();
// //           if (dir != Vector2.zero()) oldDir = dir;
// //         }
// //
// //         if (attackKeys.isEmpty) setState(AS.none, as);
// //         if (attackKeys.length == 1) {
// //           if (attackKeys.contains("K")) setState(AS.shoot, as);
// //           if (attackKeys.contains("L")) setState(AS.laser, as);
// //         } else {
// //           setState(AS.none, as);
// //         }
// //       }
// //     }
// //     return KeyEventResult.ignored;
// //   }
// //
// //   Vector2 dir = Vector2.zero();
// //   Vector2 oldDir = Vector2.zero();
// //   double deAcc = 0.3;
// //
// //   @override
// //   void handleMovement() {
// //     if (dir == Vector2.zero() && (vel.x > 0 || vel.y > 0)) {
// //       vel = (vel - Vector2.all(deAcc))
// //         ..clamp(Vector2.zero(), Vector2.all(maxVelocity));
// //       position += (Vector2(vel.x * oldDir.x, vel.y * oldDir.y))
// //         ..clamp(Vector2(-maxVelocity, -maxVelocity),
// //             Vector2(maxVelocity, maxVelocity));
// //     } else {
// //       vel = (vel + Vector2.all(acc))
// //         ..clamp(Vector2.zero(), Vector2.all(maxVelocity));
// //       position += (Vector2(vel.x * dir.x, vel.y * dir.y))
// //         ..clamp(Vector2(-maxVelocity, -maxVelocity),
// //             Vector2(maxVelocity, maxVelocity));
// //     }
// //   }
// //
// //   // ! =============================== Finite State Machine
// //
// //   @override
// //   void stateLogic() {
// //     if (ls == LS.alive) {
// //       if (enemy.ls == LS.alive) {
// //         if (ms == MS.move) {
// //           if (as == AS.shoot) {
// //             vel.clamp(Vector2.zero(), Vector2.all(shootingVelocity));
// //           } else if (as == AS.laser) {
// //             vel = Vector2.zero();
// //           }
// //         } else if (ms == MS.stun) {
// //           vel.clamp(Vector2.zero(), Vector2.all(stunnedVelocity));
// //         }
// //       } else {
// //         color = Shooter.primaryColor;
// //         cancelShoot();
// //         deactivateLaser();
// //         vel = Vector2.zero();
// //       }
// //     } else {
// //       cancelShoot();
// //       deactivateLaser();
// //     }
// //   }
// // }
