import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'user_model.dart';

final _emailController = TextEditingController();
final _passwordController = TextEditingController();

class LoginPage extends StatefulWidget {
  final void Function(BuildContext) onLoginSuccess;
  final void Function(bool) onLoginProcess;

  const LoginPage({
    super.key,
    required this.onLoginSuccess,
    required this.onLoginProcess,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
              Image.network(
                'https://ibb.co/9NTTwtt', // Ganti dengan URL gambar logo kamu
                height: 100,
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  String email = _emailController.text;
                  String password = _passwordController.text;
                  if (email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Email dan password harus diisi.')),
                    );
                    return;
                  }
                  widget.onLoginProcess(true);
                  bool isAdminUser =
                      await DatabaseHelper.instance.isAdmin(email);
                  if (isAdminUser) {
                    debugPrint('Login berhasil sebagai admin!');
                    widget.onLoginSuccess(context);
                  } else {
                    User? user =
                        await DatabaseHelper.instance.getUserByEmail(email);
                    if (user != null && user.password == password) {
                      debugPrint('Login berhasil sebagai pengguna!');
                      widget.onLoginSuccess(context);
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Login Gagal'),
                          content: const Text('Email atau password salah.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                  widget.onLoginProcess(false);
                },
                child:
                    const Text('Login', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
