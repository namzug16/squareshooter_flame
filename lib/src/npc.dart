import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:square_shooter_flame/finite_state_machina/finite_state_machina.dart';
import 'package:square_shooter_flame/src/helpers.dart';
import 'package:square_shooter_flame/src/machines/shooter_attack_state_machine.dart';
import 'package:square_shooter_flame/src/machines/shooter_state_machine.dart';
import 'package:square_shooter_flame/src/shooter.dart';

final class NPCStateMove extends ShooterStateMove {
  Vector2 _newPosition = Vector2.zero();
  bool _isAccelerating = true;
  double _distance = 0;
  double _angleMovement = 0;

  @override
  void stateLogic(double dt) {
    if (parent.vel == Vector2.zero()) getNextPosition();

    if (parent.body.worldCenter.distanceTo(_newPosition) >= _distance / 2) {
      move(_isAccelerating);
    } else {
      if (_isAccelerating) _isAccelerating = false;
      move(_isAccelerating);
    }
  }

  @override
  ShooterState? transition(double dt) {
    return null;
  }

  void move(bool accelerating) {
    parent.updateVelocity(!accelerating);

    final newPos = parent.body.position +
        Vector2(
          parent.vel.x * sin(_angleMovement),
          parent.vel.y * -cos(_angleMovement),
        );

    parent.body.setTransform(newPos, parent.body.angle);
  }

  void getNextPosition() {
    final window = parent.game.sizeOfScreen();
    final rects = getPossiblePositionRects();
    Rect? rect = rects.isNotEmpty ? rects.first : null;
    if (rects.isNotEmpty) {
      for (var i = 1; i < rects.length; i++) {
        if (getAreaOfRect(rect!) < getAreaOfRect(rects[i])) {
          rect = rects[i];
        }
      }
    }

    final newPosition = rect != null
        ? Vector2(
            inverseLerp(Random().nextDouble(), rect.topLeft.dx + parent.size,
                rect.bottomRight.dx - parent.size),
            inverseLerp(Random().nextDouble(), rect.topLeft.dy + parent.size,
                rect.bottomRight.dy - parent.size),
          )
        : Vector2(
            inverseLerp(Random().nextDouble(), parent.size * 2,
                window.x - parent.size * 2),
            inverseLerp(Random().nextDouble(), parent.size * 2,
                window.y - parent.size * 2),
          );

    _isAccelerating = true;
    _distance = parent.body.worldCenter.distanceTo(newPosition);
    _angleMovement = angleFrom(parent.body.worldCenter, newPosition);
    _newPosition = newPosition;
  }

  double getAreaOfRect(Rect r) {
    return r.longestSide * r.shortestSide;
  }

  List<Rect> getPossiblePositionRects() {
    final win = parent.game.sizeOfScreen().toRect();
    final s = parent.size;
    final area = parent.target?.area() ?? Rect.zero;
    List<Rect> result = [];
    final topLeftRect = Rect.fromPoints(
      Offset.zero,
      parent.body.worldCenter.toOffset(),
    ).deflate(s);
    if (!topLeftRect.overlaps(area)) {
      result.add(topLeftRect);
    }
    final topRightRect = Rect.fromPoints(
      parent.body.worldCenter.toOffset(),
      win.topRight,
    ).deflate(s);
    if (!topRightRect.overlaps(area)) {
      result.add(topRightRect);
    }
    final bottomLeftRect = Rect.fromPoints(
      win.bottomLeft,
      parent.body.worldCenter.toOffset(),
    ).deflate(s);
    if (!bottomLeftRect.overlaps(area)) {
      result.add(bottomLeftRect);
    }
    final bottomRightRect = Rect.fromPoints(
      parent.body.worldCenter.toOffset(),
      win.bottomRight,
    ).deflate(s);
    if (!bottomRightRect.overlaps(area)) {
      result.add(bottomRightRect);
    }

    return result;
  }
}

class NPC extends Shooter {
  NPC({
    required super.color,
    required super.initialPosition,
  }) : super(
          baseFSM: FiniteStateMachine(
            ShooterStateIdle(),
            overriddenStates: {
              ShooterStateMove: NPCStateMove(),
            },
          ),
          attackFSM: FiniteStateMachine(
            ShooterAttackStateNone(),
          ),
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(
      TimerComponent(
        period: 0.8,
        autoStart: true,
        repeat: true,
        onTick: _newAttackState,
      ),
    );
  }

  /// Chooses a random attack state
  /// between Shoot & None
  void _newAttackState() {
    final random = Random().nextDouble();
    if (random > 0.5) {
      attackFSM.setState(ShooterAttackStateShoot(), origin: "NPC random");
    } else {
      attackFSM.setState(ShooterAttackStateNone(), origin: "NPC random");
    }
  }
}
