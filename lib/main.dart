import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:square_shooter_flame/src/agent.dart';
import 'package:square_shooter_flame/src/count_down_timer.dart';
import 'package:square_shooter_flame/src/player.dart';
import 'package:square_shooter_flame/src/shooter.dart';

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
                child: Text("STOP GAME"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<Boundary> createBoundaries(SquareShooter game) {
  final topLeft = Vector2.zero();
  final bottomRight = game.size;
  final topRight = Vector2(bottomRight.x, topLeft.y);
  final bottomLeft = Vector2(topLeft.x, bottomRight.y);

  return [
    Boundary(topLeft, topRight),
    Boundary(topRight, bottomRight),
    Boundary(bottomRight, bottomLeft),
    Boundary(bottomLeft, topLeft),
  ];
}

class SquareShooter extends FlameGame with KeyboardEvents {
  SquareShooter();

  bool started = false;

  // Player? player;

  List<Shooter> shooters = [];

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    final World p = world;
    final boundaries = createBoundaries(this);
    for (final boundary in boundaries) {
      add(boundary);
    }

    debugMode = true;

    // player = Player(initialPosition: Vector2(60, 60));

    final ag1 = Agent(
      color: Colors.yellowAccent,
      initialPosition: Vector2(20, 20),
    );
    final ag2 = Agent(
      color: Colors.purpleAccent,
      initialPosition: Vector2(60, 60),
    );
    final ag3 = Agent(
      color: Colors.greenAccent,
      initialPosition: Vector2(80, 80),
    );

    // add(player!);

    add(ag1);
    add(ag2);
    add(ag3);
    shooters.addAll([ag1, ag2, ag3]);

    //FIX: add timer animation

    add(
      CountDownTimer(
        position: Vector2(50, 50),
        callback: () {
          started = true;
        }
      ),
    );
    // add(
    //   TimerComponent(
    //     period: 2,
    //     repeat: true,
    //     autoStart: true,
    //     onTick: () {
    //     },
    //   ),
    // );
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    // if (player != null) {
    //   player!.keyboardInput(
    //     event,
    //     keysPressed,
    //   );
    // }
    return KeyEventResult.ignored;
  }
//
// @override
// void update(double dt) {
//   super.update(dt);
//   if (framesShake > 0) {
//     framesShake--;
//     const double disShake = 4.0;
//     translate = Offset(
//       inverseLerp(Random().nextDouble(), -disShake, disShake),
//       inverseLerp(Random().nextDouble(), -disShake, disShake),
//     );
//   } else {
//     if (translate != Offset.zero) {
//       translate = Offset.zero;
//     }
//   }
// }
//
// @override
// void render(Canvas canvas) {
//   canvas.save();
//   canvas.translate(translate.dx, translate.dy);
//   super.render(canvas);
//   canvas.restore();
// }
//
// int framesShake = 0;
// Offset translate = Offset.zero;
//
// void shake() {
//   framesShake = 30;
// }
//
// void longShake() {
//   framesShake = 70;
// }
//
// void setUpZombieGame(){
//
//   children.clear();
//
//   final bulletPool = BulletPool();
//   add(bulletPool);
//
//   final zombie = Zombie();
//   final player = Player();
//
//   add(zombie);
//   add(player);
//
//   const padding = 100.0;
//   final pos1 = Vector2(size.x / 2, padding);
//   final pos2 = Vector2(size.x / 2, size.y - padding);
//   player.init(zombie, pos1, bulletPool);
//   zombie.init(player, pos2, bulletPool);
//
//   startGame(true);
// }
//
// void setUpAiShowCase() {
//   children.clear();
//
//   add(UI());
//   final bulletPool = BulletPool();
//   add(bulletPool);
//
//   final enemyA = Enemy('A', const Color.fromRGBO(238, 217, 77, 1.0));
//   final enemyB = Enemy('B', const Color.fromRGBO(141, 80, 246, 1.0));
//
//   add(enemyA);
//   add(enemyB);
//
//   const padding = 100.0;
//   final pos1 = Vector2(size.x / 2, padding);
//   final pos2 = Vector2(size.x / 2, size.y - padding);
//   enemyA.init(enemyB, pos1, bulletPool);
//   enemyB.init(enemyA, pos2, bulletPool);
//
//   startGame(true);
//   _gameStarted = false;
// }
//
// bool _gameStarted = false;
//
// void setUpGame() {
//   if(!_gameStarted){
//     children.clear();
//
//     final bulletPool = BulletPool();
//     add(bulletPool);
//     final player = Player();
//     final enemy = Enemy('ENEMY', const Color.fromRGBO(83, 125, 230, 1));
//
//     add(enemy);
//     add(player);
//
//     const padding = 100.0;
//     final pos1 = Vector2(size.x / 2, padding);
//     final pos2 = Vector2(size.x / 2, size.y - padding);
//     player.init(enemy, pos2, bulletPool);
//     enemy.init(player, pos1, bulletPool);
//
//     _gameStarted = true;
//     startGame(false);
//   }
// }
//
// void startGame(bool isAi) {
//   add(
//     CountDownTimer(() {
//       children.whereType<Shooter>().forEach(
//         (element) {
//           element.activate();
//         },
//       );
//     }, Vector2(size.x / 2, size.y / 2), !isAi),
//   );
// }
//
// void endGame() {
//   add(
//     TimerComponent(
//       period: 3,
//       onTick: () {
//         setUpAiShowCase();
//       },
//       removeOnFinish: true,
//     ),
//   );
// }
}
