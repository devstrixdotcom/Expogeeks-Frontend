import 'package:event_pro/data/remote/api_value.dart';
import 'package:event_pro/utils/color.dart';
import 'package:event_pro/data/local/contants.dart';
import 'package:event_pro/data/remote/get_user_data.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/utils/images.dart';
import 'package:event_pro/data/local/shared_pref_helper.dart';
import 'package:event_pro/sharedwidget/elevated_button.dart';
import 'package:event_pro/view/commonScreen/web_screen.dart';
import 'package:event_pro/view/home/home_screen.dart';
import 'package:event_pro/view/menuScreens/exhibitor/exihibitors_mettings.dart';
import 'package:event_pro/view/menuScreens/common/my_profile.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  static String id = "LoginPage";
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Demo credentials for app review / testing: bypasses the real OTP backend.
  static const String _demoEmail = 'hello123@gmail.com';
  static const String _demoOtp = '1234';

  bool _isChecked = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  String tempOTP = '';
  bool isButtonloading = false;
  bool isOtpSent = false;
  bool _isEmailValid = false;
  bool isOtpLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      final email = _emailController.text;
      setState(() {
        _isEmailValid = _validateEmail(email);
      });
    });
  }

  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email.trim());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder inputBorderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(
          color: Color.fromRGBO(0, 0, 0, 0.1),
          width: 1,
          style: BorderStyle.solid),
    );
    final termsTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WebScreen(
                    initialUrl:
                        'https://www.expogeeks.co.uk/api/content/Terms.php',
                    titleText: 'Terms & Conditions')));
      };
    final priavcyTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WebScreen(
                    initialUrl:
                        'https://www.expogeeks.co.uk/api/content/PrivacyPolicy.php',
                    titleText: 'Privacy Policy')));
      };
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: convertFigmaToUIWidth(50, width)),
              Container(child: Image.asset(loginScreenImg, fit: BoxFit.cover)),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      " Login",
                      style: TextStyle(
                          fontSize: convertFigmaToUIWidth(24, width),
                          fontWeight: FontWeight.w400,
                          color: textColor),
                    ),
                    
                    SizedBox(
                      height: convertFigmaToUIWidth(15, width) ?? 15,
                    ),

                    TextField(
                      controller: _emailController,
                      enabled: true, // Always enabled
                      onTap: () {
                        if (isOtpSent) {
                          setState(() {
                            isOtpSent = false;
                            _otpController.clear();
                            tempOTP = '';
                          });
                        }
                      },
                      decoration: InputDecoration(
                        focusedBorder: inputBorderStyle,
                        border: inputBorderStyle,
                        enabledBorder: inputBorderStyle,
                        disabledBorder: inputBorderStyle,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: convertFigmaToUIWidth(16, width) ?? 16,
                            horizontal: convertFigmaToUIWidth(16, width) ?? 16),
                        fillColor: Color.fromRGBO(0, 0, 0, 0.02),
                        filled: true,
                        labelText: 'Email',
                        focusColor: black,
                        floatingLabelStyle:
                            TextStyle(height: 1.5, color: cyangreen),
                        labelStyle: TextStyle(
                            fontSize: convertFigmaToUIWidth(16, width),
                            fontWeight: FontWeight.w400),
                      ),
                      cursorColor: cyangreen,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    
                    SizedBox(
                      height: convertFigmaToUIWidth(15, width) ?? 15,
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            _isEmailValid && !isOtpLoading
                                ? cyangreen
                                : Colors.grey,
                          ),
                          padding: MaterialStateProperty.all(
                            EdgeInsets.symmetric(
                                horizontal:
                                    convertFigmaToUIWidth(20, width) ?? 20,
                                vertical: convertFigmaToUIWidth(8, width) ?? 8),
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        onPressed: !isOtpLoading
                            ? () async {
                                // Validate on tap (instead of silently disabling
                                // the button) so the user gets clear feedback.
                                if (!_isEmailValid) {
                                  showToast('Please enter a valid email');
                                  return;
                                }
                                // Demo account: skip the OTP backend entirely.
                                if (_emailController.text.trim().toLowerCase() ==
                                    _demoEmail) {
                                  tempOTP = _demoOtp;
                                  setState(() {
                                    isOtpSent = true;
                                  });
                                  showToast('Demo OTP is $_demoOtp');
                                  return;
                                }
                                setState(() {
                                  isOtpLoading = true;
                                });
                                try {
                                  dynamic response = await apiValue.sendOTP(
                                      _emailController.text, context);
                                  if (response != null) {
                                    showToast(
                                        'OTP sent to your email successfully');
                                    tempOTP = response['otp'].toString();
                                    setState(() {
                                      isOtpSent = true;
                                    });
                                  } else {
                                    // sendOTP returns null for any transport or
                                    // non-200 failure, so this is usually the
                                    // backend being unreachable rather than a
                                    // rate limit. Say so instead of implying a
                                    // retry will help.
                                    showToast(
                                        'Could not reach the server. Check your connection and try again.');
                                  }
                                } catch (e) {
                                  showToast('Error sending OTP');
                                } finally {
                                  setState(() {
                                    isOtpLoading = false;
                                  });
                                }
                              }
                            : null,
                        child: isOtpLoading
                            ? SizedBox(
                                width: convertFigmaToUIWidth(20, width),
                                height: convertFigmaToUIWidth(20, width),
                                child: CircularProgressIndicator(
                                  color: white,
                                  strokeWidth: 2,
                                ),
                              )
                            : FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  isOtpSent ? 'Resend OTP' : 'Send OTP',
                                  style: TextStyle(
                                    fontSize: convertFigmaToUIWidth(14, width),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                      ),
                    ),

                    
                    SizedBox(
                      height: convertFigmaToUIWidth(15, width) ?? 15,
                    ),
                    TextField(
                      controller: _otpController,
                      enabled: isOtpSent,
                      decoration: InputDecoration(
                        focusedBorder: inputBorderStyle,
                        border: inputBorderStyle,
                        enabledBorder: inputBorderStyle,
                        disabledBorder: inputBorderStyle,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: convertFigmaToUIWidth(16, width) ?? 16,
                            horizontal: convertFigmaToUIWidth(16, width) ?? 16),
                        fillColor: Color.fromRGBO(0, 0, 0, 0.02),
                        filled: true,
                        labelText: 'OTP',
                        floatingLabelStyle: TextStyle(color: cyangreen),
                        focusColor: black,
                        labelStyle: TextStyle(
                            fontSize: convertFigmaToUIWidth(16, width),
                            fontWeight: FontWeight.w400),
                      ),
                      cursorColor: cyangreen,
                      inputFormatters: [LengthLimitingTextInputFormatter(4)],
                      keyboardType: TextInputType.number,
                    ),

                    SizedBox(height: convertFigmaToUIWidth(30, width)),
                    isButtonloading
                        ? Center(
                            child: CircularProgressIndicator(color: cyangreen))
                        : filledButtonWidgt(
                            context,
                            'Login',
                            () async {
                              if (_emailController.text.isEmpty) {
                                // Check if the email field is empty
                                showToast('Please enter email');
                              } else if (_otpController.text.isEmpty ||
                                  _otpController.text.length != 4) {
                                // Check if the OTP field is empty or not exactly 4 digits
                                showToast('Please enter OTP');
                              } else {
                                if (_isChecked) {
                                  // Demo account: bypass the login backend.
                                  if (_emailController.text
                                              .trim()
                                              .toLowerCase() ==
                                          _demoEmail &&
                                      _otpController.text == _demoOtp) {
                                    SharedPreferencesHelper.setUserId(
                                        id: 'demo');
                                    SharedPreferencesHelper.setUserEmail(
                                        email: _demoEmail);
                                    SharedPreferencesHelper.setUserType(
                                        type: constant.visitorUser);
                                    SharedPreferencesHelper.setUserToken(
                                        token: 'demo-token');
                                    SharedPreferencesHelper.setUserName(
                                        name: 'Demo User');
                                    SharedPreferencesHelper.setIsLoggedIn(
                                        loggedIn: true);
                                    constant.userType = constant.visitorUser;
                                    constant.userId = 'demo';
                                    constant.userToken = 'demo-token';
                                    constant.emailValue = _demoEmail;
                                    constant.nameValue = 'Demo User';
                                    showToast('Logged in as demo user');
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HomeScreen()),
                                        (route) => false);
                                    return;
                                  }
                                  if (_otpController.text == tempOTP &&
                                      !isButtonloading) {
                                    setState(() {
                                      isButtonloading = true;
                                    });
                                    dynamic response = await apiValue.loginOTP(
                                        _emailController.text, context);

                                    if (response != null) {
                                      showToast(response['message']);
                                      SharedPreferencesHelper.setUserId(
                                          id: response['userData']['id']
                                              .toString());
                                      SharedPreferencesHelper.setUserEmail(
                                          email: _emailController.text);
                                      SharedPreferencesHelper.setUserType(
                                          type: response['userData']
                                                  ['user_type']
                                              .toString());
                                      SharedPreferencesHelper.setUserToken(
                                          token: response['loginToken']
                                              .toString());
                                      SharedPreferencesHelper.setIsLoggedIn(
                                          loggedIn: true);
                                      constant.userType = response['userData']
                                              ['user_type']
                                          .toString();
                                      constant.emailValue =
                                          _emailController.text;
                                      constant.userId =
                                          response['userData']['id'].toString();
                                      constant.userToken =
                                          response['loginToken'];
                                      await GetUserData().getUserDetails();

                                      if (constant.userType ==
                                          constant.exhibitorUser) {
                                        dynamic response = await apiValue
                                            .getMeetingRequestList(context);
                                        if (response != null) {
                                          setState(() {
                                            isButtonloading = false;
                                            var tempList = response as List;
                                            print(tempList.length);
                                            if (tempList.length > 0) {
                                              Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ExhibitorMeetingsScreen(
                                                              isFromAppStart:
                                                                  true)),
                                                  (route) => false);
                                            } else {
                                              Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          HomeScreen()),
                                                  (route) => false);
                                            }
                                          });
                                        } else {
                                          setState(() {
                                            isButtonloading = false;
                                          });
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      HomeScreen()),
                                              (route) => false);
                                        }
                                      } else {
                                        setState(() {
                                          isButtonloading = false;
                                        });
                                        if (constant.nameValue == '') {
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MyProfileScreen()),
                                              (route) => false);
                                        } else {
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      HomeScreen()),
                                              (route) => false);
                                        }
                                      }
                                    } else {
                                      setState(() {
                                        isButtonloading = false;
                                      });
                                    }
                                  } else {
                                    showToast('Invalid OTP');
                                  }
                                } else {
                                  showToast('Accept terms & conditions');
                                }
                              }
                            },
                          ),
                    // SizedBox(height: 20.0),
                    SizedBox(
                      height: convertFigmaToUIWidth(20, width) ?? 20,
                    ),

                    // Terms and Conditions Text
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Checkbox(
                            activeColor: cyangreen,
                            focusColor: cyangreen,
                            checkColor: white,
                            hoverColor: cyangreen,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                            overlayColor: MaterialStatePropertyAll(cyangreen),
                            value: _isChecked,
                            onChanged: (value) {
                              setState(() {
                                _isChecked = !_isChecked;
                              });
                            },
                          ),
                          Expanded(
                            child: RichText(
                              maxLines: 3,
                              softWrap: true,
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: "By logging in, I am accepting the ",
                                    style: TextStyle(
                                        fontSize:
                                            convertFigmaToUIWidth(16, width),
                                        color: textColor),
                                  ),
                                  TextSpan(
                                    recognizer: termsTapRecognizer,
                                    text: "Terms  of Services",
                                    style: TextStyle(
                                        fontSize:
                                            convertFigmaToUIWidth(16, width),
                                        color: textColor,
                                        decoration: TextDecoration.underline),
                                  ),
                                  TextSpan(
                                    text: " and the ",
                                    style: TextStyle(
                                        fontSize:
                                            convertFigmaToUIWidth(16, width),
                                        color: textColor),
                                  ),
                                  TextSpan(
                                    recognizer: priavcyTapRecognizer,
                                    text: "Privacy policy.",
                                    style: TextStyle(
                                        fontSize:
                                            convertFigmaToUIWidth(16, width),
                                        color: textColor,
                                        decoration: TextDecoration.underline),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
