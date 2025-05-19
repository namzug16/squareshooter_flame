import 'package:flame/components.dart';

typedef BTNode = bool? Function(double dt);

mixin BehaviorTree on Component {
  ///RETURNS ON FALSE/NULL
  BTNode sequence(List<BTNode> children) => (double dt) {
        for (int i = 0; i < children.length; i++) {
          final n = children[i];
          final status = n(dt);
          if (status != true) return status;
        }
        return true;
      };

  /// RETURNS ON TRUE/NULL 
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
}
