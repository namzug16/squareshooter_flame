import 'package:flame/components.dart';
import 'package:square_shooter_flame/src/helpers.dart';

class ProgressComponent extends Component {
  final double lowerBound;
  final double upperBound;
  final double period;
  final void Function(double progress) updateProgress;
  final void Function()? onTick;

  ProgressComponent({
    required this.lowerBound,
    required this.upperBound,
    required this.period,
    required this.updateProgress,
    this.onTick,
    super.key,
  }) {
    _reversedProgress = period;
  }

  late double _reversedProgress;

  @override
  void update(double dt) {
    _reversedProgress -= dt;
    updateProgress(mapValue(
      period - _reversedProgress,
      0,
      period,
      lowerBound,
      upperBound,
    ));
    if (_reversedProgress <= 0) {
      if(onTick != null) {
        onTick!();
      }
      removeFromParent();
    }
  }
}
