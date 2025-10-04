import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_api_practice/screens/login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      title: 'Flutter API Demo',
      home: const LoginScreen(),
    );
  }
}
