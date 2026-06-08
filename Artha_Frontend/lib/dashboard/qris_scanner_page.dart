import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRISScannerPage extends StatefulWidget {
  const QRISScannerPage({super.key});

  @override
  State<QRISScannerPage> createState() => _QRISScannerPageState();
}

class _QRISScannerPageState extends State<QRISScannerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Agar kamera menutupi seluruh layar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Tombol kembali putih
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "QRIS Scanner",
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.w900,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      // MobileScanner akan membuka kamera secara otomatis
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            debugPrint('QR Code terdeteksi: ${barcode.rawValue}');
            
            // Setelah terdeteksi, kita kembalikan hasil datanya ke halaman sebelumnya
            Navigator.pop(context, barcode.rawValue);
            break; 
          }
        },
      ),
    );
  }
}