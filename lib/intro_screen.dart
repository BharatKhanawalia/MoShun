import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:human_activity/black_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  AnimationController scaleController;
  Animation<double> scaleAnimation;
  bool _noIcon = false;
  int delayAmount = 500;
  String _name;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    scaleController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              scaleController.reverse();
              Navigator.pushReplacement(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  child: BlackScreen(),
                ),
              );
            }
          });
    scaleAnimation =
        Tween<double>(begin: 1.0, end: 50.0).animate(scaleController);
  }

  @override
  void dispose() {
    scaleController.dispose();
    super.dispose();
  }

  _save() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'my_string_key';
    final value = _name;
    prefs.setString(key, value);
    print('saved $value');
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

  @override
  Widget build(BuildContext context) {
    final mediaWidth = MediaQuery.of(context).size.width;
    final mediaHeight = MediaQuery.of(context).size.height;

    // String myStringWithLinebreaks =
    //     "Walking\nWalking Upstairs\nWalking Downstairs\nSitting Down\nStanding Up\nLaying Down";

    return WillPopScope(
      onWillPop: _exitAppDialog,
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          backgroundColor: Color(0xFFFFFFFF),
          body: SingleChildScrollView(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: mediaHeight * 0.08,
                    ),
                    Container(
                      // color: Colors.yellow,
                      width: mediaWidth * 0.8,
                      child: Text(
                        'MoShun',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          height: 1.2,
                          // fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: mediaHeight * 0.1,
                ),
                Column(
                  children: [
                    Image.asset('assets/walking.gif'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        'A test app which implements Human Activity Recognition.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          // fontWeight: FontWeight.w300,
                          height: 1.3,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    // SizedBox(
                    //   height: 10,
                    // ),
                    // ListTile(
                    //     contentPadding: EdgeInsets.only(left: 25),
                    //     subtitle: Column(
                    //         children: LineSplitter.split(myStringWithLinebreaks)
                    //             .map((o) {
                    //       return Row(
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: <Widget>[
                    //           Text(
                    //             "•   ",
                    //             style: TextStyle(
                    //               fontWeight: FontWeight.w500,
                    //               fontSize: 16,
                    //               height: 1.3,
                    //             ),
                    //           ),
                    //           Expanded(
                    //             child: Text(
                    //               o,
                    //               style: TextStyle(
                    //                 // fontWeight: FontWeight.w500,
                    //                 fontSize: 16,
                    //                 height: 1.3,
                    //               ),
                    //             ),
                    //           )
                    //         ],
                    //       );
                    //     }).toList())),
                  ],
                ),
                SizedBox(
                  height: mediaHeight * 0.15,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 25),
                              width: double.infinity,
                              child: Text(
                                'Enter Your Name ',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 25,
                                vertical: 10,
                              ),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a name!';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  setState(() {
                                    _name = value;
                                  });
                                },
                                cursorColor: Colors.black,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 22,
                                  ),
                                  // filled: true,
                                  // fillColor: Color(0xFF3ACEB6).withAlpha(50),
                                  hintText: 'Your Name',

                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1.5),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                    borderSide: BorderSide(
                                        color: Colors.red, width: 1.5),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                    borderSide: BorderSide(
                                        color: Colors.red, width: 1.5),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 25, bottom: 25),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: AnimatedBuilder(
                            animation: scaleAnimation,
                            builder: (context, child) => Transform.scale(
                              scale: scaleAnimation.value,
                              child: FloatingActionButton(
                                tooltip: 'Next',
                                onPressed: () {
                                  FocusScopeNode currentFocus =
                                      FocusScope.of(context);
                                  if (!_formKey.currentState.validate()) {
                                    return;
                                  }
                                  _formKey.currentState.save();

                                  _save();
                                  if (!currentFocus.hasPrimaryFocus) {
                                    currentFocus.unfocus();
                                  }
                                  Future.delayed(Duration(milliseconds: 1000),
                                      () {
                                    setState(() {
                                      _noIcon = true;
                                    });
                                    scaleController.forward();
                                  });
                                },
                                backgroundColor: Colors.black,
                                child: _noIcon
                                    ? null
                                    : Icon(
                                        Icons.chevron_right_rounded,
                                        size: 30,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
