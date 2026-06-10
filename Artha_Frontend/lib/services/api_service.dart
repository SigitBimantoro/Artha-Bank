import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Gunakan 10.0.2.2 untuk emulator Android, atau IP fisik jika pakai HP
  static const String serverUrl = 'http://192.168.0.105:8080';
  static const String baseUrl = 'http://192.168.0.105:8080/api';

  static String resolveMediaUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$serverUrl$normalizedPath';
  }

  // ======================================================================
  // HELPER: TOKEN & HEADERS
  // ======================================================================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _getHeaders({String? pin}) async {
    final token = await getToken();
    Map<String, String> headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (pin != null && pin.isNotEmpty) {
      headers['X-PIN'] = pin;
    }
    return headers;
  }

  static Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final body = jsonEncode({
        "nama": nama,
        "email": email,
        "phone_number": phoneNumber,
        "password": password,
      });
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final body = jsonEncode({
        "phone_number": phoneNumber,
        "password": password,
      });
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      final resData = _processResponse(response);
      if (resData['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', resData['data']['token']);
      }
      return resData;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getUserByPhone(String phoneNumber) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/users/by-phone/$phoneNumber'),
        headers: headers,
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Dipanggil dari otp_page.dart sebagai ApiService.verifyOTP(...)
  static Future<Map<String, dynamic>> verifyOTP({
    required String email,
    required String kodeOTP,
  }) async {
    try {
      final body = jsonEncode({"email": email, "kode": kodeOTP});
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Dipanggil dari otp_page.dart sebagai ApiService.resendOTP(...)
  static Future<Map<String, dynamic>> resendOTP({required String email}) async {
    try {
      final body = jsonEncode({"email": email});
      final response = await http.post(
        Uri.parse('$baseUrl/resend-otp'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> logoutProcess() async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: headers,
      );
      final resData = _processResponse(response);
      if (resData['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
      }
      return resData;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> requestForgotPassword({
    required String email,
  }) async {
    try {
      final body = jsonEncode({"email": email});
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final body = jsonEncode({
        "email": email,
        "otp": otp,
        "new_password": newPassword,
      });
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ======================================================================
  // 2. PIN MANAGEMENT
  // POST /api/set-pin          (protected)
  // POST /api/verify-password  (protected)
  // POST /api/change-pin       (protected)
  // ======================================================================

  static Future<Map<String, dynamic>> setPin(String pin) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({"pin": pin});
      final response = await http.post(
        Uri.parse('$baseUrl/set-pin'),
        headers: headers,
        body: body,
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> verifyPassword(String password) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({"password": password});
      final response = await http.post(
        Uri.parse('$baseUrl/verify-password'),
        headers: headers,
        body: body,
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> changePin(
    String password,
    String newPin,
    String confirmNewPin,
  ) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        "password": password,
        "new_pin": newPin,
        "confirm_new_pin": confirmNewPin,
      });
      final response = await http.post(
        Uri.parse('$baseUrl/change-pin'),
        headers: headers,
        body: body,
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        "current_password": currentPassword,
        "new_password": newPassword,
        "confirm_new_password": confirmNewPassword,
      });
      final response = await http.post(
        Uri.parse('$baseUrl/change-password'),
        headers: headers,
        body: body,
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ======================================================================
  // 3. PROFILE
  // GET /api/profile  (protected)
  // PUT /api/profile  (protected, multipart/form-data)
  // ======================================================================

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: headers,
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// [photoPath] opsional — isi jika user mengganti foto profil
  static Future<Map<String, dynamic>> updateProfile({
    required String nama,
    required String email,
    required String phoneNumber,
    String? photoPath,
  }) async {
    try {
      final token = await getToken();
      // Backend: PUT /api/profile dengan multipart/form-data
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/profile'),
      );
      request.headers['Authorization'] = 'Bearer $token';

      if (nama.isNotEmpty) request.fields['nama'] = nama;
      if (email.isNotEmpty) request.fields['email'] = email;
      if (phoneNumber.isNotEmpty) request.fields['phone_number'] = phoneNumber;
      if (photoPath != null && photoPath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('photo', photoPath),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ======================================================================
  // 4. TRANSAKSI FINANSIAL
  // POST /api/topup                     (protected, TANPA PIN)
  // POST /api/transfer                  (protected + X-PIN)
  // POST /api/payment/pulsa             (protected + X-PIN)
  // POST /api/payment/pln               (protected + X-PIN)
  // ======================================================================

  static Future<Map<String, dynamic>> topUpInternal(
    double amount,
    String metode,
  ) async {
    // Catatan: /api/topup tidak memakai middleware CekPIN
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({"amount": amount, "metode": metode});
      final response = await http.post(
        Uri.parse('$baseUrl/topup'),
        headers: headers,
        body: body,
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> transferUang(
    String receiverPhone,
    double amount,
    String notes,
    String pin,
  ) async {
    try {
      final headers = await _getHeaders(pin: pin);
      print('[DEBUG] Transfer headers: $headers');
      print('[DEBUG] Transfer pin length: ${pin.length}');
      final body = jsonEncode({
        "receiver_phone": receiverPhone,
        "amount": amount,
        "notes": notes,
      });
      print('[DEBUG] Transfer request body: $body');
      final response = await http.post(
        Uri.parse('$baseUrl/transfer'),
        headers: headers,
        body: body,
      );
      return _processResponse(response);
    } catch (e) {
      print('[DEBUG] Transfer error: $e');
      print('[DEBUG] Error type: ${e.runtimeType}');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> beliPulsa(
    String phone,
    double amount,
    String pin,
  ) async {
    try {
      final headers = await _getHeaders(pin: pin);
      final body = jsonEncode({"phone_number": phone, "amount": amount});
      final response = await http.post(
        Uri.parse('$baseUrl/payment/pulsa'),
        headers: headers,
        body: body,
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> beliTokenListrik(
    String meter,
    double amount,
    String pin,
  ) async {
    try {
      final headers = await _getHeaders(pin: pin);
      final body = jsonEncode({"meter_number": meter, "amount": amount});
      final response = await http.post(
        Uri.parse('$baseUrl/payment/pln'),
        headers: headers,
        body: body,
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ======================================================================
  // 5. HISTORY & TRACKING
  // GET /api/history                       (protected)
  // GET /api/history/transfer              (protected)
  // GET /api/history/summary?period=...    (protected)
  // ======================================================================

  static Future<Map<String, dynamic>> getHistory({int limit = 0}) async {
    try {
      final headers = await _getHeaders();
      String url = '$baseUrl/history';
      if (limit > 0) url += '?limit=$limit';
      final response = await http.get(Uri.parse(url), headers: headers);
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getRiwayatTransferKeluar({
    int limit = 0,
  }) async {
    try {
      final headers = await _getHeaders();
      String url = '$baseUrl/history/transfer';
      if (limit > 0) url += '?limit=$limit';
      final response = await http.get(Uri.parse(url), headers: headers);
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// [period] : "weekly" | "monthly" | "yearly"
  static Future<Map<String, dynamic>> getTrackingKeuangan(String period) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/history/summary?period=$period'),
        headers: headers,
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ======================================================================
  // 6. TABUNGAN (SAVINGS)
  // GET    /api/savings              (protected)
  // POST   /api/savings              (protected)
  // PUT    /api/savings/:id          (protected)
  // POST   /api/savings/:id/add      (protected)
  // POST   /api/savings/:id/withdraw (protected)
  // ======================================================================

  static Future<Map<String, dynamic>> getSavings() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/savings'),
        headers: headers,
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> createSaving({
    required String namaTarget,
    required double targetNominal,
    double autoDebitNominal = 0,
    String autoDebitPeriode = 'NONE',
  }) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        "nama_target": namaTarget,
        "target_nominal": targetNominal,
        "auto_debit_nominal": autoDebitNominal,
        "auto_debit_periode": autoDebitPeriode,
      });
      final response = await http.post(
        Uri.parse('$baseUrl/savings'),
        headers: headers,
        body: body,
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateSaving(
    int id,
    String namaTarget,
    double targetNominal,
  ) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        "nama_target": namaTarget,
        "target_nominal": targetNominal,
      });
      final response = await http.put(
        Uri.parse('$baseUrl/savings/$id'),
        headers: headers,
        body: body,
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateSavingAutoDebit({
    required int id,
    required double autoDebitNominal,
    required String autoDebitPeriode,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        "auto_debit_nominal": autoDebitNominal,
        "auto_debit_periode": autoDebitPeriode,
      });
      final response = await http.put(
        Uri.parse('$baseUrl/savings/$id/auto-debit'),
        headers: headers,
        body: body,
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> addSaldoTabungan(
    int id,
    double amount,
  ) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({"amount": amount});
      final response = await http.post(
        Uri.parse('$baseUrl/savings/$id/add'),
        headers: headers,
        body: body,
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Backend: POST /api/savings/:id/withdraw  (BUKAN /tarik)
  static Future<Map<String, dynamic>> tarikSaldoTabungan(
    int id,
    double amount,
  ) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({"amount": amount});
      final response = await http.post(
        Uri.parse('$baseUrl/savings/$id/withdraw'),
        headers: headers,
        body: body,
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deleteSaving(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/savings/$id'),
        headers: headers,
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ======================================================================
  // 7. KONTAK FAVORIT
  // GET    /api/favorites       (protected)
  // POST   /api/favorites       (protected)
  // DELETE /api/favorites/:id   (protected)
  // ======================================================================

  static Future<Map<String, dynamic>> getFavorites() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/favorites'),
        headers: headers,
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> createFavorite(
    String phone,
    String label,
  ) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({"recipient_phone": phone, "label": label});
      final response = await http.post(
        Uri.parse('$baseUrl/favorites'),
        headers: headers,
        body: body,
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deleteFavorite(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/favorites/$id'),
        headers: headers,
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ======================================================================
  // HELPER: PROSES RESPONSE DARI BACKEND
  // ======================================================================
  static Map<String, dynamic> _processResponse(http.Response response) {
    try {
      print('[DEBUG] Response status code: ${response.statusCode}');
      print('[DEBUG] Response body: ${response.body}');
      final decoded = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': decoded};
      } else {
        return {
          'success': false,
          'message': decoded['error'] ?? 'Terjadi kesalahan pada server',
        };
      }
    } catch (e) {
      print('[DEBUG] Response processing error: $e');
      return {
        'success': false,
        'message': response.body.isNotEmpty
            ? response.body
            : 'Gagal memproses data dari server',
      };
    }
  }

  static Future<List<int>> downloadPDFReport(String period) async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/history/summary/pdf?period=$period'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return response.bodyBytes; // HARUS bodyBytes (B kapital)
    } else {
      throw Exception('Failed to load PDF');
    }
  }
}
