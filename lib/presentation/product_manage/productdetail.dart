import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../datasource/model/ProductModel.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product; // Nhận ProductModel làm tham số

  const ProductDetailScreen({super.key, required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool isExpanded = false;


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: _buildAppBar(screenWidth),
      body: Container(
          constraints: BoxConstraints.expand(),
          color: Color(0xFFF7F7F9),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.05),
                _buildTitle(screenWidth),
                _buildCategory(screenWidth),
                _buildPrice(screenWidth),
                _buildImage(screenWidth, screenHeight),
                _buildDescription(screenWidth),
                _buildReadMoreButton(screenWidth),
              ],
            ),
          ),
        ),
    );
  }

  // 🔹 AppBar Widget
  AppBar _buildAppBar(double screenWidth) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        "Sneaker Shop",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
      ],
    );
  }

  // 🔹 Tiêu đề sản phẩm
  Widget _buildTitle(double screenWidth) {
    return Container(
      width: screenWidth * 0.8,
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        widget.product.name,
        style: TextStyle(
          fontSize: screenWidth * 0.06,
          fontWeight: FontWeight.bold,
          fontFamily: GoogleFonts.raleway().fontFamily,
        ),
      ),
    );
  }

  // 🔹 Danh mục sản phẩm
  Widget _buildCategory(double screenWidth) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.activity,
            style: TextStyle(
              color: Colors.grey,
              fontSize: screenWidth * 0.04,
              fontFamily: GoogleFonts.raleway().fontFamily,
            ),
          ),
          Text(
            "Status : ${widget.product.status}% new",
            style: TextStyle(
              color: Colors.grey,
              fontSize: screenWidth * 0.04,
              fontFamily: GoogleFonts.raleway().fontFamily,
            ),
          ), Text(
            "Size : ${widget.product.size}",
            style: TextStyle(
              color: Colors.grey,
              fontSize: screenWidth * 0.04,
              fontFamily: GoogleFonts.raleway().fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Giá sản phẩm
  Widget _buildPrice(double screenWidth) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child:  Text(
        "\$${widget.product.price.toStringAsFixed(2)}",
        style: TextStyle(
          fontSize: screenWidth * 0.05,
          fontWeight: FontWeight.bold,
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
      ),
    );
  }

  // 🔹 Hình ảnh sản phẩm
  Widget _buildImage(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Image.network(
          widget.product.imageUrl,
          width: screenWidth * 0.7,
          height: screenHeight * 0.25,
          fit: BoxFit.fitWidth,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.image_not_supported,
            size: screenWidth * 0.5,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  // 🔹 Mô tả sản phẩm
  Widget _buildDescription(double screenWidth) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        isExpanded ? widget.product.description : widget.product.description.substring(0, 100) + "...",
        style: TextStyle(
          fontSize: screenWidth * 0.035,
          color: Colors.black87,
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
      ),
    );
  }

  // 🔹 Nút "Read More"
  Widget _buildReadMoreButton(double screenWidth) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          setState(() {
            isExpanded = !isExpanded;
          });
        },
        child: Text(
          isExpanded ? "Read Less" : "Read More",
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.035,
          ),
        ),
      ),
    );
  }





}
