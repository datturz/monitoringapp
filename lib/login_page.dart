import 'package:flutter/material.dart';

import 'database_helper.dart';

final _emailController = TextEditingController();
final _passwordController = TextEditingController();

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0F7FA),
              Color(0xFF2962FF)
            ], // Warna gradien biru
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.network(
                'https://ibb.co.com/9NTTwtt', // Ganti dengan URL gambar logo kamu
                height: 100,
              ),
              // Kita akan menambahkan widget lain di bawah ini
              // Field Input Email
              const SizedBox(
                  height: 30), // Menambahkan jarak antara logo dan field input
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0), // Menambahkan margin horizontal
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // Field Input Password
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0), // Menambahkan margin horizontal
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                  height:
                      25), // Menambahkan jarak antara field input password dan tombol login
              // Tombol Login
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.blue, // Mengatur warna latar belakang tombol
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15), // Mengatur padding tombol
                  textStyle: const TextStyle(
                      fontSize: 18), // Mengatur ukuran teks tombol
                  shape: RoundedRectangleBorder(
                    // Membuat tombol membulat
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  final contextToUse = context;
                  // Tambahkan logika login di sini nanti
                  String email = _emailController
                      .text; // Mendapatkan teks dari field input email
                  String password = _passwordController
                      .text; // Mendapatkan teks dari field input password
                  // Validasi input (opsional, tetapi disarankan)
                  if (email.isEmpty || password.isEmpty) {
                    // Tampilkan pesan kesalahan atau snackbar
                    return;
                  }

                  // Periksa apakah pengguna adalah admin
                  bool isAdminUser =
                      await DatabaseHelper.instance.isAdmin(email);
                  if (isAdminUser) {
                    // Navigasi ke halaman admin (misalnya, halaman User List)
                    debugPrint('Login berhasil sebagai admin!');
                    // Tambahkan kode navigasi di sini

                    // Periksa apakah widget masih terpasang
                    Navigator.push(
                      // ignore: use_build_context_synchronously
                      context,
                      MaterialPageRoute(builder: (context) => const UserList()),
                    );
                  } else {
                    // Periksa apakah pengguna ada di database
                  }
                },
                child: const Text('Login',
                    style: TextStyle(
                        color: Colors
                            .white)), // Mengatur teks tombol dengan warna putih
              ),
            ],
          ),
        ),
      ),
    );
  }
}
