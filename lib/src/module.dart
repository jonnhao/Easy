import 'package:flutter/material.dart';

import 'bloc.dart';
import 'bloc_provider.dart';
import 'dependency.dart';
import 'inject.dart';

abstract class ModuleWidget extends StatelessWidget {
  List<Bloc> get blocs;
  List<Dependency> get dependencies;
  Widget get view;

  Inject get inject => BlocProvider.tag(this.runtimeType.toString());

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      tagText: this.runtimeType.toString(),
      blocs: blocs,
      dependencies: dependencies,
      child: view,
    );
  }
}
