// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:event_pro/data/local/contants.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/exhibitor_team_list_model.dart';

class APIvalue {
  // Timeouts so a request can never hang forever. Without these, an unreachable
  // backend leaves calls pending indefinitely, which (e.g. on the login screen)
  // keeps `isOtpLoading` true and the Send OTP button permanently disabled.
  Dio dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    sendTimeout: const Duration(seconds: 20),
  ));

  // [0] = local backend (physical phone -> PC LAN IP, port 8000)
  // [1] = live backend (AWS EC2)
  static List<String> url = [
    'http://192.168.18.9:8000/api/',
    'https://www.expogeeks.co.uk/api/',
  ];

  // 1 = use live backend, 0 = use local LAN backend
  static int isbeta = 1;

  //-------------------------------api urls-----------------------------------//

  // auth
  String sendOTPURL = "${url[isbeta]}SendOTP.php";
  String loginURL = "${url[isbeta]}Login.php";
  String getUserDetailsURL = "${url[isbeta]}GetUserDetails.php";

  // organization
  String getOrganizersListURL = "${url[isbeta]}GetOrganizersList.php";
  String getOrganizerDetailsURL = "${url[isbeta]}GetOrganizerDetails.php";
  String getOrganizerFloorPlansURL = "${url[isbeta]}GetOrganizerFloorPlans.php";
  String getOrganizerCategoryListURL =
      "${url[isbeta]}GetOrganizerCategoryList.php";
  String getCategoryShowListURL = "${url[isbeta]}GetCategoryShowList.php";
  String getCategoryDetailsURL = "${url[isbeta]}GetCategoryDetails.php";

  // exhibitor
  String getOrganizerExhibitorListURL =
      "${url[isbeta]}GetOrganizerExhibitorList.php";
  String getExhibitorDetailsURL = "${url[isbeta]}GetExhibitorDetails.php";
  String getExhibitorOfferListURL = "${url[isbeta]}GetExhibitorOfferList.php";
  String getExhibitorTeamListURL = "${url[isbeta]}GetExhibitorTeamList.php";
  String addExhibitorFavouriteURL = "${url[isbeta]}AddExhibitorFavourite.php";
  String removeExhibitorFavouriteURL =
      "${url[isbeta]}RemoveExhibitorFavourite.php";

  // profile
  String getExhibitorProfileURL = "${url[isbeta]}GetExhibitorProfile.php";
  String getTeamMemberExhibitionList =
      "${url[isbeta]}GetTeamMemberExhibitionList.php";
  String editExhibitorProfileURL = "${url[isbeta]}EditExhibitorProfile.php";
  String editExhibitorProfileImageURL =
      "${url[isbeta]}EditExhibitorProfileImage.php";
  String editVisitorProfileImageURL =
      "${url[isbeta]}EditVisitorProfileImage.php";
  String editVisitorProfileURL = "${url[isbeta]}EditVisitorProfile.php";

  //feedback
  String submitExhibitorFeedbackURL =
      "${url[isbeta]}SubmitExhibitorFeedback.php";
  String submitVisitorFeedbackURL = "${url[isbeta]}SubmitVisitorFeedback.php";
  String getExhibitorFeedbackURL = "${url[isbeta]}GetExhibitorFeedback.php";
  String getVisitorFeedbackURL = "${url[isbeta]}GetVisitorFeedback.php";
  // Exhibitor login exhibitor check visitors feedback details
  String getExhibitorVisitorFeedbackURL =
      "${url[isbeta]}GetExhibitorVisitorFeedback.php";

  // scan
  String scanExhibitorURL = "${url[isbeta]}ScanExhibitor.php";
  String scanVisitorURL = "${url[isbeta]}ScanVisitor.php";

  // meeting
  String GetUserMeetingListURL = "${url[isbeta]}GetUserMeetingList.php";
  String GetVisitorCalendarDetailsURL =
      "${url[isbeta]}GetVisitorCalendarDetails.php";
  String getMeetingRequestListURL = "${url[isbeta]}GetMeetingRequestList.php";
  String updateMeetingStatusURL = "${url[isbeta]}UpdateMeetingStatus.php";
  String submitExhibitorMeetingRequestURL =
      "${url[isbeta]}SubmitExhibitorMeetingRequest.php";

  // menu
  String getFavouriteCategoryListURL =
      "${url[isbeta]}GetFavouriteCategoryList.php";
  String getFavouriteExhibitorListURL =
      "${url[isbeta]}GetFavouriteExhibitorList.php";
  String getScannedCategoryListURL = "${url[isbeta]}GetScannedCategoryList.php";
  String getUserNotificationListURL =
      "${url[isbeta]}GetUserNotificationList.php";
  String getScannedExhibitorListURL =
      "${url[isbeta]}GetScannedExhibitorList.php";
  String getScannedVisitorListURL = "${url[isbeta]}GetScannedVisitorList.php";

  String getTeamMemberDetailsURL = "${url[isbeta]}GetTeamMemberDetails.php";

  // String getExhibibtorFeedbackURL = "${url[isbeta]}GetExhibibtorFeedback.php";
  // String getExhibitorCategoryListURL = "${url[isbeta]}GetExhibitorCategoryList.php";
  // String UpdateTeamMemberSlotURL = "${url[isbeta]}UpdateTeamMemberSlot.php";

  //------------------------------------  Send otp -------------------------------------//

  Future<dynamic> sendOTP(String mobile, BuildContext context) async {
    try {
      dynamic payload = {'mobile': mobile};
      Response response = await dio.post(sendOTPURL, data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $sendOTPURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ login phone --------------------------------------//

  // Future<dynamic> loginOTP(String mobile, BuildContext context) async {
  //   try {
  //     dynamic payload = {'mobile': mobile};
  //     Response response = await dio.post(loginURL, data: jsonEncode(payload));
  //     debugPrint("response.statusCode : ${response.statusCode}\nURL : $loginURL\nPayload : $payload\nresponse ${response.data}");
  //     var data1 = response.data;
  //     if (response.statusCode == 200) {
  //       return jsonDecode(data1);
  //     } else if (response.statusCode == 401) {
  //       showInvalidTokenDialog(context);
  //     } else {
  //       showStatusFalse(context);
  //       return null;
  //     }
  //   } catch (e) {
  //     if (e is DioError) {
  //       if (e.response?.statusCode == 401) {
  //         showInvalidTokenDialog(context);
  //         debugPrint(e.response?.data);
  //       }
  //     }
  //     debugPrint(e.toString());
  //     return null;
  //   }
  // }

  //------------------------------------ login email --------------------------------------//

  Future<dynamic> loginOTP(String email, BuildContext context) async {
    try {
      dynamic payload = {'email': email};
      Response response = await dio.post(loginURL, data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $loginURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ user details --------------------------------------//

  Future<dynamic> getUserDetails() async {
    try {
      dynamic payload = {'userLoginToken': constant.userToken};
      debugPrint("URL : $getUserDetailsURL\nPayload : $payload");

      Response response =
          await dio.post(getUserDetailsURL, data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $getUserDetailsURL\nPayload : $payload\nresponse ${response.data}");
      var data1 = response.data;
      if (response.statusCode == 200) {
        return jsonDecode(data1);
      } else if (response.statusCode == 401) {
        // showInvalidTokenDialog(context);
      } else {
        // showStatusFalse(context);
        return null;
      }
    } catch (e) {
      if (e is DioError) {
        if (e.response?.statusCode == 401) {
          // showInvalidTokenDialog(context);
          debugPrint(e.response?.data);
        }
      }
      debugPrint(e.toString());
      return null;
    }
  }

  //------------------------------------ Organizers List --------------------------------------//

  Future<dynamic> getOrganizersList(BuildContext context, String type) async {
    try {
      dynamic payload = {
        'userLoginToken': constant.userToken,
        if (type != '') 'type': type
      };
      Response response =
          await dio.post(getOrganizersListURL, data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $getOrganizersListURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ Organizers detail --------------------------------------//

  Future<dynamic> getOrganizerDetails(BuildContext context, String id) async {
    try {
      dynamic payload = {
        'userLoginToken': constant.userToken,
        "organizerId": id
      };
      Response response =
          await dio.post(getOrganizerDetailsURL, data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $getOrganizerDetailsURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ floor plan --------------------------------------//

  Future<dynamic> getOrganizerFloorPlans(
      BuildContext context, String id) async {
    try {
      dynamic payload = {
        'userLoginToken': constant.userToken,
        "organizerId": id
      };
      Response response =
          await dio.post(getOrganizerFloorPlansURL, data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $getOrganizerFloorPlansURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ Organizers category list --------------------------------------//

  Future<dynamic> getOrganizerCategoryList(
      BuildContext context, String id) async {
    try {
      dynamic payload = {
        'userLoginToken': constant.userToken,
        "organizerId": id
      };
      Response response = await dio.post(getOrganizerCategoryListURL,
          data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $getOrganizerCategoryListURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ category show list --------------------------------------//

  Future<dynamic> GetCategoryShowList(BuildContext context, String id) async {
    try {
      dynamic payload = {
        'userLoginToken': constant.userToken,
        "categoryId": id
      };
      Response response =
          await dio.post(getCategoryShowListURL, data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $getCategoryShowListURL\nPayload : $payload\nresponse ${response.data}");
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
  //------------------------------------ category Details for video --------------------------------------//
  Future<dynamic> GetCategoryDetails(BuildContext context, String id) async {
    try {
      dynamic payload = {
        'userLoginToken': constant.userToken,
        "categoryId": id
      };
      Response response =
          await dio.post(getCategoryDetailsURL, data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $getCategoryDetailsURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ exhibitor list --------------------------------------//

  Future<dynamic> getOrganizerExhibitorList(
      BuildContext context, String id, String catId) async {
    try {
      dynamic payload = {
        'userLoginToken': constant.userToken,
        "organizerId": id,
        if (catId != '' && catId != 'null') "category_id": catId,
      };
      Response response = await dio.post(getOrganizerExhibitorListURL,
          data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $getOrganizerExhibitorListURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ Exhibitor Category List --------------------------------------//

  // Future<dynamic> getExhibitorCategoryList(BuildContext context, String id) async {
  //   try {
  //     dynamic payload = {'userLoginToken': constant.userToken, "organizerId": id};
  //     Response response = await dio.post(getExhibitorCategoryListURL, data: jsonEncode(payload));
  //     debugPrint("response.statusCode : ${response.statusCode}\nURL : $getExhibitorCategoryListURL\nPayload : $payload\nresponse ${response.data}");
  //     var data1 = response.data;
  //     if (response.statusCode == 200) {
  //       return jsonDecode(data1);
  //     } else if (response.statusCode == 401) {
  //       showInvalidTokenDialog(context);
  //     } else {
  //       showStatusFalse(context);
  //       return null;
  //     }
  //   } catch (e) {
  //     if (e is DioError) {
  //       if (e.response?.statusCode == 401) {
  //         showInvalidTokenDialog(context);
  //         debugPrint(e.response?.data);
  //       }
  //     }
  //     debugPrint(e.toString());
  //     return null;
  //   }
  // }

  //------------------------------------ exhibitor details --------------------------------------//

  Future<dynamic> getExhibitorDetails(context, String id) async {
    try {
      dynamic payload = {
        'userLoginToken': constant.userToken,
        "exhibitorId": id
      };
      Response response =
          await dio.post(getExhibitorDetailsURL, data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $getExhibitorDetailsURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ offers list --------------------------------------//

  Future<dynamic> getExhibitorOfferList(BuildContext context, String id) async {
    try {
      dynamic payload = {
        'userLoginToken': constant.userToken,
        "exhibitorId": id
      };
      Response response =
          await dio.post(getExhibitorOfferListURL, data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $getExhibitorOfferListURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ Exhibitor Team List --------------------------------------//

  Future<dynamic> getExhibitorTeamList(BuildContext context, String id) async {
    try {
      dynamic payload = {
        'userLoginToken': constant.userToken,
        "exhibitorId": id
      };
      Response response =
          await dio.post(getExhibitorTeamListURL, data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $getExhibitorTeamListURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ Exhibitor profile --------------------------------------//

  // Future<dynamic> getExhibitorProfile(context, {String? exhibitionId}) async {
  //   try {
  //     dynamic payload = {'userLoginToken': constant.userToken};
  //     Response response =
  //         await dio.post(getExhibitorProfileURL, data: jsonEncode(payload));
  //     debugPrint(
  //         "response.statusCode : ${response.statusCode}\nURL : $getExhibitorProfileURL\nPayload : $payload\nresponse ${response.data}");
  //     var data1 = response.data;
  //     if (response.statusCode == 200) {
  //       return jsonDecode(data1);
  //     } else if (response.statusCode == 401) {
  //       showInvalidTokenDialog(context);
  //     } else {
  //       showStatusFalse(context);
  //       return null;
  //     }
  //   } catch (e) {
  //     if (e is DioError) {
  //       if (e.response?.statusCode == 401) {
  //         showInvalidTokenDialog(context);
  //         debugPrint(e.response?.data);
  //       }
  //     }
  //     debugPrint(e.toString());
  //     return null;
  //   }
  // }

  Future<dynamic> getExhibitorProfile(context, {String? exhibitionId}) async {
    try {
      dynamic payload = {
        'userLoginToken': constant.userToken,
        if (exhibitionId != null)
          'exhibitionId': exhibitionId, // Add exhibitionId to payload
      };
      Response response =
          await dio.post(getExhibitorProfileURL, data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $getExhibitorProfileURL\nPayload : $payload\nresponse ${response.data}");
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

  // getTeamMemberExhibitionlist remains unchanged
  Future<dynamic> getTeamMemberExhibitionlist(context) async {
    try {
      dynamic payload = {'userLoginToken': constant.userToken};
      Response response = await dio.post(getTeamMemberExhibitionList,
          data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $getTeamMemberExhibitionList\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ Team Member Details --------------------------------------//

  Future<dynamic> getTeamMemberDetails(context, String id) async {
    try {
      dynamic payload = {'userLoginToken': constant.userToken, 'teamId': id};
      Response response =
          await dio.post(getTeamMemberDetailsURL, data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $getTeamMemberDetailsURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ Favourite Category List --------------------------------------//

  Future<dynamic> getFavouriteCategoryList(BuildContext context) async {
    try {
      dynamic payload = {'userLoginToken': constant.userToken};
      Response response = await dio.post(getFavouriteCategoryListURL,
          data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $getFavouriteCategoryListURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ Favourite Exhibitor List --------------------------------------//

  Future<dynamic> getFavouriteExhibitorList(
      BuildContext context, String categoryId) async {
    try {
      dynamic payload = {
        'userLoginToken': constant.userToken,
        'categoryId': categoryId
      };
      Response response = await dio.post(getFavouriteExhibitorListURL,
          data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $getFavouriteExhibitorListURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ Scanned Category List --------------------------------------//

  Future<dynamic> getScannedCategoryList(BuildContext context) async {
    try {
      dynamic payload = {'userLoginToken': constant.userToken};
      Response response =
          await dio.post(getScannedCategoryListURL, data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $getScannedCategoryListURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ Scanned Exhibitor List --------------------------------------//

  Future<dynamic> getScannedExhibitorList(
      BuildContext context, String categoryId) async {
    try {
      dynamic payload = {
        'userLoginToken': constant.userToken,
        'categoryId': categoryId
      };
      Response response =
          await dio.post(getScannedExhibitorListURL, data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $getScannedExhibitorListURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ Scanned Category List --------------------------------------//

  Future<dynamic> getUserNotificationList(BuildContext context) async {
    try {
      dynamic payload = {'userLoginToken': constant.userToken};
      Response response =
          await dio.post(getUserNotificationListURL, data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $getUserNotificationListURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ user meeting List --------------------------------------//

  Future<dynamic> GetUserMeetingList(BuildContext context) async {
    try {
      dynamic payload = {'userLoginToken': constant.userToken};
      Response response =
          await dio.post(GetUserMeetingListURL, data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $GetUserMeetingListURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ user Calendar meeting List --------------------------------------//
  Future<dynamic> GetVisitorCalendarDetails(BuildContext context) async {
    try {
      dynamic payload = {'userLoginToken': constant.userToken};
      Response response = await dio.post(GetVisitorCalendarDetailsURL,
          data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $GetVisitorCalendarDetailsURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ submit Exhibitor Meeting Request --------------------------------------//

  Future<dynamic> submitExhibitorMeetingRequest(
    BuildContext context,
    String exhibitorId,
    String teamId,
    String date,
    String time,
    String message,
  ) async {
    try {
      dynamic payload = {
        'userLoginToken': constant.userToken,
        "exhibitorId": exhibitorId,
        "teamId": teamId,
        "dateSlot": date,
        "timeSlot": time,
        "message": message
      };
      Response response = await dio.post(submitExhibitorMeetingRequestURL,
          data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $submitExhibitorMeetingRequestURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ update Team Member Slot --------------------------------------//

  // Future<dynamic> updateTeamMemberSlot(BuildContext context, String teamId, String status, String date, String time) async {
  //   try {
  //     dynamic payload = {
  //       'userLoginToken': constant.userToken,
  //       "teamId": teamId,
  //       "date_slot[0]": [date],
  //       "time_slot_Y_m_d[0]": [time]
  //     };
  //     Response response = await dio.post(UpdateTeamMemberSlotURL, data: jsonEncode(payload));
  //     debugPrint("response.statusCode : ${response.statusCode}\nURL : $UpdateTeamMemberSlotURL\nPayload : $payload\nresponse ${response.data}");
  //     var data1 = response.data;
  //     if (response.statusCode == 200) {
  //       return jsonDecode(data1);
  //     } else if (response.statusCode == 401) {
  //       showInvalidTokenDialog(context);
  //     } else {
  //       showStatusFalse(context);
  //       return null;
  //     }
  //   } catch (e) {
  //     if (e is DioError) {
  //       if (e.response?.statusCode == 401) {
  //         showInvalidTokenDialog(context);
  //         debugPrint(e.response?.data);
  //       }
  //     }
  //     debugPrint(e.toString());
  //     return null;
  //   }
  // }

  //------------------------------------ add Exhibitor Favourite --------------------------------------//

  Future<dynamic> addExhibitorFavourite(BuildContext context, String id) async {
    try {
      dynamic payload = {
        'userLoginToken': constant.userToken,
        "exhibitorId": id
      };
      Response response =
          await dio.post(addExhibitorFavouriteURL, data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $addExhibitorFavouriteURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ remove Exhibitor Favourite --------------------------------------//

  Future<dynamic> removeExhibitorFavourite(
      BuildContext context, String id) async {
    try {
      dynamic payload = {
        'userLoginToken': constant.userToken,
        "exhibitorId": id
      };
      Response response =
          await dio.post(removeExhibitorFavouriteURL, data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $removeExhibitorFavouriteURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ scan Exhibitor --------------------------------------//

  Future<dynamic> scanExhibitor(BuildContext context, String id) async {
    try {
      dynamic payload = {
        'userLoginToken': constant.userToken,
        "exhibitorId": id
      };
      Response response =
          await dio.post(scanExhibitorURL, data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $scanExhibitorURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ scan Visitor --------------------------------------//

  Future<dynamic> scanVisitor(
      BuildContext context, String id, String exhibitionId) async {
    try {
      dynamic payload = {
        'userLoginToken': constant.userToken,
        "visitorId": id,
        "exhibitionId": exhibitionId
      };
      debugPrint("\nURL : $scanVisitorURL\nPayload : $payload\n");

      Response response =
          await dio.post(scanVisitorURL, data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $scanVisitorURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ submit Exhibitor Feedback --------------------------------------//

  Future<dynamic> submitExhibitorFeedback(
    BuildContext context,
    String exhibitorId,
    String name,
    String additionalInfo,
    String? callToAction,
    String interestLevel,
    String feedback,
    File? audioName,
    // File? imageName,
    List<File> imageNames,
    File? videoName,
  ) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse(submitExhibitorFeedbackURL));

      Map<String, dynamic> jsonData = {
        'userLoginToken': constant.userToken,
        "exhibitorId": exhibitorId,
        "name": name,
        "additional_info": additionalInfo,
        "call_to_action": callToAction,
        "interest_level": interestLevel,
        "feedback": feedback,
      };

      jsonData.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      if (audioName != null) {
        var audioFileStream = http.MultipartFile.fromBytes(
            'audio_name', await audioName.readAsBytes(),
            filename: audioName.path.split('/').last);
        request.files.add(audioFileStream);
      }
      // if (imageName != null) {
      //   var imageFileStream = http.MultipartFile.fromBytes(
      //       'image_name', await imageName.readAsBytes(),
      //       filename: imageName.path.split('/').last);
      //   request.files.add(imageFileStream);
      // }
      // Add multiple images
      for (var imageName in imageNames) {
        var imageFileStream = http.MultipartFile.fromBytes(
            'image_name[]', // Use array notation for multiple files
            await imageName.readAsBytes(),
            filename: imageName.path.split('/').last);
        request.files.add(imageFileStream);
      }
      if (videoName != null) {
        var videoFileStream = http.MultipartFile.fromBytes(
            'video_name', await videoName.readAsBytes(),
            filename: videoName.path.split('/').last);
        request.files.add(videoFileStream);
      }

      debugPrint(
          "URL : ${request.url}\nfields : ${request.fields}\nfiles : ${request.files}");

      var response = await request.send();
      var data1 = await response.stream.bytesToString();
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $submitExhibitorFeedbackURL\nPayload : $jsonData\nresponse ${jsonDecode(data1)}");

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

  //------------------------------------ submit visitor Feedback --------------------------------------//

  Future<dynamic> submitVisitorFeedback(
    BuildContext context,
    String visitorId,
    String additionalInfo,
    String? callToAction,
    String interestLevel,
    File? audioName,
    // File? imageName,
    List<File> imageNames,
    File? videoName,
    String exhibitionId,
  ) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse(submitVisitorFeedbackURL));

      Map<String, dynamic> jsonData = {
        'userLoginToken': constant.userToken,
        "visitorId": visitorId,
        "additional_info": additionalInfo,
        "call_to_action": callToAction,
        "interest_level": interestLevel,
        'exhibitionId': exhibitionId,
      };

      jsonData.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      if (audioName != null) {
        var audioFileStream = http.MultipartFile.fromBytes(
            'audio_name', await audioName.readAsBytes(),
            filename: audioName.path.split('/').last);
        request.files.add(audioFileStream);
      }
      // if (imageName != null) {
      //   var imageFileStream = http.MultipartFile.fromBytes(
      //       'image_name', await imageName.readAsBytes(),
      //       filename: imageName.path.split('/').last);
      //   request.files.add(imageFileStream);
      // }
      // Add multiple images
      for (var imageName in imageNames) {
        var imageFileStream = http.MultipartFile.fromBytes(
            'image_name[]', // Use array notation for multiple files
            await imageName.readAsBytes(),
            filename: imageName.path.split('/').last);
        request.files.add(imageFileStream);
      }
      if (videoName != null) {
        var videoFileStream = http.MultipartFile.fromBytes(
            'video_name', await videoName.readAsBytes(),
            filename: videoName.path.split('/').last);
        request.files.add(videoFileStream);
      }

      debugPrint(
          "URL : ${request.url}\nfields : ${request.fields}\nfiles : ${request.files}");

      var response = await request.send();
      var data1 = await response.stream.bytesToString();
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $submitVisitorFeedbackURL\nPayload : $jsonData\nresponse ${jsonDecode(data1)}");

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

  //------------------------------------ Scanned Visitor List --------------------------------------//

  Future<dynamic> getScannedVisitorList(BuildContext context) async {
    try {
      dynamic payload = {'userLoginToken': constant.userToken};
      Response response =
          await dio.post(getScannedVisitorListURL, data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $getScannedVisitorListURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ get Exhibitor Feedback --------------------------------------//

  Future<dynamic> getExhibitorFeedback(BuildContext context) async {
    try {
      dynamic payload = {'userLoginToken': constant.userToken};
      Response response =
          await dio.post(getExhibitorFeedbackURL, data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $getExhibitorFeedbackURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ get Exhibitor Visitor Feedback URL --------------------------------------//
  // Exhibitor login exhibitor check visitors feedback details
  Future<dynamic> getExhibitorVistorFeedback(BuildContext context) async {
    try {
      dynamic payload = {'userLoginToken': constant.userToken};
      Response response = await dio.post(getExhibitorVisitorFeedbackURL,
          data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $getExhibitorVisitorFeedbackURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ get Visitor Feedback --------------------------------------//

  Future<dynamic> getVisitorFeedback(BuildContext context) async {
    try {
      dynamic payload = {'userLoginToken': constant.userToken};
      Response response =
          await dio.post(getVisitorFeedbackURL, data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $getVisitorFeedbackURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ Meeting Request List --------------------------------------//

  Future<dynamic> getMeetingRequestList(BuildContext context) async {
    try {
      dynamic payload = {'userLoginToken': constant.userToken};
      Response response =
          await dio.post(getMeetingRequestListURL, data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $getMeetingRequestListURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ Exhibibtor Feedback --------------------------------------//

  // Future<dynamic> getExhibibtorFeedback(BuildContext context) async {
  //   try {
  //     dynamic payload = {'userLoginToken': constant.userToken};
  //     Response response = await dio.post(getExhibibtorFeedbackURL, data: jsonEncode(payload));
  //     debugPrint("response.statusCode : ${response.statusCode}\nURL : $getExhibibtorFeedbackURL\nPayload : $payload\nresponse ${response.data}");
  //     var data1 = response.data;
  //     if (response.statusCode == 200) {
  //       return jsonDecode(data1);
  //     } else if (response.statusCode == 401) {
  //       showInvalidTokenDialog(context);
  //     } else {
  //       showStatusFalse(context);
  //       return null;
  //     }
  //   } catch (e) {
  //     if (e is DioError) {
  //       if (e.response?.statusCode == 401) {
  //         showInvalidTokenDialog(context);
  //         debugPrint(e.response?.data);
  //       }
  //     }
  //     debugPrint(e.toString());
  //     return null;
  //   }
  // }

  //------------------------------------ update Meeting Status --------------------------------------//

  Future<dynamic> updateMeetingStatus(BuildContext context, String meetingId,
      String status, String message) async {
    try {
      dynamic payload = {
        'userLoginToken': constant.userToken,
        "meetingId": meetingId,
        "status": status,
        'message': message
      };
      Response response =
          await dio.post(updateMeetingStatusURL, data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $updateMeetingStatusURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ Edit Exhibitor Profile --------------------------------------//

  Future<dynamic> editExhibitorProfile(
      BuildContext context,
      String name,
      String email,
      String country_code,
      String mobile,
      String office_no) async {
    try {
      dynamic payload = {
        'userLoginToken': constant.userToken,
        "name": name,
        "email": email,
        "country_code": country_code,
        "mobile": mobile,
        "office_no": office_no
      };
      debugPrint("URL : $editExhibitorProfileURL\nPayload : $payload");

      Response response =
          await dio.post(editExhibitorProfileURL, data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $editExhibitorProfileURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ Edit Exhibitor Profile image --------------------------------------//

  Future<dynamic> editExhibitorProfileImage(
      BuildContext context, File profilePic) async {
    try {
      File file = profilePic;
      Map<String, dynamic> jsonData = {'userLoginToken': constant.userToken};
      var request = http.MultipartRequest(
          'POST', Uri.parse(editExhibitorProfileImageURL));
      jsonData.forEach((key, value) {
        request.fields[key] = value.toString();
      });
      var fileStream = http.MultipartFile.fromBytes(
          'profile_pic', await file.readAsBytes(),
          filename: file.path.split('/').last);
      request.files.add(fileStream);
      var response = await request.send();

      var data1 = await response.stream.bytesToString();

      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $editExhibitorProfileImageURL\nPayload : $jsonData\nresponse ${jsonDecode(data1)}");

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

  //------------------------------------ Edit Visitor Profile --------------------------------------//

  Future<dynamic> editVisitorProfile(
    BuildContext context,
    String editType,
    String name,
    String email,
    String country_code,
    String mobile,
    String address,
    String budget,
    String destination,
    String venue,
    String wedDate,
  ) async {
    try {
      dynamic payload = {
        'userLoginToken': constant.userToken,
        "editType": editType,
        if (editType == 'contact') "name": name,
        if (editType == 'contact') "email": email,
        if (editType == 'contact') "country_code": country_code,
        if (editType == 'contact') "mobile": mobile,
        if (editType == 'address') "address": address,
        if (editType == 'budget') "estimated_budget": budget,
        if (editType == 'expected_date') "expected_date": wedDate,
        if (editType == 'destination') "destination": destination,
        if (editType == 'venue') "venue": venue,
      };
      debugPrint("URL : $editVisitorProfileURL\nPayload : $payload");

      Response response =
          await dio.post(editVisitorProfileURL, data: jsonEncode(payload));
      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $editVisitorProfileURL\nPayload : $payload\nresponse ${response.data}");
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

  //------------------------------------ Edit Visitor Profile image --------------------------------------//

  Future<dynamic> editVisitorProfileImage(
      BuildContext context, File profilePic) async {
    try {
      File file = profilePic;
      Map<String, dynamic> jsonData = {'userLoginToken': constant.userToken};
      var request =
          http.MultipartRequest('POST', Uri.parse(editVisitorProfileImageURL));
      jsonData.forEach((key, value) {
        request.fields[key] = value.toString();
      });
      var fileStream = http.MultipartFile.fromBytes(
          'profile_pic', await file.readAsBytes(),
          filename: file.path.split('/').last);
      request.files.add(fileStream);
      var response = await request.send();

      var data1 = await response.stream.bytesToString();

      debugPrint(
          "response.statusCode : ${response.statusCode}\nURL : $editVisitorProfileImageURL\nPayload : $jsonData\nresponse $data1");

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
}

APIvalue apiValue = APIvalue();
