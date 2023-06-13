import 'package:flutter/material.dart';
import 'package:siplant_pbm/screen/home_page.dart';
import 'package:siplant_pbm/screen/login_page.dart';
import 'package:siplant_pbm/screen/profil.dart';
import 'package:siplant_pbm/screen/register.dart';
import 'package:siplant_pbm/routes.dart';
import 'package:siplant_pbm/screen/splash.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login App',
      initialRoute: SplashScreen.routeName,
      routes: routes,
    );
  }
}
