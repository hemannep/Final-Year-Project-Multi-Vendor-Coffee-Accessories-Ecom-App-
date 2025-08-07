import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silverskin/constant.dart';


class ForgetPassController {
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Make HTTP POST request
      var response = await http.post(
        Uri(
          scheme: "http",
          host: ipAddress, 
          path: "/silverskin-api/auth/forgetPassword.php",
        ),
        body: {
          'email': email,
        },
      );

      // Decode the response
      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['success']) {
          // Handle successful password reset
          return {
            'success': true,
            'message': data['message'],
          };
        } else {
          // Handle failure response
          return {
            'success': false,
            'message': data['message'],
          };
        }
      } else {
        // Handle server error
        return {
          'success': false,
          'message': "Server error! Please try again later.",
        };
      }
    } catch (error) {
      // Handle network or parsing errors
      return {
        'success': false,
        'message': "An error occurred: ${error.toString()}",
      };
    }
  }
}
