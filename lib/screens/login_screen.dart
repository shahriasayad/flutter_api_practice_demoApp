import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_api_practice/screens/userlist_screen.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool loading = false;

  Future<bool> login(String email, String password) async {
    const String apiKey = 'reqres-free-v1';
    final url = Uri.parse('https://reqres.in/api/login');
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'x-api-key': apiKey,
    };
    final Response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (Response.statusCode == 200) {
      final data = jsonDecode(Response.body);
      print('Token: ${data['token']}');
      return true;
    } else {
      print('Error: ${Response.body}');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsetsGeometry.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 13),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 13),

            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      setState(() => loading = true);
                      bool success = await login(
                        emailController.text,
                        passwordController.text,
                      );
                      setState(() => loading = false);

                      if (success) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UserListScreen(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Login Failed")),
                        );
                      }
                    },
                    child: const Text("Login"),
                  ),
          ],
        ),
      ),
    );
  }
}
