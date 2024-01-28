import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'welcomepage.dart';

class ProfilePage extends StatefulWidget {
  final String? email;

  ProfilePage({Key? key, this.email}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? username; // Variable to store the fetched username

  @override
  void initState() {
    super.initState();
    // Fetch the username when the widget is initialized
    fetchUsername();
  }

  // Function to fetch the username from Firestore
  Future<void> fetchUsername() async {
    try {
      // Assuming 'users' is your Firestore collection name
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // If a user with the given email is found, retrieve the username
        username = querySnapshot.docs[0]['username'];
        // Update the state to trigger a rebuild with the fetched username
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
  }

  // Function to handle the log out action
  void logOut() {
    // Add any logic needed for logging out, such as clearing user session, etc.

    // Navigate to the WelcomePage
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => WelcomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/po2.jpg'), // Change to your image asset
            ),
            SizedBox(height: 20),
            _buildProfileInfo('Email', widget.email),
            SizedBox(height: 20),
            _buildProfileInfo('Username', username),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: logOut,
              child: Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(String label, String? value) {
    return TextField(
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        labelText: label,
        icon: Icon(label == 'Email' ? Icons.email : Icons.person),
      ),
      enabled: false,
    );
  }
}
