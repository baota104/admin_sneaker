import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domains/datasource/model/ProductModel.dart';



class ProductDetailScreen extends StatefulWidget {
  final ProductModel product; // Nhận ProductModel làm tham số

  const ProductDetailScreen({super.key, required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool isExpanded = false;

  final PageController _pageController = PageController();
  int _currentPage = 0;
  final TransformationController _transformationController = TransformationController();

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.dispose();
    super.dispose();
  }
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
  Widget  _buildImage(double screenWidth, double screenHeight) {
    return  Column(
      children: [
        Container(
          height: screenHeight * 0.25,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.product.imageUrls.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Hiển thị ảnh zoom khi nhấn
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      insetPadding: EdgeInsets.all(20),
                      child: InteractiveViewer(
                        transformationController: _transformationController,
                        panEnabled: true,
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Image.network(
                          widget.product.imageUrls[index],
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.product.imageUrls[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.product.imageUrls.length,
                (index) => GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                width: 8,
                height: 8,
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? Colors.blue
                      : Colors.grey.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),
      ],
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
