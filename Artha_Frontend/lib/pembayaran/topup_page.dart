import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
  final TextEditingController _amountController = TextEditingController();
  String _selectedMethod = 'Bank Jago';
  bool _isLoading = false;

  static const Color primaryColor = Color(0xFF4D55CC);

  List<_TopUpMethod> get _bankMethods => [
    _TopUpMethod(name: 'Bank Jago', value: 'Bank Jago', logo: _buildJagoLogo()),
    _TopUpMethod(
      name: 'Bank BNI',
      value: 'Bank BNI',
      logo: _buildTextLogo('BNI', const Color(0xFF006B93), 19),
    ),
    _TopUpMethod(
      name: 'Bank BRI',
      value: 'Bank BRI',
      logo: _buildTextLogo('BRI', const Color(0xFF00539B), 23),
    ),
    _TopUpMethod(
      name: 'Bank BSI',
      value: 'Bank BSI',
      logo: _buildBoxLogo('BSI', const Color(0xFF2FAFA5)),
    ),
    _TopUpMethod(
      name: 'Bank BCA',
      value: 'Bank BCA',
      logo: _buildBoxLogo('BCA', const Color(0xFF006DB6)),
    ),
  ];

  List<_TopUpMethod> get _cashMethods => [
    _TopUpMethod(
      name: 'Indomaret',
      value: 'Indomaret',
      logo: _buildStoreLogo('Indomaret'),
    ),
    _TopUpMethod(
      name: 'Alfamaret',
      value: 'Alfamaret',
      logo: _buildStoreLogo('Alfamart'),
    ),
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submitTopUp() async {
    final text = _amountController.text.replaceAll('.', '');
    final amount = double.tryParse(text);
    if (amount == null || amount < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal top up Rp 10.000'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final res = await ApiService.topUpInternal(amount, _selectedMethod);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Top Up berhasil!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Top Up gagal')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 128),
              child: Container(
                margin: const EdgeInsets.only(bottom: 44),
                padding: const EdgeInsets.fromLTRB(40, 28, 40, 74),
                decoration: const BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(170),
                    bottomRight: Radius.circular(170),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: primaryColor,
                              size: 42,
                            ),
                          ),
                        ),
                        const SizedBox(width: 38),
                        const Text(
                          'Top Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 78),
                    const Text(
                      'Lewat Bank',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ..._bankMethods.map(_buildMethodTile),
                    const SizedBox(height: 30),
                    const Text(
                      'Pakai Uang Tunai',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ..._cashMethods.map(_buildMethodTile),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(40, 22, 40, 28),
                child: SizedBox(
                  width: double.infinity,
                  height: 78,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _showAmountSheet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(34),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Konfirmasi',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
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

  Widget _buildMethodTile(_TopUpMethod method) {
    final selected = method.value == _selectedMethod;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method.value),
      child: Container(
        height: 126,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 42),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(36),
        ),
        child: Row(
          children: [
            SizedBox(width: 86, child: Center(child: method.logo)),
            const SizedBox(width: 24),
            Expanded(
              child: Text(
                method.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: primaryColor,
                  fontFamily: 'Poppins',
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor, width: 3),
              ),
              child: selected
                  ? const Center(
                      child: CircleAvatar(
                        radius: 12,
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

  void _showAmountSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            28,
            30,
            28,
            MediaQuery.of(context).viewInsets.bottom + 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan Nominal',
                style: TextStyle(
                  color: primaryColor,
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 22),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(
                  color: primaryColor,
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  hintText: '10.000',
                  hintStyle: TextStyle(
                    color: primaryColor.withValues(alpha: 0.55),
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _submitTopUp();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Top Up Sekarang',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildJagoLogo() {
    return const Text(
      'J',
      style: TextStyle(
        color: Color(0xFFFFA91F),
        fontFamily: 'Poppins',
        fontSize: 48,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  static Widget _buildTextLogo(String text, Color color, double size) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontFamily: 'Poppins',
        fontSize: size,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  static Widget _buildBoxLogo(String text, Color color) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  static Widget _buildStoreLogo(String text) {
    return Container(
      width: 76,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: text == 'Alfamart'
              ? const Color(0xFF0062B8)
              : const Color(0xFF1678D2),
          fontFamily: 'Poppins',
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
