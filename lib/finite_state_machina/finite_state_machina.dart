import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';

base class MachineState<P> {
  P get parent {
    assert(_parent != null, 'Parent has not been set');
    return _parent!;
  }

  P? _parent;

  @protected
  bool get parentIsSet => _parent != null;

  /// Whether this state can be reentered
  ///
  /// If true, the state will be reentered when the state machine
  /// sets it as the current state, this means, the [enterState] method
  /// and [exitState] will be called as if it was a new state.
  ///
  /// On TRANSITIONS, this is ignored, and the state will not be reentered
  /// This is because transitions simply check if the state should change to a
  /// different state or not
  bool acceptsReentry() => false;

  void registerParent(P parent) {
    if (_parent != null) {
      return;
    }
    _parent = parent;
  }

  void stateLogic(double dt) {}

  MachineState<P>? transition(double dt) => null;

  void render(Canvas canvas) {}

  void enterState(covariant MachineState<P> oldState) {}

  void exitState(covariant MachineState<P> newState) {}

  bool acceptsForcedStateFrom(MachineState<P> state) => true;
}

class FiniteStateMachine<T> {
  /// Overridden states
  ///
  /// Used in case a state is shared between FSM and it
  /// has different logic for each one
  final Map<Type, MachineState<T>> overriddenStates;

  /// Current state of the FSM
  MachineState<T> get state => _state;

  late MachineState<T> _state;

  FiniteStateMachine(
    MachineState<T> initialState, {
    this.overriddenStates = const {},
  }) {
    _state = initialState;
    _updateHistory("INITIAL STATE", initialState.runtimeType.toString());
  }

  /// FORCED STATE VARIABLES
  /// forced state simply means that
  /// the transition has come from the outside
  MachineState<T>? _stateBeingForced;

  bool get _stateWillBeForced =>
      _stateBeingForced != null &&
      (_stateBeingForced.runtimeType != _state.runtimeType ||
          (_stateBeingForced.runtimeType == _state.runtimeType &&
              _state.acceptsReentry()));

  late T _parent;

  void registerParent(T parent) {
    _parent = parent;
  }

  void stateLogic(double dt) {
    /// FORCED STATE
    if (_stateWillBeForced) {
      _transitionTo(_stateBeingForced!, "FORCED");
      _stateBeingForced = null;
      return;
    } else {
      _stateTransitionCustomOrigin = "";
      _stateBeingForced = null;
    }

    /// NORMAL STATE CHECKS / TRANSITIONS
    state.registerParent(_parent);
    state.stateLogic(dt);
    var transition = state.transition(dt);
    final overridden = overriddenStates[transition.runtimeType];
    transition = overridden ?? transition;
    if (transition != null && transition.runtimeType != state.runtimeType) {
      _transitionTo(transition, "TRANSITION");
    }
  }

  /// FORCES A STATE TO BE SET
  void setState(
    MachineState<T> newState, {
    /// Origin, used for debugging
    /// the origin indicates where this state has been set
    /// and it will be added to the FSM history record
    ///
    /// Will only be visible when state is forced
    String origin = "",
  }) {
    newState.registerParent(_parent);
    if (!newState.acceptsForcedStateFrom(state)) {
      return;
    }

    /// Will update the state fo the next frame
    _stateBeingForced = newState;
    _stateTransitionCustomOrigin = origin;
  }

  String _stateTransitionCustomOrigin = "";

  void _transitionTo(MachineState<T> newState, String stateComesFrom) {
    newState.registerParent(_parent);
    state.exitState(newState);
    newState.enterState(state);
    _state = newState;
    _updateHistory(
      stateComesFrom + " " + _stateTransitionCustomOrigin,
      newState.runtimeType.toString(),
    );
    _stateTransitionCustomOrigin = "";
  }

  /// HISTORY FOR DEBUGGING
  ///
  /// Here you can check how
  /// the state machine has transitioned
  /// from Forced states or Transitions
  List<String> get history => _history;
  final List<String> _history = [];

  void _updateHistory(String stateComesFrom, String newStateRuntimeType) {
    _history.add(stateComesFrom + ": " + newStateRuntimeType);
  }

  /// DEBUG MODE
  ///
  /// WHEN ACTIVE IT WILL RENDER THE CURRENT STATE
  /// ON TOP OF THE COMPONENT
  bool debugMode = false;
}

mixin HasFiniteStateMachines<T> on Component {
  final List<FiniteStateMachine<T>> _FSMs = [];

  void registerFSM(FiniteStateMachine<T> fsm) {
    _FSMs.add(fsm);
    fsm.registerParent(this as T);
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (final fsm in _FSMs) {
      fsm.stateLogic(dt);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    for (int i = 0; i < _FSMs.length; i++) {
      final fsm = _FSMs[i];
      if (fsm.state.parentIsSet) {
        fsm.state.render(canvas);
      }
      if (fsm.debugMode) {
        final text = fsm.state.runtimeType.toString();
        final textPainter = TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              color: debugColor,
              fontSize: 3,
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();

        textPainter.paint(canvas, Offset(0, -textPainter.height * (i + 2)));
      }
    }
  }
}
