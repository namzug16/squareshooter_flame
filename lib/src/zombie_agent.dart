
import 'package:square_shooter_flame/src/agent.dart';
import 'package:square_shooter_flame/src/shooter.dart';

class ZombieAgent extends Agent {
  ZombieAgent({required super.color, required super.initialPosition});

  @override
  final speed = 1.0;

  @override
  void stateBT(double dt) {
    if (game.started) {
      movementBT(dt);

      switch (state) {
        case ShooterState.idle:
          break;
        case ShooterState.stunned:
          stunnedBT(dt);
        case ShooterState.shooting:
          break;
        case ShooterState.killing:
          break;
      }
    }
  }
}
