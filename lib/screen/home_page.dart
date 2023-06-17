import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:siplant_pbm/screen/maps.dart';

class HomePage extends StatefulWidget {
  static String routeName = "/home";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool isLoading = false;
  List<dynamic> weatherData = [];
  String cityName = '';
  double latitude = 0.0;
  double longitude = 0.0;
  String apiKey = "e4b2057dc1c953be9043355664a278ab";
  MapController mapController = MapController();

  void initState() {
    super.initState();

    getLocation();
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(
          context, '/SplashScreen', (Route<dynamic> route) => false);
    } catch (e) {}
  }

  Future<void> getWeather() async {
    setState(() {
      isLoading = true;
    });

    var url = Uri.parse(
        "http://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&appid=$apiKey");
    var response = await http.get(url);
    var data = jsonDecode(response.body);

    setState(() {
      if (data['list'] != null) {
        weatherData = data['list'];
        cityName = data['city']['name'];
      } else {
        weatherData = [];
        cityName = '';
      }
      isLoading = false;
    });
  }

  Widget weatherIcon(String iconCode) {
    String iconUrl = "http://openweathermap.org/img/w/$iconCode.png";
    return Image.network(
      iconUrl,
      width: MediaQuery.of(context).size.width / 7,
      height: MediaQuery.of(context).size.height / 20,
    );
  }

  Future<void> getLocation() async {
    final PermissionStatus permissionStatus =
        await Permission.location.request();

    if (permissionStatus.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });

      await getWeather();
    } else {
      setState(() {
        latitude = 0.0;
        longitude = 0.0;
      });
    }
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
                var username = userData['username'] ?? '';
                var userfullname = userData['fullname'] ?? '';
                return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 40.0, right: 10.0),
                      color: Color(0xFF98FFA2),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 10),
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage(
                                    userData['imagepengguna'] ?? ''),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome...',
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    userData['username'] ?? '',
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              IconButton(
                                icon: Icon(Icons.receipt_long),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/riwayat');
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.logout),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Konfirmasi Logout'),
                                        content: Text(
                                            'Apakah Anda yakin ingin logout?'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text(
                                              'Batal',
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          ElevatedButton(
                                            child: Text(
                                              'Logout',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            onPressed: _logout,
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                    GestureDetector(
                      child: Container(
                        // width: MediaQuery.of(context).size.width * 1,
                        // height: MediaQuery.of(context).size.height * 0.5,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(20.0),
                          gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [
                              Color(0xFF98FFA2),
                              Color(0xFFCBFFD0),
                            ],
                          ),
                        ),
                        margin: EdgeInsets.all(10.0),
                        padding: EdgeInsets.all(3.0),
                        child: Column(
                          children: <Widget>[
                            if (isLoading)
                              CircularProgressIndicator()
                            else if (weatherData.isNotEmpty)
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      'Cuaca',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Flexible(
                                        flex: 3,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: 3,
                                          itemBuilder: (context, index) {
                                            var forecast =
                                                weatherData[index * 1];
                                            var dateTime = DateTime
                                                .fromMillisecondsSinceEpoch(
                                                    forecast['dt'] * 1000);

                                            var description =
                                                forecast['weather'][0]
                                                    ['description'];
                                            var iconCode =
                                                forecast['weather'][0]['icon'];

                                            return ListTile(
                                              title: Row(
                                                children: [
                                                  weatherIcon(iconCode),
                                                  Text(
                                                    '${dateTime.hour}:00 - ',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    '$description',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      Flexible(
                                        flex: 1,
                                        child: Padding(
                                          padding: EdgeInsets.all(0.0),
                                          child: weatherData.isNotEmpty
                                              ? Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    weatherIcon(weatherData[0]
                                                        ['weather'][0]['icon']),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      '${(weatherData[0]['main']['temp'] - 273.15).round()}°C',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${weatherData[0]['weather'][0]['description']}',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      '$cityName',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : SizedBox(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    CarouselSlider(
                      items: [
                        Container(
                          margin: EdgeInsets.only(top: 20.0),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                  'https://firebasestorage.googleapis.com/v0/b/siplant-23018.appspot.com/o/beautiful%20garden%20(1).png?alt=media&token=6d38d779-79b5-46e6-8afc-f2e7ccbabc65'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 20.0),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                  'https://firebasestorage.googleapis.com/v0/b/siplant-23018.appspot.com/o/The%20Easiest%20Way%20To%20Water%20Your%20Garden.jpg?alt=media&token=c6d7b40d-dc76-40bf-bfbb-b5c6bda0e718'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 20.0),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                  'https://firebasestorage.googleapis.com/v0/b/siplant-23018.appspot.com/o/How%20to%20Garden%20on%20a%20Slope_%20The%20Best%20Plants%20and%20Tips%20to%20Beautify%20a%20Hilly%20Yard%20(1).jpg?alt=media&token=e1dc81cb-f961-4c74-90cc-6a0f22dd90bb'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ],
                      options: CarouselOptions(
                        height: 150.0,
                        enlargeCenterPage: true,
                        autoPlay: false,
                        aspectRatio: 16 / 9,
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enableInfiniteScroll: true,
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        viewportFraction: 0.8,
                      ),
                    ),
                  ],
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
