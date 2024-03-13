import 'dart:math';

import 'package:flame/components.dart';
import 'package:square_shooter_flame/src/shooter.dart';
import 'package:square_shooter_flame/src/behavior_tree/behavior_tree_stateless.dart';

class Agent extends Shooter with BehaviorTree, AgentMovement {
  Agent({required super.color, required super.initialPosition});

  late final bt = sequence([
    (_) => game.started,
    //movement
    sequence([
      (_) => !isDead,
      forceSuccess(sequence([
        hasArrivedToDesiredPosition,
        setDesiredPositionValues,
      ])),
      move,
    ]),
    fallback([
      //stunned
      sequence([
        (_) => isStunned,
        stopAttack,
        setStunnedValues,
        setMovementStepLimit(0.1),
        tickStunTimer,
      ]),
      forceFailure(resetMovementStepLimit),
      //target selection
      sequence([
        (_) => target == null,
        stopAttack,
        getTarget,
      ]),
      sequence([
        (_) => target!.isStunned,
        stopAttack,
      ]),
      //attack
      sequence([
        (_) => !target!.isDead && !target!.isStunned,
        fallback([
          sequence([
            (_) => !isAttacking,
            tickAttackCooldownTimer,
            setRandomAttackTimer,
            attack,
          ]),
          sequence([
            setMovementStepLimit(0.3),
            tickAttackTimer,
            setRandomAttackCooldownTimer,
            stopAttack,
          ]),
        ]),
      ]),
    ]),
  ]);

  @override
  void update(double dt) {
    super.update(dt);
    bt(dt);
  }

  bool? getTarget(double dt) {
    final targets = game.shooters.where((element) => element != this).toList();
    target = targets.first;
    return true;
  }

  Timer _attackTimer = Timer(0);

  bool? setRandomAttackTimer(double dt) {
    _attackTimer = Timer(Random().nextDouble() * 5 + 1);
    return true;
  }

  bool? tickAttackTimer(double dt) {
    if (_attackTimer.finished) return true;
    _attackTimer.update(dt);
    return null;
  }

  Timer _attackCooldownTimer = Timer(0);

  bool? setRandomAttackCooldownTimer(double dt) {
    _attackCooldownTimer = Timer(Random().nextDouble() * 5 + 1);
    return true;
  }

  bool? tickAttackCooldownTimer(double dt) {
    if (_attackCooldownTimer.finished) return true;
    _attackCooldownTimer.update(dt);
    return null;
  }
}

mixin AgentMovement on Shooter {
  late Vector2 _start;
  Vector2? _end;
  double _duration = 0;
  double _elapsed = 0;

  bool? hasArrivedToDesiredPosition(double dt) {
    _end ??= body.position;
    return body.position.distanceTo(_end!) <= 5;
  }

  bool? setDesiredPositionValues(double dt) {
    _start = body.position;
    _end = getNextPosition();
    final distance = _start.distanceTo(_end!);
    _duration = distance / speed;
    _elapsed = 0;
    return true;
  }

  bool? move(double dt) {
    resetColor();
    _elapsed += dt * (movementStepLimit ?? 1);
    double t = min(1.0, _elapsed / _duration);
    t = _ease(t);
    Vector2 newPos = _start + (_end! - _start) * t;
    body.setTransform(newPos, body.angle);
    return true;
  }

  double _ease(double t) => t * t * (3 - 2 * t);

  Vector2 getNextPosition() {
    Vector2 newPosition = body.position;
    final window = game.sizeOfScreen();
    while (size * 3 > body.position.distanceTo(newPosition)) {
      final x = size + Random().nextDouble() * (window.x - 2 * size);
      final y = size + Random().nextDouble() * (window.y - 2 * size);
      newPosition = Vector2(x, y);
    }
    return newPosition;
  }
}
