import 'package:easy/easy.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(BlocProvider(
    blocs: [Bloc((i) => AppBloc())],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyState',
      home: MainPage(),
    );
  }
}

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

  @override
  void dispose() {
    super.dispose();
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = EasyState.of<AppBloc>(context, listen: false);
    // Note with this print on the console that unlike setState, clicking the Increment Button does not rebuild the widget.
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
                child: Text('inject 333 on Counter'),
              ),
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
                builder: (context, value, child) => Text(
                      "${value.counter}",
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
