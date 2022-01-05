import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry/sentry.dart';

Future<void> main() async {
  /*await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://17dda7c8b6124d80b157e150407c5ccb@o1108354.ingest.sentry.io/6135970';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(MyApp()),
  );*/

  runZonedGuarded(() async {
    WidgetsFlutterBinding
        .ensureInitialized(); // To ensure that everything is working
    await SentryFlutter.init(
      (options) {
        options.dsn =
            'https://17dda7c8b6124d80b157e150407c5ccb@o1108354.ingest.sentry.io/6135970';
        // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
        // We recommend adjusting this value in production.
        options.tracesSampleRate = 1.0;
      },
      appRunner: () => runApp(MyApp(
        navigatorObservers: [
          SentryNavigatorObserver(),
        ],
      )),
    );
  }, (error, stackTrace) async {
    if (kDebugMode) {
      log(error.toString(), error: error, stackTrace: stackTrace, name: 'dart');
    }

    ///if(kReleaseMode){ // Only on release mode
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
    );

    ///}
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  const MyApp({this.navigatorObservers = const <NavigatorObserver>[]});
  final List<NavigatorObserver> navigatorObservers;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: navigatorObservers,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class CustomException implements Exception {
  String cause;
  CustomException(this.cause);
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> _createError() async {
    throw new CustomException('This is a custom exception');

    /*try {

    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Vamos a producir un error',
            ),
            Container(
              margin: EdgeInsets.only(top: 20.0),
              child: Column(
                children: [
                  FloatingActionButton(
                    onPressed: _createError,
                    child: Icon(Icons.error_outline),
                  ),
                  Text('Error Basico'),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20.0),
              child: Column(
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      FlutterError.reportError(FlutterErrorDetails(
                          exception: Exception('Flutter Exception'),
                          stack: StackTrace.current));
                    },
                    child: Icon(Icons.error_outline),
                  ),
                  Text('Error Flutter'),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20.0),
              child: Column(
                children: [
                  FloatingActionButton(
                    onPressed: () async {
                      Timer(Duration(seconds: 2), ()async{
                        Future<void>.error(
                            Exception('Dart exception'), StackTrace.current);
                      });
                    },
                    child: Icon(Icons.error_outline),
                  ),
                  Text('Error Dart Async'),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20.0),
              child: Column(
                children: [
                  FloatingActionButton(
                    onPressed: () async {
                      final channel = const MethodChannel('crashy-custom-channel');
                      await channel.invokeMethod('blah');
                    },
                    child: Icon(Icons.error_outline),
                  ),
                  Text('Error Natural'),
                ],
              ),
            )
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
