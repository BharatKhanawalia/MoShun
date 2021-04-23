import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:human_activity/home_screen.dart';
import 'package:human_activity/show_up.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension GlobalKeyExtension on GlobalKey {
  Rect get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    var translation = renderObject?.getTransformTo(null)?.getTranslation();
    if (translation != null && renderObject.paintBounds != null) {
      return renderObject.paintBounds
          .shift(Offset(translation.x, translation.y));
    } else {
      return null;
    }
  }
}

class BlackScreen extends StatefulWidget {
  @override
  _BlackScreenState createState() => _BlackScreenState();
}

class _BlackScreenState extends State<BlackScreen>
    with SingleTickerProviderStateMixin {
  int delayAmount = 10;
  final containerKey = GlobalKey();

  double imageContainerHeight;
  double imageContainerWidth;
  Color color = Colors.black;
  double top = 0;
  double left = 0;
  String name = '';

  bool getStartedPressed = false;

  double animationHeight = 1000;
  double animationWidth = 1000;
  BorderRadiusGeometry borderRadius = BorderRadius.circular(1);

  void printWidgetPosition() {
    print('absolute coordinates on screen: ${containerKey.globalPaintBounds}');
    imageContainerHeight = containerKey.globalPaintBounds.bottom -
        containerKey.globalPaintBounds.top;
    imageContainerWidth = containerKey.globalPaintBounds.right -
        containerKey.globalPaintBounds.left;
    top = containerKey.globalPaintBounds.top;
    left = containerKey.globalPaintBounds.left;
    setState(() {
      getStartedPressed = true;
      animationHeight = imageContainerHeight;
      animationWidth = imageContainerWidth;
      borderRadius = BorderRadius.circular(animationHeight / 2);
      // color = Colors.white;
    });
    Future.delayed(Duration(milliseconds: 1500), () {
      setState(() {
        color = Colors.white;
      });
    });
    Future.delayed(Duration(milliseconds: 2000), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    });
  }

  _read() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'my_string_key';
    final value = prefs.getString(key) ?? 'User';
    setState(() {
      name = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _read();
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
    Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: _exitAppDialog,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            AnimatedContainer(
              margin: EdgeInsets.only(
                left: left,
                top: top,
              ),
              duration: Duration(milliseconds: 600),
              height: animationHeight,
              width: animationWidth,
              curve: Curves.fastOutSlowIn,
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                color: color,
              ),
            ),
            Container(
              padding: EdgeInsets.all(30),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: size.height / 110,
                    ),
                    Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          key: containerKey,
                          child: ShowUp(
                            delay: delayAmount,
                            child: Hero(
                              tag: 'dp',
                              child: SvgPicture.asset(
                                "assets/avatar.svg",
                                height: size.height * 0.2,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ShowUp(
                          delay: delayAmount + 400,
                          child: Text(
                            'Hi!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        ShowUp(
                          delay: delayAmount + 600,
                          child: Text(
                            name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        ShowUp(
                          delay: delayAmount + 1000,
                          child: Text(
                            'Welcome to our app :)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    ShowUp(
                      delay: delayAmount + 1200,
                      child: ElevatedButton(
                        onPressed:
                            getStartedPressed ? null : printWidgetPosition,
                        child: Text(
                          'Get Started',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          onPrimary: Colors.black,
                          shadowColor: Colors.white,
                          elevation: 5,
                          primary: Colors.white,
                          minimumSize:
                              Size(size.width * 0.8, size.height * 0.06),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
