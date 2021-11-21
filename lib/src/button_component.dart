
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

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
