import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PemesananPage extends StatefulWidget {
  static String routeName = "/pemesanan";

  final String workername;
  final String workertime;
  final String workerprice;

  PemesananPage({
    required this.workername,
    required this.workertime,
    required this.workerprice,
  });

  @override
  _PemesananPageState createState() => _PemesananPageState();
}

class _PemesananPageState extends State<PemesananPage> {
  String currentDate = '';

  @override
  void initState() {
    super.initState();
    currentDate = DateFormat('dd MMM yyyy').format(DateTime.now());
  }

  Future<void> _pushTransaksi() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }

      DocumentSnapshot userData =
          await firestore.collection('users').doc(user.uid).get();
      String pemesan = userData['username'] ?? '';
      String email = userData['email'] ?? '';

      Map<String, dynamic> transaksiData = {
        'userid': user.uid,
        'pemesan': pemesan,
        'email': email,
        'nama_pekerja': widget.workername,
        'durasi': widget.workertime,
        'harga': widget.workerprice,
        'tanggal': currentDate,
      };

      await firestore.collection('transaksi').add(transaksiData);

      // Berhasil menyimpan data, lakukan tindakan lain atau navigasi ke halaman lain
      Navigator.pushNamed(context, '/home');
    } catch (e) {
      // Tangani kesalahan yang terjadi saat menyimpan data
      print('Terjadi kesalahan: $e');
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

                if (!snapshot.hasData) {
                  return Center(
                    child: Text('No user data found'),
                  );
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>;
                var username = userData['username'] ?? '';
                var email = userData['email'] ?? '';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 60),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: Column(
                        children: [
                          SizedBox(height: 16),
                          Image.asset(
                            'assets/logo2.png',
                            width: 150.0,
                            height: 150.0,
                          ),
                          SizedBox(height: 16),
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
                                Text(
                                  'Transaksi',
                                  style: TextStyle(
                                    fontSize: 40,
                                  ),
                                ),
                                Divider(
                                  color: Colors.black,
                                  height: 10,
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'pemesan: $username / $email',
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Nama Pekerja: ${widget.workername}',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Durasi: ${widget.workertime}',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Harga: ${widget.workerprice}',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 223),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: _pushTransaksi,
                                  child: Text(
                                    'Bayar',
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
                    ),
                  ],
                );
              },
            )
          : Center(
              child: Text('User not logged in'),
            ),
    );
  }
}
