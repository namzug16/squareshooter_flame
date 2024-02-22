import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:square_shooter_flame/behavior_tree/behavior_tree.dart';
import 'package:square_shooter_flame/src/boundary.dart';
import 'package:square_shooter_flame/src/machines/shooter_state_machine.dart';
import 'package:square_shooter_flame/src/npc.dart';
import 'package:square_shooter_flame/src/player.dart';
import 'package:square_shooter_flame/src/shooter.dart';

void main() {
  final game = SquareShooter();
  runApp(
    SquareShooterGame(game),
  );
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
  final bottomRight = game.sizeOfScreen();
  final topRight = Vector2(bottomRight.x, topLeft.y);
  final bottomLeft = Vector2(topLeft.x, bottomRight.y);

  return [
    Boundary(topLeft, topRight),
    Boundary(topRight, bottomRight),
    Boundary(bottomRight, bottomLeft),
    Boundary(bottomLeft, topLeft),
  ];
}

class SquareShooter extends Forge2DGame with KeyboardEvents {
  SquareShooter()
      : super(
          gravity: Vector2.zero(),
        );

  Player? player;

  List<Shooter> shooters = [];

  Vector2 sizeOfScreen() {
    return screenToWorld(camera.viewport.effectiveSize);
  }

  final temp = Temp();

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    final boundaries = createBoundaries(this);
    for (final boundary in boundaries) {
      add(boundary);
    }
    debugMode = true;
    player = Player(initialPosition: Vector2(60, 60));
    final npc = NPC(
      color: Colors.yellowAccent,
      initialPosition: Vector2(20, 20),
    );
    final npc2 = NPC(
      color: Colors.purpleAccent,
      initialPosition: Vector2(60, 60),
    );
    final npc3 = NPC(
      color: Colors.greenAccent,
      initialPosition: Vector2(100, 100),
    );
    // player!.registerEnemy(npc);
    // npc.registerEnemy(player!);
    // add(player!);
    npc.registerTarget(npc2);
    npc2.registerTarget(npc);
    npc3.registerTarget(npc);
    add(npc);
    add(npc2);
    add(npc3);
    shooters.add(npc);
    shooters.add(npc2);
    shooters.add(npc3);
    add(
      TimerComponent(
        period: 2,
        repeat: true,
        autoStart: true,
        onTick: () {
          final availableShooters = shooters
              .where((element) =>
                  element.baseFSM.state.runtimeType != ShooterStateDead)
              .toList();
          if (availableShooters.isEmpty) {
            return;
          }
          for (final shooter in availableShooters) {
            final otherShooters = availableShooters
                .where((element) => element != shooter)
                .toList();
            if (otherShooters.isEmpty) {
              return;
            }
            final closestShooter = otherShooters.reduce(
              (value, element) {
                final distance = shooter.body.worldCenter
                    .distanceToSquared(element.body.worldCenter);
                final valueDistance = shooter.body.worldCenter
                    .distanceToSquared(value.body.worldCenter);
                return distance < valueDistance ? element : value;
              },
            );
            shooter.registerTarget(closestShooter);
          }
        },
      ),
    );
    add(temp);
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (player != null) {
      player!.keyboardInput(
        event,
        keysPressed,
      );
    }
    return KeyEventResult.handled;
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

class Temp extends BodyComponent<SquareShooter> with HasBehaviorTrees<Temp> {
  @override
  Body createBody() {
    final shape = CircleShape()..radius = 2;
    final fixtureDef = FixtureDef(shape)
      ..restitution = 0.0
      ..density = 0.0
      ..friction = 0.0;
    final bodyDef = BodyDef()
      ..position = Vector2(10, 10)
      ..userData = this
      ..type = BodyType.dynamic
      ..bullet = true;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  late BehaviorTree<Temp> tree;

  @override
  Future<void> onLoad() async {
    tree = BehaviorTree(
      this,
      SelectorNode(
        "select_a_number",
        [
          SequenceNode(
            "sequence_numbers",
            [
              ConditionalNode("one", () => true),
              ConditionalNode("two", () => true),
              ConditionalNode("three", () => false),
            ],
          ),
          InverterNode(
            "inverter_one",
            ConditionalNode("one", () => false),
          ),
          ConditionalNode("two", () => false),
          ConditionalNode("three", () => false),
          ActionNode("action", (dt) => BTNodeStatus.running),
          ConditionalNode("four", () => false),
        ],
      ),
      observers: [
        BTObserverLogger(),
      ]
    );
    registerBehaviorTree(tree);
    super.onLoad();
  }
}
