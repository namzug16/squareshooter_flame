import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:square_shooter_flame/main.dart';
import 'package:square_shooter_flame/src/button_component.dart';

class UI extends FlameGame
    with HasGameRef<SquareShooter>, HasTappableComponents {
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
    add(
      ButtonComponent(
        position: Vector2(gameRef.size.x / 2, gameRef.size.y / 2),
        callback: () {
          gameRef.setUpGame();
        },
      ),
    );
  }
}
