import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dart:convert';

class RiwayatPage extends StatefulWidget {
  static const String routeName = '/riwayat';

  @override
  _RiwayatPageState createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  late Stream<QuerySnapshot> _riwayatStream;
  MapController mapController = MapController();

  @override
  void initState() {
    super.initState();

    _riwayatStream = _getRiwayatStream();
  }

  Stream<QuerySnapshot> _getRiwayatStream() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.empty();
    }

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    Stream<QuerySnapshot> riwayatStream = firestore
        .collection('transaksi')
        .where('userid', isEqualTo: user.uid)
        .snapshots();

    return riwayatStream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Transaksi',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Color(0xFF98FFA2),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _riwayatStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Terjadi kesalahan: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('Tidak ada riwayat transaksi.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var riwayatData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              var pemesan = riwayatData['pemesan'] ?? '';
              var email = riwayatData['email'] ?? '';
              var namaPekerja = riwayatData['nama_pekerja'] ?? '';
              var durasi = riwayatData['durasi'] ?? '';
              var harga = riwayatData['harga'] ?? '';
              var tanggal = riwayatData['tanggal'] ?? '';

              return Container(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFCBFFD0),
                        border: Border.all(
                          color: Colors.black,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      margin:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text('Pemesan: $pemesan / $email'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 15),
                                Text('Nama Pekerja: $namaPekerja'),
                                Text('Durasi: $durasi'),
                                Text('Harga: $harga'),
                                SizedBox(height: 10),
                                Text('Tanggal Pemesanan: $tanggal'),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: Icon(Icons.map),
                              onPressed: () {
                                // Navigasi ke halaman peta di sini
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
