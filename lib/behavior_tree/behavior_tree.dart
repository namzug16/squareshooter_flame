import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

class BTObserver<T extends Component> {
  late final BehaviorTree<T> behaviorTree;

  void beforeResolve() {}

  void onResolve(BTNode<T> node, BTNodeStatus status) {}

  void afterResolve() {}
}

class BTObserverLogger<T extends Component> extends BTObserver<T> {

  final List<(String parentFullPath, String name, String result)> entries = [];

  @override
  void onResolve(BTNode<T> node, BTNodeStatus status) {
    // print("${node.fullPath} -> ${status.name}");
    /// parent full path without child name
    /// e.g. "root/sequence/selector" -> "root/sequence"
    final parentFullPath  = node.fullPath.substring(0, node.fullPath.lastIndexOf("/"));
    entries.add((parentFullPath, node.name, status.name));
  }

  @override
  void afterResolve() {
    if(entries.isEmpty) {
      debugPrint("${"\n" * 3}${behaviorTree.parent.runtimeType} --- TREE ${behaviorTree.root.name} =====================================");
      debugPrint("EMPTY TREE");
      debugPrint("TREE ${behaviorTree.root.name} =====================================");
      return;
    }
    debugPrint("${"\n" * 3}${behaviorTree.parent.runtimeType} --- RESOLVING TREE ${behaviorTree.root.name} =====================================");
    debugPrint("| ROOT");
    printEntries(entries.last.$1);
    debugPrint(
        "TREE RESOLVED ${behaviorTree.root.name} =====================================");
    entries.clear();
  }

  void printEntries(String parentFullPath) {
    final children = entries.where((e) => e.$1 == parentFullPath).toList();
    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      debugPrint("| ${"-" * child.$1.length} | ${child.$2} -> ${child.$3}");
      printEntries("${child.$1}/${child.$2}");
    }
  }
}

enum BTNodeStatus {
  success,
  failure,
  running;

  String get name => switch (this) {
        BTNodeStatus.success => "SUCCESS",
        BTNodeStatus.failure => "FAILURE",
        BTNodeStatus.running => "RUNNING",
      };
}

class BTNode<T extends Component> {
  final String name;

  BTNode(
    this.name,
    List<BTNode<T>> children,
  ) {
    _children = children.map((e) => e.toChildNode()).toList();
    _originalNodeChildren = children;
  }

  List<BTChildNode<T>> get children => _children;
  List<BTChildNode<T>> _children = [];
  late List<BTNode<T>> _originalNodeChildren;

  BTChildNode<T> toChildNode() {
    return BTChildNode<T>(this);
  }

  T? get parent => _parent;
  T? _parent;

  BTNodeStatus resolve(double dt) {
    return BTNodeStatus.success;
  }

  String get fullPath => _fullPath;
  String _fullPath = "";

  List<BTObserver<T>> _observers = [];

  void onLoad({
    required T parent,
    required String parentNodeFullPath,
    required List<BTObserver<T>> observers,
  }) {
    _parent = parent;
    _fullPath = "$parentNodeFullPath/$name";
    _observers = observers;
  }

  @protected
  @nonVirtual
  BTNodeStatus privateResolve(double dt) {
    final status = resolve(dt);
    for (int i = 0; i < _observers.length; i++) {
      final observer = _observers[i];
      observer.onResolve(this, status);
    }
    return status;
  }
}

class BTChildNode<T extends Component> {
  BTChildNode(BTNode<T> node) {
    _node = node;
  }

  late BTNode<T> _node;

  @nonVirtual
  BTNodeStatus resolve(double dt) {
    return _node.privateResolve(dt);
  }
}

abstract class CompositeNode<T extends Component> extends BTNode<T> {
  CompositeNode(super.name, super.children);
}

abstract class DecoratorNode<T extends Component> extends BTNode<T> {
  DecoratorNode(String name, BTNode<T> child) : super(name, [child]);
}

abstract class LeafNode<T extends Component> extends BTNode<T> {
  LeafNode(String name) : super(name, []);

  void render(Canvas canvas) {}
}

class BehaviorTree<T extends Component> {
  final T parent;
  final BTNode<T> root;
  final List<BTObserver<T>> observers;

  BehaviorTree(
    this.parent,
    this.root, {
    this.observers = const [],
  });

  /// needs to be called on component's onLoad
  @nonVirtual
  void onLoad() {
    _recursiveOnLoad("ROOT", [root]);
    for (int i = 0; i < observers.length; i++) {
      final observer = observers[i];
      observer.behaviorTree = this;
    }
  }

  void _recursiveOnLoad(
    String parentNodeFullPath,
    List<BTNode<T>> nodes,
  ) {
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      node.onLoad(
        parent: parent,
        parentNodeFullPath: parentNodeFullPath,
        observers: observers,
      );
      if (node.children.isNotEmpty) {
        _recursiveOnLoad(node.fullPath, node._originalNodeChildren);
      }
    }
  }

  /// LastNode is the last node that was resolved
  /// meaning, the last node that was running or succeeded
  // late BTNode<T> _lastResolvedNode = root;

  @nonVirtual
  void resolve(double dt) {
    for(int i = 0; i < observers.length; i++) {
      final observer = observers[i];
      observer.beforeResolve();
    }
    root.toChildNode().resolve(dt);
    for(int i = 0; i < observers.length; i++) {
      final observer = observers[i];
      observer.afterResolve();
    }
  }

  // BTNode<T> _recursiveResolve(
  //   double dt,
  //   List<BTNode<T>> nodes,
  // ) {
  //   if (nodes.isEmpty) return _lastResolvedNode;
  //
  //   for (int i = 0; i < nodes.length; i++) {
  //     final node = nodes[i];
  //
  //     final status = node.resolve(dt);
  //
  //     if (debugPrintOnResolve) {
  //       print("|| ${node.fullPath} ---> ${status.name}");
  //     }
  //
  //     if (status == BTNodeStatus.failure) {
  //       _recursiveResolve(dt, node.children);
  //     } else {
  //       return node;
  //     }
  //   }
  //
  //   return _lastResolvedNode;
  // }

  void render(Canvas canvas) {}
}

/// ============================================================================

final class SelectorNode<T extends Component> extends CompositeNode<T> {
  SelectorNode(
    String name,
    List<BTNode<T>> children,
  ) : super(
          "SELECTOR_$name",
          children,
        );

  @override
  BTNodeStatus resolve(double dt) {
    for (int i = 0; i < children.length; i++) {
      final child = children[i];

      /// fix this call to resolve........
      final status = child.resolve(dt);
      if (status != BTNodeStatus.failure) {
        return status;
      }
    }
    return BTNodeStatus.failure;
  }
}

final class SequenceNode<T extends Component> extends CompositeNode<T> {
  SequenceNode(
    String name,
    List<BTNode<T>> children,
  ) : super(
          "SEQUENCE_$name",
          children,
        );

  @override
  BTNodeStatus resolve(double dt) {
    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      final status = child.resolve(dt);
      if (status != BTNodeStatus.success) {
        return status;
      }
    }
    return BTNodeStatus.success;
  }
}

//// ===========================================================================

final class ConditionalNode<T extends Component> extends LeafNode<T> {
  final Function() condition;

  ConditionalNode(String name, this.condition) : super("CONDITIONAL_$name");

  @override
  BTNodeStatus resolve(double dt) {
    return condition() ? BTNodeStatus.success : BTNodeStatus.failure;
  }
}

class ActionNode<T extends Component> extends LeafNode<T> {
  final BTNodeStatus Function(double dt) action;

  ActionNode(String name, this.action) : super("ACTION_$name");

  @override
  BTNodeStatus resolve(double dt) => action(dt);
}

extension ActionNodeExtension on BTNodeStatus Function(double dt) {
  ActionNode toActionNode(String name) => ActionNode(name, this);
}

extension ConditionalNodeExtension on bool Function() {
  ConditionalNode toConditionalNode(String name) => ConditionalNode(name, this);
}

/// ============================================================================

class InverterNode<T extends Component> extends DecoratorNode<T> {
  InverterNode(String name, BTNode<T> child) : super("INVERTER_$name", child);

  @override
  BTNodeStatus resolve(double dt) {
    final status = children.first.resolve(dt);
    if (status == BTNodeStatus.success) {
      return BTNodeStatus.failure;
    } else if (status == BTNodeStatus.failure) {
      return BTNodeStatus.success;
    } else {
      return status;
    }
  }
}

/// ============================================================================

mixin HasBehaviorTrees<T extends Component> on Component {
  final List<BehaviorTree<T>> behaviorTrees = [];

  @nonVirtual
  void registerBehaviorTree(BehaviorTree<T> tree) {
    behaviorTrees.add(tree);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    for (int i = 0; i < behaviorTrees.length; i++) {
      final tree = behaviorTrees[i];
      tree.onLoad();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (int i = 0; i < behaviorTrees.length; i++) {
      final tree = behaviorTrees[i];
      tree.resolve(dt);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    for (int i = 0; i < behaviorTrees.length; i++) {
      final tree = behaviorTrees[i];

      /// FIND OUT WHAT/HOW TO RENDER
      tree.render(canvas);
    }
  }
}
