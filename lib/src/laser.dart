import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:square_shooter_flame/main.dart';
import 'package:square_shooter_flame/src/helpers.dart';
import 'package:square_shooter_flame/src/shooter.dart';

const _chargeTime = 1.0;

class Laser extends PositionComponent with CollisionCallbacks {
  final Vector2 initialPosition;
  final Vector2 directionVector;
  final Color color;
  final Shooter owner;
  final double strokeWidth;

  Laser({
    required this.initialPosition,
    required this.directionVector,
    required this.color,
    required this.owner,
    required this.strokeWidth,
  }) : super(
          position: initialPosition,
          size: Vector2(strokeWidth, 5000),
          angle: -math.atan2(directionVector.x, directionVector.y),
        );

  bool activated = false;
  bool detached = false;

  Timer _dt = Timer(_chargeTime);

  void detach() {
    detached = true;
    activated = false;
    _dt = Timer(_t.progress * 0.5);
  }

  void _tickDetachedTimer(dt) {
    if (_dt.finished) {
      removeFromParent();
      return;
    }
    _dt.update(dt);
  }

  late final _t = Timer(_chargeTime);

  void _tickActivationTimer(dt) {
    if (_t.finished) {
      activated = true;
      return;
    }
    _t.update(dt);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (detached) {
      _tickDetachedTimer(dt);
    } else {
      _tickActivationTimer(dt);
    }
  }

  bool? _targetIsInAim;

  //NOTE: it returns false as soon as it is called because the collision
  //cycle has not yet started. That's why we need [_targetIsInAim]
  bool targetIsInAim() {
    final res = activeCollisions.any((e) => e is Shooter && e != owner);
    if (_targetIsInAim == null) {
      if (res) _targetIsInAim = res;
      return true;
    }
    return res;
  }

  RectangleHitbox? _hitbox;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    debugMode = gameDebugMode;
    _hitbox = RectangleHitbox.relative(
      Vector2(1, 1),
      parentSize: size,
    );
    add(_hitbox!);
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.rotate(math.pi * 0.5);
    final path = Path()
      ..moveTo(owner.size.x, 0)
      ..lineTo((owner.game.size.x * 2), 0);
    canvas.drawPath(
      path,
      Paint()
        ..color = detached ? color.withOpacity(0.3) : color.withOpacity(_t.progress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = detached ? inverseLerp(_dt.progress, strokeWidth, 0) : inverseLerp(_t.progress, 0, strokeWidth)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
    canvas.save();
    canvas.rotate(math.pi * 0.5 + math.pi);
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: owner.size.x),
      0,
      detached ? inverseLerp(_dt.progress, math.pi, 0) : inverseLerp(_t.progress, 0, math.pi),
      false,
      Paint()
        ..color = detached ? color.withOpacity(0.3) : color
        ..style = PaintingStyle.stroke
        ..strokeWidth = detached ? inverseLerp(_dt.progress, strokeWidth, 0) : inverseLerp(_t.progress, 0, strokeWidth)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
    canvas.save();
    canvas.rotate(math.pi * 0.5);
    canvas.transform(Float64List.fromList([-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, owner.size.x, 0, 0, 1]));
    canvas.drawArc(
      Rect.fromCircle(center: Offset(owner.size.x, 0), radius: owner.size.x),
      0,
      detached ? inverseLerp(_dt.progress, math.pi, 0) : inverseLerp(_t.progress, 0, math.pi),
      false,
      Paint()
        ..color = detached ? color.withOpacity(0.3) : color
        ..style = PaintingStyle.stroke
        ..strokeWidth = detached ? inverseLerp(_dt.progress, strokeWidth, 0) : inverseLerp(_t.progress, 0, strokeWidth)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }
}
