import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'forgot_password_otp_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  static const Color primaryColor = Color(0xFF4D55CC);

  Future<void> _sendOtp() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Masukkan email Anda"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final res = await ApiService.requestForgotPassword(
      email: _emailController.text.trim(),
    );    
    
    setState(() => _isLoading = false);

    if (res['success']) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ForgotPasswordOtpPage(email: _emailController.text.trim()),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message']), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: primaryColor, 
                          shape: BoxShape.circle
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                  const Text(
                    "Lupa kata sandi",
                    style: TextStyle(
                      color: primaryColor, 
                      fontSize: 22, 
                      fontWeight: FontWeight.w800, 
                      fontFamily: 'Poppins'
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              
              // DESKRIPSI
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      color: primaryColor, 
                      fontSize: 13, 
                      fontFamily: 'Poppins', 
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      TextSpan(text: "Masukkan "),
                      TextSpan(text: "email terdaftar", style: TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(text: " Anda di bawah ini.\nKami akan mengirimkan kode verifikasi untuk\nmengatur ulang kata sandi."),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // INPUT EMAIL
              const Text(
                "Email",
                style: TextStyle(
                  color: primaryColor, 
                  fontSize: 13, 
                  fontWeight: FontWeight.w700, 
                  fontFamily: 'Poppins'
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 14, fontFamily: 'Poppins', color: primaryColor),
                decoration: InputDecoration(
                  hintText: "Masukkan Email terdaftar",
                  hintStyle: TextStyle(color: primaryColor.withValues(alpha: 0.5), fontSize: 13),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: primaryColor, width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // TOMBOL KIRIM KODE
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Kirim Kode", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}