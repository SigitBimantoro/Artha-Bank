import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'auth_page.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email; // Pastikan menggunakan email
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
    
    // 🟢 PERBAIKAN: Gunakan parameter 'email' sesuai backend
    final res = await ApiService.resetPassword(
      email: widget.email, 
      otp: widget.otpCode,
      newPassword: _newPasswordController.text,
    );
    
    setState(() => _isLoading = false);

    if (res['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['data']['message'] ?? "Sandi berhasil diubah!"), backgroundColor: Colors.green),
      );
      if (!mounted) return;
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  Widget _buildPasswordField(String label, String hint, TextEditingController controller, bool obscure, VoidCallback onToggle) {
    const Color primaryColor = Color(0xFF4D55CC);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(fontSize: 14, fontFamily: 'Poppins'),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: primaryColor.withOpacity(0.5), fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: primaryColor.withOpacity(0.7)),
              onPressed: onToggle,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(color: primaryColor, width: 1.5),
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
    const Color primaryColor = Color(0xFF4D55CC);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Text("Atur Ulang Sandi", style: TextStyle(color: primaryColor, fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Poppins')),
                  ],
                ),
                const SizedBox(height: 40),
                _buildPasswordField("Kata sandi baru", "Masukkan kata sandi baru", _newPasswordController, _obscureNew, () => setState(() => _obscureNew = !_obscureNew)),
                const SizedBox(height: 20),
                _buildPasswordField("Konfirmasi kata sandi baru", "Ulangi kata sandi baru", _confirmPasswordController, _obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm)),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitReset,
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Konfirmasi Sandi", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}