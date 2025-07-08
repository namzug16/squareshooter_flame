import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:square_shooter_flame/src/behavior_tree/behavior_tree_stateless.dart';
import 'package:square_shooter_flame/src/shooter.dart';

class Agent extends Shooter with AgentMovement, BehaviorTree {
  Agent({required super.color, required super.initialPosition});

  late final movementBT = fallback([
    (_) => isDead,
    sequence([
      hasArrivedToDesiredPosition,
      setNewDesiredPositionValues,
    ]),
    move,
  ]);

  late final idleBT = fallback([
    sequence([
      (_) => target == null || target!.isDead,
      getTarget,
      setRandomAttackCooldownTimer,
    ]),
    sequence([
      tickAttackCooldownTimer,
      transitionStateFromBT(ShooterState.shooting),
    ]),
  ]);

  late final shootingBT = fallback([
    sequence([
      (_) => target?.state == ShooterState.stunned,
      transitionStateFromBT(ShooterState.killing),
    ]),
    sequence([
      tickAttackTimer,
      transitionStateFromBT(ShooterState.idle),
    ]),
  ]);

  late final killingBT = fallback([
    sequence([
      (_) => !(attachedLaser?.targetIsInAim() ?? false),
      transitionStateFromBT(ShooterState.idle),
    ]),
    sequence([
      (_) => target?.isDead == true,
      transitionStateFromBT(ShooterState.idle),
    ]),
  ]);

  late final stunnedBT = sequence([
    tickStunTimer,
    transitionStateFromBT(ShooterState.idle),
  ]);

  @override
  void update(double dt) {
    super.update(dt);
    stateBT(dt);
  }

  void stateBT(double dt) {
    if (game.started) {
      movementBT(dt);

      switch (state) {
        case ShooterState.idle:
          idleBT(dt);
        case ShooterState.stunned:
          stunnedBT(dt);
        case ShooterState.shooting:
          shootingBT(dt);
        case ShooterState.killing:
          killingBT(dt);
      }
    }
  }

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
        setRandomAttackCooldownTimer(0);
      case ShooterState.stunned:
        setStunnedColor();
        setMovementStepLimitOnStunned();
      case ShooterState.shooting:
        setMovementStepLimitOnShooting();
        setRandomAttackTimer(0);
        attack(0);
      case ShooterState.killing:
        setMovementStepLimitOnKilling();
        tryKillTarget();
    }
  }

  bool? getTarget(double dt) {
    final targets = game.shooters.where((element) => element != this && !element.isDead).toList();

    if (targets.isEmpty) return null;

    target = targets.first;

    return true;
  }

  Timer _attackTimer = Timer(5);

  bool? setRandomAttackTimer(double dt) {
    _attackTimer = Timer(math.Random().nextDouble() * 5 + 1);
    return true;
  }

  bool? tickAttackTimer(double dt) {
    if (_attackTimer.finished) return true;
    _attackTimer.update(dt);
    return null;
  }

  Timer _attackCooldownTimer = Timer(3);

  bool? setRandomAttackCooldownTimer(double dt) {
    _attackCooldownTimer = Timer(math.Random().nextDouble() * 5 + 1);
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

  bool? hasArrivedToDesiredPosition(double dt) {
    _end ??= position;
    return position.distanceTo(_end!) <= 5;
  }

  bool? setNewDesiredPositionValues(double dt) {
    _start = position;
    _end = getNextPosition();
    return true;
  }

  bool? move(double dt) {
    if (movementStepLimit == 0) return true;
    final dir = ((_end ?? _start) - _start).normalized();
    position += dir * (movementStepLimit ?? 1) * speed;
    return true;
  }

  Vector2 getNextPosition() {
    final targetPosition = target?.position ?? game.size / 2;
    final math.Random rng = math.Random();
    final randomMultiplier = 7 + rng.nextDouble() * 7;
    double radius = size.x * randomMultiplier;
    const samples = 20;
    final step = size.x;

    while (radius > 0) {
      final Vector2 toA = position - targetPosition;
      final List<Vector2> possiblePositions = List.generate(samples, (i) {
        final double angle = i * (2 * math.pi / samples);
        return Vector2(
          targetPosition.x + math.cos(angle) * radius,
          targetPosition.y + math.sin(angle) * radius,
        );
      });

      final valid = possiblePositions.where((p) {
        final bool onScreen = p.x >= 0 && p.y >= 0 && p.x <= game.size.x && p.y <= game.size.y;
        if (!onScreen) return false;

        final Vector2 toP = p - targetPosition;
        return toP.dot(toA) >= 0;
      }).toList();

      if (valid.isNotEmpty) {
        return valid[rng.nextInt(valid.length)];
      }

      radius -= step;
    }

    return targetPosition;
  }
}
