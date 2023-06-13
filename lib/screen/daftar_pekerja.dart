import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:siplant_pbm/routes.dart';
import 'package:siplant_pbm/screen/pemesanan.dart';

class DaftarPekerjaPage extends StatefulWidget {
  static const String routeName = '/pekerja';

  @override
  _DaftarPekerjaPagestate createState() => _DaftarPekerjaPagestate();
}

class _DaftarPekerjaPagestate extends State<DaftarPekerjaPage> {
  late Stream<QuerySnapshot> _rentalStream;
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();

    _rentalStream =
        FirebaseFirestore.instance.collection('pekerja').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pekerja',
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
        stream: _rentalStream,
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
              child: Text('Tidak ada data sewa pekerja yang tersedia.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var pekerjaData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              var workername = pekerjaData['nama'] ?? '';
              var workertime = pekerjaData['waktu'] ?? '';
              var workerprice = pekerjaData['harga'] ?? '';

              // var startDate = rentalData['startDate'] != null
              //     ? (rentalData['startDate'] as Timestamp).toDate()
              //     : null;

              return Container(
                decoration: BoxDecoration(
                  color: Color(int.parse('0xFFCBFFD0')),
                  border: Border.all(
                    color: Colors.black,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                padding: EdgeInsets.all(16.0),
                child: ListTile(
                  // leading: Image.asset(
                  //     'path_to_image'), // Ganti 'path_to_image' dengan path file gambar Anda
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nama: $workername'),
                      Text('waktu: $workertime'),
                      Text('Harga: $workerprice'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PemesananPage(
                            workername: workername,
                            workertime: workertime,
                            workerprice: workerprice,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
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

  void _deleteRental(String rentalId) {
    FirebaseFirestore.instance.collection('sini').doc(rentalId).delete();
  }
}
