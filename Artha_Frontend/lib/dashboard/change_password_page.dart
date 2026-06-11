import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _hideCurrent = true;
  bool _hideNew = true;
  bool _hideConfirm = true;

  static const Color primaryColor = Color(0xFF4D55CC);

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final current = _currentPasswordController.text.trim();
    final next = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      _showMessage('Semua kolom wajib diisi.', isError: true);
      return;
    }
    if (next.length < 6) {
      _showMessage('Kata sandi baru minimal 6 karakter.', isError: true);
      return;
    }
    if (next != confirm) {
      _showMessage('Konfirmasi kata sandi tidak cocok.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final res = await ApiService.changePassword(
      currentPassword: current,
      newPassword: next,
      confirmNewPassword: confirm,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      _showMessage(res['data']['message'] ?? 'Kata sandi berhasil diubah.');
      Navigator.pop(context);
    } else {
      _showMessage(
        res['message'] ?? 'Gagal mengubah kata sandi.',
        isError: true,
      );
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Widget _buildPasswordField(String label, String hint, TextEditingController controller, bool obscure, VoidCallback onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
        ),
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
                        decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                  const Text(
                    "Ubah Kata Sandi",
                    style: TextStyle(color: primaryColor, fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Poppins'),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // DESKRIPSI
              const Center(
                child: Text(
                  "Masukkan Kata sandi baru Anda di bawah ini.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: primaryColor, fontSize: 13, fontFamily: 'Poppins'),
                ),
              ),
              const SizedBox(height: 40),

              // INPUT FIELDS
              _buildPasswordField(
                "Kata sandi saat ini",
                "Masukkan kata sandi saat ini",
                _currentPasswordController,
                _hideCurrent,
                () => setState(() => _hideCurrent = !_hideCurrent),
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                "Kata sandi baru",
                "Masukkan kata sandi baru",
                _newPasswordController,
                _hideNew,
                () => setState(() => _hideNew = !_hideNew),
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                "Konfirmasi kata sandi baru",
                "Ulangi kata sandi baru",
                _confirmPasswordController,
                _hideConfirm,
                () => setState(() => _hideConfirm = !_hideConfirm),
              ),
              const SizedBox(height: 40),

              // TOMBOL SIMPAN
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
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