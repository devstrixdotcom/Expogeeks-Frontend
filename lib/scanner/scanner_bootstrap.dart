import 'package:event_pro/scanner/data/local/contants.dart';
import 'package:event_pro/scanner/data/local/shared_pref_helper.dart';
import 'package:event_pro/scanner/utils/helper_functions.dart';

/// Loads the staff (scanner) session into memory. This is the part of the old
/// Expogeeks-Scanner `main()` that restored the saved login.
///
/// Returns true if a staff member is currently logged in.
Future<bool> initScannerSession() async {
  await SharedPreferencesHelper.init();

  constant.userType = SharedPreferencesHelper.getUserType();
  constant.phoneValue = SharedPreferencesHelper.getUserPhone();
  constant.userId = SharedPreferencesHelper.getUserId();
  constant.userToken = SharedPreferencesHelper.getUserToken();
  constant.nameValue = capitalizeWords(SharedPreferencesHelper.getUserName());
  constant.emailValue = SharedPreferencesHelper.getUserEmail();

  return SharedPreferencesHelper.getIsLoggedIn();
}
