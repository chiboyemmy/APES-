import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

/// Handles SMS OTP authentication with Firebase Cloud Functions
class TSMSAuth extends GetxController {
  static TSMSAuth get instance => Get.isRegistered() ? Get.find() : Get.put(TSMSAuth());

  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Sends OTP to specified phone number
  ///
  /// [phoneNumber] must be in E.164 format (+[country code][number])
  /// Throws [FirebaseAuthException] on failure
  Future<void> sendOtp({ required String phoneNumber, String? msg}) async {
    try {
      // Validate input format
      if (phoneNumber.isEmpty || !phoneNumber.startsWith('+')) {
        throw FirebaseAuthException(
          code: 'invalid-phone',
          message: 'Invalid phone number format. Must start with country code',
        );
      }

      // Call Cloud Function
      final response = await _functions.httpsCallable('sendOtp').call({'phoneNumber': phoneNumber, 'msg': msg});

      // Handle response
      if (response.data['success'] != true) {
        throw FirebaseAuthException(
          code: response.data['code'] ?? 'send-failed',
          message: response.data['message'] ?? 'Failed to send OTP',
        );
      }
    } on FirebaseFunctionsException catch (e) {
      throw _parseFunctionError(e);
    } catch (e) {
      throw FirebaseAuthException(
        code: 'unknown-error',
        message: 'Failed to send OTP',
      );
    }
  }

  /// Verifies OTP code and authenticates user
  ///
  /// Returns [Token] on success
  /// Throws [FirebaseAuthException] on failure
  Future<String> verifyOtp({required String phone, required String otp}) async {
    try {
      // Validate input
      if (phone.isEmpty || !phone.startsWith('+')) {
        throw FirebaseAuthException(
          code: 'invalid-phone',
          message: 'Invalid phone number format',
        );
      }

      if (otp.isEmpty || otp.length != 6) {
        throw FirebaseAuthException(
          code: 'invalid-code',
          message: 'OTP code must be 6 digits',
        );
      }

      // Call verification function
      final response = await _functions.httpsCallable('verifyOtp').call({'phoneNumber': phone.trim(), 'otp': otp.trim()});

      // Handle response
      if (response.data['success'] != true) {
        throw FirebaseAuthException(
          code: response.data['code'] ?? 'verification-failed',
          message: response.data['message'] ?? 'OTP verification failed',
        );
      }

      // Extract token and authenticate
      final token = response.data['token'] as String;
      return token;
    } on FirebaseFunctionsException catch (e) {
      throw _parseFunctionError(e);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'authentication-failed',
        message: 'Failed to authenticate user',
      );
    }
  }

  /// Parses Firebase Functions errors into auth exceptions
  FirebaseAuthException _parseFunctionError(FirebaseFunctionsException e) {
    final details = e.details is Map ? e.details as Map : {};
    return FirebaseAuthException(
      code: e.code,
      message: details['message']?.toString() ?? e.message ?? 'Authentication service error',
    );
  }
}
