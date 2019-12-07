import 'package:easy/src/easy_bloc.dart';
import 'package:flutter/material.dart';
import 'consumer.dart';
import 'module.dart';

class ConsumerModule<R extends ModuleWidget, T extends EasyBloc>
    extends Consumer<T> {
  ConsumerModule(
      {Key key,
      final bool Function(T oldValue, T newValue) distinct,
      @required Widget Function(BuildContext context, T value) builder})
      : super(
            key: key, builder: builder, tag: R.toString(), distinct: distinct);
}
