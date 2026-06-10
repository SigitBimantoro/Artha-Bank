import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'input_nominal_page.dart';

class _TopUpMethod {
  final String name;
  final String value;
  final String assetPath;
  final String guideTitle;
  final List<String> guideSteps;
  final bool isCashier;

  const _TopUpMethod({
    required this.name,
    required this.value,
    required this.assetPath,
    required this.guideTitle,
    required this.guideSteps,
    required this.isCashier,
  });
}

class TopUpPage extends StatefulWidget {
  const TopUpPage({super.key});

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  static const Color primaryColor = Color(0xFF4D55CC);

  String _selectedMethod = 'Bank Jago';
  bool _isConfirmed = false;
  bool _isGuideExpanded = true;
  final String _virtualAccountNumber = '8930 8123 4567 8910';

  List<_TopUpMethod> get _bankMethods => [
        _TopUpMethod(
          name: 'Bank Jago',
          value: 'Bank Jago',
          assetPath: 'assets/bankjago.png',
          guideTitle: 'Petunjuk Transfer mBanking',
          guideSteps: const [
            'Buka menu transfer pada aplikasi mobile banking.',
            'Pilih transfer ke rekening/virtual account.',
            'Masukkan nomor VA yang tertera.',
            'Cek nominal, lalu konfirmasi transaksi.',
          ],
          isCashier: false,
        ),
        _TopUpMethod(
          name: 'Bank BNI',
          value: 'Bank BNI',
          assetPath: 'assets/BNI.png',
          guideTitle: 'Petunjuk Transfer mBanking',
          guideSteps: const [
            'Buka menu transfer pada aplikasi mobile banking.',
            'Pilih transfer ke rekening/virtual account.',
            'Masukkan nomor VA yang tertera.',
            'Cek nominal, lalu konfirmasi transaksi.',
          ],
          isCashier: false,
        ),
        _TopUpMethod(
          name: 'Bank BRI',
          value: 'Bank BRI',
          assetPath: 'assets/BRI.png',
          guideTitle: 'Petunjuk Transfer mBanking',
          guideSteps: const [
            'Buka menu transfer pada aplikasi mobile banking.',
            'Pilih transfer ke rekening/virtual account.',
            'Masukkan nomor VA yang tertera.',
            'Cek nominal, lalu konfirmasi transaksi.',
          ],
          isCashier: false,
        ),
        _TopUpMethod(
          name: 'Bank BSI',
          value: 'Bank BSI',
          assetPath: 'assets/BSI.png',
          guideTitle: 'Petunjuk Transfer mBanking',
          guideSteps: const [
            'Buka menu transfer pada aplikasi mobile banking.',
            'Pilih transfer ke rekening/virtual account.',
            'Masukkan nomor VA yang tertera.',
            'Cek nominal, lalu konfirmasi transaksi.',
          ],
          isCashier: false,
        ),
        _TopUpMethod(
          name: 'Bank BCA',
          value: 'Bank BCA',
          assetPath: 'assets/BCA.png',
          guideTitle: 'Petunjuk Transfer mBanking',
          guideSteps: const [
            'Buka menu transfer pada aplikasi mobile banking.',
            'Pilih transfer ke rekening/virtual account.',
            'Masukkan nomor VA yang tertera.',
            'Cek nominal, lalu konfirmasi transaksi.',
          ],
          isCashier: false,
        ),
      ];

  List<_TopUpMethod> get _cashMethods => [
        _TopUpMethod(
          name: 'Indomaret',
          value: 'Indomaret',
          assetPath: 'assets/Frame 156-6.png',
          guideTitle: 'Petunjuk Transaksi di Kasir',
          guideSteps: const [
            'Datangi kasir dan sampaikan ingin top up Artha.',
            'Tunjukkan nomor VA ke kasir.',
            'Sebutkan nominal top up yang dipilih.',
            'Simpan struk setelah transaksi selesai.',
          ],
          isCashier: true,
        ),
        _TopUpMethod(
          name: 'Alfamaret',
          value: 'Alfamaret',
          assetPath: 'assets/Alfamaret.png',
          guideTitle: 'Petunjuk Transaksi di Kasir',
          guideSteps: const [
            'Datangi kasir dan sampaikan ingin top up Artha.',
            'Tunjukkan nomor VA ke kasir.',
            'Sebutkan nominal top up yang dipilih.',
            'Simpan struk setelah transaksi selesai.',
          ],
          isCashier: true,
        ),
      ];

  _TopUpMethod get _selectedMethodData =>
      [..._bankMethods, ..._cashMethods].firstWhere(
        (method) => method.value == _selectedMethod,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          if (_isConfirmed)
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(50),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    _buildConfirmationView(),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(50),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 10),
                      Expanded(child: _buildSelectionView()),
                    ],
                  ),
                ),
              ),
            ),
          if (_isConfirmed) const Spacer(),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
            color: const Color(0xFFFAFAFA),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (_isConfirmed) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InputNominalPage(
                          receiverName: _selectedMethod,
                          receiverPhone: _virtualAccountNumber,
                          transactionType: 'TOPUP',
                        ),
                      ),
                    );
                  } else {
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_isConfirmed) {
                setState(() {
                  _isConfirmed = false;
                  _isGuideExpanded = true;
                });
              } else {
                Navigator.pop(context);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: primaryColor,
                size: 20,
              ),
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

  Widget _buildSelectionView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text(
            'Lewat Bank',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 15),
          ..._bankMethods.map(_buildMethodTile),
          const SizedBox(height: 25),
          const Text(
            'Pakai Uang Tunai',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 15),
          ..._cashMethods.map(_buildMethodTile),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildConfirmationView() {
    final method = _selectedMethodData;

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 15, bottom: 40),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: _buildMethodLogo(method),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    method.name,
                    style: const TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'No Rek/Virtual Account',
                  style: TextStyle(
                    color: Color(0xFF9F9F9F),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _virtualAccountNumber,
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _showCopiedPopup,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Salin',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          if (method.isCashier) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildBarcode(_virtualAccountNumber.replaceAll(' ', '')),
                  const SizedBox(height: 10),
                  const Text(
                    'BISMILLAH NILAIA',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
          ],
          GestureDetector(
            onTap: () => setState(() => _isGuideExpanded = !_isGuideExpanded),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          method.guideTitle,
                          style: const TextStyle(
                            color: primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      Icon(
                        _isGuideExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: primaryColor,
                        size: 30,
                      ),
                    ],
                  ),
                  if (_isGuideExpanded) ...[
                    const SizedBox(height: 18),
                    ...method.guideSteps.map(
                      (step) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 7),
                              child: Icon(
                                Icons.circle,
                                size: 8,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                step,
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontSize: 13,
                                  height: 1.35,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodTile(_TopUpMethod method) {
    final bool isSelected = method.value == _selectedMethod;

    return GestureDetector(
      onTap: () => setState(() {
        _selectedMethod = method.value;
        _isGuideExpanded = true;
      }),
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
            SizedBox(
              width: 42,
              height: 42,
              child: _buildMethodLogo(method),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                method.name,
                style: const TextStyle(
                  color: primaryColor,
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor, width: 1.5),
              ),
              child: isSelected
                  ? const Center(
                      child: CircleAvatar(
                        radius: 7,
                        backgroundColor: primaryColor,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCopiedPopup() async {
    await Clipboard.setData(
      ClipboardData(text: _virtualAccountNumber.replaceAll(' ', '')),
    );

    if (!mounted) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Copied',
      barrierColor: Colors.black.withValues(alpha: 0.2),
      pageBuilder: (context, _, _) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 330,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFF1FD45A),
                    child: Icon(Icons.check, color: Colors.white, size: 22),
                  ),
                  SizedBox(width: 18),
                  Text(
                    'Berhasil Disalin',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  Widget _buildBarcode(String value) {
    return SizedBox(
      width: double.infinity,
      height: 86,
      child: CustomPaint(
        painter: _SimpleBarcodePainter(value),
      ),
    );
  }

  Widget _buildMethodLogo(_TopUpMethod method) {
    if (method.name == 'Indomaret') {
      return FittedBox(
        fit: BoxFit.contain,
        child: Text.rich(
          const TextSpan(
            children: [
              TextSpan(
                text: 'Indomar',
                style: TextStyle(color: Color(0xFF1765D8)),
              ),
              TextSpan(
                text: 'et',
                style: TextStyle(color: Color(0xFFE21B2D)),
              ),
            ],
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      );
    }

    return Image.asset(
      method.assetPath,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}

class _SimpleBarcodePainter extends CustomPainter {
  final String value;

  _SimpleBarcodePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;

    final paint = Paint()..color = Colors.black;
    final baseWidth = size.width / 120;
    double x = 0;
    var index = 0;

    while (x < size.width) {
      final digit = int.tryParse(digits[index % digits.length]) ?? 0;
      final barWidth = digit.isEven ? baseWidth * 1.35 : baseWidth * 0.65;
      final barHeight = size.height * (0.76 + (digit % 4) * 0.05);

      canvas.drawRect(
        Rect.fromLTWH(x, 0, barWidth, barHeight),
        paint,
      );
      x += barWidth + baseWidth * 0.35;

      if (index % 4 == 3) {
        x += baseWidth * 0.45;
      }
      index++;
    }
  }

  @override
  bool shouldRepaint(covariant _SimpleBarcodePainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
