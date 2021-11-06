import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:square_shooter_flame/src/bullet.dart';
import 'package:square_shooter_flame/src/helpers.dart';
import 'package:square_shooter_flame/src/player.dart';
import 'package:square_shooter_flame/src/square_component.dart';

import 'src/area.dart';
import 'src/enemy.dart';
import 'src/laser.dart';
import 'src/signals/signals.dart';

void main() {
  final game = SquareShooter();
  runApp(
    GameWidget(
      game: game,
    ),
  );
}

class SquareShooter extends FlameGame
    with KeyboardEvents, HasCollidables, HasTappableComponents{
  late BulletPool bulletPool;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    add(UI());
    bulletPool = BulletPool();
    add(bulletPool);
    setUpAiShowCase();
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ){
    final player = children.whereType<Player>();
    if(player.isNotEmpty){
      return (player.first).keyboardInput(event, keysPressed);
    }else{
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
    // print(children.where((element) => element is! Bullet).toList());
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

  void setUpAiShowCase() {
    children.whereType<SquareComponent>().forEach((element) {element.removeFromParent();});
    children.whereType<Area>().forEach((element) {element.removeFromParent();});
    final enemyA = Enemy('A', const Color.fromRGBO(77, 238, 182, 1.0));
    final enemyB = Enemy('B', const Color.fromRGBO(208, 80, 246, 1));

    add(enemyA);
    add(enemyB);

    const padding = 100.0;
    final pos1 = Vector2(size.x / 2, padding);
    final pos2 = Vector2(size.x / 2, size.y - padding);
    enemyA.init(enemyB, pos1, bulletPool);
    enemyB.init(enemyA, pos2, bulletPool);

    startGame(true);
  }

  bool gameStarted = false;
  void setUpGame() {
    children.whereType<SquareComponent>().forEach((element) {element.removeFromParent();});
    children.whereType<Area>().forEach((element) {element.removeFromParent();});
    final player = Player();
    final enemy = Enemy('ENEMY', const Color.fromRGBO(83, 125, 230, 1));

    add(enemy);
    add(player);

    const padding = 100.0;
    final pos1 = Vector2(size.x / 2, padding);
    final pos2 = Vector2(size.x / 2, size.y - padding);
    player.init(enemy, pos2, bulletPool);
    enemy.init(player, pos1, bulletPool);

    startGame(false);
    gameStarted = true;
  }

  void startGame(bool isAi) {
    if (!isAi) {
      children.firstWhere((value) => value is UI).removeFromParent();
    }

    final t = children.whereType<CountDownTimer>();
    if(t.isNotEmpty){
      print('t aint empty');
      for (final element in t) {element.removeFromParent();}
    }
    print(t);
    add(
      CountDownTimer(() {
        children.whereType<SquareComponent>().forEach((element) {
          element.activate();
        },);
      }, Vector2(size.x / 2, size.y / 2), !isAi),
    );
  }

  void restartGame(bool gameHasBeenPlayed) {
    if (gameHasBeenPlayed) add(UI());
    gameStarted = false;
    setUpAiShowCase();
  }

  void endGame(){
    final timer = Timer(
        3,
      callback: (){
          if(gameStarted == true){
            restartGame(true);
            gameStarted = false;
          }else{
            restartGame(false);
          }
      }
    )..start();
    add(TimerComponent(timer));
  }
}

class CountDownTimer extends TimerComponent {
  final Function callback;
  final Vector2 position;
  final bool showText;

  CountDownTimer(
    this.callback,
    this.position,
    this.showText,
  ) : super(
          Timer(3.0)..start(),
        );

  @override
  void onRemove() {
    super.onRemove();
    callback.call();
  }

  double sweepAngle = 0;
  int time = 0;
  final paint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5.0
    ..strokeCap = StrokeCap.round;

  static const double size = 300;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.translate(position.x - size / 2, position.y - size / 2);
    canvas.drawArc(Vector2.all(size).toRect(), 0, sweepAngle, false, paint);
    if (showText) {
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: time.toString(),
          style: const TextStyle(
              fontSize: 200, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
          canvas, Offset(size / 2 - tp.width / 2, size / 2 - tp.height / 2));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    sweepAngle = inverseLerp(timer.progress, 0.0, 2 * pi);
    time = inverseLerp(timer.progress, 0.0, 3.0).floor();
  }
}

class UI extends FlameGame
    with HasGameRef<SquareShooter>, HasTappableComponents{
  static const double padding = 50.0;
  static const double fontSize = 20.0;
  static const titleTextConfig =
      TextPaintConfig(color: Colors.white, fontSize: 40);
  static const textConfig = TextPaintConfig(color: Colors.white);
  final textPaintTitle = TextPaint(config: titleTextConfig);
  final textPaint = TextPaint(config: textConfig);

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    add(TextComponent("SquareShooter", textRenderer: textPaintTitle)
      ..x = padding
      ..y = padding * 0.8);
    add(TextComponent("Move: \"A\", \"W\", \"D\", \"S\"",
        textRenderer: textPaint)
      ..x = padding
      ..y = padding * 2);
    add(TextComponent("Shoot (Stuns enemy): \"K\"", textRenderer: textPaint)
      ..x = padding
      ..y = padding * 3);
    add(TextComponent("Laser (Kills enemy): \"L\"", textRenderer: textPaint)
      ..x = padding
      ..y = padding * 4);
    add(ButtonComponent(
        position: Vector2(gameRef.size.x / 2, gameRef.size.y / 2),
        callback: () {
          gameRef.setUpGame();
        }));
  }
}

class ButtonComponent extends PositionComponent with Tappable {
  final Function callback;

  ButtonComponent({
    required Vector2 position,
    required this.callback,
  }) : super(anchor: Anchor.center, position: position, size: Vector2(100, 50));

  static const textConfig = TextPaintConfig(
    color: Colors.black,
  );
  final textPaint = TextPaint(config: textConfig);

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    add(TextComponent("START", textRenderer: textPaint)
      ..anchor = Anchor.center
      ..x = size.x / 2
      ..y = size.y / 2);
    add(
      ScaleEffect(
          scale: Vector2.all(1.2),
          curve: Curves.linear,
          speed: 0.2,
          isInfinite: true,
          isAlternating: true),
    );
  }

  @override
  bool onTapDown(TapDownInfo info) {
    callback.call();
    return true;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRRect(
        RRect.fromRectAndRadius(size.toRect(), const Radius.circular(5)),
        Paint()..color = Colors.red);
  }
}
