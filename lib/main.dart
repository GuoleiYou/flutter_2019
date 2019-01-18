import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//void main() => runApp(new ParametersPage());
//void main() => runApp(new SendParametersPage());
void main() => runApp(_widgetForRoute(window.defaultRouteName));

Widget _widgetForRoute(String route) {
  switch (route) {
    case 'flower shop':
      return Center(
        child: Text('This is the $route', textDirection: TextDirection.ltr),
      );
    case "Juliet's home":
      return Center(
        child: Text('This is $route', textDirection: TextDirection.ltr),
      );
    case 'send flower':
      return new ParametersPage();
    case 'climb':
      return new SendParametersPage();
    default:
      return Center(
        child: Text('Undefined route:$route', textDirection: TextDirection.ltr),
      );
  }
}

class ParametersPage extends StatefulWidget {
  _ParametersPageState createState() => _ParametersPageState();
}

class _ParametersPageState extends State<ParametersPage> {
  static const EventChannel eventChannel = const EventChannel('com.youguolei.flutter.sendflower');

  @override
  void initState() {
    super.initState();

    eventChannel.receiveBroadcastStream('Hi, Romeo!').listen(_onEvent,onError:_onError);
  }

  String naviTitle = 'title';

  void _onEvent(Object event) {
    setState(() {
      naviTitle = event.toString();
    });
  }

  void _onError(Object error) {
    print('error');
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Material(
        child: new Scaffold(
          body: new Center(
            child: new Text(naviTitle),
          ),
        ),
      ),
    );
  }
}

class SendParametersPage extends StatefulWidget {
  _SendParametersPage createState() => _SendParametersPage();
}

class _SendParametersPage extends State<SendParametersPage> {
  static const MethodChannel methodChannel = const MethodChannel('com.youguolei.parameters.escape');

  String _windowState = 'Closed';

  void _pressAction() {
    setState(() {

      print('flutter log : now print:windowState=$_windowState');

      if(_windowState == 'Closed') {
        _toNativeSomethingAndGetInfo();
      } else if(_windowState == 'Open') {
        Map<String, String> map = {'title' : 'this rope is from flutter'};
        methodChannel.invokeMethod('toNativePush',map);
      }else if(_windowState == 'Ropedown') {
        Map<String, dynamic> map = {'content':'climp','data':[1,2,3,4,5]};
        methodChannel.invokeMethod('toNativePop',map);
      }
    });
  }

  void _ropeAction() {
    setState(() {
      _windowState = 'Ropedown';
    });
  }

  Future<Null> _toNativeSomethingAndGetInfo() async {
    dynamic result;
    try {
      result = await methodChannel.invokeMethod('toNativeSomething','window state $_windowState');
    } on PlatformException {
      result = 100000;
    }

    setState(() {
      if(result is String) {
        _windowState = result;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Material(
        child: new Scaffold(
          body: new Center(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(
                  'The window state:',
                ),
                new Text(
                  '$_windowState',
                  style: Theme.of(context).textTheme.display1,
                ),
                new FlatButton(onPressed: _ropeAction,
                  child: new Text('press to release the rope'),
                ),
              ],
            ),
          ),
          floatingActionButton: new FloatingActionButton(
            onPressed: _pressAction,
            tooltip: 'Increment',
            child: new Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}