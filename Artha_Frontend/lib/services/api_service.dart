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

  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

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

  static Future<Map<String, dynamic>> logoutProcess() async {
    final headers = await getAuthHeaders();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: headers,
      );
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
  // ENDPOINT LUPA KATA SANDI (VIA EMAIL)
  // ==========================================

  static Future<Map<String, dynamic>> requestForgotPassword({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forgot-password'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-password'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "otp": otp,
        "new_password": newPassword,
      }),
    );
    return _processResponse(response);
  }

  // ==========================================
  // ENDPOINT KEAMANAN PIN
  // ==========================================
  
  static Future<Map<String, dynamic>> setPin({required String pin}) async {
    final headers = await getAuthHeaders();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/set-pin'),
        headers: headers,
        body: jsonEncode({"pin": pin}),
      );
      return _processResponse(response);
    } catch (e) {
      return {
        "success": false,
        "message": "Gagal terhubung ke server",
      };
    }
  }

  // ==========================================
  // ENDPOINT TRANSAKSI / PEMBAYARAN
  // ==========================================

  static Future<Map<String, dynamic>> beliPulsa({
    required String phoneNumber,
    required double amount,
    required String pin,
  }) async {
    final headers = await getAuthHeaders();
    headers['X-PIN'] = pin; 

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payment/pulsa'),
        headers: headers,
        body: jsonEncode({
          "phone_number": phoneNumber,
          "amount": amount,
        }),
      );
      return _processResponse(response);
    } catch (e) {
      return {
        "success": false,
        "message": "Gagal terhubung ke server",
      };
    }
  }

  // ==========================================
  // ENDPOINT PROFILE
  // ==========================================
  
  static Future<Map<String, dynamic>> getProfile() async {
    final headers = await getAuthHeaders();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: headers,
      );
      return _processResponse(response);
    } catch (e) {
      return {
        "success": false,
        "message": "Gagal terhubung ke server",
      };
    }
  }

  // ==========================================
  // HELPER UNTUK MEMPROSES RESPONSE
  // ==========================================
  static Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {"success": true, "data": jsonDecode(response.body)};
    } else {
      final errorData = jsonDecode(response.body);
      return {
        "success": false,
        "message": errorData['error'] ?? 'Terjadi kesalahan sistem',
      };
    }
  }
}