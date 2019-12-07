
import 'package:easy/src/easy_bloc.dart';
import 'inject.dart';

class Bloc<T extends EasyBloc> {
  final T Function(Inject i) inject;
  final bool singleton;

  Bloc(this.inject, {this.singleton = true});
}
