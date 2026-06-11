import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final nameController =
  TextEditingController();

  final emailController =
  TextEditingController();

  final phoneController =
  TextEditingController();

  final passwordController =
  TextEditingController();

  bool isLoading = false;

  Future<void> register() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
              "Vui lòng nhập đầy đủ thông tin"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    String? result =
    await AuthService().register(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      password:
      passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (result == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const HomeScreen(),
        ),
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(result),
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đăng ký"),
      ),
      body: SingleChildScrollView(
        padding:
        const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 30),

            TextField(
              controller:
              nameController,
              decoration:
              const InputDecoration(
                labelText:
                "Họ và tên",
                border:
                OutlineInputBorder(),
                prefixIcon:
                Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
              emailController,
              keyboardType:
              TextInputType.emailAddress,
              decoration:
              const InputDecoration(
                labelText:
                "Email",
                border:
                OutlineInputBorder(),
                prefixIcon:
                Icon(Icons.email),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
              phoneController,
              keyboardType:
              TextInputType.phone,
              decoration:
              const InputDecoration(
                labelText:
                "Số điện thoại",
                border:
                OutlineInputBorder(),
                prefixIcon:
                Icon(Icons.phone),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
              passwordController,
              obscureText: true,
              decoration:
              const InputDecoration(
                labelText:
                "Mật khẩu",
                border:
                OutlineInputBorder(),
                prefixIcon:
                Icon(Icons.lock),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width:
              double.infinity,
              height: 50,
              child:
              ElevatedButton(
                onPressed:
                isLoading
                    ? null
                    : register,
                child:
                isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                  "Đăng ký",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}