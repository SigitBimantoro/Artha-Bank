import 'package:flutter/material.dart';

import '../pembayaran/input_pin_page.dart';

class QrisScanData {
  final String rawPayload;
  final String merchantName;
  final double? amount;

  const QrisScanData({
    required this.rawPayload,
    required this.merchantName,
    this.amount,
  });

  factory QrisScanData.fromPayload(String rawPayload) {
    final tags = _readEmvTags(rawPayload);
    final merchant = (tags['59'] ?? '').trim();
    final amountText = (tags['54'] ?? '').trim();
    final amount = double.tryParse(amountText);

    return QrisScanData(
      rawPayload: rawPayload,
      merchantName: merchant.isEmpty ? 'Merchant QRIS' : merchant,
      amount: amount != null && amount > 0 ? amount : null,
    );
  }

  static Map<String, String> _readEmvTags(String payload) {
    final result = <String, String>{};
    var index = 0;

    while (index + 4 <= payload.length) {
      final id = payload.substring(index, index + 2);
      final length = int.tryParse(payload.substring(index + 2, index + 4));
      if (length == null) break;

      final valueStart = index + 4;
      final valueEnd = valueStart + length;
      if (valueEnd > payload.length) break;

      result[id] = payload.substring(valueStart, valueEnd);
      index = valueEnd;
    }

    return result;
  }
}

class QrisPaymentPage extends StatefulWidget {
  final QrisScanData data;

  const QrisPaymentPage({super.key, required this.data});

  @override
  State<QrisPaymentPage> createState() => _QrisPaymentPageState();
}

class _QrisPaymentPageState extends State<QrisPaymentPage> {
  static const Color primaryColor = Color(0xFF4D55CC);
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.data.amount == null ? '' : _formatInput(widget.data.amount!),
    );
  }

  double get _amount {
    final clean = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(clean) ?? 0;
  }

  bool get _canContinue => _amount > 0;

  static String _formatInput(double value) {
    final raw = value.toInt().toString();
    return raw.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
  }

  String _formatCurrencyInput(String value) {
    final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return '';
    return clean.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
  }

  void _onAmountChanged(String value) {
    final formatted = _formatCurrencyInput(value);
    if (formatted == value) {
      setState(() {});
      return;
    }
    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    setState(() {});
  }

  void _continueToPin() {
    if (!_canContinue) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InputPinPage(
          amount: _amount,
          type: 'QRIS',
          target: widget.data.merchantName,
          notes: widget.data.rawPayload,
          skipConfirmation: true,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 22,
            right: 22,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 29,
                        ),
                      ),
                    ),
                    const SizedBox(width: 42),
                    const Text(
                      'Bayar ke',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 66),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(28, 46, 28, 34),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(34),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.storefront_outlined,
                          color: primaryColor,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        widget.data.merchantName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 66),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(32, 28, 28, 28),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(34),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nominal Transaksi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Text(
                            'Rp ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 35,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              onChanged: _onAmountChanged,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 35,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Poppins',
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isCollapsed: true,
                                hintText: '0',
                                hintStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 35,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _amountController.clear();
                              setState(() {});
                            },
                            child: const Icon(
                              Icons.cancel_outlined,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        color: Colors.white,
                        thickness: 3,
                        height: 10,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom > 0
                      ? 110
                      : 230,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _canContinue ? _continueToPin : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      disabledBackgroundColor: const Color(0xFFC9C9C9),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Lanjutkan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Poppins',
                      ),
                    ),
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
