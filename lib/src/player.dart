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

    if (!game.started) return;

    position += _mDir * (movementStepLimit ?? 1) * speed;

    if (state == ShooterState.stunned) {
      final finished = tickStunTimer(dt);
      if (finished == true) {
        transitionState(ShooterState.idle);
      }
    }
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
