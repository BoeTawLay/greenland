import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  Future<void> _signUp() async {
    try {
      // Validate email format
      if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(_emailController.text.trim())) {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message: 'Invalid email format. Please enter a valid email address.',
        );
      }

      // Validate username format (You can customize the username validation rule)
      if (_usernameController.text.trim().isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-username',
          message: 'Username cannot be empty.',
        );
      }

      // Validate password format (You can customize the password validation rule)
      if (_passwordController.text.length < 6) {
        throw FirebaseAuthException(
          code: 'weak-password',
          message: 'Password must be at least 6 characters long.',
        );
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Save the user data to Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': _emailController.text.trim(),
        'username': _usernameController.text.trim(),
      });

      // User signed up successfully, you can navigate to the next screen or perform other actions.
      print('User signed up: ${userCredential.user?.email}');
    } catch (e) {
      // Handle errors here
      print('Error during signup: $e');
      String errorMessage = 'Signup failed. Please try again.';
      if (e is FirebaseAuthException) {
        errorMessage = e.message ?? 'Signup failed. Please try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SignUp'),
        backgroundColor: Color.fromARGB(255, 186, 195, 188),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Color.fromARGB(255, 165, 169, 166),
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Image.asset(
                'lib/images/io2.png',
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 16),
              Card(
                elevation: 5.0,
                
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  
                ),
                color: Color.fromARGB(255, 95, 105, 101),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          _signUp();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.orange,
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        ),
                        child: Text('Sign', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 130),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
