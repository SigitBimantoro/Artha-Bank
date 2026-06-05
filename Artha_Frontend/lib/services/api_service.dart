import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Ingat: Ganti IP ini jika IP WiFi laptopmu berubah!
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
  // 1. AUTHENTICATION & PROFILE
  // ==========================================
  static Future<Map<String, dynamic>> register({required String nama, required String email, required String phoneNumber, required String password}) async {
    final response = await http.post(Uri.parse('$baseUrl/register'), headers: {"Content-Type": "application/json"}, body: jsonEncode({"nama": nama, "email": email, "phone_number": phoneNumber, "password": password}));
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> verifyOTP({required String email, required String kodeOTP}) async {
    final response = await http.post(Uri.parse('$baseUrl/verify-otp'), headers: {"Content-Type": "application/json"}, body: jsonEncode({"email": email, "kode": kodeOTP}));
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> login({required String phoneNumber, required String password}) async {
    final response = await http.post(Uri.parse('$baseUrl/login'), headers: {"Content-Type": "application/json"}, body: jsonEncode({"phone_number": phoneNumber, "password": password}));
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> resendOTP({required String email}) async {
    final response = await http.post(Uri.parse('$baseUrl/resend-otp'), headers: {"Content-Type": "application/json"}, body: jsonEncode({"email": email}));
    return _processResponse(response);
  }

  // 👇 INI DIA FUNGSI YANG HILANG (LUPA KATA SANDI) 👇
  static Future<Map<String, dynamic>> requestForgotPassword({required String email}) async {
    final response = await http.post(Uri.parse('$baseUrl/forgot-password'), headers: {"Content-Type": "application/json"}, body: jsonEncode({"email": email}));
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> resetPassword({required String email, required String otp, required String newPassword}) async {
    final response = await http.post(Uri.parse('$baseUrl/reset-password'), headers: {"Content-Type": "application/json"}, body: jsonEncode({"email": email, "otp": otp, "new_password": newPassword}));
    return _processResponse(response);
  }
  // 👆 ========================================= 👆

  static Future<Map<String, dynamic>> getProfile() async {
    final headers = await getAuthHeaders();
    final response = await http.get(Uri.parse('$baseUrl/profile'), headers: headers);
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> updateProfile({String? nama, String? email, String? phoneNumber}) async {
    final headers = await getAuthHeaders();
    headers['Content-Type'] = 'application/x-www-form-urlencoded';
    Map<String, String> body = {};
    if (nama != null) body['nama'] = nama;
    if (email != null) body['email'] = email;
    if (phoneNumber != null) body['phone_number'] = phoneNumber;

    final response = await http.put(Uri.parse('$baseUrl/profile'), headers: headers, body: body);
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> logoutProcess() async {
    final headers = await getAuthHeaders();
    try {
      final response = await http.post(Uri.parse('$baseUrl/logout'), headers: headers);
      await clearLocalToken();
      return _processResponse(response);
    } catch (e) {
      await clearLocalToken();
      return {"success": false, "message": "Koneksi terputus, sesi lokal diakhiri."};
    }
  }

  // ==========================================
  // 2. KEAMANAN & PIN
  // ==========================================
  static Future<Map<String, dynamic>> setPin({required String pin}) async {
    final headers = await getAuthHeaders();
    final response = await http.post(Uri.parse('$baseUrl/set-pin'), headers: headers, body: jsonEncode({"pin": pin}));
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> verifyPassword({required String password}) async {
    final headers = await getAuthHeaders();
    final response = await http.post(Uri.parse('$baseUrl/verify-password'), headers: headers, body: jsonEncode({"password": password}));
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> changePin({required String password, required String newPin, required String confirmNewPin}) async {
    final headers = await getAuthHeaders();
    final response = await http.post(Uri.parse('$baseUrl/change-pin'), headers: headers, body: jsonEncode({"password": password, "new_pin": newPin, "confirm_new_pin": confirmNewPin}));
    return _processResponse(response);
  }

  // ==========================================
  // 3. TRANSAKSI (TRANSFER & PEMBAYARAN)
  // ==========================================
  static Future<Map<String, dynamic>> beliPulsa({required String phoneNumber, required double amount, required String pin}) async {
    final headers = await getAuthHeaders();
    headers['X-PIN'] = pin; 
    final response = await http.post(Uri.parse('$baseUrl/payment/pulsa'), headers: headers, body: jsonEncode({"phone_number": phoneNumber, "amount": amount}));
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> transferUang({required String receiverPhone, required double amount, required String pin, String notes = ""}) async {
    final headers = await getAuthHeaders();
    headers['X-PIN'] = pin; 
    final response = await http.post(Uri.parse('$baseUrl/transfer'), headers: headers, body: jsonEncode({"receiver_phone": receiverPhone, "amount": amount, "notes": notes}));
    return _processResponse(response);
  }

  // ==========================================
  // 4. HISTORY & TRACKING
  // ==========================================
  static Future<Map<String, dynamic>> getHistory({int limit = 0}) async {
    final headers = await getAuthHeaders();
    String url = '$baseUrl/history';
    if (limit > 0) url += '?limit=$limit';
    final response = await http.get(Uri.parse(url), headers: headers);
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> getTrackingKeuangan(String period) async {
    final headers = await getAuthHeaders();
    final response = await http.get(Uri.parse('$baseUrl/history/summary?period=$period'), headers: headers);
    return _processResponse(response);
  }

  // ==========================================
  // 5. TABUNGAN IMPIAN (SAVINGS)
  // ==========================================
  static Future<Map<String, dynamic>> getSavings() async {
    final headers = await getAuthHeaders();
    final response = await http.get(Uri.parse('$baseUrl/savings'), headers: headers);
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> createSaving({required String namaTarget, required double targetNominal, double? autoDebitNominal, String? autoDebitPeriode}) async {
    final headers = await getAuthHeaders();
    final response = await http.post(Uri.parse('$baseUrl/savings'), headers: headers, body: jsonEncode({"nama_target": namaTarget, "target_nominal": targetNominal, "auto_debit_nominal": autoDebitNominal ?? 0, "auto_debit_periode": autoDebitPeriode ?? "NONE"}));
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> addSaldoTabungan(int savingId, double amount) async {
    final headers = await getAuthHeaders();
    final response = await http.post(Uri.parse('$baseUrl/savings/$savingId/add'), headers: headers, body: jsonEncode({"amount": amount}));
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> tarikSaldoTabungan(int savingId, double amount) async {
    final headers = await getAuthHeaders();
    final response = await http.post(Uri.parse('$baseUrl/savings/$savingId/withdraw'), headers: headers, body: jsonEncode({"amount": amount}));
    return _processResponse(response);
  }

  // ==========================================
  // 6. FAVORIT (KONTAK TRANSFER)
  // ==========================================
  static Future<Map<String, dynamic>> getFavorites() async {
    final headers = await getAuthHeaders();
    final response = await http.get(Uri.parse('$baseUrl/favorites'), headers: headers);
    return _processResponse(response);
  }

  // HELPER RESPONSE
  static Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {"success": true, "data": jsonDecode(response.body)};
    } else {
      final errorData = jsonDecode(response.body);
      return {"success": false, "message": errorData['error'] ?? 'Terjadi kesalahan sistem'};
    }
  }
}