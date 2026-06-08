import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _hideCurrent = true;
  bool _hideNew = true;
  bool _hideConfirm = true;

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

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4D55CC);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Ubah Kata Sandi'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildPasswordField(
                label: 'Kata sandi saat ini',
                controller: _currentPasswordController,
                obscure: _hideCurrent,
                onToggle: () => setState(() => _hideCurrent = !_hideCurrent),
              ),
              const SizedBox(height: 18),
              _buildPasswordField(
                label: 'Kata sandi baru',
                controller: _newPasswordController,
                obscure: _hideNew,
                onToggle: () => setState(() => _hideNew = !_hideNew),
              ),
              const SizedBox(height: 18),
              _buildPasswordField(
                label: 'Konfirmasi kata sandi baru',
                controller: _confirmPasswordController,
                obscure: _hideConfirm,
                onToggle: () => setState(() => _hideConfirm = !_hideConfirm),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Simpan Kata Sandi',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
        ),
      ),
    );
  }
}
