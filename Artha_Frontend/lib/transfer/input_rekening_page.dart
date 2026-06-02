import 'package:flutter/material.dart';
import '../pembayaran/input_pin_page.dart'; // <-- Path sudah benar

class InputRekeningPage extends StatefulWidget {
  final String? initialBankName;
  final String? initialBankType;

  const InputRekeningPage({
    super.key, 
    this.initialBankName, 
    this.initialBankType,
  });

  @override
  State<InputRekeningPage> createState() => _InputRekeningPageState();
}

class _InputRekeningPageState extends State<InputRekeningPage> {
  final TextEditingController _rekeningController = TextEditingController();

  late String selectedBankName;
  late String selectedBankType;

  @override
  void initState() {
    super.initState();
    selectedBankName = widget.initialBankName ?? "Bank Mandiri";
    selectedBankType = widget.initialBankType ?? "mandiri";
  }

  @override
  void dispose() {
    _rekeningController.dispose();
    super.dispose();
  }

  // --- POP-UP CEK DETAIL PENERIMA ---
  void _showCekDetailPenerimaBottomSheet() {
    const Color primaryColor = Color(0xFF4D55CC);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(35),
              topRight: Radius.circular(35),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 35),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Cek Detail Penerima",
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: primaryColor,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 15),
                    
                    const Text(
                      "Muhammad Reza Raffi",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 5),
                    
                    Text(
                      "$selectedBankName - ${_rekeningController.text}",
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 13,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Pastikan data penerima sudah benar.",
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 13,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 25),

              GestureDetector(
                onTap: () {
                  Navigator.pop(context); 
                  
                  // ========================================================
                  // 🟢 PERBAIKAN DI SINI: Menambahkan parameter yang diminta
                  // ========================================================
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InputPinPage(
                        phoneNumber: _rekeningController.text, 
                        amount: 0, // <-- Diisi 0 sementara agar tidak merah
                      ), 
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Center(
                    child: Text(
                      "Lanjutkan",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  "Ubah Penerima",
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // --- POP-UP SELEKSI BANK ---
  void _showPilihBankBottomSheet() {
    const Color primaryColor = Color(0xFF4D55CC);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Pilih Bank Tujuan",
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildBankOptionItem("Bank Mandiri", "mandiri"),
                  const SizedBox(width: 15),
                  _buildBankOptionItem("Bank BNI", "BNI"),
                  const SizedBox(width: 15),
                  _buildBankOptionItem("Bank Jago", "jago"),
                ],
              ),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4D55CC);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 45, left: 24, right: 24),
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
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
                        "Transfer",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),

                  GestureDetector(
                    onTap: _showPilihBankBottomSheet,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Nama Bank",
                                style: TextStyle(
                                  color: primaryColor.withOpacity(0.5),
                                  fontSize: 11,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedBankName,
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                          _renderBankLogo(selectedBankType),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextFormField(
                      controller: _rekeningController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w900,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Nomor Rekening',
                        labelStyle: TextStyle(
                          color: primaryColor.withOpacity(0.5),
                          fontSize: 11,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                        hintText: "Masukkan nomor rekening",
                        hintStyle: TextStyle(
                          color: primaryColor.withOpacity(0.3),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Expanded(child: SizedBox()),
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 30, top: 10),
          child: GestureDetector(
            onTap: () {
              if (_rekeningController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Silakan isi nomor rekening terlebih dahulu!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              _showCekDetailPenerimaBottomSheet();
            },
            child: Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Center(
                child: Text(
                  'Lanjutkan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBankOptionItem(String name, String type) {
    const Color primaryColor = Color(0xFF4D55CC);
    bool isCurrentSelected = selectedBankType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedBankName = name;
          selectedBankType = type;
        });
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Container(
            width: 75,
            height: 70,
            decoration: BoxDecoration(
              color: isCurrentSelected ? const Color(0xFFE8E9F9) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCurrentSelected ? primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(child: _renderBankLogo(type)),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              color: isCurrentSelected ? primaryColor : const Color(0xFF666666),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderBankLogo(String type) {
    if (type == "mandiri") {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            "mandırı",
            style: TextStyle(color: Color(0xFF1C3F94), fontSize: 11, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
          ),
          Container(
            width: 14, height: 2.5,
            decoration: BoxDecoration(color: const Color(0xFFF7B819), borderRadius: BorderRadius.circular(2)),
          ),
        ],
      );
    } else if (type == "BNI") {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("B", style: TextStyle(color: Color(0xFFF15A22), fontSize: 14, fontWeight: FontWeight.w900)),
          Text("NI", style: TextStyle(color: Color(0xFF005A6F), fontSize: 14, fontWeight: FontWeight.w900)),
        ],
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(color: const Color(0xFFF5A623), borderRadius: BorderRadius.circular(5)),
        child: const Text(
          "jago",
          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        ),
      );
    }
  }
}