//
// import 'package:flame/components.dart';
// import 'package:flame/game.dart';
// import 'package:flutter/foundation.dart';
//
// mixin Signalable on Component {
//   List<String> get signals => _signals;
//   final List<String> _signals = [];
//
//   @nonVirtual
//   void addSignal(String signal) {
//     _signals.add(signal);
//   }
//
//   void onSignalReceived(String signal, [Map<String, dynamic>? payload]);
//
//   @override
//   void onRemove() {
//     final parentGame = findParent<FlameGame>();
//     if(parentGame is HasSignalables){
//       parentGame.signalables.remove(this);
//     }
//     super.onRemove();
//   }
//
// }
//
// mixin Emitter on Component {
//   @nonVirtual
//   void emitSignal(String signal, [bool isGlobal = false, bool once = true, Map<String, dynamic>? payload]) {
//     final p = findParent<HasSignalables>();
//     if (once) {
//       p?.emitSingleSignal(signal, isGlobal, payload);
//     } else {
//       p?.emitConstantSignal(signal, isGlobal, payload);
//     }
//   }
//
//   @nonVirtual
//   void clearLastSignal(){
//     final p = findParent<HasSignalables>();
//     p?.clearLastSingleSignal();
//   }
//
// }
//
// mixin HasSignalables on FlameGame {
//   final List<Signalable> signalables = [];
//
//   @override
//   void prepareComponent(Component component) {
//     super.prepareComponent(component);
//     if (component is Signalable) {
//       signalables.add(component);
//     }
//   }
//
//   @override
//   Future<void>? onLoad() {
//     children.register<Signalable>();
//     return super.onLoad();
//   }
//
//   @override
//   void update(double dt) {
//     super.update(dt);
//     handleSignalEmissions();
//   }
//
//   final List<String> _signals = [];
//   bool _currentSignalIsGlobal = false;
//   Map<String, dynamic>? _payload;
//
//   @nonVirtual
//   void emitConstantSignal(String signal, bool isGlobal, Map<String, dynamic>? payload) {
//     if (!_signals.contains(signal)) {
//       if (isGlobal != _currentSignalIsGlobal) {
//         _currentSignalIsGlobal = isGlobal;
//       }
//       _signals.add(signal);
//       _payload = payload;
//     }
//     if (_singleSignal != null) {
//       _singleSignal = null;
//     }
//   }
//
//   String? _singleSignal;
//
//   @nonVirtual
//   void emitSingleSignal(String signal, bool isGlobal, Map<String, dynamic>? payload) {
//     if (!_signals.contains(signal) && _singleSignal != signal) {
//       if (isGlobal != _currentSignalIsGlobal) {
//         _currentSignalIsGlobal = isGlobal;
//       }
//       _singleSignal = signal;
//       _signals.add(signal);
//       _payload = payload;
//     }
//   }
//
//   @nonVirtual
//   void clearLastSingleSignal() => _singleSignal = null;
//
//   @nonVirtual
//   void handleSignalEmissions() {
//     if (_signals.isNotEmpty) {
//       if(_currentSignalIsGlobal){
//         for (final s in signalables) {
//           if (s.signals.contains(_signals.last)) {
//             s.onSignalReceived(_signals.last, _payload);
//           }
//         }
//         _signals.removeLast();
//         _currentSignalIsGlobal = false;
//       }else{
//         for (final s in signalables) {
//           if (s.signals.contains(_signals.last)) {
//             s.onSignalReceived(_signals.last, _payload);
//             _signals.removeLast();
//             break;
//           }
//         }
//       }
//     }
//   }
// }
