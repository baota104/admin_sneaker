import 'package:adminsneaker/presentation/product_manage/productdetail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../datasource/model/ProductModel.dart';
import 'ProductProvider.dart';

class ProductManagementScreen extends StatefulWidget {
  @override
  _ProductManagementScreenState createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  late List<ProductModel> products;
  late List<ProductModel> filteredProducts;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    products = [];
    filteredProducts = [];
    searchController.addListener(_filterProducts);
    Future.delayed(Duration.zero, () {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterProducts() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredProducts = products.where((product) {
        return product.name.toLowerCase().contains(query) ||
            product.brand.toLowerCase().contains(query) ||
            product.activity.toLowerCase().contains(query) ||
            product.price.toString().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
        title: Text("Manage Product"),
    bottom: PreferredSize(
    preferredSize: Size.fromHeight(60),
    child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextField(
    controller: searchController,
    decoration: InputDecoration(
    hintText: 'Search for product...',
    prefixIcon: Icon(Icons.search),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    ),
    filled: true,
    fillColor: Colors.white,
    ),
    ),
    ),
    ),
    ),
    body: Consumer<ProductProvider>(
    builder: (context, productProvider, child) {
    print(" UI nhận số sản phẩm: ${productProvider.products.length}");
    products = productProvider.products;

    // Nếu không có từ khóa tìm kiếm, hiển thị tất cả sản phẩm
    if (searchController.text.isEmpty) {
    filteredProducts = List.from(products);
    }

    if (filteredProducts.isEmpty) {
    return Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Icon(Icons.search_off, size: 50, color: Colors.grey),
    SizedBox(height: 10),
    Text(
    searchController.text.isEmpty
    ? "Don't have any product available!"
        : "Can't find relevent product",
    style: TextStyle(fontSize: 16),
    ),
    ],
    ),
    );
    }

    return _buildCartItemList(screenWidth, screenHeight, productProvider);
    },
    ),
    floatingActionButton: FloatingActionButton(
    child: Icon(Icons.add),
    onPressed: () => _addProduct(context, Provider.of<ProductProvider>(context, listen: false)),
    ));
  }

  Widget _buildCartItemList(double screenWidth, double screenHeight, ProductProvider productprovider) {
    return ListView.builder(
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        return _buildCartItem(filteredProducts[index], index, screenWidth, screenHeight, productprovider);
      },
    );
  }

  Widget _buildCartItem(ProductModel item, int index, double screenWidth, double screenHeight, ProductProvider productprovider) {
    return Slidable(
      key: ValueKey(item.name),
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.20,
        children: [
          GestureDetector(
            onTap: () {
              _editProduct(context, productprovider, item);
            },
            child: Container(
              child: Center(
                child: Text(
                  "EDIT",
                  style: TextStyle(
                      color: Colors.white
                  ),
                ),
              ),
              width: screenWidth * 0.15,
              height: screenHeight * 0.17,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.20,
        children: [
          Container(
            width: screenWidth * 0.15,
            height: screenHeight * 0.12,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.white, size: screenWidth * 0.07),
              onPressed: () {
                productprovider.deleteProduct(item.productId);
              },
            ),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: item)));
        },
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenHeight * 0.015),
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: screenWidth * 0.18,
                    height: screenWidth * 0.18,
                    decoration: BoxDecoration(
                      color: Color(0xFFF7F7F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.image, size: screenWidth * 0.1, color: Colors.grey
                      ),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.raleway().fontFamily,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        "\$${item.price.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Colors.grey,
                          fontFamily: GoogleFonts.poppins().fontFamily,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editProduct(BuildContext context, ProductProvider productProvider, ProductModel product) {
    final _nameController = TextEditingController(text: product.name);
    final _priceController = TextEditingController(text: product.price.toString());
    final _discountpriceController = TextEditingController(text: product.discountPrice.toString());
    final _brandController = TextEditingController(text: product.brand);
    final _stockController = TextEditingController(text: product.stock.toString());
    final _sizeController = TextEditingController(text: product.size.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit product"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: "Product name"),
                ),
                TextField(
                  controller: _brandController,
                  decoration: InputDecoration(labelText: "Brand"),
                ),
                TextField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: "Price"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _discountpriceController,
                  decoration: InputDecoration(labelText: "Discount"),
                ),
                TextField(
                  controller: _stockController,
                  decoration: InputDecoration(labelText: "Stock"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _sizeController,
                  decoration: InputDecoration(labelText: "Size"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Save"),
              onPressed: () {
                final updatedProduct = ProductModel(
                  productId: product.productId,
                  name: _nameController.text,
                  brand: _brandController.text,
                  price: double.tryParse(_priceController.text) ?? 0,
                  discountPrice: double.tryParse(_discountpriceController.text) ?? 0,
                  stock: int.tryParse(_stockController.text) ?? 0,
                  activity: product.activity,
                  description: product.description,
                  status: product.status,
                  imageUrl: product.imageUrl,
                  isloved: product.isloved,
                  size: int.tryParse(_sizeController.text) ?? 0,
                );

                productProvider.updateProduct(updatedProduct);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _addProduct(BuildContext context, ProductProvider productProvider) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _priceController = TextEditingController();
    final _brandController = TextEditingController();
    final _discountController = TextEditingController();
    final _stockController = TextEditingController();
    final _sizeController = TextEditingController();
    final _statusController = TextEditingController();
    final _imageUrlController = TextEditingController();
    final _descriptionController = TextEditingController();

    String _selectedActivity = 'basketball';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Product"),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: "Product name"),
                    validator: (value) =>
                    value == null || value.isEmpty ? "Mustn't leave empty" : null,
                  ),
                  TextFormField(
                    controller: _brandController,
                    decoration: InputDecoration(labelText: "Brand"),
                    validator: (value) =>
                    value == null || value.isEmpty ? "Mustn't leave empty" : null,
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(labelText: "Giá"),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Mustn't leave empty";
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) return "Price must be greater than 0";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _discountController,
                    decoration: InputDecoration(labelText: "DiscountPrice (optional)"),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return null;
                      final discount = double.tryParse(value);
                      final price = double.tryParse(_priceController.text);
                      if (discount == null || discount < 0) return "DiscountPrice must be greater than 0";
                      if (price != null && discount > price) return "DiscountPrice must be greater than Price";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _stockController,
                    decoration: InputDecoration(labelText: "Stock"),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Mustn't leave empty";
                      final stock = int.tryParse(value);
                      if (stock == null || stock <= 0) return "stock must be > 0";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _sizeController,
                    decoration: InputDecoration(labelText: "Size"),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Mustn't leave empty";
                      final size = int.tryParse(value);
                      if (size == null || size <= 0) return "Size must be > 0";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _statusController,
                    decoration: InputDecoration(labelText: "new status (%)"),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Mustn't leave empty";
                      final status = int.tryParse(value);
                      if (status == null || status < 0 || status > 100) {
                        return "status must be from 0% to 100%";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: "description"),
                    maxLines: 3,
                    validator: (value) =>
                    value == null || value.isEmpty ? "Mustn't leave empty" : null,
                  ),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: InputDecoration(labelText: "URL Product"),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Mustn't leave empty";
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedActivity,
                    decoration: InputDecoration(labelText: "activity"),
                    items: ['basketball', 'volleyball', 'running', 'daily', 'football']
                        .map((activity) => DropdownMenuItem(
                      value: activity,
                      child: Text(activity.toUpperCase()),
                    ))
                        .toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        _selectedActivity = newValue;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Add"),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final newProduct = ProductModel(
                    productId: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _nameController.text,
                    brand: _brandController.text,
                    price: double.parse(_priceController.text),
                    discountPrice: double.tryParse(_discountController.text) ?? 0,
                    stock: int.parse(_stockController.text),
                    activity: _selectedActivity,
                    description: _descriptionController.text,
                    status: int.parse(_statusController.text),
                    imageUrl: _imageUrlController.text,
                    isloved: false,
                    size: int.parse(_sizeController.text),
                  );
                  productProvider.addProduct(newProduct);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }
}