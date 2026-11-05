// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:event_pro/scanner/data/local/contants.dart';
import 'package:event_pro/scanner/utils/helper_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class APIvalue {
  // Timeouts so a request can never hang forever. Without these an unreachable
  // or slow backend leaves the call pending indefinitely, which on the login
  // screen keeps `isButtonloading` true and the spinner turning for good.
  // Android is far more prone to this than iOS: it will happily sit on a
  // half-open socket (captive portals, flaky mobile data, carrier NAT) where
  // iOS gives up quickly on its own.
  Dio dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    sendTimeout: const Duration(seconds: 20),
  ));

  static List<String> url = [
    'http://192.168.18.9:8000/api/', // local LAN backend (XAMPP / php -S :8000)
    'https://www.expogeeks.co.uk/api/', // live server (web root = /var/www/html, no /demo/)
  ];

  // 0 = local backend, 1 = live server.
  //
  // Only ever consulted in debug/profile. A release build ALWAYS uses the live
  // server (see `_baseUrl`): shipping a release APK that was compiled while
  // this was flipped to 0 points the app at a developer LAN address that no
  // real device can reach, and every request dies instantly — which the login
  // screen used to report as "Invalid username or password".
  static int isbeta = 1;

  static String get _baseUrl => kReleaseMode ? url[1] : url[isbeta];

  //-------------------------------eventspro_scanner api urls -----------------------------------//
  String organizerLoginURL = "${_baseUrl}OrganizerLogin.php";
  String getOrganizerExhibitionListURL =
      "${_baseUrl}GetOrganizerExhibitionList.php";
  String getExhibitionAttendanceListURL =
      "${_baseUrl}GetExhibitionAttendanceList.php";
  String updateExhibitionAttendanceURL =
      "${_baseUrl}UpdateExhibitionAttendance.php";

  //------------------------------------ LOGIN -------------------------------//

  Future<dynamic> organizerLogin(
      String username, String password, BuildContext context) async {
    try {
      dynamic payload = {
        'username': username,
        'password': password,
      };

      Response response = await dio.post(
        organizerLoginURL,
        data: jsonEncode(payload),
      );

      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $organizerLoginURL\nPayload : $payload\nresponse ${response.data}");

      // The endpoint currently replies with `text/html`, so Dio hands back a
      // String. Never assume that: if the server (or a proxy/CDN in front of
      // it) ever sends `application/json`, Dio decodes it for us and calling
      // jsonDecode on the resulting Map throws — which the old catch-all
      // swallowed into a bare `null`, i.e. "Invalid username or password".
      final Map<String, dynamic> body = _asJsonMap(response.data);

      // Always hand the parsed body back, success or not, so the caller can
      // show the server's own message instead of guessing at bad credentials.
      return body;
    } on DioException catch (e) {
      debugPrint("Login DioException: ${e.type} ${e.message}\n"
          "response: ${e.response?.statusCode} ${e.response?.data}");

      // A transport failure is not a credentials failure — say so, otherwise
      // every dropped connection reads as "Invalid username or password".
      final Map<String, dynamic>? body =
          e.response == null ? null : _asJsonMap(e.response!.data);
      if (body != null && body.isNotEmpty) return body;

      return <String, dynamic>{
        'status': 'false',
        'networkError': true,
        'message': _networkMessage(e),
      };
    } catch (e) {
      debugPrint("Login error: ${e.toString()}");
      return <String, dynamic>{
        'status': 'false',
        'networkError': true,
        'message': 'Something went wrong. Please try again.',
      };
    }
  }

  /// Decodes a Dio response body that may arrive either already-decoded (when
  /// the content type is JSON) or as a raw String (when it is not).
  Map<String, dynamic> _asJsonMap(dynamic data) {
    try {
      if (data is Map) return Map<String, dynamic>.from(data);
      if (data is String && data.trim().isNotEmpty) {
        final decoded = jsonDecode(data);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      }
    } catch (e) {
      debugPrint("Unparseable response body: $data ($e)");
    }
    return <String, dynamic>{};
  }

  String _networkMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The server took too long to respond. Check your connection and try again.';
      case DioExceptionType.connectionError:
        return 'Cannot reach the server. Check your internet connection.';
      case DioExceptionType.badCertificate:
        return 'Secure connection failed. Check the date & time on your device.';
      default:
        return 'Network error. Please try again.';
    }
  }

  //------------------------------------ GetOrganizerExhibitionList ----------//

  Future<dynamic> getOrganizerExhibitionList(
      BuildContext context, String type) async {
    try {
      dynamic payload = {'userLoginToken': constant.userToken};
      Response response = await dio.post(getOrganizerExhibitionListURL,
          data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $getOrganizerExhibitionListURL\nPayload : $payload\nresponse ${response.data}");
      var data1 = response.data;
      if (response.statusCode == 200) {
        return jsonDecode(data1);
      } else if (response.statusCode == 401) {
        showInvalidTokenDialog(context);
      } else {
        showStatusFalse(context);
        return null;
      }
    } catch (e) {
      if (e is DioError) {
        if (e.response?.statusCode == 401) {
          showInvalidTokenDialog(context);
          debugPrint(e.response?.data);
        }
      }
      debugPrint(e.toString());
      return null;
    }
  }

//------------------------------------ fetchExhibitionAttendanceList ---------//

  Future<dynamic> getExhibitionAttendanceList(
      BuildContext context, String exhibitionId) async {
    try {
      dynamic payload = {
        'userLoginToken': constant.userToken,
        'exhibitionId': exhibitionId,
      };

      debugPrint("URL : $getExhibitionAttendanceListURL\nPayload : $payload\n");

      Response response = await dio.post(
        getExhibitionAttendanceListURL,
        data: jsonEncode(payload),
      );

      debugPrint(
          "response.statusCode : ${response.statusCode}\nresponse : ${response.data}");

      var data1 = response.data;
      if (response.statusCode == 200) {
        return jsonDecode(data1);
      } else if (response.statusCode == 401) {
        showInvalidTokenDialog(context);
      } else {
        showStatusFalse(context);
        return null;
      }
    } catch (e) {
      if (e is DioError) {
        if (e.response?.statusCode == 401) {
          showInvalidTokenDialog(context);
          debugPrint(e.response?.data);
        }
      }
      debugPrint(e.toString());
      return null;
    }
  }

  //------------------------------------ SCAN --------------------------------//

  Future<dynamic> updateExhibitionAttendance(
      BuildContext context, String exhibitionId, String txnId) async {
    try {
      dynamic payload = {
        'userLoginToken': constant.userToken,
        'exhibitionId': exhibitionId,
        'txnId': txnId,
      };
      debugPrint(
          "\nURL : $updateExhibitionAttendanceURL\nPayload : $payload\n");

      Response response = await dio.post(updateExhibitionAttendanceURL,
          data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $updateExhibitionAttendanceURL\nPayload : $payload\nresponse ${response.data}");

      // Check if the response is a String, then decode it to a Map
      var data1 = response.data;
      if (data1 is String) {
        // If the response is a String, parse it into a Map
        data1 = jsonDecode(data1);
      }

      if (data1 is Map<String, dynamic>) {
        if (data1['status'] == 'true') {
          // Handle success response
          debugPrint(data1['message']);
          return data1;
        } else if (data1['status'] == 'false') {
          // Handle success response
          debugPrint(data1['message']);
          return data1;
        } else {
          // Handle failure response (status is not true)
          showStatusFalse(context);
          debugPrint("Failure: ${data1['message']}");
          return null;
        }
      } else {
        // If the response is not a Map, handle accordingly
        debugPrint("Invalid response format: $data1");
        showStatusFalse(context);
        return null;
      }
    } catch (e) {
      if (e is DioError) {
        if (e.response?.statusCode == 401) {
          showInvalidTokenDialog(context);
          debugPrint(e.response?.data);
        }
      }
      debugPrint(e.toString());
      return null;
    }
  }
}

APIvalue apiValue = APIvalue();
