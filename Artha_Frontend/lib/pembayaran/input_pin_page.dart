import 'package:flutter/material.dart';
import '../services/api_service.dart';

class InputPinPage extends StatefulWidget {
  final String? phoneNumber; // Untuk Transfer
  final double amount;       // Untuk Transfer
  final String? notes;       // Untuk Transfer
  
  // Tambahkan variabel untuk Pulsa/Listrik jika perlu
  final String? type;        // 'TRANSFER', 'PULSA', 'PLN', 'TOPUP'
  final String? target;      // Nomor HP pulsa / Nomor meteran

  const InputPinPage({
    super.key, 
    this.phoneNumber, 
    this.amount = 0, 
    this.notes = "",
    this.type = 'TRANSFER',
    this.target,
  });

  @override
  State<InputPinPage> createState() => _InputPinPageState();
}

class _InputPinPageState extends State<InputPinPage> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;

  Future<void> _eksekusiTransaksi() async {
    setState(() => _isLoading = true);
    
    Map<String, dynamic> res;

    // Arahkan ke fungsi API yang sesuai berdasarkan jenis transaksi
    if (widget.type == 'TRANSFER') {
      res = await ApiService.transferUang(widget.phoneNumber!, widget.amount, widget.notes!, _pinController.text);
    } else if (widget.type == 'PULSA') {
      res = await ApiService.beliPulsa(widget.target!, widget.amount, _pinController.text);
    } else if (widget.type == 'PLN') {
      res = await ApiService.beliTokenListrik(widget.target!, widget.amount, _pinController.text);
    } else {
      res = {'success': false, 'message': 'Tipe transaksi tidak dikenal'};
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (res['success']) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Transaksi Berhasil!"), backgroundColor: Colors.green));
        Navigator.popUntil(context, (route) => route.isFirst); // Kembali ke Home
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message']), backgroundColor: Colors.red));
        _pinController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4D55CC);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Masukkan PIN"), backgroundColor: primaryColor),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text("Masukkan 6 digit PIN untuk mengonfirmasi transaksi"),
            const SizedBox(height: 20),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: (_pinController.text.length == 6 && !_isLoading) ? _eksekusiTransaksi : null,
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Bayar Sekarang"),
            )
          ],
        ),
      ),
    );
  }
}