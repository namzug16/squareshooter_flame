
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/animation.dart';

import 'helpers.dart';

class ShockWave extends ParticleComponent {
  ShockWave({
    required Vector2 position,
    required Color color,
    required double maxRadius,
  }) : super(TranslatedParticle(
    offset: position,
    child: ComputedParticle(
      renderer: (canvas, particle) {
        final s = inverseLerp(particle.progress * 2, 10, maxRadius);
        final rect =
        Rect.fromCenter(center: Offset.zero, width: s, height: s);
        final paint = Paint()
          ..color =
          color.withOpacity((1 - particle.progress * 2).clamp(0, 1))
          ..style = PaintingStyle.stroke
          ..strokeWidth = inverseLerp(particle.progress * 2, 10, 0);
        canvas.drawArc(rect, 0, pi * 2, false, paint);
      },
    ),
  ));
}

class Explosion extends ParticleComponent {
  Explosion({
    required Vector2 position,
    required Color color,
    required int amountParticles,
    double maxRadius = 400.0,
    double minRadius = 150.0,
    double particleSize = 20.0,
  }) : super(
    TranslatedParticle(
      lifespan: 2.0,
      offset: position,
      child: Particle.generate(
        count: amountParticles,
        generator: (i) {
          final r = Random().nextDouble();
          final radius = inverseLerp(r, minRadius, maxRadius);
          final angleSection = pi*2/amountParticles;
          return MovingParticle(
            curve: const Interval(0.0, 0.3, curve: Curves.decelerate),
            to: Vector2(
              sin(i * angleSection) * radius,
              cos(i * angleSection) * radius,
            ),
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final paint = Paint()
                  ..color = color.withOpacity(
                      (1 - particle.progress * 2).clamp(0, 1));
                final rect = Rect.fromCenter(
                  center: Offset.zero,
                  width: particleSize,
                  height: particleSize,
                );
                canvas.save();
                canvas.rotate(particle.progress * pi);
                canvas.drawRRect(
                  RRect.fromRectAndRadius(rect, Radius.circular(particleSize/4)),
                  paint,
                );
                canvas.restore();
              },
            ),
          );
        },
      ),
    ),
  );
}