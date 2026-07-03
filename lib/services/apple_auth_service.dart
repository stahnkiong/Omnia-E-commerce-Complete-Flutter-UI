import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleAuthService {
  final Dio _dio = Dio();

  /// Performs the Apple Sign-In flow:
  /// 1. Prompts the native iOS Apple Sign-In sheet.
  /// 2. Extracts identity token and user names.
  /// 3. Sends them to the custom Medusa endpoint.
  /// 4. Stores the returned token into Hive for persistence.
  Future<String?> signInWithApple() async {
    try {
      // 1. Invoke native iOS authorization layer
      final AuthorizationCredentialAppleID credential = 
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // 2. Token Extraction
      final String? identityToken = credential.identityToken;
      if (identityToken == null) {
        throw Exception("Apple Sign-In failed: identityToken is null");
      }

      final String? firstName = credential.givenName;
      final String? lastName = credential.familyName;

      log("Apple Sign-In: Native authentication successful. Identity token obtained.");

      // 3. Outbound Network Bridge
      final response = await _dio.post(
        'https://api.omniafoodsupply.shop/store/auth/apple',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'identityToken': identityToken,
          'firstName': firstName,
          'lastName': lastName,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> responseData = 
            response.data is String ? jsonDecode(response.data) : response.data;
        
        // 4. Session State Persistence (Hive)
        final String? token = responseData['access_token'] ?? responseData['token'];
        if (token == null || token.isEmpty) {
          throw Exception("Authentication response did not contain a valid session token");
        }

        // Open local Hive box dedicated to session variables and save
        final Box sessionBox = await Hive.openBox('session_variables');
        await sessionBox.put('access_token', token);

        log("Apple Sign-In: Session token saved to Hive successfully.");
        return token;
      } else {
        throw Exception(
          "Medusa backend returned status code ${response.statusCode}: ${response.statusMessage}"
        );
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      // 5. Graceful Failures: Catch and silence user cancellations
      if (e.code == AuthorizationErrorCode.canceled) {
        log("Apple Sign-In: User canceled the authentication process.");
        return null;
      }
      log("❌ Apple Sign-In Authorization Exception: ${e.message} (Code: ${e.code})");
      rethrow;
    } on DioException catch (e) {
      log("❌ Apple Sign-In Network Error: ${e.message}");
      if (e.response != null) {
        log("Response body: ${e.response?.data}");
      }
      rethrow;
    } catch (e, stackTrace) {
      log("❌ Unexpected error during Apple Sign-In: $e");
      log("Stack trace: $stackTrace");
      rethrow;
    }
  }
}
