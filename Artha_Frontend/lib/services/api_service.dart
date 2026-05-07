import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.18.7:8080/api';
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
      body: jsonEncode({
        "email": email,
        "kode": kodeOTP,
      }),
    );
    return _processResponse(response);
  }
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );
    return _processResponse(response);
  }
  static Future<Map<String, dynamic>> resendOTP({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/resend-otp'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
      }),
    );
    return _processResponse(response);
  }
  static Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {"success": true, "data": jsonDecode(response.body)};
    } else {
      final errorData = jsonDecode(response.body);
      return {"success": false, "message": errorData['error'] ?? 'Terjadi kesalahan sistem'};
    }
  }
}