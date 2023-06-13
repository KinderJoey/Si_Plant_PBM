import 'package:flutter/material.dart';
import 'package:siplant_pbm/screen/login_page.dart';
import 'package:siplant_pbm/screen/register.dart';

class SplashScreen extends StatelessWidget {
  static String routeName = "/SplashScreen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(int.parse('0xFF98FFA2')),
      body: Center(
        child: Column(
          // padding: EdgeInsets.fromLTRB(0, 50, 0, 20),
          children: [
            SizedBox(height: 50),
            Image.asset(
              'assets/name.png',
              width: 170.0,
              height: 170.0,
            ),
            Image.asset(
              'assets/tampilanawal.png',
            ),
            Container(
              margin: EdgeInsets.fromLTRB(40, 20, 40, 20),
              padding: EdgeInsets.fromLTRB(10, 0, 10, 25),
              height: 170,
              child: Column(
                children: [
                  Container(
                    width: 250,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/login");
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 23,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    child: Text(
                      "Not a member? Signup now",
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
