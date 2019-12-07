
import 'package:easy/src/easy_bloc.dart';
import 'package:flutter/material.dart';
import 'bloc_provider.dart';

class Consumer<T extends EasyBloc> extends StatefulWidget {
  final Widget Function(BuildContext context, T value) builder;
  final String tag;
  final bool Function(T oldValue, T newValue) distinct;

  Consumer(
      {Key key, @required this.builder, this.tag = "global", this.distinct})
      : super(key: key);

  @override
  _ConsumerState<T> createState() => _ConsumerState<T>();
}

class _ConsumerState<T extends EasyBloc> extends State<Consumer<T>> {
  T value;

  String tag = "global";

  void listener() {
    T newValue = BlocProvider.tag(widget.tag).getBloc<T>();
    if (widget.distinct == null || widget.distinct(value, newValue)) {
      setState(() {
        value = newValue;
      });
    }
  }

  @override
  void initState() {
    value = BlocProvider.tag(widget.tag).getBloc<T>();
    value.addListener(listener);
    super.initState();
  }

  @override
  void dispose() {
    value.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, value);
  }
}
