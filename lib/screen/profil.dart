import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class ProfilePage extends StatefulWidget {
  static String routeName = "/profile";

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 2;
  double latitude = 0.0;
  double longitude = 0.0;

  Future<void> getLocation() async {
    final PermissionStatus permissionStatus =
        await Permission.location.request();

    if (permissionStatus.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          latitude = position.latitude;
          longitude = position.longitude;
        });

        await saveLocationToFirestore();
      } catch (e) {
        print('Error getting location: $e');
      }
    } else {
      setState(() {
        latitude = 0.0;
        longitude = 0.0;
      });
    }
  }

  Future<void> saveLocationToFirestore() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    if (user != null) {
      try {
        await firestore.collection('users').doc(user.uid).update({
          'latitude': latitude,
          'longitude': longitude,
        });
      } catch (e) {
        print('Error saving location to Firestore: $e');
      }
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(
          context, '/SplashScreen', (Route<dynamic> route) => false);
    } catch (e) {}
  }

  void _editProfile() {
    Navigator.pushNamed(context, '/editProfile');
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      body: user != null
          ? FutureBuilder<DocumentSnapshot>(
              future: firestore.collection('users').doc(user.uid).get(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(
                    child: Text('No user data found'),
                  );
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>;

                return Padding(
                  padding: EdgeInsets.all(0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.topRight,
                        padding: EdgeInsets.fromLTRB(0, 40, 10, 0),
                        child: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigator.pushNamed(context, '/editProfile');
                          },
                        ),
                      ),
                      Spacer(),
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            NetworkImage(userData['imagepengguna'] ?? ''),
                      ),
                      SizedBox(height: 10),
                      Text(
                        userData['username'] ?? '',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 30),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(50),
                            topRight: Radius.circular(50),
                          ),
                          color: Color(int.parse('0xFF98FFA2')),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.person),
                              title: Text(userData['fullname'] ?? ''),
                            ),
                            Divider(color: Colors.black),
                            ListTile(
                              leading: Icon(Icons.email),
                              title: Text(userData['email'] ?? ''),
                            ),
                            Divider(color: Colors.black),
                            ListTile(
                              leading: Icon(Icons.location_on),
                              title: Text(userData['address'] ?? ''),
                            ),
                            Divider(color: Colors.black),
                            ListTile(
                              leading: Icon(Icons.phone),
                              title: Text(userData['phoneNumber'] ?? ''),
                            ),
                            Divider(color: Colors.black),
                            Container(
                              alignment: Alignment.topRight,
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: IconButton(
                                icon: Icon(Icons.my_location),
                                onPressed: getLocation,
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: _logout,
                              child: Text(
                                'Log Out',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          : Center(
              child: Text('User not logged in'),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          }
          if (index == 1) {
            Navigator.pushNamed(context, '/pekerja');
          }
          if (index == 2) {
            Navigator.pushNamed(context, '/profile');
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.engineering),
            label: 'Pekerja',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
