import 'package:flame/components.dart';

typedef BTNode = bool? Function(double dt);

mixin BehaviorTree on Component {
  BTNode sequence(List<BTNode> children) => (double dt) {
        for (int i = 0; i < children.length; i++) {
          final n = children[i];
          final status = n(dt);
          if (status != true) return status;
        }
        return true;
      };

  BTNode fallback(List<BTNode> children) => (double dt) {
        for (int i = 0; i < children.length; i++) {
          final n = children[i];
          final status = n(dt);
          if (status != false) return status;
        }
        return false;
      };

  BTNode inverter(BTNode child) => (double dt) => child(dt) == null ? null : !child(dt)!;

  BTNode forceSuccess(BTNode child) => (double dt) => child(dt) == null ? null : true;

  BTNode forceFailure(BTNode child) => (double dt) => child(dt) == null ? null : false;

  BTNode printNodeSuccess(String text) {
    return (_) {
      print(text);
      return true;
    };
  }

  BTNode printNodeFailure(String text) {
    return (_) {
      print(text);
      return false;
    };
  }
}

/*
enum BTStatus {
  success,
  failure,
  running;
}

typedef BTNode = BTStatus Function();

mixin BehaviorTree on Component {
  BTNode sequence(List<BTNode> children) {
    for (int i = 0; i < children.length; i++) {
      final n = children[i];
      final status = n();
      if (status != BTStatus.success) return () => status;
    }
    return () => BTStatus.success;
  }

  BTNode fallback(List<BTNode> children) {
    for (int i = 0; i < children.length; i++) {
      final n = children[i];
      final status = n();
      if (status != BTStatus.failure) return () => status;
    }
    return () => BTStatus.failure;
  }

  BTNode inverter(BTNode child) => () => switch (child()) {
        BTStatus.success => BTStatus.failure,
        BTStatus.failure => BTStatus.success,
        BTStatus.running => BTStatus.running,
      };

  BTNode forceSuccess(BTNode child) => () => switch (child()) {
        BTStatus.running => BTStatus.running,
        _ => BTStatus.success,
      };

  BTNode forceFailure(BTNode child) => () => switch (child()) {
        BTStatus.running => BTStatus.running,
        _ => BTStatus.success,
      };
}

*/
