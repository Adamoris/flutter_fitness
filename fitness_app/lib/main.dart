import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SensorData {
  static const MethodChannel _channel = MethodChannel('com.example/sensor');

  static Future<void> startUpdates(
      Function stepsCallback, Function distanceCallback) async {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'stepsUpdate':
          stepsCallback(call.arguments);
          break;
        case 'distanceUpdate':
          distanceCallback(call.arguments);
          break;
      }
    });
    await _channel.invokeMethod('startUpdates');
  }

  static Future<void> stopUpdates() async {
    await _channel.invokeMethod('stopUpdates');
  }

  // // similar methods for other sensor data
  // void startListening() {
  //   // Listen for method invocations from Swift.
  //   _channel.setMethodCallHandler((MethodCall call) async {
  //     switch (call.method) {
  //       case 'stepsUpdate':
  //         // Do something with the step count.
  //         int steps = call.arguments;
  //         print('Steps: $steps');
  //         break;
  //       case 'distanceUpdate':
  //         // Do something with the distance data.
  //         double distance = call.arguments;
  //         print('Distance: $distance');
  //         break;
  //     }
  //   });
  // }

  // void stopListening() {
  //   // Stop listening for method invocations from Swift.
  //   _channel.setMethodCallHandler(null);
  // }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TitleScreen(),
    );
  }
}

class TitleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fitness App"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Today's stats",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text("Calories burned: 0"), // replace 0 with actual value
            Text("Distance traveled: 0"), // replace 0 with actual value
            ElevatedButton(
              child: Text("Start Run"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RunScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RunScreen extends StatefulWidget {
  @override
  _RunScreenState createState() => _RunScreenState();
}

class _RunScreenState extends State<RunScreen> {
  // Assume these values will be updated in real-time
  double _caloriesBurned = 0.0;
  double _stepsTaken = 0.0;
  double _distanceTraveled = 0.0;

  @override
  void initState() {
    super.initState();
    startRun();
  }

  void startRun() async {
    SensorData.startUpdates((steps) {
      setState(() {
        _stepsTaken += steps;
      });
    }, (distance) {
      setState(() {
        _distanceTraveled += distance;
      });
    });
  }

  void endRun() async {
    SensorData.stopUpdates();
    // navigate to the summary screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Active Run"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Current Run Stats",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text("Calories burned: $_caloriesBurned"),
            Text("Steps Taken: $_stepsTaken"),
            Text("Distance traveled: $_distanceTraveled"),
            ElevatedButton(
              child: Text("End Run"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SummaryScreen(
                      caloriesBurned: _caloriesBurned,
                      distanceTraveled: _distanceTraveled,
                      stepsTaken: _stepsTaken,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryScreen extends StatelessWidget {
  final double caloriesBurned;
  final double stepsTaken;
  final double distanceTraveled;

  SummaryScreen(
      {required this.caloriesBurned,
      required this.distanceTraveled,
      required this.stepsTaken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Run Summary"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Run Stats",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text("Calories burned: $caloriesBurned"),
            Text("Steps Taken: $stepsTaken"),
            Text("Distance traveled: $distanceTraveled"),
            ElevatedButton(
              child: Text("Back to Title"),
              onPressed: () {
                Navigator.popUntil(
                  context,
                  ModalRoute.withName(Navigator.defaultRouteName),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
