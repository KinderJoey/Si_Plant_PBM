import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class EditProfilePage extends StatefulWidget {
  static String routeName = "/editProfile";

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _fullnameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();

  Future<void> _updateProfile() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('images');

    Reference referenceImageToUpload = referenceDirImages.child(user!.uid);

    if (user != null) {
      try {
        await referenceImageToUpload.putFile(File(_image!.path));
        //Success: get the download URL
        imageUrl = await referenceImageToUpload.getDownloadURL();
        bool confirmSave = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Yakin ingin menyimpan?'),
              content: Text('Yakin ingin menyimpan perubahan?'),
              actions: <Widget>[
                TextButton(
                  child: Text('Batal'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text('Simpan'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );

        if (confirmSave == true) {
          await firestore.collection('users').doc(user.uid).update({
            'imagepengguna': imageUrl,
            'username': _usernameController.text,
            'fullname': _fullnameController.text,
            'email': _emailController.text,
            'address': _addressController.text,
            'phoneNumber': _phoneNumberController.text,
          });
          Navigator.pushNamed(context, '/profile');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile updated successfully'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullnameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  File? _image;
  XFile? _images;
  String? imageUrl;
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    Future<void> getImagefromCamera() async {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.camera);

      setState(() {
        _images = image;
        _image = File(_images!.path);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Color(0xFF98FFA2),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
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

                _usernameController.text = userData['username'] ?? '';
                _fullnameController.text = userData['fullname'] ?? '';
                _emailController.text = userData['email'] ?? '';
                _addressController.text = userData['address'] ?? '';
                _phoneNumberController.text = userData['phoneNumber'] ?? '';

                return Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          Container(
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  NetworkImage(userData['imagepengguna'] ?? ''),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Color(0xFF98FFA2),
                                borderRadius: BorderRadius.circular(500)),
                            margin: EdgeInsets.only(left: 65, top: 65),
                            width: 40,
                            height: 40,
                            child: IconButton(
                              icon: Icon(Icons.camera),
                              onPressed: () {
                                // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                //     content: Text(
                                //         'email yang anda masukkan tidak terdaftar'),
                                //     backgroundColor: Colors.red));
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: Icon(Icons.camera),
                                            title: Text('Open Camera'),
                                            onTap: () {
                                              getImagefromCamera();
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          ListTile(
                                            leading: Icon(Icons.photo_library),
                                            title: Text('Select from Gallery'),
                                            onTap: () async {
                                              final picker = ImagePicker();
                                              final pickedImage =
                                                  await picker.pickImage(
                                                      source:
                                                          ImageSource.gallery);
                                              if (pickedImage != null) {
                                                setState(
                                                  () {
                                                    _image =
                                                        File(pickedImage.path);
                                                  },
                                                );
                                                Navigator.of(context).pop();
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _fullnameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'Email',
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Address',
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _phoneNumberController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF98FFA2),
                        ),
                        onPressed: _updateProfile,
                        child: Text(
                          'Simpan',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                          ),
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
    );
  }
}
