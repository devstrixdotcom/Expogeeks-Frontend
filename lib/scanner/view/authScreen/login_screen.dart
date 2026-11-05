import 'package:event_pro/scanner/utils/color.dart';
import 'package:event_pro/scanner/data/local/contants.dart';
import 'package:event_pro/scanner/data/remote/api_value.dart';
import 'package:event_pro/scanner/utils/helper_functions.dart';
import 'package:event_pro/scanner/utils/images.dart';
import 'package:event_pro/scanner/data/local/shared_pref_helper.dart';
import 'package:event_pro/scanner/sharedwidget/elevated_button.dart';
import 'package:event_pro/scanner/view/authScreen/signup_screen.dart';
import 'package:event_pro/scanner/view/commonScreen/web_screen.dart';
import 'package:event_pro/scanner/view/home/home_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  static String id = "LoginPage";
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;
  bool _isChecked = false;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool isButtonloading = false;

  @override
  void initState() {
    super.initState();
    checkExistingCredentials();
  }

  void checkExistingCredentials() async {
    bool isLoggedIn = SharedPreferencesHelper.getIsLoggedIn();

    if (isLoggedIn) {
      // User is already logged in, navigate to home screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    OutlineInputBorder inputBorderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(
        color: Color.fromRGBO(0, 0, 0, 0.1),
        width: 1,
        style: BorderStyle.solid,
      ),
    );

    final termsTapRecognizer =
        TapGestureRecognizer()
          ..onTap = () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => WebScreen(
                      initialUrl:
                          'https://www.expogeeks.co.uk/api/content/Terms.php',
                      titleText: 'Terms & Conditions',
                    ),
              ),
            );
          };

    final priavcyTapRecognizer =
        TapGestureRecognizer()
          ..onTap = () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => WebScreen(
                      initialUrl:
                          'https://www.expogeeks.co.uk/api/content/PrivacyPolicy.php',
                      titleText: 'Privacy Policy',
                    ),
              ),
            );
          };

    Future<bool> onWillPop(BuildContext context) {
      // Opened from the Staff / Visitor choice: just go back to it.
      if (Navigator.of(context).canPop()) return Future.value(true);
      showExitApp(context);
      return Future.value(false);
    }

    return WillPopScope(
      onWillPop: () => onWillPop(context),
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                // SizedBox(height: height * 0.05),
                // Back arrow to the Staff / Visitor choice when opened from it.
                if (Navigator.of(context).canPop())
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top, left: 4),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: cyangreen),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  )
                else
                  SizedBox(height: convertFigmaToUIWidth(50, width)),
                Container(
                  child: Image.asset(loginScreenImg, fit: BoxFit.cover),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        " Login",
                        style: TextStyle(
                          fontSize: convertFigmaToUIWidth(24.08, width),
                          fontWeight: FontWeight.w400,
                          color: textColor,
                        ),
                      ),

                      SizedBox(height: convertFigmaToUIWidth(20, width)),

                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          focusedBorder: inputBorderStyle,
                          border: inputBorderStyle,
                          enabledBorder: inputBorderStyle,
                          disabledBorder: inputBorderStyle,
                          enabled: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: convertFigmaToUIWidth(18, width) ?? 18,
                            horizontal: convertFigmaToUIWidth(24, width) ?? 24,
                          ),
                          fillColor: Color.fromRGBO(0, 0, 0, 0.02),
                          filled: true,
                          labelText: 'Username',
                          focusColor: black,
                          floatingLabelStyle: TextStyle(color: cyangreen),
                          labelStyle: TextStyle(
                            fontSize: convertFigmaToUIWidth(18, width),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        cursorColor: cyangreen,
                        keyboardType: TextInputType.text,
                        // Flutter leaves autocorrect/suggestions ON for a plain
                        // text field. On Android, Gboard's suggestion strip and
                        // glide typing will happily rewrite or space-pad a
                        // username as it is committed. (Case is safe either
                        // way — the backend matches app_username with a
                        // case-insensitive collation.)
                        textCapitalization: TextCapitalization.none,
                        autocorrect: false,
                        enableSuggestions: false,
                      ),

                      SizedBox(height: convertFigmaToUIWidth(15, width)),

                      TextField(
                        controller: _passwordController,

                        obscureText:
                            !_isPasswordVisible, // Toggle password visibility
                        decoration: InputDecoration(
                          focusedBorder: inputBorderStyle,
                          border: inputBorderStyle,
                          enabledBorder: inputBorderStyle,
                          disabledBorder: inputBorderStyle,
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isPasswordVisible =
                                    !_isPasswordVisible; // Toggle visibility
                              });
                            },
                            child: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: cyangreen,
                            ),
                          ),

                          suffixIconConstraints: BoxConstraints(
                            maxHeight: convertFigmaToUIWidth(50, width) ?? 50,
                            minHeight: convertFigmaToUIWidth(50, width) ?? 50,
                            maxWidth: convertFigmaToUIWidth(50, width) ?? 50,
                            minWidth: convertFigmaToUIWidth(50, width) ?? 50,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: convertFigmaToUIWidth(18, width) ?? 18,
                            horizontal: convertFigmaToUIWidth(24, width) ?? 24,
                          ),
                          fillColor: Color.fromRGBO(0, 0, 0, 0.02),
                          filled: true,
                          labelText: 'Password',
                          floatingLabelStyle: TextStyle(color: cyangreen),
                          focusColor: black,
                          labelStyle: TextStyle(
                            fontSize: convertFigmaToUIWidth(18, width),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        cursorColor: cyangreen,
                        keyboardType: TextInputType.visiblePassword,
                        autocorrect: false,
                        enableSuggestions: false,
                      ),

                      SizedBox(height: convertFigmaToUIWidth(20, width)),

                      isButtonloading
                          ? Center(
                            child: CircularProgressIndicator(color: cyangreen),
                          )
                          : filledButtonWidgt(context, 'Login', () async {
                            if (_passwordController.text.isEmpty) {
                              showToast('Invalid Password');
                            } else {
                              if (_isChecked) {
                                if (_usernameController.text.isNotEmpty &&
                                    !isButtonloading) {
                                  setState(() {
                                    isButtonloading = true;
                                  });

                                  // Authenticate against the backend
                                  // (OrganizerLogin.php) and persist the token.
                                  final response =
                                      await apiValue.organizerLogin(
                                    _usernameController.text.trim(),
                                    _passwordController.text,
                                    context,
                                  );

                                  if (response != null &&
                                      response['status'] == 'true') {
                                    showToast('Login successful');

                                    final String token =
                                        (response['loginToken'] ?? '')
                                            .toString();
                                    final Map<String, dynamic> userData =
                                        (response['userData']
                                                as Map<String, dynamic>?) ??
                                            <String, dynamic>{};
                                    final String displayName =
                                        (userData['app_username'] ??
                                                userData['name'] ??
                                                '')
                                            .toString();

                                    // Persist the backend session locally
                                    SharedPreferencesHelper.setIsLoggedIn(
                                      loggedIn: true,
                                    );
                                    SharedPreferencesHelper.setUserToken(
                                      token: token,
                                    );
                                    SharedPreferencesHelper.setUserId(
                                      id: (userData['id'] ?? '').toString(),
                                    );
                                    SharedPreferencesHelper.setUserName(
                                      name: displayName,
                                    );
                                    SharedPreferencesHelper.setUserEmail(
                                      email: _usernameController.text.trim(),
                                    );

                                    // Update in-memory constants so API calls
                                    // immediately have a valid token.
                                    constant.userToken = token;
                                    constant.userId =
                                        (userData['id'] ?? '').toString();
                                    constant.nameValue = displayName;
                                    constant.emailValue =
                                        _usernameController.text.trim();

                                    // Navigate to home screen
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HomeScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  } else {
                                    if (mounted) {
                                      setState(() {
                                        isButtonloading = false;
                                      });
                                    }
                                    // Show what actually went wrong. Reporting
                                    // every failure as bad credentials hid the
                                    // real cause (timeouts, unreachable host)
                                    // and made this impossible to diagnose on
                                    // a device.
                                    final String message = (response?['message']
                                                as String?)
                                            ?.trim()
                                            .isNotEmpty ==
                                            true
                                        ? response!['message'] as String
                                        : 'Invalid username or password';
                                    showToast(message);
                                  }
                                } else {
                                  showToast('Please enter a username');
                                }
                              } else {
                                showToast('Please accept terms & conditions');
                              }
                            }
                          }),

                      SizedBox(height: convertFigmaToUIWidth(20, width)),

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
                                borderRadius: BorderRadius.circular(4),
                              ),
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
                                      text:
                                          "By logging in, I am accepting the ",
                                      style: TextStyle(
                                        fontSize: convertFigmaToUIWidth(
                                          16,
                                          width,
                                        ),
                                        color: textColor,
                                      ),
                                    ),
                                    TextSpan(
                                      recognizer: termsTapRecognizer,
                                      text: "Terms  of Services",
                                      style: TextStyle(
                                        fontSize: convertFigmaToUIWidth(
                                          16,
                                          width,
                                        ),
                                        color: textColor,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    TextSpan(
                                      text: " and the ",
                                      style: TextStyle(
                                        fontSize: convertFigmaToUIWidth(
                                          16,
                                          width,
                                        ),
                                        color: textColor,
                                      ),
                                    ),
                                    TextSpan(
                                      recognizer: priavcyTapRecognizer,
                                      text: "Privacy policy.",
                                      style: TextStyle(
                                        fontSize: convertFigmaToUIWidth(
                                          16,
                                          width,
                                        ),
                                        color: textColor,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: convertFigmaToUIWidth(10, width)),

                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpPage(),
                              ),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: "Don't have an account? ",
                                  style: TextStyle(
                                    fontSize: convertFigmaToUIWidth(16, width),
                                    color: textColor,
                                  ),
                                ),
                                TextSpan(
                                  text: "Sign Up",
                                  style: TextStyle(
                                    fontSize: convertFigmaToUIWidth(16, width),
                                    color: cyangreen,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: convertFigmaToUIWidth(30, width)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showExitApp(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Are you sure you want to exit the app?'),
          actions: <Widget>[
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(cyangreen),
              ),
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),

            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(cyangreen),
              ),
              child: const Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop();
                SystemNavigator.pop();
              },
            ),
          ],
        );
      },
    );
  }
}
