import 'dart:async';
import 'package:flutter/material.dart';
import 'ProductAddPage.dart';
import 'ProductPage.dart';
import 'ProfilePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Homepage extends StatefulWidget {
  final String? email;

  Homepage({Key? key, this.email}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final PageController _pageController = PageController(initialPage: 0);
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentPage < 7) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 207, 211, 207),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
              print('Search button pressed');
            },
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Image.asset(
              'lib/images/cx34.png',
              height: 100,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPressableIconCard(Icons.explore, 'Items', Color.fromARGB(255, 95, 105, 101), () {
                    print('Items icon pressed');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProductPage()),
                    );
                  }),
                  _buildPressableIconCard(Icons.add, 'Add', Color.fromARGB(255, 95, 105, 101), () {
                    print('Add icon pressed');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProductAddPage()),
                    );
                  }),
                  _buildPressableIconCard(Icons.favorite, 'Fav', Color.fromARGB(255, 95, 105, 101), () {
                    print('Fav icon pressed');
                  }),
                  _buildPressableIconCard(Icons.person, 'Profile', Color.fromARGB(255, 95, 105, 101), () {
                    print('Profile icon pressed');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(email: widget.email),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Add spacing here
            SizedBox(height: 100),

            Container(
              
              color: Color.fromARGB(255, 110, 113, 112),
              height: 300.0, // Adjust the height as needed
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Product List',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: _buildProductWidgets(), // Display product widgets here
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPressableIconCard(IconData icon, String title, Color color, VoidCallback onPressed) {
    return Expanded(
      child: InkResponse(
        onTap: onPressed,
        child: Card(
          elevation: 5.0,
          color: color,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductWidgets() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
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

        var products = snapshot.data!.docs;
        List<Widget> productWidgets = [];

        for (var product in products) {
          var data = product.data() as Map<String, dynamic>;

          var imageUrl = data['imageUrl'];
          var productName = data['productName'] ?? '';

          productWidgets.add(
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              
              width: 300, // Adjust the width as needed
              margin: EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  imageUrl != null
                      ? Image.network(
                          imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          color: const Color.fromARGB(255, 255, 255, 255),
                          child: Icon(Icons.shopping_cart),
                        ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product: $productName',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      // Add more details if needed
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: productWidgets,
          ),
        );
      },
    );
  }
}
