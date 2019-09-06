# Easy
An easy Flutter state management that allows minimal rebuild of widgets and improves performance.

## Getting Started

This package is available on pub.dev:
[package](https://pub.dev/packages/easy),

##HOW TO USE?

Add this to your package's pubspec.yaml file:
```yaml
dependencies:
  easy: 
```

Import it:

```dart
import 'package:easy/easy.dart';
```

Add EasyManager and your state class to Main:

example:

```dart
void main() {
  runApp(EasyManager(
    bloc: [
      Easy<AppBloc>(
        builder: (context) => AppBloc(),
      ),
    ],
    child: MyApp(),
  ));
}
```
Create your state class and extends EasyBloc overriding touch method:

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

With Easy, any variable you put into your EasyBloc class will be accessible through the Widget Store. 
And to call any function or method within your EasyBloc class you just need to call "EasyState.of<T>(context, listen: false)" with the method.

You can call "EasyState.of<T>(context, listen: false)" in building your widget like this:

Example:
```dart
class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //
    final bloc = EasyState.of<AppBloc>(context, listen: false);
    
    return Scaffold(
      floatingActionButton: FloatingActionButton(
      //Run the "touch" method and everything in it in your EasyBloc class will be instantly executed.
          child: Icon(Icons.add), onPressed: () => bloc.touch()),
      body: Center(
      // Get the value of any variable within your EasyBloc class using the "Store" widget.
        child: Store<AppBloc>(
            builder: (context, value, child) => Text(
                  "${value.counter}",
                  style: TextStyle(fontSize: 50),
                )),
      ),
    );
  }
}
```
And that's all, when you click on the FloatingActionButton the value will be incremented automatically.
Only the Text will be redone, all other widgets will remain intact. This allows for considerable performance gain when you have heavy widgets (such as videos, gifs, maps) in the tree.

In addition to improving performance, clearing code that will separate the business logic part of the UI (following the BLoC standard), 
EasyProvider works with Singletons, so you can call the Widget Store from anywhere in your code, even on another screen, 
being able to read and change it from anywhere without any boilerplate code!

```dart
class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = EasyState.of<AppBloc>(context, listen: false);
    print("rebuild");
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add), onPressed: () => bloc.touch()),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SecondRoute()),
                  );
                },
                child: Text('Go to Next Screen!'),
              ),
              Store<AppBloc>(
                  builder: (context, value, child) => Text(
                        "${value.counter}",
                        style: TextStyle(fontSize: 50),
                      )),
            ],
          ),
        ),
      ),
    );
  }
}

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = EasyState.of<AppBloc>(context, listen: false);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        heroTag: "increment second route",
        onPressed: () => bloc.touch(),
      ),
      appBar: AppBar(
        title: Text("Second Route"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Store<AppBloc>(
                builder: (context, counter, child) => Text(
                      "${counter.counter}",
                      style: TextStyle(fontSize: 50),
                    )),
            RaisedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Go back!'),
            ),
          ],
        ),
      ),
    );
  }
}
```
You can amazingly increment the counter number of both screens!
That is all? No. You in addition to performing functions you can inject values from anywhere in your code.

This is made possible by the injection methods incorporated in Easy.
Easy natively accepts Strings, int, Map, List, bool, double and dynamic for injection. Simply override any inject method on your EasyBloc.

Example with int:

```dart
class AppBloc extends EasyBloc {
  int counter = 0;

  @override
  void injectInt(int integer) {
    counter = integer;
    super.injectInt(integer);
  }

  @override
  void touch() {
    counter++;
    super.touch();
  }
}
```
Now, inject any value via parameter, and the counter will be updated automatically.

Note that if you click increment, it will increment the value already injected. 
This would not be possible for example, natively with Streams, unless you used RxDart's BehaviourSubject.

```dart
class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = EasyState.of<AppBloc>(context, listen: false);
    print("rebuild");
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add), onPressed: () => bloc.touch()),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SecondRoute()),
                  );
                },
                child: Text('Go to Next Screen!'),
              ),
              Store<AppBloc>(
                  builder: (context, value, child) => Text(
                        "${value.counter}",
                        style: TextStyle(fontSize: 50),
                      )),
              RaisedButton(
                onPressed: () {
                  bloc.injectInt(333);
                },
                child: Text('inject 333 on counter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

Didn't like my comment above? Keep calm, I also love Streams, inclusive, you can use Streams with this package if you prefer.

```
class AppBloc extends EasyBloc {
  int counter = 0;

  final _counterController = StreamController<int>();

  // can work with rxDart like:
  // final _counterController = BehaviouSubject<int>();

  get counterOut => _counterController.stream;

  @override
  void touch() {
    counter++;
    _counterController.sink.add(counter);
    super.touch();
  }

  @override
  void dispose() {
    _counterController.close();
    super.dispose();
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = EasyState.of<AppBloc>(context, listen: false);
    print("rebuild");
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add), onPressed: () => bloc.touch()),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              StreamBuilder<int>(
                  initialData: 0,
                  stream: bloc.counterOut,
                  builder: (context, snapshot) {
                    return Text(
                      "${snapshot.data}",
                      style: TextStyle(fontSize: 50),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
```




For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
