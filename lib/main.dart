import 'dart:math';

import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/timer.dart';
import 'package:flutter/material.dart';
import 'package:square_shooter_flame/src/agent.dart';
import 'package:square_shooter_flame/src/count_down_timer.dart';
import 'package:square_shooter_flame/src/player.dart';
import 'package:square_shooter_flame/src/shooter.dart';
import 'package:square_shooter_flame/src/zombie_agent.dart';

const gameDebugMode = false;

void main() {
  final game = SquareShooter(GameType.agents);
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
                },
                child: const Text("STOP GAME"),
              ),
            ),
            Positioned(
              top: 100,
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

enum GameType {
  agents,
  player,
  test,
}

class SquareShooter extends FlameGame with HasCollisionDetection, HasKeyboardHandlerComponents {
  SquareShooter(this.type);

  final GameType type;

  bool started = false;

  List<Shooter> shooters = [];

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    switch (type) {
      case GameType.agents:
        final ag1 = Agent(color: Colors.yellowAccent, initialPosition: Vector2(100, 100));
        final ag2 = Agent(color: Colors.green, initialPosition: Vector2(500, 500));
        final ag3 = Agent(color: Colors.greenAccent, initialPosition: Vector2(700, 700));
        shooters.addAll([ag1, ag2, ag3]);
      case GameType.player:
        final ag = Agent(color: Colors.yellowAccent, initialPosition: Vector2(100, 100));
        final player = Player(color: Colors.greenAccent, initialPosition: Vector2(500, 500));
        player.target = ag;
        shooters.addAll([ag, player]);
      case GameType.test:
        final zag = ZombieAgent(color: Colors.yellowAccent, initialPosition: Vector2(100, 100));
        final player = Player(color: Colors.greenAccent, initialPosition: Vector2(500, 500));
        player.target = zag;
        shooters.addAll([zag, player]);
    }

    for (final c in shooters) {
      add(c);
    }

    add(
      CountDownTimer(
        position: Vector2(100, 100),
        callback: () {
          started = true;
        },
      ),
    );
  }

  Timer _shakeTimer = Timer(0.5, autoStart: false);
  int _shakeStrength = 20;

  void lightShake() {
    _shakeStrength = 5;
    _shakeTimer.start();
  }

  void strongShake() {
    _shakeStrength = 20;
    _shakeTimer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _shakeTimer.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (_shakeTimer.isRunning()) {
      canvas.translate(Random().nextDouble() * _shakeStrength, Random().nextDouble() * _shakeStrength);
    }
    super.render(canvas);
  }
}
