import 'package:flutter/material.dart';

import '../dashboard/main_page.dart';
import '../services/api_service.dart';

class ConfirmPinPage extends StatefulWidget {
  final String newPin;

  const ConfirmPinPage({super.key, required this.newPin});

  @override
  State<ConfirmPinPage> createState() => _ConfirmPinPageState();
}

class _ConfirmPinPageState extends State<ConfirmPinPage> {
  static const Color primaryColor = Color(0xFF4D55CC);

  final TextEditingController _confirmPinController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _simpanPin() async {
    if (_confirmPinController.text != widget.newPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi PIN tidak cocok!'),
          backgroundColor: Colors.red,
        ),
      );
      _confirmPinController.clear();
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);
    final res = await ApiService.setPin(widget.newPin);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN Keamanan berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainPage(initialIndex: 0)),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Gagal menyimpan PIN'),
          backgroundColor: Colors.red,
        ),
      );
      _confirmPinController.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 64),
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
                      width: width * 0.78,
                      height: 330,
                      child: Image.asset(
                        'assets/BGSEC.jpg',
                        fit: BoxFit.cover,
                        opacity: const AlwaysStoppedAnimation(0.78),
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 88, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Konfirmasi PIN',
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 39,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              'Masukkan kembali 6 digit PIN yang baru saja Anda buat. Pastikan kombinasi angka yang dimasukkan sudah persis sama dengan sebelumnya.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                height: 1.42,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 66),
                            _buildPinBoxes(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 54),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: SizedBox(
                width: double.infinity,
                height: 53,
                child: ElevatedButton(
                  onPressed:
                      (_confirmPinController.text.length == 6 && !_isLoading)
                      ? _simpanPin
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    disabledBackgroundColor: primaryColor.withValues(
                      alpha: 0.45,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Simpan PIN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Poppins',
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinBoxes() {
    return SizedBox(
      height: 76,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              final char = _confirmPinController.text.length > index
                  ? _confirmPinController.text[index]
                  : '';

              return Container(
                width: 45,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: [
                    if (index >= 4)
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.24),
                        blurRadius: 0,
                        spreadRadius: 4,
                      ),
                  ],
                ),
                child: Center(
                  child: char.isEmpty
                      ? Container(width: 18, height: 3, color: primaryColor)
                      : Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                ),
              );
            }),
          ),
          Positioned.fill(
            child: TextField(
              controller: _confirmPinController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              autofocus: true,
              showCursor: false,
              enableInteractiveSelection: false,
              style: const TextStyle(color: Colors.transparent, fontSize: 1),
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }
}
