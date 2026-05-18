import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Ganti IP ini sesuai dengan IPv4 laptop kamu (pastikan HP/Emulator satu WiFi)
  static const String baseUrl = 'http://192.168.18.79:8080/api';

  // ==========================================
  // MANAJEMEN JWT TOKEN LOKAL & HEADER
  // ==========================================

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Fungsi ini otomatis menyisipkan Token JWT ke header.
  // Gunakan untuk endpoint protected seperti topup, transfer, dan logout.
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // Menghapus token dari memori HP
  static Future<void> clearLocalToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // ==========================================
  // ENDPOINT AUTHENTICATION
  // ==========================================

  static Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nama": nama,
        "email": email,
        "phone_number": phoneNumber,
        "password": password,
      }),
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> verifyOTP({
    required String email,
    required String kodeOTP,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-otp'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "kode": kodeOTP}),
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> login({
    required String phoneNumber,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phone_number": phoneNumber, "password": password}),
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> resendOTP({required String email}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/resend-otp'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );
    return _processResponse(response);
  }

  // Fungsi Hit API Logout ke Backend (Ubah status REVOKED di DB Golang)
  static Future<Map<String, dynamic>> logoutProcess() async {
    final headers = await getAuthHeaders();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: headers,
      );
      // Hapus token lokal agar user tetap keluar dari aplikasi,
      // terlepas dari apakah koneksi internet berhasil memanggil API atau tidak.
      await clearLocalToken();
      return _processResponse(response);
    } catch (e) {
      await clearLocalToken();
      return {
        "success": false,
        "message": "Koneksi terputus, sesi lokal diakhiri.",
      };
    }
  }

  // ==========================================
  // HELPER UNTUK MEMPROSES RESPONSE
  // ==========================================
  static Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Backend return data sukses
      return {"success": true, "data": jsonDecode(response.body)};
    } else {
      // Backend return gin.H{"error": "..."}
      final errorData = jsonDecode(response.body);
      return {
        "success": false,
        "message": errorData['error'] ?? 'Terjadi kesalahan sistem',
      };
    }
  }
}
