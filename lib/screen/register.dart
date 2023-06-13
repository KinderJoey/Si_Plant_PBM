import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class RegistrationPage extends StatefulWidget {
  static String routeName = "/signup";
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Future<void> _registerUser() async {
    try {
      String imageprofil =
          'https://firebasestorage.googleapis.com/v0/b/siplant-23018.appspot.com/o/profile1.png?alt=media&token=c53079b1-98f9-4bf8-b0b2-028cf577a79b&_gl=1*aab3ox*_ga*Njk2NTgyMzgyLjE2ODUxOTUzNTY.*_ga_CW55HF8NVT*MTY4NjE5MzMzNC4yNy4xLjE2ODYxOTg1MzguMC4wLjA.';
      String fullname = '';
      String username = _usernameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String address = '';
      String phoneNumber = '';
      double latitude = 0.0;
      double longitude = 0.0;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });
      // Create user in Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user ID from userCredential
      String userId = userCredential.user!.uid;

      // Save user details in Firestore
      await _firestore.collection('users').doc(userId).set({
        'imagepengguna': imageprofil,
        'fullname': fullname,
        'username': username,
        'email': email,
        'address': address,
        'phoneNumber': phoneNumber,
        'latitude': latitude,
        'longitude': longitude,
      });

      // Navigate to home page or perform other actions
      Navigator.pushNamed(context, '/home');
    } catch (e) {
      // Handle registration errors
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Registration Error'),
            content: Text('cek kembali email atau username'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Spacer(),
            Image.asset(
              'assets/logo2.png',
              width: 150.0,
              height: 150.0,
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Color(int.parse('0xFF98FFA2'))),
              ),
              onPressed: _registerUser,
              child: Text(
                'Register',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                ),
              ),
            ),
            Spacer(),
            TextButton(
              child: Text(
                "Have Account?",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
