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

  static const textStyle = TextStyle(
    color: Colors.black,
  );
  final textPaint = TextPaint(style: textStyle);

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    add(TextComponent(text: "START", textRenderer: textPaint)
      ..anchor = Anchor.center
      ..x = size.x / 2
      ..y = size.y / 2);
    add(
      ScaleEffect.to(
        Vector2.all(1.2),
        EffectController(
          duration: 0.5,
          curve: Curves.linear,
          infinite: true,
          alternate: true,
        ),
      ),
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
