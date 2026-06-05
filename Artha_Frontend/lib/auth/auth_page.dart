import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dashboard/main_page.dart';
import 'otp_page.dart';
import '../services/api_service.dart';
import 'forgot_password_page.dart';
import 'create_pin_page.dart'; 


class AuthPage extends StatefulWidget {
  final bool isLoginInitial;
  const AuthPage({super.key, this.isLoginInitial = true});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late bool isLogin;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLogin = widget.isLoginInitial;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      isLogin = !isLogin;
      _obscurePassword = true;
      _obscureConfirmPassword = true;
    });
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _nameController.clear();
    _phoneController.clear();
  }

  Future<void> _submitData() async {
    FocusScope.of(context).unfocus();

    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _showError("Form tidak boleh kosong.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (isLogin) {
        // --- PROSES LOGIN ---
        final res = await ApiService.login(
          phoneNumber: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (res['success']) {
          final token = res['data']['token'];
          final hasPin = res['data']['has_pin'] ?? false; // Cek status PIN

          // Simpan Token JWT (kunci 'token' sesuai dengan ApiService.getToken())
          if (token != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', token.toString());
          }

          if (!mounted) return;

          // Percabangan Alur PIN
          if (!hasPin) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CreatePinPage()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainPage()),
            );
          }
        } else {
          _showError(res['message']);
        }
      } else {
        // --- PROSES REGISTER ---
        if (_passwordController.text != _confirmPasswordController.text) {
          _showError("Konfirmasi sandi tidak cocok!");
          return;
        }

        final res = await ApiService.register(
          nama: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          password: _passwordController.text,
        );

        if (res['success']) {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OtpPage(email: _emailController.text.trim()),
            ),
          );
        } else {
          _showError(res['message']);
        }
      }
    } catch (e) {
      _showError("Gagal terhubung ke server.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint, {
    TextEditingController? controller,
    bool isPassword = false,
    bool? obscureText,
    VoidCallback? onToggle,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: isPassword ? (obscureText ?? true) : false,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xA54D55CC), fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    iconSize: 20,
                    icon: Icon(
                      (obscureText ?? true)
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xA54D55CC),
                    ),
                    onPressed: onToggle,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4D55CC);
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOutCubic,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Image.asset(
                        'assets/BGSEC.jpg',
                        fit: BoxFit.cover,
                        opacity: const AlwaysStoppedAnimation(0.8),
                        errorBuilder: (context, error, stackTrace) =>
                            Container(),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 40, 24, 25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              child: Text(
                                isLogin ? 'Log In' : 'Sign Up',
                                key: ValueKey<bool>(isLogin),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              child: Text(
                                isLogin
                                    ? 'Selamat datang kembali! Mari lanjut pantau pengeluaranmu.'
                                    : 'Yuk, mulai perjalanan finansial yang lebih tenang. Daftar sekarang.',
                                key: ValueKey<bool>(isLogin),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  height: 1.4,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),
                            _buildTextField(
                              isLogin ? "Nomor telepon" : "Email",
                              isLogin
                                  ? "Masukkan nomor telepon"
                                  : "Masukkan email",
                              controller: _emailController,
                              keyboardType: isLogin
                                  ? TextInputType.phone
                                  : TextInputType.emailAddress,
                            ),
                            _buildTextField(
                              "Kata sandi",
                              "Masukkan kata sandi",
                              controller: _passwordController,
                              isPassword: true,
                              obscureText: _obscurePassword,
                              onToggle: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                            
                            // TOMBOL LUPA KATA SANDI
                            if (isLogin)
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ForgotPasswordPage(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Lupa kata sandi?",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ),
                            if (isLogin) const SizedBox(height: 15),

                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 800),
                              sizeCurve: Curves.easeInOutCubic,
                              crossFadeState: isLogin
                                  ? CrossFadeState.showFirst
                                  : CrossFadeState.showSecond,
                              firstChild: const SizedBox(
                                width: double.infinity,
                                height: 0,
                              ),
                              secondChild: Column(
                                children: [
                                  _buildTextField(
                                    "Konfirmasi kata sandi",
                                    "Ulangi kata sandi",
                                    controller: _confirmPasswordController,
                                    isPassword: true,
                                    obscureText: _obscureConfirmPassword,
                                    onToggle: () => setState(
                                      () => _obscureConfirmPassword =
                                          !_obscureConfirmPassword,
                                    ),
                                  ),
                                  _buildTextField(
                                    "Nama lengkap",
                                    "Masukkan nama lengkap",
                                    controller: _nameController,
                                  ),
                                  _buildTextField(
                                    "Nomor telepon",
                                    "Masukkan nomor telepon",
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              child: Text(
                                isLogin ? 'Log In' : 'Sign Up',
                                key: ValueKey<bool>(isLogin),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: _isLoading ? null : _toggleAuthMode,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Text.rich(
                        TextSpan(
                          text: isLogin
                              ? 'Belum punya akun? '
                              : 'Sudah punya akun? ',
                          style: const TextStyle(
                            color: primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            TextSpan(
                              text: isLogin ? 'Sign Up' : 'Log In',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        key: ValueKey<bool>(isLogin),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}