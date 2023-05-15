import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SensorData {
  static const MethodChannel _channel = MethodChannel('com.example/sensor');

  static Future<void> startStepsUpdates(Function callback) async {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'stepsUpdate':
          callback(call.arguments);
          break;
      }
    });
    await _channel.invokeMethod('startStepsUpdates');
  }

  static Future<void> stopStepsUpdates() async {
    await _channel.invokeMethod('stopStepsUpdates');
  }

  // similar methods for other sensor data
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
              style: Theme.of(context).textTheme.headline5,
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
  double _distanceTraveled = 0.0;

  @override
  void initState() {
    super.initState();
    startRun();
  }

  void startRun() async {
    SensorData.startStepsUpdates((steps) {
      setState(() {
        _distanceTraveled +=
            steps; // replace this with a conversion from steps to distance
      });
    });
  }

  void endRun() async {
    SensorData.stopStepsUpdates();
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
              style: Theme.of(context).textTheme.headline5,
            ),
            Text("Calories burned: $_caloriesBurned"),
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
  final double distanceTraveled;

  SummaryScreen({required this.caloriesBurned, required this.distanceTraveled});

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
              style: Theme.of(context).textTheme.headline5,
            ),
            Text("Calories burned: $caloriesBurned"),
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
