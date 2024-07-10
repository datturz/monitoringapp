import 'package:flutter/material.dart';
import 'package:myapp/login_page.dart';
void main() {
  runApp(const MyApp());
}
// Suggested code may be subject to a license. Learn more: ~LicenseLog:841275603.

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pemantau Pesanan',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(), // Ganti dengan nama widget halaman login kamu
    );
  }
}
