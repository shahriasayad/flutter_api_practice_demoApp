import 'package:flutter/material.dart';
import 'package:flutter_api_practice/screens/image_upload_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  Future<List<dynamic>> fetchUsers() async {
    final url = Uri.parse('https://reqres.in/api/users?page=1');
    const String apiKey = 'reqres-free-v1';
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'x-api-key': apiKey,
    };
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']; // returning the list of users
    } else {
      throw Exception("Failed to fetch users");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Users"),
        centerTitle: true,
        actions: [
          // Go to image upload screen
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ImageUploadScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchUsers(), // Fetch API data
        builder: (context, snapshot) {
          // Checking the state of async operation
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(user['first_name']?.substring(0, 1) ?? "?"),
                ),
                title: Text("${user['first_name']} ${user['last_name']}"),
                subtitle: Text(user['email']?.toString() ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}
