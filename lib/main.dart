import 'package:adminsneaker/presentation/comment_screen/CommentScreen.dart';
import 'package:adminsneaker/presentation/comment_screen/Comment_provider.dart';
import 'package:adminsneaker/presentation/customer_screen/customer_Screen.dart';
import 'package:adminsneaker/presentation/customer_screen/customer_provider.dart';
import 'package:adminsneaker/presentation/dashboard/DashboardScreen.dart';
import 'package:adminsneaker/presentation/dashboard/dashboard_provider.dart';
import 'package:adminsneaker/presentation/orderscreen/OrderManagementScreen.dart';
import 'package:adminsneaker/presentation/orderscreen/order_provider.dart';
import 'package:adminsneaker/presentation/product_manage/ProductManagementScreen.dart';
import 'package:adminsneaker/presentation/product_manage/ProductProvider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

  } catch (e) {
    print(" Lỗi Firebase: $e");
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        ChangeNotifierProvider(create: (context)=> OrderProvider() ),
        ChangeNotifierProvider(create: (context)=> DashboardProvider() ),
        ChangeNotifierProvider(create: (context)=> CustomerProvider() ),
        ChangeNotifierProvider(create: (context)=> CommentProvider() ),
      ],
      child: AdminApp(),
    ),
  );
}

class AdminApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Panel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AdminDashboard(),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Admin Panel', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('View Stastics'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag),
              title: Text('Manage Products'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProductManagementScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.receipt_long),
              title: Text('Manage Orders'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => OrderManagementScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Manage Customers'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.comment),
              title: Text('Manage Comments'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CommentScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.medical_information),
              title: Text('Admin Information'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CommentScreen()));
              },
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
       mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network("https://i.postimg.cc/3JC5JZd8/Picture1.png"),
          Container(
              child: Text("Welcome to admin dashboard",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40,
                color: Colors.black,
                fontFamily: GoogleFonts.raleway().fontFamily
              ),
            ),
          )
        ],
      ),
    );
  }
}


