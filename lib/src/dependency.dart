
import 'inject.dart';

class Dependency<T> {
  final T Function(Inject i) inject;
  final bool singleton;

  Dependency(this.inject, {this.singleton = true});
}
