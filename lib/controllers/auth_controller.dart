import 'dart:convert';
 
import 'package:http/http.dart' as http;
 
 
class AuthController {
 
  // Store the session cookie for webview SSO
  static String? sessionCookie;
 
  final String _baseUrl = 'https://classicdigitallibraries.com/public/api';
 
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String captcha = '',
  }) async {
    final Uri url = Uri.parse('$_baseUrl/login');
 
    final Map<String, dynamic> requestBody = {
      'email_username': email,
      'password': password,
      'g-recaptcha-response': captcha,  
    };
 
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
 
      final responseData = jsonDecode(response.body);
 
      // Capture the session cookie from the response headers
      final rawCookie = response.headers['set-cookie'];
      if (rawCookie != null) {
        final match = RegExp(r'(laravel_session|sessionid)=([^;]+)').firstMatch(rawCookie);
        if (match != null) {
          sessionCookie = match.group(0);
        }
      }
 
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Something went wrong: $e',
      };
    }
  }
}

