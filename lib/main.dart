import 'dart:math' as math;

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
  runApp(const SquareShooter());
}

class SquareShooter extends StatefulWidget {
  const SquareShooter({Key? key}) : super(key: key);

  @override
  State<SquareShooter> createState() => _SquareShooterState();
}

class _SquareShooterState extends State<SquareShooter> {
  late final SquareShooterGame game;

  void onGameFinished(GameType type) => setState(() {
        switch (type) {
          case GameType.player:
            _isMenuVisible = true;
          case GameType.agentsSimple:
          case GameType.agentsChaos:
          case GameType.test:
        }
      });

  void onGameStarted(GameType type) => setState(() {
        switch (type) {
          case GameType.player:
            _isMenuVisible = false;
          case GameType.agentsChaos:
          case GameType.agentsSimple:
          case GameType.test:
        }
      });

  bool _isMenuVisible = true;

  @override
  void initState() {
    super.initState();
    game = SquareShooterGame(
      onGameStarted: onGameStarted,
      onGameFinished: onGameFinished,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Square Shooter',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: GameWidget(
                game: game,
                autofocus: true,
                addRepaintBoundary: true,
              ),
            ),
            if (_isMenuVisible)
              Positioned(
                top: 0,
                left: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      const Text("SQUARE SHOOTER", style: TextStyle(fontSize: 60, color: Colors.white)),
                      const Text("Controls", style: TextStyle(fontSize: 20, color: Colors.white)),
                      const Text("Movement: WASD", style: TextStyle(fontSize: 16, color: Colors.white)),
                      const Text("Shoot: K", style: TextStyle(fontSize: 16, color: Colors.white)),
                      const Text("Kill: L", style: TextStyle(fontSize: 16, color: Colors.white)),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            game.startPlayerGame();
                          });
                        },
                        child: const Text("PLAY"),
                      ),
                      // TextButton(
                      //   onPressed: () {
                      //     game.pauseEngine();
                      //   },
                      //   child: const Text("PAUSE GAME ENGINE"),
                      // ),
                      // TextButton(
                      //   onPressed: () {
                      //     game.resumeEngine();
                      //   },
                      //   child: const Text("RESUME GAME ENGINE"),
                      // ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              game.startAgentsSimpleGame();
                            });
                          },
                          child: const Text("START AGENTS GAME (Simple)"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              game.startAgentsChaosGame();
                            });
                          },
                          child: const Text("START AGENTS GAME (Chaos)"),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum GameType {
  agentsSimple,
  agentsChaos,
  player,
  test,
}

class SquareShooterGame extends FlameGame with HasCollisionDetection, HasKeyboardHandlerComponents {
  SquareShooterGame({
    required this.onGameStarted,
    required this.onGameFinished,
  });

  final void Function(GameType type) onGameStarted;
  final void Function(GameType type) onGameFinished;

  bool get started => _started;
  bool _started = false;

  bool _finished = false;

  GameType _currentGameType = GameType.agentsSimple;

  List<Shooter> get shooters => _shooters;
  final List<Shooter> _shooters = [];

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    startAgentsSimpleGame();
  }

  void startAgentsSimpleGame() => _loadGame(GameType.agentsSimple);

  void startAgentsChaosGame() => _loadGame(GameType.agentsChaos);

  void startPlayerGame() => _loadGame(GameType.player);

  void _loadGame(GameType type) {
    _started = false;
    _finished = false;
    _currentGameType = type;
    _shooters.clear();

    removeAll(children);

    switch (type) {
      case GameType.agentsSimple:
        _shooters.addAll([
          Agent(color: cs[0], initialPosition: Vector2(size.x * 0.5, 100)),
          Agent(color: cs[1], initialPosition: Vector2(size.x * 0.5, size.y * 0.5)),
          Agent(color: cs[2], initialPosition: Vector2(size.x * 0.5, size.y - 100)),
        ]);
      case GameType.agentsChaos:
        for (final c in cs) {
          _shooters.add(
            Agent(
              color: c,
              initialPosition: Vector2(
                math.Random().nextDouble() * size.x,
                math.Random().nextDouble() * size.y,
              ),
              size: math.min(60, size.x * 0.04),
            ),
          );
        }
      case GameType.player:
        final ag = Agent(color: Colors.yellowAccent, initialPosition: Vector2(size.x * 0.5, 100));
        final player = Player(color: Colors.greenAccent, initialPosition: Vector2(size.x * 0.5, size.y - 100));
        player.target = ag;
        _shooters.addAll([ag, player]);
      case GameType.test:
        final zag = ZombieAgent(color: Colors.yellowAccent, initialPosition: Vector2(size.x * 0.5, 100));
        final player = Player(color: Colors.greenAccent, initialPosition: Vector2(size.x * 0.5, size.y - 100));
        player.target = zag;
        _shooters.addAll([zag, player]);
    }

    for (final c in _shooters) {
      add(c);
    }

    add(
      CountDownTimer(
        position: size * 0.5,
        callback: () {
          _started = true;
        },
      ),
    );

    onGameStarted(type);
  }

  void _checkGameStatus() {
    if (!_finished && _shooters.where((e) => !e.isDead).length == 1) {
      _finished = true;
      onGameFinished(_currentGameType);
    }
  }

  final _shakeTimer = Timer(0.5, autoStart: false);
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
    _checkGameStatus();
  }

  @override
  void render(Canvas canvas) {
    if (_shakeTimer.isRunning()) {
      canvas.translate(math.Random().nextDouble() * _shakeStrength, math.Random().nextDouble() * _shakeStrength);
    }
    super.render(canvas);
  }
}

final cs = [
  Colors.pinkAccent,
  Colors.purpleAccent,
  Colors.deepPurpleAccent,
  Colors.indigoAccent,
  Colors.blueAccent,
  Colors.lightBlueAccent,
  Colors.cyanAccent,
  Colors.tealAccent,
  Colors.greenAccent,
  Colors.lightGreenAccent,
  Colors.limeAccent,
  Colors.yellowAccent,
  Colors.amberAccent,
  Colors.orangeAccent,
  Colors.deepOrangeAccent,
];
