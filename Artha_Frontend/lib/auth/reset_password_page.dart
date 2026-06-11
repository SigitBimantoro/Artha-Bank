import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'auth_page.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email; 
  final String otpCode;

  const ResetPasswordPage({
    super.key,
    required this.email,
    required this.otpCode,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  static const Color primaryColor = Color(0xFF4D55CC);

  Future<void> _submitReset() async {
    if (_newPasswordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      _showError("Kolom kata sandi tidak boleh kosong.");
      return;
    }
    
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showError("Konfirmasi kata sandi tidak cocok.");
      return;
    }

    setState(() => _isLoading = true);
    
    final res = await ApiService.resetPassword(
      email: widget.email, 
      otp: widget.otpCode,
      newPassword: _newPasswordController.text,
    );
    
    setState(() => _isLoading = false);

    if (res['success']) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['data']['message'] ?? "Sandi berhasil diubah!"), backgroundColor: Colors.green),
      );
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthPage(isLoginInitial: true)),
        (route) => false,
      );
    } else {
      _showError(res['message']);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  Widget _buildPasswordField(String label, String hint, TextEditingController controller, bool obscure, VoidCallback onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(fontSize: 14, fontFamily: 'Poppins', color: primaryColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: primaryColor.withValues(alpha: 0.5), fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: primaryColor),
              onPressed: onToggle,
            ),
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                        decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                  const Text(
                    "Atur Ulang Sandi",
                    style: TextStyle(color: primaryColor, fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Poppins'),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // DESKRIPSI
              const Text(
                "Masukkan Kata sandi baru Anda di bawah ini.",
                textAlign: TextAlign.center,
                style: TextStyle(color: primaryColor, fontSize: 13, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 40),

              // INPUT FIELDS
              _buildPasswordField("Kata sandi baru", "Masukkan kata sandi baru", _newPasswordController, _obscureNew, () => setState(() => _obscureNew = !_obscureNew)),
              const SizedBox(height: 20),
              _buildPasswordField("Konfirmasi kata sandi baru", "Ulangi kata sandi baru", _confirmPasswordController, _obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm)),
              const SizedBox(height: 40),

              // TOMBOL KONFIRMASI
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : const Text("Konfirmasi Sandi", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}