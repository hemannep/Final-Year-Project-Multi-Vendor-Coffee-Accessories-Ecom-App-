import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/controllers/getDataController.dart';
import 'package:http/http.dart' as http;
import 'package:silverskin/models/users.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final GetDataController dataController = Get.find<GetDataController>();
  List<User> _users = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("http://$ipAddress/silverskin-api/admin/getUsers.php"),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _users = (data['users'] as List)
                .map((user) => User.fromJson(user))
                .toList();
          });
        }
      }
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        message: "Error fetching users: ${e.toString()}",
        duration: const Duration(seconds: 2),
        backgroundColor: accentColor,
      ));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteUser(String userId) async {
    try {
      final response = await http.post(
        Uri.parse("http://$ipAddress/silverskin-api/admin/deleteUser.php"),
        body: json.encode({'user_id': userId}),
        headers: {'Content-Type': 'application/json'},
      );
      
      final data = json.decode(response.body);
      if (data['success']) {
        Get.showSnackbar(const GetSnackBar(
          message: "User deleted successfully",
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ));
        _fetchUsers(); // Refresh the list
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        message: "Error deleting user: ${e.toString()}",
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _showDeleteConfirmation(User user) {
    Get.defaultDialog(
      title: "Delete User",
      middleText: "Are you sure you want to delete ${user.name}? This action cannot be undone.",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: textColor,
      onConfirm: () {
        Get.back();
        _deleteUser(user.user_id!);
      },
      onCancel: () => Get.back(),
    );
  }

  void _showUserDetails(User user) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: secondaryColor,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white54,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  user.name ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  user.role?.toUpperCase() ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    color: user.role == 'admin' 
                      ? Colors.blue 
                      : user.role == 'vendor' 
                        ? Colors.green 
                        : textSecondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildDetailRow(Icons.email, "Email", user.email ?? 'Not provided'),
              _buildDetailRow(Icons.phone, "Phone", user.phone ?? 'Not provided'),
              const SizedBox(height: 20),
              
              Center(
                child: TextButton(
                  onPressed: () => _showDeleteConfirmation(user),
                  child: const Text(
                    "Delete User",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: textSecondaryColor),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: textSecondaryColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<User> get _filteredUsers {
    if (_searchController.text.isEmpty) {
      return _users;
    }
    return _users.where((user) =>
      user.name?.toLowerCase().contains(_searchController.text.toLowerCase()) == true ||
      user.email?.toLowerCase().contains(_searchController.text.toLowerCase()) == true ||
      user.phone?.toLowerCase().contains(_searchController.text.toLowerCase()) == true
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Users',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: secondaryColor,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: accentColor),
            onPressed: _fetchUsers,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: gradientBackground,
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: accentColor))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search users...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: borderColor),
                        ),
                        filled: true,
                        fillColor: boxColor,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      color: accentColor,
                      onRefresh: _fetchUsers,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return _buildUserCard(user);
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildUserCard(User user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: boxColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: borderColor, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showUserDetails(user),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: secondaryColor,
                child: Icon(
                  Icons.person,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email ?? 'No email',
                      style: const TextStyle(
                        fontSize: 14,
                        color: textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(
                  user.role?.toUpperCase() ?? 'USER',
                  style: TextStyle(
                    color: user.role == 'admin' 
                      ? Colors.blue 
                      : user.role == 'vendor' 
                        ? Colors.green 
                        : textColor,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: user.role == 'admin' 
                  ? Colors.blue.withOpacity(0.2)
                  : user.role == 'vendor' 
                    ? Colors.green.withOpacity(0.2)
                    : boxColor,
                side: BorderSide(
                  color: user.role == 'admin' 
                    ? Colors.blue 
                    : user.role == 'vendor' 
                      ? Colors.green 
                      : borderColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}