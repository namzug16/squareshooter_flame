import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:square_shooter_flame/src/area.dart';
import 'package:square_shooter_flame/src/bullet.dart';
import 'package:square_shooter_flame/src/count_down_timer.dart';
import 'package:square_shooter_flame/src/enemy.dart';
import 'package:square_shooter_flame/src/helpers.dart';
import 'package:square_shooter_flame/src/player.dart';
import 'package:square_shooter_flame/src/square_component.dart';
import 'package:square_shooter_flame/src/ui.dart';
import 'package:square_shooter_flame/src/zombie.dart';

void main() {
  final game = SquareShooter();
  runApp(
    GameWidget(
      game: game,
    ),
  );
}

class SquareShooter extends FlameGame
    with KeyboardEvents, HasCollidables, HasTappables {

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    setUpAiShowCase();
    // setUpGame();
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final player = children.whereType<Player>();
    if (player.isNotEmpty) {
      return (player.first).keyboardInput(event, keysPressed);
    } else {
      return KeyEventResult.ignored;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (framesShake > 0) {
      framesShake--;
      const double disShake = 4.0;
      translate = Offset(
        inverseLerp(Random().nextDouble(), -disShake, disShake),
        inverseLerp(Random().nextDouble(), -disShake, disShake),
      );
    } else {
      if (translate != Offset.zero) {
        translate = Offset.zero;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(translate.dx, translate.dy);
    super.render(canvas);
    canvas.restore();
  }

  int framesShake = 0;
  Offset translate = Offset.zero;

  void shake() {
    framesShake = 30;
  }

  void longShake() {
    framesShake = 70;
  }

  void setUpZombieGame(){

    children.clear();

    final bulletPool = BulletPool();
    add(bulletPool);

    final zombie = Zombie();
    final player = Player();

    add(zombie);
    add(player);

    const padding = 100.0;
    final pos1 = Vector2(size.x / 2, padding);
    final pos2 = Vector2(size.x / 2, size.y - padding);
    player.init(zombie, pos1, bulletPool);
    zombie.init(player, pos2, bulletPool);

    startGame(true);
  }

  void setUpAiShowCase() {
    children.clear();

    // add(UI());
    final bulletPool = BulletPool();
    add(bulletPool);

    final enemyA = Enemy('A', const Color.fromRGBO(238, 217, 77, 1.0));
    final enemyB = Enemy('B', const Color.fromRGBO(141, 80, 246, 1.0));

    add(enemyA);
    add(enemyB);

    const padding = 100.0;
    final pos1 = Vector2(size.x / 2, padding);
    final pos2 = Vector2(size.x / 2, size.y - padding);
    enemyA.init(enemyB, pos1, bulletPool);
    enemyB.init(enemyA, pos2, bulletPool);

    startGame(true);
    _gameStarted = false;
  }

  bool _gameStarted = false;

  void setUpGame() {
    if(!_gameStarted){
      children.clear();

      final bulletPool = BulletPool();
      add(bulletPool);
      final player = Player();
      final enemy = Enemy('ENEMY', const Color.fromRGBO(83, 125, 230, 1));

      add(enemy);
      add(player);

      const padding = 100.0;
      final pos1 = Vector2(size.x / 2, padding);
      final pos2 = Vector2(size.x / 2, size.y - padding);
      player.init(enemy, pos2, bulletPool);
      enemy.init(player, pos1, bulletPool);

      _gameStarted = true;
      startGame(false);
    }
  }

  void startGame(bool isAi) {
    add(
      CountDownTimer(() {
        children.whereType<SquareComponent>().forEach(
          (element) {
            element.activate();
          },
        );
      }, Vector2(size.x / 2, size.y / 2), !isAi),
    );
  }

  void endGame() {
    add(
      TimerComponent(
        period: 3,
        onTick: () {
          setUpAiShowCase();
        },
        removeOnFinish: true,
      ),
    );
  }
}
