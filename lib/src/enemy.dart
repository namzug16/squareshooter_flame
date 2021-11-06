import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import 'area.dart';
import 'helpers.dart';
import 'square_component.dart';

class Enemy extends SquareComponent {
  Enemy(
      String name,
      Color uniqueColor,
      ) : super(uniqueColor: uniqueColor, name: name);

  Area? bulletFinder;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    bulletFinder = Area(owner: name, callback: (points) => dodge(points));
    gameRef.add(bulletFinder!);
  }

  @override
  void update(double dt) {
    super.update(dt);
    pickAState();
    if(bulletFinder != null){
      bulletFinder!.updatePosition(center);
    }
  }

  bool? escapeDir;
  bool escaping = false;

  void dodge(Set<Vector2> intersectionPoints) {
    if (!escaping) {
      final a = angleFrom(center, intersectionPoints.first);
      if (a < aimAngle) {
        // * right
        escapeDir = false;
      } else {
        // * left
        escapeDir = true;
      }
      escaping = true;
    }
  }

  @override
  final double acc = 0.9;

  Vector2 _newPosition = Vector2.zero();
  bool _isAccelerating = true;
  double _distance = 0;
  double _angleMovement = 0;

  void move(bool accelerating) {
    vel = (accelerating ? (vel + Vector2.all(acc)) : (vel - Vector2.all(acc)))
      ..clamp(Vector2.zero(), Vector2.all(maxVelocity));
    position +=
    (Vector2(vel.x * sin(_angleMovement), vel.y * -cos(_angleMovement)))
      ..clamp(Vector2(-maxVelocity, -maxVelocity),
          Vector2(maxVelocity, maxVelocity));
  }

  @override
  void handleMovement() {
    if (vel == Vector2.zero()) getNextPosition();
    if (escaping) getScapePosition();

    if (as != AS.laser) {
      if (center.distanceTo(_newPosition) >= _distance / 2) {
        move(_isAccelerating);
      } else {
        if (_isAccelerating) _isAccelerating = false;
        move(_isAccelerating);
      }
    }
  }

  List<Rect> getPossiblePositionRects() {
    final win = gameRef.size.toRect();
    final s = size.x;
    List<Rect> result = [];
    final topLeftRect =
    Rect.fromPoints(Offset.zero, center.toOffset()).deflate(s);
    if (!topLeftRect.overlaps(enemy.area)) result.add(topLeftRect);
    final topRightRect =
    Rect.fromPoints(center.toOffset(), win.topRight).deflate(s);
    if (!topRightRect.overlaps(enemy.area)) result.add(topRightRect);
    final bottomLeftRect =
    Rect.fromPoints(win.bottomLeft, center.toOffset()).deflate(s);
    if (!bottomLeftRect.overlaps(enemy.area)) result.add(bottomLeftRect);
    final bottomRightRect =
    Rect.fromPoints(center.toOffset(), win.bottomRight).deflate(s);
    if (!bottomRightRect.overlaps(enemy.area)) result.add(bottomRightRect);

    return result;
  }

  double getAreaOfRect(Rect r) {
    return r.longestSide * r.shortestSide;
  }

  static const double scapeDistance = 100.0;

  void getScapePosition() {
    Vector2 newPosition = Vector2.zero();
    if (escapeDir!) {
      final a = aimAngle - pi / 2;
      newPosition = Vector2(
          center.x + scapeDistance * sin(a), center.y + scapeDistance * -cos(a))
        ..clamp(Vector2.zero(), gameRef.size);
    } else {
      final a = aimAngle + pi / 2;
      newPosition = Vector2(
          center.x + scapeDistance * sin(a), center.y + scapeDistance * -cos(a))
        ..clamp(Vector2.zero(), gameRef.size);
    }

    _isAccelerating = true;
    _distance = center.distanceTo(newPosition);
    _angleMovement = angleFrom(center, newPosition);
    escaping = false;
    _newPosition = newPosition;
  }

  void getNextPosition() {
    escaping = false;
    final window = gameRef.size;
    final rects = getPossiblePositionRects();
    Rect? rect = rects.isNotEmpty ? rects.first : null;
    if (rects.isNotEmpty) {
      for (var i = 1; i < rects.length; i++) {
        if (getAreaOfRect(rect!) < getAreaOfRect(rects[i])) {
          rect = rects[i];
        }
      }
    }

    final newPosition = rect != null
        ? Vector2(
      inverseLerp(Random().nextDouble(), rect.topLeft.dx + size.x,
          rect.bottomRight.dx - size.x),
      inverseLerp(Random().nextDouble(), rect.topLeft.dy + size.y,
          rect.bottomRight.dy - size.y),
    )
        : Vector2(
      inverseLerp(
          Random().nextDouble(), size.x * 2, window.x - size.x * 2),
      inverseLerp(
          Random().nextDouble(), size.y * 2, window.y - size.y * 2),
    );

    _isAccelerating = true;
    _distance = center.distanceTo(newPosition);
    _angleMovement = angleFrom(center, newPosition);
    _newPosition = newPosition;
  }

  bool boolForNewState = true;
  int frameCountForNewState = 100;

  void pickAState() {
    // return;

    if (ls == LS.dead) {
      return;
    }

    if (enemy.ls == LS.dead) {
      setState(AS.none, as);
      return;
    }

    if (enemy.ms == MS.stun && as == AS.laser) {
      if (!enemy.insideEnemyLaserAim) {
        setState(AS.none, as);
        return;
      }
    }

    if (enemy.ms == MS.stun) {
      if (center.distanceTo(enemy.center) > 150) {
        setState(AS.laser, as);
        // setState(AS.none, as);
        return;
      }
      setState(AS.none, as);
      return;
    }

    if (enemy.as == AS.laser && !insideEnemyLaserAim) {
      // TODO fix this state change
      setState(AS.laser, as);
      // setState(MS.escape, ms);
      return;
    }

    if (center.distanceTo(enemy.center) > 200 &&
        enemy.as != AS.shoot &&
        enemy.ms != MS.stun) {
      if (boolForNewState && frameCountForNewState > 0) {
        setState(AS.shoot, as);
      } else {
        setState(AS.none, as);
      }
      frameCountForNewState--;
      if (frameCountForNewState == 0) {
        frameCountForNewState =
            inverseLerp(Random().nextDouble(), 60, 100).toInt();
        boolForNewState = Random().nextBool();
      }
      return;
    }

    if (enemy.as == AS.shoot) {
      if (boolForNewState && frameCountForNewState > 0) {
        setState(AS.shoot, as);
      } else {
        setState(AS.none, as);
      }
      frameCountForNewState--;
      if (frameCountForNewState == 0) {
        frameCountForNewState =
            inverseLerp(Random().nextDouble(), 30, 40).toInt();
        boolForNewState = Random().nextBool();
      }
      return;
    }

    if (as == AS.laser && !enemy.insideEnemyLaserAim) {
      setState(AS.none, as);
      return;
    }
  }

  @override
  void stateLogic() {
    if (ls == LS.alive) {
      if (enemy.ls == LS.alive) {
        if (ms == MS.move) {
          if (as == AS.shoot) {
            vel.clamp(Vector2.zero(), Vector2.all(shootingVelocity));
          } else if (as == AS.laser) {
            vel = Vector2.zero();
          }
        } else if (ms == MS.stun) {
          color = SquareComponent.stunnedColor;
          vel.clamp(Vector2.zero(), Vector2.all(stunnedVelocity));
        }
      } else {
        color = SquareComponent.primaryColor;
        cancelShoot();
        deactivateLaser();
        vel = Vector2.zero();
      }
    } else {
      cancelShoot();
      deactivateLaser();
    }
  }

  // @override
  // void onRemove() {
  //   gameRef.remove(bulletFinder!);
  //   super.onRemove();
  // }
}
