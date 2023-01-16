import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:car24repair/screen/loginscreen/login_screen.dart';
import 'package:car24repair/screen/mainscreen/home_screen/home_screen.dart';
import 'package:car24repair/screen/mainscreen/home_tech_screen/home_screen_tech.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
    ));
    return MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen());
  }
}

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? user_id;
  String? user_type;
  Future get_user_id() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = preferences.getString('user_id');
      user_type = preferences.getString('user_type');
    });
  }

  @override
  void initState() {
    get_user_id();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(
        child: Image.asset(
          "assets/images/logo.png",
        ),
      ),
      nextScreen: user_id == "" || user_id == null
          ? LoginScreen()
          : user_type == "user"
              ? HomeScreen()
              : HomeScreenTech(),
      splashIconSize: 200,
      backgroundColor: Colors.white,
      duration: 2000,
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
    );
  }
}
