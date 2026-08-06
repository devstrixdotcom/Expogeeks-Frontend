import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages

class SharedPreferencesHelper {
  static final SharedPreferencesHelper _instance =
      SharedPreferencesHelper._ctor();

  static String userId = 'userId';
  static String userToken = 'userToken';
  static String userCountryCode = 'countryCode';
  static String userPhone = 'userPhone';
  static String userType = 'userType';
  static String userName = 'userName';
  static String userEmail = 'userEmail';
  static String userWeddingRole = 'userWeddingRole';
  static String userAddress = 'userAddress';
  static String userBudget = 'userBudget';
  static String expectedDate = 'expectedDate';
  static String qrCode = 'qrCode';
  static String officeNumber = 'officeNumber';
  static String exhibitorCategory = 'exhibitorCategory';
  static String exhibitorCompanyName = 'exhibitorCompanyName';
  static String exhibitorCompanyImage = 'exhibitorCompanyImage';
  static String imageLink = 'imageLink';
  static String circularImageLink = 'circularImageLink';
  static String destination = 'destination';
  static String uservenue = 'venue';
  static String isFirstTime = 'isFirstTime';
  static String isLoggedIn = 'isLoggedIn';
  static String showQrCode = 'showQrCode';
  static String userTickets = 'userTickets';

  factory SharedPreferencesHelper() {
    return _instance;
  }

  SharedPreferencesHelper._ctor();
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

//---------------------------------------------------------------

  static void setUserId({required String id}) {
    _prefs.setString(userId, id);
  }

  static String getUserId() {
    return _prefs.getString(userId) ?? "";
  }

  //---------------------------------------------------------------

  static void setUserToken({required String token}) {
    _prefs.setString(userToken, token);
  }

  static String getUserToken() {
    return _prefs.getString(userToken) ?? "";
  }

  //-------------------------------------------------------------

  static void setUserType({required String type}) {
    _prefs.setString(userType, type);
  }

  static String getUserType() {
    return _prefs.getString(userType) ?? "";
  }

  //-------------------------------------------------------------

  static void setUserName({required String name}) {
    _prefs.setString(userName, name);
  }

  static String getUserName() {
    return _prefs.getString(userName) ?? "";
  }

  //-------------------------------------------------------------

  static void setUserEmail({required String email}) {
    _prefs.setString(userEmail, email);
  }

  static String getUserEmail() {
    return _prefs.getString(userEmail) ?? "";
  }

  // -------------------------------------------------------------

  // static void setUserCountryCode({required String countrycode}) {
  //   debugPrint("SET countrycode: $countrycode");
  //   _prefs.setString(userCountryCode, countrycode);
  // }

  // static String getUserCountryCode() {
  //   debugPrint("GET countrycode: ${_prefs.getString(userCountryCode)}");
  //   return _prefs.getString(userCountryCode) ?? "";
  // }
  static void setUserCountryCode({required String countrycode}) {
    _prefs.setString(userCountryCode, countrycode);
  }

  static String getUserCountryCode() {
    return _prefs.getString(userCountryCode) ?? "";
  }

  //-------------------------------------------------------------

  static void setUserPhone({required String phone}) {
    _prefs.setString(userPhone, phone);
  }

  static String getUserPhone() {
    return _prefs.getString(userPhone) ?? "";
  }

  //-------------------------------------------------------------

  static void setUserWeddingRole({required String weddingRole}) {
    _prefs.setString(userWeddingRole, weddingRole);
  }

  static String getUserWeddingRole() {
    return _prefs.getString(userWeddingRole) ?? "";
  }

  //-------------------------------------------------------------

  static void setUserAddress({required String address}) {
    _prefs.setString(userAddress, address);
  }

  static String getUserAddress() {
    return _prefs.getString(userAddress) ?? "";
  }

  //-------------------------------------------------------------

  static void setUserBudget({required String budget}) {
    _prefs.setString(userBudget, budget);
  }

  static String getUserBudget() {
    return _prefs.getString(userBudget) ?? "";
  }

  //-------------------------------------------------------------

  static void setExpectedDate({required String exDate}) {
    _prefs.setString(expectedDate, exDate);
  }

  static String getExpectedDate() {
    return _prefs.getString(expectedDate) ?? "";
  }

  //-------------------------------------------------------------

  static void setQrCode({required String code}) {
    _prefs.setString(qrCode, code);
  }

  static String getQrCode() {
    return _prefs.getString(qrCode) ?? "";
  }

  //-------------------------------------------------------------

  static void setOfficeNumber({required String number}) {
    _prefs.setString(officeNumber, number);
  }

  static String getOfficeNumber() {
    return _prefs.getString(officeNumber) ?? "";
  }

  //-------------------------------------------------------------

  static void setExhibitorCategory({required String cat}) {
    _prefs.setString(exhibitorCategory, cat);
  }

  static String getExhibitorCategory() {
    return _prefs.getString(exhibitorCategory) ?? "";
  }

  //-------------------------------------------------------------

  static void setExhibitorCompanyName({required String company}) {
    _prefs.setString(exhibitorCompanyName, company);
  }

  static String getExhibitorCompanyName() {
    return _prefs.getString(exhibitorCompanyName) ?? "";
  }

  //-------------------------------------------------------------

  static void setExhibitorCompanyImage({required String img}) {
    _prefs.setString(exhibitorCompanyImage, img);
  }

  static String getExhibitorCompanyImage() {
    return _prefs.getString(exhibitorCompanyImage) ?? "";
  }

  //-------------------------------------------------------------

  static void setImageLink({required String link}) {
    _prefs.setString(imageLink, link);
  }

  static String getImageLink() {
    return _prefs.getString(imageLink) ?? "";
  }

  //-------------------------------------------------------------

  static void setCircularImageLink({required String circularLink}) {
    _prefs.setString(circularImageLink, circularLink);
  }

  static String getCircularImageLink() {
    return _prefs.getString(circularImageLink) ?? "";
  }

  //-------------------------------------------------------------

  static void setDestination({required String dest}) {
    _prefs.setString(destination, dest);
  }

  static String getDestination() {
    return _prefs.getString(destination) ?? "";
  }

  //-------------------------------------------------------------

  static void setVenue({required String venue}) {
    _prefs.setString(uservenue, venue);
  }

  static String getVenue() {
    return _prefs.getString(uservenue) ?? "";
  }

  //-------------------------------------------------------------------

  static void setIsFirstTime({required bool firstTime}) {
    _prefs.setBool(isFirstTime, firstTime);
  }

  static bool getIsFirstTime() {
    return _prefs.getBool(isFirstTime) ?? true;
  }

  //-------------------------------------------------------------------

  static void setIsLoggedIn({required bool loggedIn}) {
    _prefs.setBool(isLoggedIn, loggedIn);
  }

  static bool getIsLoggedIn() {
    return _prefs.getBool(isLoggedIn) ?? false;
  }

  //-------------------------------------------------------------------
  //-------------------------------------------------------------------
  static void setShowQrCode({required List<dynamic> codes}) {
    // Convert each item to string explicitly
    final stringList = codes.map((e) => e.toString()).toList();
    _prefs.setStringList(showQrCode, stringList);
  }

  static List<String> getShowQrCode() {
    return _prefs.getStringList(showQrCode) ?? [];
  }

//-------------------------------------------------------------------
  static void setUserTickets({required List<dynamic> tickets}) {
    final ticketsJson = jsonEncode(tickets);
    _prefs.setString(userTickets, ticketsJson);
  }

  static List<dynamic> getUserTickets() {
    final ticketsJson = _prefs.getString(userTickets) ?? '[]';
    return jsonDecode(ticketsJson);
  }
  //-------------------------------------------------------------------
  //-------------------------------------------------------------------

  //-------------------------------------------------------------------
  static void clearShareCache() {
    _prefs.clear();
  }
}
