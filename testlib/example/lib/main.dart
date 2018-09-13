import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:testlib/testlib.dart';
import 'package:testlib_example/adjustCommandExecutor.dart';
import 'package:testlib_example/command.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  AdjustCommandExecutor _adjustCommandExecutor;
  String _clientSdkPlatform = '';
  String _clientSdk = '';

  static String _protocol = 'https';
  static String _port = '8443';
  static String _address = '10.0.2.2';
  String _baseUrl = _protocol + '://' + _address + ':' + _port;
  String _gdprUrl = _protocol + '://' + _address + ':' + _port;

  @override
  void initState() {
    super.initState();
    initPlatformState();

    // init test library
    Testlib.init(_baseUrl);

    _adjustCommandExecutor = new AdjustCommandExecutor(_baseUrl, _gdprUrl);

    if (Platform.isAndroid) {
      _clientSdkPlatform = 'android4.14.0';
    } else if (Platform.isIOS) {
      _clientSdkPlatform = 'ios4.14.0';
    }

    // _clientSdk = 'flutter4.14.0@$_clientSdkPlatform';
    _clientSdk = 'android4.13.0';

    Testlib.doNotExitAfterEnd();
    
    Testlib.addTest('current/app-secret/Test_AppSecret_with_secret');
    // Testlib.addTestDirectory('current/event-tracking');

    Testlib.setExecuteCommandHalder((final dynamic callArgs) {
      Command command = new Command(callArgs);
      print('>>> EXECUTING METHOD: [${command.className}.${command.methodName}] <<<');
      _adjustCommandExecutor.executeCommand(command);
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await Testlib.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Flutter test app'),
        ),
        body: new CustomScrollView(shrinkWrap: true, slivers: <Widget>[
          new SliverPadding(
              padding: const EdgeInsets.all(20.0),
              sliver: new SliverList(
                  delegate: new SliverChildListDelegate(<Widget>[
                new Text('Running on: $_platformVersion\n'),
                buildCupertinoButton(
                    'Start Test Session',
                    () => Testlib.startTestSession(_clientSdk))
              ])))
        ]),
      ),
    );
  }

  static Widget buildCupertinoButton(String text, Function action) {
    return new CupertinoButton(
      child: Text(text),
      color: CupertinoColors.activeBlue,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 30.0),
      onPressed: action,
    );
  }
}
