import 'package:flutter/material.dart';
import '../pembayaran/input_pin_page.dart';

class InputNominalPage extends StatefulWidget {
  final String receiverPhone;
  final String receiverName;

  const InputNominalPage({
    super.key,
    required this.receiverPhone,
    required this.receiverName,
  });

  @override
  State<InputNominalPage> createState() => _InputNominalPageState();
}

class _InputNominalPageState extends State<InputNominalPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4D55CC);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Nominal Transfer",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Penerima
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Penerima",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.receiverName,
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    widget.receiverPhone,
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Input Nominal
            const Text(
              "Nominal (Rp)",
              style: TextStyle(
                color: primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              decoration: InputDecoration(
                hintText: "0",
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Input Catatan (Opsional)
            const Text(
              "Catatan (Opsional)",
              style: TextStyle(
                color: primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: "Contoh: Bayar hutang makan",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const Spacer(),

            // Tombol Lanjutkan
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(
                    _amountController.text.replaceAll('.', ''),
                  );
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Masukkan nominal yang valid!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Lanjut ke halaman PIN Transfer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InputPinPage(
                        phoneNumber: widget.receiverPhone,
                        amount: amount,
                        type: 'TRANSFER',
                        notes: _notesController.text,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  "Lanjutkan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
