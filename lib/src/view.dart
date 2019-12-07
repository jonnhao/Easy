
import 'inject.dart';

class View<Widget> {
  final Widget Function(Inject i) inject;

  View(this.inject);
}
