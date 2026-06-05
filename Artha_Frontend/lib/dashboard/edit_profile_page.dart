import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Menarik data user saat ini sebelum diedit
  Future<void> _loadProfileData() async {
    final res = await ApiService.getProfile();
    if (mounted) {
      setState(() {
        if (res['success']) {
          final data = res['data']['data'];
          _namaController.text = data['nama'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phone_number'] ?? '';
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res['message'] ?? 'Gagal memuat data'), backgroundColor: Colors.red),
          );
        }
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk mengirim data baru ke backend
  Future<void> _simpanPerubahan() async {
    if (_namaController.text.isEmpty || _emailController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua kolom harus diisi!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    final res = await ApiService.updateProfile(
      nama: _namaController.text,
      email: _emailController.text,
      phoneNumber: _phoneController.text,
    );

    setState(() => _isSaving = false);

    if (res['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: Colors.green),
        );
        // Mengembalikan nilai 'true' ke ProfilePage agar ProfilePage melakukan refresh data
        Navigator.pop(context, true); 
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Gagal memperbarui profil'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4D55CC);

    return Scaffold(
      backgroundColor: primaryColor, // Full background biru
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
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
                    "Edit Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),

            // --- AREA FORM KONTEN ---
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Column(
                  children: [
                    // --- FOTO PROFIL ---
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Center(
                        child: Icon(Icons.person, size: 55, color: primaryColor),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Ubah Foto",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // --- FORM INPUT ---
                    _buildEditField("Nama lengkap", _namaController),
                    const SizedBox(height: 20),
                    _buildEditField("Email", _emailController),
                    const SizedBox(height: 20),
                    _buildEditField("Nomor Telepon", _phoneController, isNumber: true),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // --- TOMBOL SIMPAN ---
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
              child: ElevatedButton(
                onPressed: _isSaving || _isLoading ? null : _simpanPerubahan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: _isSaving 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text(
                  "Simpan perubahan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
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

  // Widget Helper Form Input persis seperti aslinya
  Widget _buildEditField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
          style: const TextStyle(
            color: Color(0xFF4D55CC),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            suffixIcon: const Icon(Icons.edit, color: Color(0xFF4D55CC), size: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}