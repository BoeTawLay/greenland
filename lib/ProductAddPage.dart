import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProductAddPage(),
    );
  }
}

class ProductAddPage extends StatefulWidget {
  @override
  _ProductAddPageState createState() => _ProductAddPageState();
}

class _ProductAddPageState extends State<ProductAddPage> {
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productIdController = TextEditingController();
  final TextEditingController purchasePriceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController itemTypeController = TextEditingController();
  final TextEditingController itemDescriptionController = TextEditingController();
  TextEditingController _salesPriceController = TextEditingController();
  File? _image;

  double _calculateSalesPrice(double purchasePrice) {
    return purchasePrice * 1.4;
  }

  Future<void> _addProduct() async {
    try {
      if (!validateInputs()) {
        return;
      }

      String imageUrl = '';

      if (_image != null) {
        String imagePath = 'product_images/${DateTime.now().millisecondsSinceEpoch}.png';
        UploadTask uploadTask = FirebaseStorage.instance.ref().child(imagePath).putFile(_image!);

        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
        imageUrl = await taskSnapshot.ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('products').add({
        'productName': productNameController.text,
        'productId': productIdController.text,
        'purchasePrice': double.parse(purchasePriceController.text),
        'salesPrice': double.parse(_salesPriceController.text),
        'quantity': int.parse(quantityController.text),
        'itemType': itemTypeController.text,
        'itemDescription': itemDescriptionController.text,
        'imageUrl': imageUrl,
      });

      clearFields();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product added successfully'),
          backgroundColor: Color.fromARGB(255, 0, 255, 0),
        ),
      );
    } catch (e) {
      print('Error adding product: $e');
      String errorMessage = 'Failed to add product. Please try again.';
      if (e is FirebaseException) {
        errorMessage = e.message ?? 'Failed to add product. Please try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool validateInputs() {
    if (productNameController.text.isEmpty ||
        productIdController.text.isEmpty ||
        purchasePriceController.text.isEmpty ||
        quantityController.text.isEmpty ||
        itemTypeController.text.isEmpty ||
        itemDescriptionController.text.isEmpty ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All fields are required. Please fill them.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  void clearFields() {
    productNameController.clear();
    productIdController.clear();
    purchasePriceController.clear();
    quantityController.clear();
    itemTypeController.clear();
    itemDescriptionController.clear();
    _salesPriceController.clear();
    _image = null;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Color.fromARGB(255, 255, 255, 255),
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: _image != null
                      ? Image.file(
                          _image!,
                          width: 30,
                          height: 30,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.add_a_photo, size: 30, color: Colors.white),
                  onPressed: _pickImage,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: productNameController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: productIdController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Product ID',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: purchasePriceController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Purchase Price',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _salesPriceController.text = _calculateSalesPrice(double.parse(value)).toString();
                  });
                },
              ),
              SizedBox(height: 16),
              TextField(
                enabled: false,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Sales Price',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                controller: _salesPriceController,
              ),
              SizedBox(height: 16),
              TextField(
                controller: quantityController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextField(
                controller: itemTypeController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Item Type',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: itemDescriptionController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Item Description',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addProduct,
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 250, 151, 2),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Add Product',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
