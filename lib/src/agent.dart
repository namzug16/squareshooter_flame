import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:square_shooter_flame/src/behavior_tree/behavior_tree_stateless.dart';
import 'package:square_shooter_flame/src/shooter.dart';

class Agent extends Shooter with AgentMovement, BehaviorTree {
  Agent({required super.color, required super.initialPosition});

  late final movementBT = sequence([
    (_) => !isDead,
    forceSuccess(sequence([
      hasArrivedToDesiredPosition,
      setDesiredPositionValues,
    ])),
    move,
  ]);

  late final idleBT = sequence([
    fallback([
      (_) => target != null,
      getTarget,
      setRandomAttackCooldownTimer,
    ]),
    tickAttackCooldownTimer,
    transitionStateFromBT(ShooterState.shooting),
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
    // sequence([
    //   inverter((_) => attachedLaser?.targetIsInAim() ?? true),
    //   transitionStateFromBT(ShooterState.idle),
    // ]),
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

    if (game.started) {
      // movementBT(dt);

      switch (state) {
        case ShooterState.idle:
          // idleBT(dt);
        case ShooterState.stunned:
          stunnedBT(dt);
        case ShooterState.shooting:
          // shootingBT(dt);
        case ShooterState.killing:
          // killingBT(dt);
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
    if (targets.isNotEmpty) {
      target = targets.first;
    } else {
      target = null;
    }
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
  double _duration = 0;
  double _elapsed = 0;

  bool? hasArrivedToDesiredPosition(double dt) {
    _end ??= position;
    return position.distanceTo(_end!) <= 5;
  }

  bool? setDesiredPositionValues(double dt) {
    _start = position;
    _end = getNextPosition();
    final distance = _start.distanceTo(_end!);
    _duration = distance / speed;
    _elapsed = 0;
    return true;
  }

  bool? move(double dt) {
    if (movementStepLimit == 0) return true;
    _elapsed += dt * (movementStepLimit ?? 1);
    double t = math.min(1.0, _elapsed / _duration);
    t = _ease(t);
    Vector2 newPos = _start + (_end! - _start) * t;
    position = newPos;
    return true;
  }

  double _ease(double t) => t * t * (3 - 2 * t);

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
