import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProductPage(),
    );
  }
}

class ProductPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Page'),
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
      body: ProductList(),
      backgroundColor: Color.fromARGB(255, 207, 211, 207),
    );
  }
}

class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() {});
            },
            decoration: InputDecoration(
              labelText: 'Search by Product Name',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
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

                var productName = data['productName'] ?? '';
                if (!productName.toLowerCase().contains(searchController.text.toLowerCase())) {
                  continue;
                }

                var productId = data['productId'] ?? '';
                var purchasePrice = data['purchasePrice'] ?? 0.0;
                var salesPrice = data['salesPrice'] ?? 0.0;
                var quantity = data['quantity'] ?? 0;
                var itemType = data['itemType'] ?? '';
                var itemDescription = data['itemDescription'] ?? '';
                var imageUrl = data['imageUrl'];

                productWidgets.add(
                  Card(
                    elevation: 5.0,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(
                        'Product: $productName',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID: $productId'),
                          Text('Purchase Price: \$${purchasePrice.toStringAsFixed(2)}'),
                          Text('Sales Price: \$${salesPrice.toStringAsFixed(2)}'),
                          Text('Quantity: $quantity'),
                          Text('Type: $itemType'),
                          Text('Description: $itemDescription'),
                        ],
                      ),
                      leading: imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4.0),
                              child: Image.network(
                                imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[300],
                              child: Icon(Icons.shopping_cart),
                            ),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              child: Wrap(
                                children: <Widget>[
                                  ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text('Edit Product'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditProductScreen(product: product),
                                        ),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.delete),
                                    title: Text('Delete Product'),
                                    onTap: () {
                                      FirebaseFirestore.instance.collection('products').doc(product.id).delete();
                                      Navigator.pop(context);
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
                );
              }

              return ListView(
                children: productWidgets,
              );
            },
          ),
        ),
      ],
    );
  }
}

class EditProductScreen extends StatefulWidget {
  final QueryDocumentSnapshot product;

  EditProductScreen({required this.product});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController productNameController;
  late TextEditingController productIdController;
  late TextEditingController purchasePriceController;
  late TextEditingController salePriceController;
  late TextEditingController quantityController;
  late TextEditingController itemTypeController;
  late TextEditingController itemDescriptionController;

  @override
  void initState() {
    super.initState();

    var data = widget.product.data() as Map<String, dynamic>;
    productNameController = TextEditingController(text: data['productName']);
    productIdController = TextEditingController(text: data['productId']);
    purchasePriceController = TextEditingController(text: data['purchasePrice'].toString());
    salePriceController = TextEditingController(text: data['salesPrice'].toString());
    quantityController = TextEditingController(text: data['quantity'].toString());
    itemTypeController = TextEditingController(text: data['itemType']);
    itemDescriptionController = TextEditingController(text: data['itemDescription']);

    purchasePriceController.addListener(() {
      updateSalePrice();
    });
  }

  @override
  void dispose() {
    productNameController.dispose();
    productIdController.dispose();
    purchasePriceController.dispose();
    salePriceController.dispose();
    quantityController.dispose();
    itemTypeController.dispose();
    itemDescriptionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: productNameController,
                  decoration: InputDecoration(labelText: 'Product Name'),
                ),
                TextFormField(
                  controller: productIdController,
                  decoration: InputDecoration(labelText: 'Product ID'),
                ),
                TextFormField(
                  controller: purchasePriceController,
                  decoration: InputDecoration(labelText: 'Purchase Price'),
                ),
                TextFormField(
                  controller: salePriceController,
                  decoration: InputDecoration(labelText: 'Sale Price'),
                  readOnly: true,
                ),
                TextFormField(
                  controller: quantityController,
                  decoration: InputDecoration(labelText: 'Quantity'),
                ),
                TextFormField(
                  controller: itemTypeController,
                  decoration: InputDecoration(labelText: 'Item Type'),
                ),
                TextFormField(
                  controller: itemDescriptionController,
                  decoration: InputDecoration(labelText: 'Item Description'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    updateProduct();
                  },
                  child: Text('Update'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void updateProduct() {
    FirebaseFirestore.instance.collection('products').doc(widget.product.id).update({
      'productName': productNameController.text,
      'productId': productIdController.text,
      'purchasePrice': double.parse(purchasePriceController.text),
      'salesPrice': double.parse(salePriceController.text),
      'quantity': int.parse(quantityController.text),
      'itemType': itemTypeController.text,
      'itemDescription': itemDescriptionController.text,
    });

    Navigator.pop(context);
  }

  void updateSalePrice() {
    double purchasePrice = double.parse(purchasePriceController.text);
    double profitMargin = 0.40; // 40% profit margin
    double salePrice = purchasePrice * (1 + profitMargin);

    salePriceController.text = salePrice.toStringAsFixed(2);
  }
}
