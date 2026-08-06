import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:event_pro/data/remote/api_value.dart';
import 'package:event_pro/data/local/contants.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/data/local/shared_pref_helper.dart';

class GetUserData {
  GetUserData();
  Future<dynamic> getUserDetails() async {
    try {
      if (constant.userType == constant.exhibitorUser) {
        dynamic responseExhibitorProfile =
            await apiValue.getExhibitorProfile(null);

        if (responseExhibitorProfile != null) {
          dynamic responseExhibitorDetails = await apiValue.getExhibitorDetails(
              null, responseExhibitorProfile["exhibitorId"]);

          SharedPreferencesHelper.setUserName(
              name: responseExhibitorProfile["name"] ?? '');
          SharedPreferencesHelper.setUserCountryCode(
              countrycode: responseExhibitorProfile["country_code"] ?? '');
          SharedPreferencesHelper.setUserPhone(
              phone: responseExhibitorProfile["mobile"] ?? '');
          SharedPreferencesHelper.setUserEmail(
              email: responseExhibitorProfile["email"] ?? '');
          SharedPreferencesHelper.setExpectedDate(
              exDate: responseExhibitorProfile["expectedDate"] ?? '');
          SharedPreferencesHelper.setQrCode(
              code: responseExhibitorProfile['qrCode'] ?? '');
          SharedPreferencesHelper.setOfficeNumber(
              number: responseExhibitorProfile['officeNo'] ?? '');
          SharedPreferencesHelper.setImageLink(
              link: responseExhibitorProfile['imageLink'] ?? '');
          SharedPreferencesHelper.setCircularImageLink(
              circularLink: responseExhibitorProfile['iconLink'] ?? '');
          SharedPreferencesHelper.setExhibitorCategory(
              cat: responseExhibitorDetails['category'] ?? '');
          SharedPreferencesHelper.setExhibitorCompanyName(
              company: responseExhibitorDetails['name'] ?? '');
          SharedPreferencesHelper.setExhibitorCompanyImage(
              img: responseExhibitorDetails['imageLink'] ?? '');

          constant.nameValue =
              await capitalizeWords(responseExhibitorProfile['name'] ?? '');
          constant.countryCodeValue =
              responseExhibitorProfile['country_code'] ?? '';
          constant.phoneValue = responseExhibitorProfile['mobile'] ?? '';
          constant.emailValue = responseExhibitorProfile['email'] ?? '';
          constant.expectedDateValue =
              responseExhibitorProfile['expectedDate'] ?? '';
          constant.qrCodeValue = responseExhibitorProfile['qrCode'] ?? '';
          constant.imageLinkValue = responseExhibitorProfile['imageLink'] ?? '';
          constant.circularImageLinkValue =
              responseExhibitorProfile['iconLink'] ?? '';
          constant.officeNumber = responseExhibitorProfile['officeNo'] ?? '';
          constant.exhibitorCategory =
              responseExhibitorDetails['category'] ?? '';
          constant.exhibitorCompanyName =
              responseExhibitorDetails['name'] ?? '';
          constant.exhibitorCompanyImage =
              responseExhibitorDetails['imageLink'] ?? '';

          print('id          - ${SharedPreferencesHelper.getUserId()}');
          print(constant.userId);
          print('userType    - ${SharedPreferencesHelper.getUserType()}');
          print(constant.userType);
          print('usertoken   - ${SharedPreferencesHelper.getUserToken()}');
          print(constant.userToken);
          print('name        - ${SharedPreferencesHelper.getUserName()}');
          print(constant.nameValue);
          print('email       - ${SharedPreferencesHelper.getUserEmail()}');
          print(constant.emailValue);
          print(
              'Country Code       - ${SharedPreferencesHelper.getUserCountryCode()}');
          print(constant.countryCodeValue);
          print('mobile       - ${SharedPreferencesHelper.getUserPhone()}');
          print(constant.phoneValue);
          print('date        - ${SharedPreferencesHelper.getExpectedDate()}');
          print(constant.expectedDateValue);
          print('qrcode      - ${SharedPreferencesHelper.getQrCode()}');
          print(constant.qrCodeValue);
          print('image       - ${SharedPreferencesHelper.getImageLink()}');
          print(constant.imageLinkValue);
          print('officenumber- ${SharedPreferencesHelper.getOfficeNumber()}');
          print(constant.officeNumber);
          print(
              'exhibitorCat- ${SharedPreferencesHelper.getExhibitorCategory()}');
          print(constant.exhibitorCategory);
          print(
              'exhibitorComp- ${SharedPreferencesHelper.getExhibitorCompanyName()}');
          print(constant.exhibitorCompanyName);
          print(
              'exhibitorCompImage- ${SharedPreferencesHelper.getExhibitorCompanyImage()}');
          print(constant.exhibitorCompanyImage);
          print('isfirsttime - ${SharedPreferencesHelper.getIsFirstTime()}');
          print('isloggedin  - ${SharedPreferencesHelper.getIsLoggedIn()}');
        } else {
          showToast('Something went wrong plzz login again');
        }
      } else {
        dynamic response = await apiValue.getUserDetails();
        if (response != null) {
          SharedPreferencesHelper.setUserName(name: response["name"] ?? '');
          SharedPreferencesHelper.setUserCountryCode(
              countrycode: response["country_code"] ?? '');
          SharedPreferencesHelper.setUserPhone(phone: response["mobile"] ?? '');
          SharedPreferencesHelper.setUserEmail(email: response["email"] ?? '');
          SharedPreferencesHelper.setUserWeddingRole(
              weddingRole: response["weddingRole"] ?? '');
          SharedPreferencesHelper.setUserAddress(
              address: response['address'] ?? '');
          SharedPreferencesHelper.setUserBudget(
              budget: response["estimated_budget"] ?? '');
          SharedPreferencesHelper.setExpectedDate(
              exDate: response["expectedDate"] ?? '');
          SharedPreferencesHelper.setQrCode(code: response['qrCode'] ?? '');
          SharedPreferencesHelper.setImageLink(
              link: response['imageLink'] ?? '');
          SharedPreferencesHelper.setDestination(
              dest: response['destination'] ?? '');
          SharedPreferencesHelper.setVenue(venue: response['venue'] ?? '');
          SharedPreferencesHelper.setShowQrCode(
              codes: response['showQR'] ?? []);
          if (response["ticketArr"] != null && response["ticketArr"] is List) {
            SharedPreferencesHelper.setUserTickets(
                tickets: response["ticketArr"]);
          }

          constant.nameValue = await capitalizeWords(response['name'] ?? '');
          constant.countryCodeValue = response['country_code'] ?? '';
          constant.phoneValue = response['mobile'] ?? '';
          constant.emailValue = response['email'] ?? '';
          constant.weddingRoleValue = response['weddingRole'] ?? '';
          constant.addressValue = response['address'] ?? '';
          constant.budgetValue = response['estimated_budget'] ?? '';
          constant.expectedDateValue = response['expectedDate'] ?? '';
          constant.qrCodeValue = response['qrCode'] ?? '';
          constant.imageLinkValue = response['imageLink'] ?? '';
          constant.destinationValue = response['destination'] ?? '';
          constant.venueValue = response['venue'] ?? '';
          
          constant.ticketArr = response['ticketArr'] ?? [];

          print('id          - ${SharedPreferencesHelper.getUserId()}');
          print(constant.userId);
          print('userType    - ${SharedPreferencesHelper.getUserType()}');
          print(constant.userType);
          print('usertoken   - ${SharedPreferencesHelper.getUserToken()}');
          print(constant.userToken);
          print('name        - ${SharedPreferencesHelper.getUserName()}');
          print(constant.nameValue);
          print('email       - ${SharedPreferencesHelper.getUserEmail()}');
          print(constant.emailValue);
          print(
              'Country Code       - ${SharedPreferencesHelper.getUserCountryCode()}');
          print(constant.countryCodeValue);
          print('mobile       - ${SharedPreferencesHelper.getUserPhone()}');
          print(constant.phoneValue);
          print(
              'weddingrole - ${SharedPreferencesHelper.getUserWeddingRole()}');
          print(constant.weddingRoleValue);
          print('address     -  ${SharedPreferencesHelper.getUserAddress()}');
          print(constant.addressValue);
          print('budget      - ${SharedPreferencesHelper.getUserBudget()}');
          print(constant.budgetValue);
          print('date        - ${SharedPreferencesHelper.getExpectedDate()}');
          print(constant.expectedDateValue);
          print('qrcode      - ${SharedPreferencesHelper.getQrCode()}');
          print(constant.qrCodeValue);
          print('image       - ${SharedPreferencesHelper.getImageLink()}');
          print(constant.imageLinkValue);
          print('destination - ${SharedPreferencesHelper.getDestination()}');
          print(constant.destinationValue);
          print('venue       - ${SharedPreferencesHelper.getVenue()}');
          print(constant.venueValue);
          print('isfirsttime - ${SharedPreferencesHelper.getIsFirstTime()}');
          print('isloggedin  - ${SharedPreferencesHelper.getIsLoggedIn()}');

          print(
              'ticketArr - ${SharedPreferencesHelper.getUserTickets().join(", ")}');
          print(constant.ticketArr.join(", "));
        } else {
          showToast('Something went wrong plzz login again');
        }
      }
      // ignore: deprecated_member_use
    } on DioError catch (e) {
      log(e.toString());
      print(e.toString());
    }
  }
}
