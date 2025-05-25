import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


import '../../domains/datasource/model/UserModel.dart';
import '../../domains/Controller/customer_provider.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerProvider>(context, listen: false).fetchCustomers();
    });
    _searchController.addListener(_filterCustomers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    final provider = Provider.of<CustomerProvider>(context, listen: false);

    setState(() {
      _filteredCustomers = provider.customers.where((user) {
        return user.name.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query) ||
            user.phone.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("User Management"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
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
      body: Consumer<CustomerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.customers.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          final customersToDisplay =
          _searchController.text.isEmpty ? provider.customers : _filteredCustomers;

          if (customersToDisplay.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_alt_outlined, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    _searchController.text.isEmpty
                        ? "No users found!"
                        : "No matching users found",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: customersToDisplay.length,
            itemBuilder: (context, index) {
              final user = customersToDisplay[index];
              return _buildCustomerItem(user, screenWidth, screenHeight, context);
            },
          );
        },
      ),
    );
  }

  Widget _buildCustomerItem(UserModel user, double screenWidth, double screenHeight, BuildContext context) {
    return Slidable(
      key: ValueKey(user.userId),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: [
          Container(
            width: screenWidth * 0.2,
            height: screenHeight * 0.12,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.white),
              onPressed: () => _confirmDeleteUser(context, user.userId),
            ),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user.imageUrl),
            radius: 25,
          ),
          title: Text(
            user.name,
            style: GoogleFonts.raleway(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.email),
              Text(user.phone),
              Text(
                'Registered: ${DateFormat('dd/MM/yyyy').format(user.createdAt)}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          trailing: Switch(
            value: !user.isDisabled,
            onChanged: (value) {
              print("Toggling status for user: ${user.userId}");
              Provider.of<CustomerProvider>(context, listen: false)
                  .toggleUserStatus(user.userId, !value);
            },
            activeColor: Colors.green,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteUser(BuildContext context, String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Deletion"),
        content: Text("Are you sure you want to delete this user?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await Provider.of<CustomerProvider>(context, listen: false)
          .deleteUser(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User deleted successfully")),
      );
    }
  }
}