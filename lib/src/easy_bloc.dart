library easy;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class EasyBloc extends ChangeNotifier {
  void touch() {
    notifyListeners();
  }

  void injectString(String string) {
    notifyListeners();
  }

  void injectInt(int integer) {
    notifyListeners();
  }

  void injectList(List list) {
    notifyListeners();
  }

  void injectMap(Map map) {
    notifyListeners();
  }

  void injectBool(bool boolean) {
    notifyListeners();
  }

  void injectDouble(double float) {
    notifyListeners();
  }

  void injectDynamic(dynamic variable) {
    notifyListeners();
  }

  void dispose();
}

typedef UpdateShouldNotify<T> = bool Function(T previous, T current);

Type _typeOf<T>() => T;

abstract class SingleChildCloneableWidget implements Widget {
  SingleChildCloneableWidget cloneWithChild(Widget child);
}

class InheritedProvider<T> extends InheritedWidget {
  const InheritedProvider({
    Key key,
    @required T value,
    UpdateShouldNotify<T> updateShouldNotify,
    Widget child,
  })  : _value = value,
        _updateShouldNotify = updateShouldNotify,
        super(key: key, child: child);

  final T _value;
  final UpdateShouldNotify<T> _updateShouldNotify;

  @override
  bool updateShouldNotify(InheritedProvider<T> oldWidget) {
    if (_updateShouldNotify != null) {
      return _updateShouldNotify(oldWidget._value, _value);
    }
    return oldWidget._value != _value;
  }
}

class EasyState<T> extends ValueDelegateWidget<T>
    implements SingleChildCloneableWidget {
  EasyState({
    Key key,
    @required ValueBuilder<T> builder,
    Disposer<T> dispose,
    Widget child,
  }) : this._(
    key: key,
    delegate: BuilderStateDelegate<T>(builder, dispose: dispose),
    updateShouldNotify: null,
    child: child,
  );

  EasyState.value({
    Key key,
    @required T value,
    UpdateShouldNotify<T> updateShouldNotify,
    Widget child,
  }) : this._(
    key: key,
    delegate: SingleValueDelegate<T>(value),
    updateShouldNotify: updateShouldNotify,
    child: child,
  );

  EasyState._({
    Key key,
    @required ValueStateDelegate<T> delegate,
    this.updateShouldNotify,
    this.child,
  }) : super(key: key, delegate: delegate);

  static T of<T>(BuildContext context, {bool listen = true}) {
    final type = _typeOf<InheritedProvider<T>>();
    final provider = listen
        ? context.inheritFromWidgetOfExactType(type) as InheritedProvider<T>
        : context.ancestorInheritedElementForWidgetOfExactType(type)?.widget
    as InheritedProvider<T>;

    if (provider == null) {
      throw ProviderNotFoundError(T, context.widget.runtimeType);
    }

    return provider._value;
  }

  static void Function<T>(T value) debugCheckInvalidValueType = <T>(T value) {
    assert(() {
      if (value is Listenable || value is Stream) {
        throw FlutterError('''
Tried to use EasyState with a subtype of Listenable/Stream ($T).

```
''');
      }
      return true;
    }());
  };

  final UpdateShouldNotify<T> updateShouldNotify;

  @override
  EasyState<T> cloneWithChild(Widget child) {
    return EasyState._(
      key: key,
      delegate: delegate,
      updateShouldNotify: updateShouldNotify,
      child: child,
    );
  }

  final Widget child;

  @override
  Widget build(BuildContext context) {
    assert(() {
      EasyState.debugCheckInvalidValueType?.call<T>(delegate.value);
      return true;
    }());
    return InheritedProvider<T>(
      value: delegate.value,
      updateShouldNotify: updateShouldNotify,
      child: child,
    );
  }
}

class ProviderNotFoundError extends Error {
  final Type valueType;

  final Type widgetType;

  ProviderNotFoundError(
      this.valueType,
      this.widgetType,
      );

  @override
  String toString() {
    return '''
Error: Could not find the correct EasyState<$valueType> above this $widgetType Widget

To fix, please:

  * Ensure the EasyState<$valueType> is an ancestor to this $widgetType Widget
  * Provide types to EasyState<$valueType>
  * Provide types to Store<$valueType>
  * Provide types to EasyState.of<$valueType>()
  * Always use package imports. Ex: `import 'package:my_app/my_code.dart';
  * Ensure the correct `context` is being used.

If none of these solutions work, please file a bug at:
https:
''';
  }
}

class Easy<T extends ChangeNotifier> extends ListenableProvider<T>
    implements SingleChildCloneableWidget {
  static void _disposer(BuildContext context, ChangeNotifier notifier) =>
      notifier?.dispose();

  Easy({
    Key key,
    @required ValueBuilder<T> builder,
    Widget child,
  }) : super(key: key, builder: builder, dispose: _disposer, child: child);

  Easy.value({
    Key key,
    @required T value,
    Widget child,
  }) : super.value(key: key, value: value, child: child);
}

class Store<T> extends StatelessWidget implements SingleChildCloneableWidget {
  Store({
    Key key,
    @required this.builder,
    this.child,
  })  : assert(builder != null),
        super(key: key);

  final Widget child;

  final Widget Function(BuildContext context, T value, Widget child) builder;

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      EasyState.of<T>(context),
      child,
    );
  }

  @override
  Store<T> cloneWithChild(Widget child) {
    return Store(
      key: key,
      builder: builder,
      child: child,
    );
  }
}

class Store2<A, B> extends StatelessWidget
    implements SingleChildCloneableWidget {
  Store2({
    Key key,
    @required this.builder,
    this.child,
  })  : assert(builder != null),
        super(key: key);

  final Widget child;

  final Widget Function(BuildContext context, A value, B value2, Widget child)
  builder;

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      EasyState.of<A>(context),
      EasyState.of<B>(context),
      child,
    );
  }

  @override
  Store2<A, B> cloneWithChild(Widget child) {
    return Store2(
      key: key,
      builder: builder,
      child: child,
    );
  }
}

class Store3<A, B, C> extends StatelessWidget
    implements SingleChildCloneableWidget {
  Store3({
    Key key,
    @required this.builder,
    this.child,
  })  : assert(builder != null),
        super(key: key);

  final Widget child;

  final Widget Function(
      BuildContext context, A value, B value2, C value3, Widget child) builder;

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      EasyState.of<A>(context),
      EasyState.of<B>(context),
      EasyState.of<C>(context),
      child,
    );
  }

  @override
  Store3<A, B, C> cloneWithChild(Widget child) {
    return Store3(
      key: key,
      builder: builder,
      child: child,
    );
  }
}

class Store4<A, B, C, D> extends StatelessWidget
    implements SingleChildCloneableWidget {
  Store4({
    Key key,
    @required this.builder,
    this.child,
  })  : assert(builder != null),
        super(key: key);

  final Widget child;

  final Widget Function(BuildContext context, A value, B value2, C value3,
      D value4, Widget child) builder;
  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      EasyState.of<A>(context),
      EasyState.of<B>(context),
      EasyState.of<C>(context),
      EasyState.of<D>(context),
      child,
    );
  }

  @override
  Store4<A, B, C, D> cloneWithChild(Widget child) {
    return Store4(
      key: key,
      builder: builder,
      child: child,
    );
  }
}

class Store5<A, B, C, D, E> extends StatelessWidget
    implements SingleChildCloneableWidget {
  Store5({
    Key key,
    @required this.builder,
    this.child,
  })  : assert(builder != null),
        super(key: key);

  final Widget child;

  final Widget Function(BuildContext context, A value, B value2, C value3,
      D value4, E value5, Widget child) builder;

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      EasyState.of<A>(context),
      EasyState.of<B>(context),
      EasyState.of<C>(context),
      EasyState.of<D>(context),
      EasyState.of<E>(context),
      child,
    );
  }

  @override
  Store5<A, B, C, D, E> cloneWithChild(Widget child) {
    return Store5(
      key: key,
      builder: builder,
      child: child,
    );
  }
}

class Store6<A, B, C, D, E, F> extends StatelessWidget
    implements SingleChildCloneableWidget {
  Store6({
    Key key,
    @required this.builder,
    this.child,
  })  : assert(builder != null),
        super(key: key);

  final Widget child;

  final Widget Function(BuildContext context, A value, B value2, C value3,
      D value4, E value5, F value6, Widget child) builder;

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      EasyState.of<A>(context),
      EasyState.of<B>(context),
      EasyState.of<C>(context),
      EasyState.of<D>(context),
      EasyState.of<E>(context),
      EasyState.of<F>(context),
      child,
    );
  }

  @override
  Store6<A, B, C, D, E, F> cloneWithChild(Widget child) {
    return Store6(
      key: key,
      builder: builder,
      child: child,
    );
  }
}

typedef ValueBuilder<T> = T Function(BuildContext context);

typedef Disposer<T> = void Function(BuildContext context, T value);

abstract class StateDelegate {
  BuildContext _context;

  BuildContext get context => _context;

  StateSetter _setState;

  @protected
  StateSetter get setState => _setState;

  @protected
  @mustCallSuper
  void initDelegate() {}

  @protected
  @mustCallSuper
  void didUpdateDelegate(covariant StateDelegate old) {}

  @protected
  @mustCallSuper
  void dispose() {}
}

abstract class DelegateWidget extends StatefulWidget {
  const DelegateWidget({
    Key key,
    this.delegate,
  })  : assert(delegate != null),
        super(key: key);

  @protected
  final StateDelegate delegate;

  @protected
  Widget build(BuildContext context);

  @override
  StatefulElement createElement() => _DelegateElement(this);

  @override
  _DelegateWidgetState createState() => _DelegateWidgetState();
}

class _DelegateWidgetState extends State<DelegateWidget> {
  @override
  void initState() {
    super.initState();
    _mountDelegate();
    _initDelegate();
  }

  void _initDelegate() {
    assert(() {
      (context as _DelegateElement)._debugIsInitDelegate = true;
      return true;
    }());
    widget.delegate.initDelegate();
    assert(() {
      (context as _DelegateElement)._debugIsInitDelegate = false;
      return true;
    }());
  }

  void _mountDelegate() {
    widget.delegate
      .._context = context
      .._setState = setState;
  }

  void _unmountDelegate(StateDelegate delegate) {
    delegate
      .._context = null
      .._setState = null;
  }

  @override
  void didUpdateWidget(DelegateWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.delegate != oldWidget.delegate) {
      _mountDelegate();
      if (widget.delegate.runtimeType != oldWidget.delegate.runtimeType) {
        oldWidget.delegate.dispose();
        _initDelegate();
      } else {
        widget.delegate.didUpdateDelegate(oldWidget.delegate);
      }
      _unmountDelegate(oldWidget.delegate);
    }
  }

  @override
  Widget build(BuildContext context) => widget.build(context);

  @override
  void dispose() {
    widget.delegate.dispose();
    _unmountDelegate(widget.delegate);
    super.dispose();
  }
}

class _DelegateElement extends StatefulElement {
  _DelegateElement(DelegateWidget widget) : super(widget);

  bool _debugIsInitDelegate = false;

  @override
  DelegateWidget get widget => super.widget as DelegateWidget;

  @override
  InheritedWidget inheritFromElement(Element ancestor, {Object aspect}) {
    assert(() {
      if (_debugIsInitDelegate) {
        final targetType = ancestor.widget.runtimeType;

        throw FlutterError('''
inheritFromWidgetOfExactType($targetType) or inheritFromElement() was called
before ${widget.delegate.runtimeType}.initDelegate() completed.

When an inherited widget changes, for example if the value of Theme.of()
changes, its dependent widgets are rebuilt. If the dependent widget's reference
to the inherited widget is in a constructor or an initDelegate() method, then
the rebuilt dependent widget will not reflect the changes in the inherited
widget.

Typically references to inherited widgets should occur in widget build()
methods. Alternatively, initialization based on inherited widgets can be placed
in the didChangeDependencies method, which is called after initDelegate and
whenever the dependencies change thereafter.''');
      }
      return true;
    }());
    return super.inheritFromElement(ancestor, aspect: aspect);
  }
}

abstract class ValueStateDelegate<T> extends StateDelegate {
  T get value;
}

class SingleValueDelegate<T> extends ValueStateDelegate<T> {
  SingleValueDelegate(this.value);

  @override
  final T value;
}

class BuilderStateDelegate<T> extends ValueStateDelegate<T> {
  BuilderStateDelegate(this._builder, {Disposer<T> dispose})
      : assert(_builder != null),
        _dispose = dispose;

  final ValueBuilder<T> _builder;
  final Disposer<T> _dispose;

  T _value;
  @override
  T get value => _value;

  @override
  void initDelegate() {
    super.initDelegate();
    _value = _builder(context);
  }

  @override
  void didUpdateDelegate(BuilderStateDelegate<T> old) {
    super.didUpdateDelegate(old);
    _value = old.value;
  }

  @override
  void dispose() {
    _dispose?.call(context, value);
    super.dispose();
  }
}

abstract class ValueDelegateWidget<T> extends DelegateWidget {
  ValueDelegateWidget({
    Key key,
    @required ValueStateDelegate<T> delegate,
  }) : super(key: key, delegate: delegate);

  @override
  @protected
  ValueStateDelegate<T> get delegate => super.delegate as ValueStateDelegate<T>;
}

class ListenableProvider<T extends Listenable> extends ValueDelegateWidget<T>
    implements SingleChildCloneableWidget {
  ListenableProvider({
    Key key,
    @required ValueBuilder<T> builder,
    Disposer<T> dispose,
    Widget child,
  }) : this._(
    key: key,
    delegate: _BuilderListenableDelegate(builder, dispose: dispose),
    child: child,
  );

  ListenableProvider.value({
    Key key,
    @required T value,
    Widget child,
  }) : this._(
    key: key,
    delegate: _ValueListenableDelegate(value),
    child: child,
  );

  ListenableProvider._valueDispose({
    Key key,
    @required T value,
    Disposer<T> disposer,
    Widget child,
  }) : this._(
    key: key,
    delegate: _ValueListenableDelegate(value, disposer),
    child: child,
  );

  ListenableProvider._({
    Key key,
    @required _ListenableDelegateMixin<T> delegate,
    this.child,
  }) : super(key: key, delegate: delegate);

  final Widget child;

  @override
  ListenableProvider<T> cloneWithChild(Widget child) {
    return ListenableProvider._(
      key: key,
      delegate: delegate as _ListenableDelegateMixin<T>,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final delegate = this.delegate as _ListenableDelegateMixin<T>;
    return InheritedProvider<T>(
      value: delegate.value,
      updateShouldNotify: delegate.updateShouldNotify,
      child: child,
    );
  }
}

class _ValueListenableDelegate<T extends Listenable>
    extends SingleValueDelegate<T> with _ListenableDelegateMixin<T> {
  _ValueListenableDelegate(T value, [this.disposer]) : super(value);

  final Disposer<T> disposer;

  @override
  void didUpdateDelegate(_ValueListenableDelegate<T> oldDelegate) {
    super.didUpdateDelegate(oldDelegate);
    if (oldDelegate.value != value) {
      _removeListener?.call();
      oldDelegate.disposer?.call(context, oldDelegate.value);
      if (value != null) startListening(value, rebuild: true);
    }
  }

  @override
  void startListening(T listenable, {bool rebuild = false}) {
    assert(disposer == null || debugCheckIsNewlyCreatedListenable(listenable));
    super.startListening(listenable, rebuild: rebuild);
  }
}

class _BuilderListenableDelegate<T extends Listenable>
    extends BuilderStateDelegate<T> with _ListenableDelegateMixin<T> {
  _BuilderListenableDelegate(ValueBuilder<T> builder, {Disposer<T> dispose})
      : super(builder, dispose: dispose);

  @override
  void startListening(T listenable, {bool rebuild = false}) {
    assert(debugCheckIsNewlyCreatedListenable(listenable));
    super.startListening(listenable, rebuild: rebuild);
  }
}

mixin _ListenableDelegateMixin<T extends Listenable> on ValueStateDelegate<T> {
  UpdateShouldNotify<T> updateShouldNotify;
  VoidCallback _removeListener;

  bool debugCheckIsNewlyCreatedListenable(Listenable listenable) {
    if (listenable is ChangeNotifier) {
      // ignore: invalid_use_of_protected_member
      assert(!listenable.hasListeners, '''
The default constructor of ListenableProvider/EasyManager
must create a new, unused Listenable.

If you want to reuse an existing Listenable, use the second constructor:

- DO use EasyManager.value to provider an existing ChangeNotifier:

MyChangeNotifier variable;
ChangeNotifierProvider.value(
  value: variable,
  child: ...
)

- DON'T reuse an existing ChangeNotifier using the default constructor.

MyEasyManager variable;
EasyManager(
  builder: (_) => variable,
  child: ...
)
''');
    }
    return true;
  }

  @override
  void initDelegate() {
    super.initDelegate();
    if (value != null) startListening(value);
  }

  @override
  void didUpdateDelegate(StateDelegate old) {
    super.didUpdateDelegate(old);
    final delegate = old as _ListenableDelegateMixin<T>;

    _removeListener = delegate._removeListener;
    updateShouldNotify = delegate.updateShouldNotify;
  }

  void startListening(T listenable, {bool rebuild = false}) {
    var buildCount = 0;
    final setState = this.setState;
    final listener = () => setState(() => buildCount++);

    var capturedBuildCount = buildCount;

    if (rebuild) capturedBuildCount--;
    updateShouldNotify = (_, __) {
      final res = buildCount != capturedBuildCount;
      capturedBuildCount = buildCount;
      return res;
    };

    listenable.addListener(listener);
    _removeListener = () {
      listenable.removeListener(listener);
      _removeListener = null;
      updateShouldNotify = null;
    };
  }

  @override
  void dispose() {
    _removeListener?.call();
    super.dispose();
  }
}

abstract class Void {}

class ValueListenableProvider<T> extends ValueDelegateWidget<ValueListenable<T>>
    implements SingleChildCloneableWidget {
  ValueListenableProvider({
    Key key,
    @required ValueBuilder<ValueNotifier<T>> builder,
    UpdateShouldNotify<T> updateShouldNotify,
    Widget child,
  }) : this._(
    key: key,
    delegate: BuilderStateDelegate<ValueNotifier<T>>(
      builder,
      dispose: _dispose,
    ),
    updateShouldNotify: updateShouldNotify,
    child: child,
  );

  ValueListenableProvider.value({
    Key key,
    @required ValueListenable<T> value,
    UpdateShouldNotify<T> updateShouldNotify,
    Widget child,
  }) : this._(
    key: key,
    delegate: SingleValueDelegate(value),
    updateShouldNotify: updateShouldNotify,
    child: child,
  );

  ValueListenableProvider._({
    Key key,
    @required ValueStateDelegate<ValueListenable<T>> delegate,
    this.updateShouldNotify,
    this.child,
  }) : super(key: key, delegate: delegate);

  static void _dispose(BuildContext context, ValueNotifier notifier) {
    notifier.dispose();
  }

  final Widget child;

  final UpdateShouldNotify<T> updateShouldNotify;

  @override
  ValueListenableProvider<T> cloneWithChild(Widget child) {
    return ValueListenableProvider._(
      key: key,
      delegate: delegate,
      updateShouldNotify: updateShouldNotify,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T>(
      valueListenable: delegate.value,
      builder: (_, value, child) {
        return InheritedProvider<T>(
          value: value,
          updateShouldNotify: updateShouldNotify,
          child: child,
        );
      },
      child: child,
    );
  }
}
