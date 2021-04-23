import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:human_activity/show_up.dart';
import 'package:scidart/numdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sensors/sensors.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _read();
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));
    _loadModel();
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    timer.cancel();
  }

  String name = '';
  _read() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'my_string_key';
    final value = prefs.getString(key) ?? 'User';
    print('read: $value');
    setState(() {
      name = value;
    });
  }

  Future<bool> _exitAppDialog() async {
    return (await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          title: Text(
            'Exit Application',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontFamily: 'Nexa',
            ),
          ),
          content: Text(
            'Are you sure you want to exit the app?',
            style: TextStyle(
              fontFamily: 'Nexa',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'No',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Nexa',
                ),
              ),
              style: ElevatedButton.styleFrom(
                onPrimary: Colors.black,
                shadowColor: Colors.grey[400],
                elevation: 5,
                primary: Colors.grey[100],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                SystemNavigator.pop();
              },
              child: Text(
                'Yes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Nexa',
                ),
              ),
              style: ElevatedButton.styleFrom(
                onPrimary: Colors.white,
                shadowColor: Colors.black,
                elevation: 5,
                primary: Colors.black,
              ),
            ),
          ],
        );
      },
    ));
  }

  List<double> _accelerometerValues;
  List<double> _userAccelerometerValues;
  List<double> _gyroscopeValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];
  bool recordingOn = false;
  List<List<double>> array = [];
  var maxIndex;
  Timer timer;
  static const _modelFile = 'model.tflite';
  Interpreter _interpreter;

  void _loadModel() async {
    // Creating the interpreter using Interpreter.fromAsset
    _interpreter = await Interpreter.fromAsset(_modelFile);
    print('Interpreter loaded successfully');
    _interpreter.allocateTensors();
    print(_interpreter.getInputTensors());
    print(_interpreter.getOutputTensors());
  }

  void _predict() {
    for (int i = 0; i < 9; i++) {
      Array tArray = Array.empty();
      for (int j = 0; j < 128; j++) {
        tArray.add(array[j][i]);
      }
      for (int k = 0; k < 128; k++) {
        array[k][i] = (array[k][i] - mean(tArray)) / (sqrt(variance(tArray)));
      }
    }
    List<List<List<double>>> input = [array];
    List<List<double>> output =
        List.generate(1, (index) => List.generate(6, (index) => null));
    _interpreter.run(input, output);
    var max =
        output[0].reduce((current, next) => current > next ? current : next);
    setState(() {
      maxIndex = output[0].indexWhere((element) => element == max);
    });
    if (maxIndex == 0) {
      print('Walking');
    } else if (maxIndex == 1) {
      print('Walking Upstairs');
    } else if (maxIndex == 2) {
      print('Walking Downstairs');
    } else if (maxIndex == 3) {
      print('Sitting');
    } else if (maxIndex == 4) {
      print('Standing');
    } else if (maxIndex == 5) {
      print('Laying');
    }
  }

  String get activityText {
    if (maxIndex == 0) {
      return 'Walking';
    }
    if (maxIndex == 1) {
      return 'Walking Upstairs';
    }
    if (maxIndex == 2) {
      return 'Walking Downstairs';
    }
    if (maxIndex == 3) {
      return 'Sitting';
    }
    if (maxIndex == 4) {
      return 'Standing';
    }
    if (maxIndex == 5) {
      return 'Laying';
    }
    return '--';
  }

  void addToArray() {
    setState(() {
      array.add([
        _userAccelerometerValues[0],
        _userAccelerometerValues[1],
        _userAccelerometerValues[2],
        _gyroscopeValues[0],
        _gyroscopeValues[1],
        _gyroscopeValues[2],
        _accelerometerValues[0],
        _accelerometerValues[1],
        _accelerometerValues[2],
      ]);
    });
  }

  void startRecording() {
    timer = Timer.periodic(Duration(milliseconds: 20), (timer) {
      if (array.length < 129) {
        addToArray();
      }
      if (array.length == 129) {
        timer.cancel();
        _predict();
        array.clear();
        startRecording();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: _exitAppDialog,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  SizedBox(
                    height: size.height * 0.06,
                  ),
                  Hero(
                    tag: 'dp',
                    child: PhysicalModel(
                      elevation: 8,
                      color: Colors.white,
                      shadowColor: Colors.grey[300],
                      shape: BoxShape.circle,
                      child: SvgPicture.asset(
                        "assets/avatar.svg",
                        height: size.height * 0.07,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  ShowUp(
                    delay: 700,
                    child: Text(
                      'Hi, $name',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Nexa',
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  ShowUp(
                    delay: 900,
                    child: Text(
                      'Your Activity:',
                      style: TextStyle(
                          fontSize: 36,
                          color: Colors.black,
                          fontFamily: 'Nexa',
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  ShowUp(
                    delay: 1100,
                    child: Container(
                      margin: EdgeInsets.all(25),
                      height: size.height * 0.2,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[400],
                            offset: Offset(0.0, 10.0), //(x,y)
                            blurRadius: 8.0,
                          )
                        ],
                      ),
                      child:
                          // SelectableText('${[array]}'),
                          Center(
                        child: recordingOn
                            ? activityText == '--'
                                ? CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black,
                                    ),
                                  )
                                : Text(
                                    activityText,
                                    style: TextStyle(
                                      fontSize: 45,
                                      fontFamily: 'Nexa',
                                    ),
                                  )
                            : Text(
                                '--',
                                style: TextStyle(
                                  fontSize: 45,
                                  fontFamily: 'Nexa',
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  ShowUp(
                    delay: 1300,
                    child: RichText(
                      text: TextSpan(
                        children: recordingOn && activityText != '--'
                            ? <TextSpan>[
                                TextSpan(text: 'Current Status: '),
                                TextSpan(
                                  text: 'Active',
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.green,
                                      fontFamily: 'Nexa',
                                      fontWeight: FontWeight.w600),
                                ),
                              ]
                            : <TextSpan>[
                                TextSpan(text: 'Current Status: '),
                                TextSpan(
                                  text: 'Inactive',
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.red,
                                      fontFamily: 'Nexa',
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontFamily: 'Nexa',
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ShowUp(
                    delay: 1400,
                    child: ElevatedButton(
                      onPressed: recordingOn
                          ? null
                          : () {
                              print('--Activity Started--');
                              startRecording();
                              recordingOn = true;
                            },
                      child: Text(
                        '▶   Start Listening',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Nexa',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        onPrimary: Colors.white,
                        shadowColor: Colors.black,
                        elevation: 3,
                        primary: Colors.black,
                        minimumSize: Size(
                          size.width * 0.8,
                          size.height * 0.07,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ShowUp(
                    delay: 1500,
                    child: ElevatedButton(
                      onPressed: recordingOn
                          ? () {
                              timer.cancel();
                              // print(array);

                              setState(() {
                                array.clear();
                                recordingOn = false;
                              });
                              print('--Activity Stopped--');
                            }
                          : null,
                      child: Text(
                        '■   Stop Listening',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Nexa',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        onPrimary: Colors.white,
                        shadowColor: Colors.black,
                        elevation: 3,
                        primary: Colors.black,
                        minimumSize: Size(
                          size.width * 0.8,
                          size.height * 0.07,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
