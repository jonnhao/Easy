# Easy
An easy Flutter state management that allows minimal rebuild of widgets and improves performance.

This library is completely interoperable with Provider, Scooped_model and Bloc_pattern, allowing you to use multiple state managers.

## Getting Started

Add EasyManager and your state class to Main:

example:

```dart
import 'package:easy/easy.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(BlocProvider(
    blocs: [Bloc((i) => AppBloc())],
    child: MyApp(),
  ));
}
```
Create a logic class and extends EasyBloc:
```dart
class AppBloc extends EasyBloc {
  int counter = 0;

  @override
  void touch() {
    counter++;
    super.touch();
  }
}
```
User EasyState to locate your logic class and Store for access to all your variables and methods of your EasyBloc class.
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = EasyState.of<AppBloc>(context, listen: false);
    return MaterialApp(
        title: 'EasyState',
        home: Scaffold(
          floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add), onPressed: () => bloc.touch()),
          body: Center(
            child: Store<AppBloc>(
              builder: (context, value, child) => Text(
                "${value.counter}",
                style: TextStyle(fontSize: 50),
              ),
            ),
          ),
        ));
  }
}
```
