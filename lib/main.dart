import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:square_shooter_flame/src/agent.dart';
import 'package:square_shooter_flame/src/count_down_timer.dart';
import 'package:square_shooter_flame/src/player.dart';
import 'package:square_shooter_flame/src/shooter.dart';

const gameDebugMode = false;

void main() {
  final game = SquareShooter();
  runApp(SquareShooterGame(game));
}

class SquareShooterGame extends StatelessWidget {
  const SquareShooterGame(this.game, {Key? key}) : super(key: key);

  final SquareShooter game;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Square Shooter',
      home: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: GameWidget(
                game: game,
                autofocus: true,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: ElevatedButton(
                onPressed: () {
                  game.pauseEngine();
                  print("GAME PAUSED");
                },
                child: const Text("STOP GAME"),
              ),
            ),
            Positioned(
              top: 20,
              left: 0,
              child: ElevatedButton(
                onPressed: () {
                  game.resumeEngine();
                },
                child: const Text("RESUME GAME"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// List<Boundary> createBoundaries(SquareShooter game) {
//   final topLeft = Vector2.zero();
//   final bottomRight = game.size;
//   final topRight = Vector2(bottomRight.x, topLeft.y);
//   final bottomLeft = Vector2(topLeft.x, bottomRight.y);
//
//   return [
//     Boundary(topLeft, topRight),
//     Boundary(topRight, bottomRight),
//     Boundary(bottomRight, bottomLeft),
//     Boundary(bottomLeft, topLeft),
//   ];
// }

class SquareShooter extends FlameGame with HasCollisionDetection, HasKeyboardHandlerComponents {
  SquareShooter();

  bool started = false;

  List<Shooter> shooters = [];

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    final ag1 = Agent(color: Colors.yellowAccent, initialPosition: Vector2(100, 100));
    // final ag2 = Agent(color: Colors.green, initialPosition: Vector2(500, 500));
    final player = Player(color: Colors.greenAccent, initialPosition: Vector2(500, 500));
    // final ag3 = Agent(color: Colors.greenAccent, initialPosition: Vector2(500, 500));

    add(ag1);
    add(player);
    // add(ag2);
    // add(ag3);
    // shooters.addAll([ag1, ag2, ag3]);
    // shooters.addAll([ag1, ag2]);
    shooters.addAll([ag1, player]);

    player.target = ag1;

    add(
      CountDownTimer(
          position: Vector2(100, 100),
          callback: () {
            started = true;
          }),
    );
  }

  // @override
  // KeyEventResult onKeyEvent(
  //   KeyEvent event,
  //   Set<LogicalKeyboardKey> keysPressed,
  // ) {
  //   // if (player != null) {
  //   //   player!.keyboardInput(
  //   //     event,
  //   //     keysPressed,
  //   //   );
  //   // }
  //   return KeyEventResult.ignored;
  // }
}
