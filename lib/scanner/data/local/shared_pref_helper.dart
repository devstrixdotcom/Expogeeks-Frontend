import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages

class SharedPreferencesHelper {
  static final SharedPreferencesHelper _instance =
      SharedPreferencesHelper._ctor();

  static const String keyPrefix = 'scanner_';

  static String userId = 'scanner_userId';
  static String userToken = 'scanner_userToken';
  static String userPhone = 'scanner_userPhone';
  static String userType = 'scanner_userType';
  static String userName = 'scanner_userName';
  static String userEmail = 'scanner_userEmail';
  static String userWeddingRole = 'scanner_userWeddingRole';
  static String userAddress = 'scanner_userAddress';
  static String userBudget = 'scanner_userBudget';
  static String expectedDate = 'scanner_expectedDate';
  static String qrCode = 'scanner_qrCode';
  static String officeNumber = 'scanner_officeNumber';
  static String exhibitorCategory = 'scanner_exhibitorCategory';
  static String exhibitorCompanyName = 'scanner_exhibitorCompanyName';
  static String exhibitorCompanyImage = 'scanner_exhibitorCompanyImage';
  static String imageLink = 'scanner_imageLink';
  static String circularImageLink = 'scanner_circularImageLink';
  static String destination = 'scanner_destination';
  static String venue = 'scanner_venue';
  static String isFirstTime = 'scanner_isFirstTime';
  static String isLoggedIn = 'scanner_isLoggedIn';

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
    _prefs.setString(venue, venue);
  }

  static String getVenue() {
    return _prefs.getString(venue) ?? "";
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
  /// Staff (scanner) data lives in the same SharedPreferences store as the
  /// visitor/exhibitor app, so only wipe our own `scanner_` keys here.
  static void clearShareCache() {
    for (final key in _prefs.getKeys().toList()) {
      if (key.startsWith(keyPrefix)) _prefs.remove(key);
    }
  }
}
