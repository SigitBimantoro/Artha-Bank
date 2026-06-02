import 'package:flutter/material.dart';
import 'input_pin_page.dart';

class PilihPaketPage extends StatefulWidget {
  final bool isDataTab;
  final String phoneNumber;

  const PilihPaketPage({
    super.key,
    this.isDataTab = false,
    required this.phoneNumber,
  });

  @override
  State<PilihPaketPage> createState() => _PilihPaketPageState();
}

class _PilihPaketPageState extends State<PilihPaketPage> {
  late bool isDataActive;

  int? selectedPulsaIndex;
  int? selectedDataIndex;

  final List<String> listPulsa = [
    "15 rb", "20 rb", "25 rb", "30 rb", "40 rb", "50 rb",
    "75 rb", "100 rb", "150 rb", "200 rb", "300 rb", "500 rb",
  ];

  final List<Map<String, String>> listData = [
    {"type": "Internet Flash", "size": "500 Mb", "price": "15 rb"},
    {"type": "Internet Flash", "size": "1 Gb", "price": "30 rb"},
    {"type": "Internet Flash", "size": "2 Gb", "price": "45 rb"},
    {"type": "Internet OMG!", "size": "7 Gb", "price": "65 rb"},
    {"type": "Internet simPATI", "size": "10 Gb", "price": "70 rb"},
    {"type": "Internet OMG!", "size": "15 Gb", "price": "100 rb"},
  ];

  @override
  void initState() {
    super.initState();
    isDataActive = widget.isDataTab;
  }

  // --- FUNGSI UNTUK MENAMPILKAN POP-UP KONFIRMASI ---
  void _showKonfirmasiDialog(String nominalHarga) {
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Konfirmasi Pembayaran",
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.vibration, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Telkomsel Prepaid",
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        widget.phoneNumber,
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 11,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 15),
              const Divider(color: primaryColor, thickness: 1),
              const SizedBox(height: 15),

              const Text(
                "Detail pembayaran",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 15),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Nominal Pembayaran",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    "Rp $nominalHarga.000",
                    style: const TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Biaya Transaksi",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    "Rp 0", // Kita gratiskan biaya admin sesuai backend
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Tutup Dialog pop-up
                  
                  // Mengubah string "15" menjadi double 15000.0 untuk dikirim ke Backend
                  double finalAmount = double.parse(nominalHarga) * 1000;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InputPinPage(
                        phoneNumber: widget.phoneNumber,
                        amount: finalAmount,
                      ),
                    ),
                  ); 
                },
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(20),
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
              const SizedBox(height: 10),
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
          Expanded(
            child: Container(
              width: double.infinity,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
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
                          ),
                          const SizedBox(height: 5),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.vibration,
                              color: primaryColor,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Telkomsel Prepaid",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Text(
                            widget.phoneNumber.isNotEmpty ? widget.phoneNumber : "Nomor tidak valid",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 25),
                        ],
                      ),
                    ),
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(height: 2, width: double.infinity, color: Colors.white),
                        Row(
                          children: [
                            _buildTabItem("Pulsa", !isDataActive),
                            _buildTabItem("Data", isDataActive),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isDataActive ? "Pilih Paket Data" : "Pilih Jumlah Pulsa",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: isDataActive ? _buildDataGrid() : _buildPulsaGrid(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isDataActive = label == "Data";
            selectedPulsaIndex = null;
            selectedDataIndex = null;
          });
        },
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 25),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPulsaGrid() {
    return GridView.builder(
      padding: const EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 40),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2, 
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: listPulsa.length,
      itemBuilder: (context, index) {
        bool isSelected = selectedPulsaIndex == index;
        return GestureDetector(
          onTap: () => setState(() => selectedPulsaIndex = index),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? const Color(0xFF2C265C) : Colors.transparent,
                width: isSelected ? 3 : 0,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3)),
              ],
            ),
            child: Center(
              child: Text(
                listPulsa[index],
                style: const TextStyle(
                  color: Color(0xFF4D55CC),
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataGrid() {
    return GridView.builder(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 40),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85, 
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: listData.length,
      itemBuilder: (context, index) {
        bool isSelected = selectedDataIndex == index;
        return GestureDetector(
          onTap: () => setState(() => selectedDataIndex = index),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected ? const Color(0xFF2C265C) : Colors.transparent,
                width: isSelected ? 3 : 0,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3)),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(listData[index]['type']!, style: const TextStyle(color: Color(0xFF4D55CC), fontSize: 10, fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
                      const SizedBox(height: 6),
                      Text(listData[index]['size']!, style: const TextStyle(color: Color(0xFF4D55CC), fontWeight: FontWeight.w900, fontSize: 20, height: 1.1, fontFamily: 'Poppins')),
                      const SizedBox(height: 4),
                      Text(listData[index]['price']!, style: const TextStyle(color: Color(0xFF4D55CC), fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Poppins')),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(color: const Color(0xFF4D55CC), borderRadius: BorderRadius.circular(15)),
                  child: const Center(child: Text("Detail", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomButton() {
    bool isPackageSelected = (!isDataActive && selectedPulsaIndex != null) || 
                             (isDataActive && selectedDataIndex != null);

    return Container(
      color: const Color(0xFFF9F9F9),
      padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 30),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: isPackageSelected 
              ? () {
                  if (!isDataActive && selectedPulsaIndex != null) {
                    String nominal = listPulsa[selectedPulsaIndex!].replaceAll(RegExp(r'[^0-9]'), '');
                    _showKonfirmasiDialog(nominal);
                  } else if (isDataActive && selectedDataIndex != null) {
                    String nominal = listData[selectedDataIndex!]['price']!.replaceAll(RegExp(r'[^0-9]'), '');
                    _showKonfirmasiDialog(nominal);
                  }
                }
              : null,
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              color: isPackageSelected ? const Color(0xFF4D55CC) : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Center(
              child: Text(
                "Lanjutkan",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}