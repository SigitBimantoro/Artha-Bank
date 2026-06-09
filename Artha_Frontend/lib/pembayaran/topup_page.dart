import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'input_nominal_page.dart';// Import halaman nominal

class _TopUpMethod {
  final String name;
  final String value;
  final Widget logo;

  const _TopUpMethod({
    required this.name,
    required this.value,
    required this.logo,
  });
}

class TopUpPage extends StatefulWidget {
  const TopUpPage({super.key});

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  String _selectedMethod = 'Bank Jago';
  bool _isConfirmed = false;
  final String _virtualAccountNumber = "8930 8123 4567 8910";

  static const Color primaryColor = Color(0xFF4D55CC);

  List<_TopUpMethod> get _bankMethods => [
    _TopUpMethod(name: 'Bank Jago', value: 'Bank Jago', logo: _buildJagoLogo()),
    _TopUpMethod(name: 'Bank BNI', value: 'Bank BNI', logo: _buildTextLogo('BNI', const Color(0xFF006B93))),
    _TopUpMethod(name: 'Bank BRI', value: 'Bank BRI', logo: _buildTextLogo('BRI', const Color(0xFF00539B))),
    _TopUpMethod(name: 'Bank BSI', value: 'Bank BSI', logo: _buildBoxLogo('BSI', const Color(0xFF2FAFA5))),
    _TopUpMethod(name: 'Bank BCA', value: 'Bank BCA', logo: _buildBoxLogo('BCA', const Color(0xFF006DB6))),
  ];

  List<_TopUpMethod> get _cashMethods => [
    _TopUpMethod(name: 'Indomaret', value: 'Indomaret', logo: _buildStoreLogo('Indomaret')),
    _TopUpMethod(name: 'Alfamaret', value: 'Alfamaret', logo: _buildStoreLogo('Alfamart')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Background bawah putih abu
      body: Column(
        children: [
          if (_isConfirmed)
            // MODE 2: KONFIRMASI VA (Biru hanya membungkus konten atas)
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // KUNCI: Agar tidak melar ke bawah
                  children: [
                    _buildHeader(),
                    _buildConfirmationView(), // Memanggil UI Kotak VA
                  ],
                ),
              ),
            )
          else
            // MODE 1: PILIH BANK (Biru melar sampai tombol)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 10),
                      Expanded(child: _buildSelectionView()), // Daftar Bank bisa discroll
                    ],
                  ),
                ),
              ),
            ),

          // Jika di mode Konfirmasi VA, beri Spacer (Ruang putih kosong) ke bawah
          if (_isConfirmed) const Spacer(),

          // --- TOMBOL BAWAH (DI AREA PUTIH) ---
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
            color: const Color(0xFFFAFAFA),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (_isConfirmed) {
                    // Setelah OK di VA, arahkan ke Input Nominal
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InputNominalPage(
                          receiverName: _selectedMethod,
                          receiverPhone: _virtualAccountNumber,
                          transactionType: 'TOPUP', // Penanda alur Top Up
                        ),
                      ),
                    );
                  } else {
                    // Dari Pilih Bank, masuk ke Konfirmasi VA
                    setState(() => _isConfirmed = true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _isConfirmed ? 'Ok' : 'Konfirmasi',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Header (Tombol Back & Judul)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_isConfirmed) {
                setState(() => _isConfirmed = false); // Kembali ke Pilih Bank
              } else {
                Navigator.pop(context); // Kembali ke Home
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: primaryColor, size: 20),
            ),
          ),
          const SizedBox(width: 20),
          const Text(
            'Top Up',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // UI 1: Pilih Metode
  Widget _buildSelectionView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text('Lewat Bank', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 15),
          ..._bankMethods.map(_buildMethodTile),
          const SizedBox(height: 25),
          const Text('Pakai Uang Tunai', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 15),
          ..._cashMethods.map(_buildMethodTile),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // UI 2: Tampilan Konfirmasi Virtual Account
  Widget _buildConfirmationView() {
    final method = [..._bankMethods, ..._cashMethods].firstWhere((m) => m.value == _selectedMethod);

    return Padding(
      // Padding bottom 40 agar lengkungan birunya agak turun ke bawah persis figma
      padding: const EdgeInsets.only(left: 24, right: 24, top: 15, bottom: 40),
      child: Column(
        children: [
          // Kotak 1: Nama Bank
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                SizedBox(width: 40, child: method.logo),
                const SizedBox(width: 15),
                Text(method.name, style: const TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Poppins')),
              ],
            ),
          ),
          const SizedBox(height: 15),
          // Kotak 2: Virtual Account
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("No Rek/Virtual Account", style: TextStyle(color: Color(0xFF9F9F9F), fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_virtualAccountNumber, style: const TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Poppins')),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: _virtualAccountNumber.replaceAll(' ', '')));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nomor disalin!"), duration: Duration(seconds: 1)));
                      },
                      child: const Text("Salin", style: TextStyle(color: primaryColor, fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Poppins')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodTile(_TopUpMethod method) {
    final bool isSelected = method.value == _selectedMethod;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method.value),
      child: Container(
        height: 65,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(width: 50, alignment: Alignment.centerLeft, child: method.logo),
            const SizedBox(width: 10),
            Expanded(
              child: Text(method.name, style: const TextStyle(color: primaryColor, fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w800)),
            ),
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primaryColor, width: 1.5)),
              child: isSelected ? const Center(child: CircleAvatar(radius: 7, backgroundColor: primaryColor)) : null,
            ),
          ],
        ),
      ),
    );
  }

  // --- LOGO BUILDERS ---
  static Widget _buildJagoLogo() => const Text('J', style: TextStyle(color: Color(0xFFFFA91F), fontSize: 24, fontWeight: FontWeight.w900));
  static Widget _buildTextLogo(String text, Color color) => Text(text, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900));
  static Widget _buildBoxLogo(String text, Color color) => Container(
    padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
    child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
  );
  static Widget _buildStoreLogo(String text) => Text(text, style: TextStyle(color: text == 'Alfamart' ? Colors.red : Colors.blue, fontSize: 12, fontWeight: FontWeight.w900));
}