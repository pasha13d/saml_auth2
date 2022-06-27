import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth0_id_token.dart';

typedef AsyncCallback = Future<String> Function();

class _LoginInfo extends ChangeNotifier {
  var _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  set isLoggedIn(bool value) {
    _isLoggedIn = value;
    notifyListeners();
  }
}

@immutable
class AuthService {
  static final AuthService instance = AuthService._internal();

  factory AuthService() {
    return instance;
  }

  AuthService._internal();

  final _loginInfo = _LoginInfo();
  get loginInfo => _loginInfo;

  String? accessToken;
  Auth0IdToken? auth0IdToken;

  final appAuth = FlutterAppAuth();
  final secureStorage = FlutterSecureStorage();

  static const AUTH0_DOMAIN = "Your domain";
  static const AUTH0_CLIENT_ID = "Your client Id";
  static const AUTH0_ISSUER = 'https://$AUTH0_DOMAIN';
  static const BUNDLE_IDENTIFIER = 'com.example.oktasamlnew';
  static const AUTH0_REDIRECT_URI = '$BUNDLE_IDENTIFIER://login-callback';
  static const REFRESH_TOKEN = 'refresh_token';

  Future<String> init() async {
    return errorHandler(() async {
      final securedRefreshToken = await secureStorage.read(key: REFRESH_TOKEN);

      print('securedRefreshToken $securedRefreshToken');
      /// for first time login
      if(securedRefreshToken == null) {
        return 'You need to login!';
      }

      final response = await appAuth.token(
        TokenRequest(
          AUTH0_CLIENT_ID,
          AUTH0_REDIRECT_URI,
          issuer: AUTH0_ISSUER,
          refreshToken: securedRefreshToken,
        ),
      );

      return await _setLocalVariables(response);
    });
  }

  isAuthResultValid(TokenResponse? responce) {
    return responce?.idToken != null && responce?.idToken != null;
  }
  
  Future<String> _setLocalVariables(TokenResponse? result) async {
    if(isAuthResultValid(result)) {
      accessToken = result!.accessToken;
      auth0IdToken = parseIdToken(result.idToken!);
      print('result.idToken1 $auth0IdToken');

      if(result.refreshToken != null) {
        await secureStorage.write(
          key: REFRESH_TOKEN,
          value: result.refreshToken
        );
      }

      _loginInfo.isLoggedIn = true;
      return 'Success';
    }
    return 'Passing Token went wrong';
  }

  Future<String> errorHandler(AsyncCallback callback) async {
    try {
      return await callback();
    } on TimeoutException catch(e) {
      return e.message ?? 'Timeout Error!';
    } on FormatException catch(e) {
      return e.message;
    } on SocketException catch(e) {
      return e.message;
    } on PlatformException catch(e) {
      return e.message ?? 'Something is Wrong! Code ${e.code}';
    } catch(e) {
      return 'Unknown error ${e.runtimeType}';
    }
  }

  Future<String> login() async {
   return errorHandler(() async {
     // _loginInfo.isLoggedIn = true;
     final authorizationTokenRequest = AuthorizationTokenRequest(
       AUTH0_CLIENT_ID,
       AUTH0_REDIRECT_URI,
       issuer: AUTH0_ISSUER,
       scopes: ['openid', 'profile', 'email', 'offline_access', 'api'],
     );
     print('authorizationTokenRequest $authorizationTokenRequest');
     final result =
     await appAuth.authorizeAndExchangeCode(authorizationTokenRequest);

     print('result ${result}');
     print('idToken ${result?.idToken}');

     return _setLocalVariables(result);
   });
  }

  /// parse id token
  Auth0IdToken parseIdToken(String idToken) {
    final parts = idToken.split(r'.');

    final Map<String, dynamic> json = jsonDecode(
      utf8.decode(
        base64Url.decode(
          base64Url.normalize(parts[1]),
        ),
      ),
    );

    return Auth0IdToken.fromJson(json);
  }

  logout() {
    _loginInfo.isLoggedIn = false;
  }
}
