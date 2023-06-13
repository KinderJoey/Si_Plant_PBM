import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

    if (user != null) {
      try {
        await firestore.collection('users').doc(user.uid).update({
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

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                        onPressed: _updateProfile,
                        child: Text('Save'),
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
