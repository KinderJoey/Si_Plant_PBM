import 'package:flutter/widgets.dart';
import 'package:siplant_pbm/screen/login_page.dart';
import 'package:siplant_pbm/screen/profil.dart';
import 'package:siplant_pbm/screen/register.dart';

import 'package:siplant_pbm/screen/splash.dart';
import 'package:siplant_pbm/screen/login_page.dart';
import 'package:siplant_pbm/screen/home_page.dart';
import 'package:siplant_pbm/screen/register.dart';
import 'package:siplant_pbm/screen/profil.dart';
import 'package:siplant_pbm/screen/edit_profil.dart';
import 'package:siplant_pbm/screen/daftar_pekerja.dart';
import 'package:siplant_pbm/screen/riwayat.dart';
import 'package:siplant_pbm/screen/location_page.dart';

final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  LoginPage.routeName: (context) => LoginPage(),
  HomePage.routeName: (context) => HomePage(),
  RegistrationPage.routeName: (context) => RegistrationPage(),
  ProfilePage.routeName: (context) => ProfilePage(),
  EditProfilePage.routeName: (context) => EditProfilePage(),
  DaftarPekerjaPage.routeName: (context) => DaftarPekerjaPage(),
  RiwayatPage.routeName: (context) => RiwayatPage(),
  LocationPage.routeName: (context) => LocationPage(),
};
