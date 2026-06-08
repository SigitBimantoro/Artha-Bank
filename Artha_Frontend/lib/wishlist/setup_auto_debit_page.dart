import 'package:flutter/material.dart';

class SetupAutoDebitPage extends StatefulWidget {
  final int savingId;
  final String namaTarget;

  const SetupAutoDebitPage({
    super.key,
    required this.savingId,
    required this.namaTarget,
  });

  @override
  State<SetupAutoDebitPage> createState() => _SetupAutoDebitPageState();
}

class _SetupAutoDebitPageState extends State<SetupAutoDebitPage> {
  final TextEditingController _nominalController = TextEditingController();

  // Pilihan periode sesuai logika backend: DAILY, WEEKLY, MONTHLY
  String _selectedPeriode = 'MONTHLY';
  final List<Map<String, String>> _periodeOptions = [
    {'label': 'Harian', 'value': 'DAILY'},
    {'label': 'Mingguan', 'value': 'WEEKLY'},
    {'label': 'Bulanan', 'value': 'MONTHLY'},
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4D55CC);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Auto-Debit Tabungan",
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w900,
            fontFamily: 'Poppins',
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Tabungan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Atur pemindahan saldo otomatis untuk wishlist: ${widget.namaTarget}",
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Input Nominal
            const Text(
              "Nominal Auto-Debit",
              style: TextStyle(
                color: primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nominalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Contoh: 50000",
                prefixText: "Rp ",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: primaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Pilih Periode
            const Text(
              "Frekuensi Auto-Debit",
              style: TextStyle(
                color: primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _periodeOptions.map((opt) {
                bool isSelected = _selectedPeriode == opt['value'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedPeriode = opt['value']!),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.28,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: primaryColor),
                    ),
                    child: Center(
                      child: Text(
                        opt['label']!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const Spacer(),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Logika integrasi backend simpan auto debit
                  print(
                    "Simpan: ${_nominalController.text} Periode: $_selectedPeriode",
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Aktifkan Auto-Debit",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
