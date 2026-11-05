import 'package:event_pro/scanner/data/local/db_helper.dart';
import 'package:event_pro/scanner/sharedwidget/elevated_button.dart';
import 'package:event_pro/scanner/utils/color.dart';
import 'package:event_pro/scanner/utils/helper_functions.dart';
import 'package:event_pro/scanner/utils/images.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  static String id = "SignUpPage";

  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isChecked = false;
  bool isButtonloading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final RegExp _emailRegex =
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty) {
      showToast('Please enter your name');
      return;
    }
    if (!_emailRegex.hasMatch(email)) {
      showToast('Please enter a valid email');
      return;
    }
    if (password.isEmpty || password.length < 6) {
      showToast('Password must be at least 6 characters');
      return;
    }
    if (password != confirmPassword) {
      showToast('Passwords do not match');
      return;
    }
    if (!_isChecked) {
      showToast('Please accept terms & conditions');
      return;
    }

    setState(() => isButtonloading = true);

    final result = await DBHelper.instance.signUp(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );

    if (!mounted) return;
    setState(() => isButtonloading = false);

    if (result == -1) {
      showToast('An account with this email already exists');
      return;
    }

    showToast('Account created successfully. Please login.');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    OutlineInputBorder inputBorderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(
        color: Color.fromRGBO(0, 0, 0, 0.1),
        width: 1,
        style: BorderStyle.solid,
      ),
    );

    InputDecoration fieldDecoration(String label, {Widget? suffixIcon}) {
      return InputDecoration(
        focusedBorder: inputBorderStyle,
        border: inputBorderStyle,
        enabledBorder: inputBorderStyle,
        disabledBorder: inputBorderStyle,
        suffixIcon: suffixIcon,
        suffixIconConstraints: suffixIcon == null
            ? null
            : BoxConstraints(
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
        labelText: label,
        focusColor: black,
        floatingLabelStyle: TextStyle(color: cyangreen),
        labelStyle: TextStyle(
          fontSize: convertFigmaToUIWidth(18, width),
          fontWeight: FontWeight.w400,
        ),
      );
    }

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                      " Sign Up",
                      style: TextStyle(
                        fontSize: convertFigmaToUIWidth(24.08, width),
                        fontWeight: FontWeight.w400,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: convertFigmaToUIWidth(20, width)),

                    TextField(
                      controller: _nameController,
                      decoration: fieldDecoration('Full Name'),
                      cursorColor: cyangreen,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                    ),
                    SizedBox(height: convertFigmaToUIWidth(15, width)),

                    TextField(
                      controller: _emailController,
                      decoration: fieldDecoration('Email'),
                      cursorColor: cyangreen,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: convertFigmaToUIWidth(15, width)),

                    TextField(
                      controller: _phoneController,
                      decoration: fieldDecoration('Phone (optional)'),
                      cursorColor: cyangreen,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: convertFigmaToUIWidth(15, width)),

                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: fieldDecoration(
                        'Password',
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          }),
                          child: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: cyangreen,
                          ),
                        ),
                      ),
                      cursorColor: cyangreen,
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    SizedBox(height: convertFigmaToUIWidth(15, width)),

                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      decoration: fieldDecoration(
                        'Confirm Password',
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          }),
                          child: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: cyangreen,
                          ),
                        ),
                      ),
                      cursorColor: cyangreen,
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    SizedBox(height: convertFigmaToUIWidth(20, width)),

                    isButtonloading
                        ? Center(
                            child:
                                CircularProgressIndicator(color: cyangreen),
                          )
                        : filledButtonWidgt(context, 'Sign Up', _onSignUp),

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
                            overlayColor:
                                MaterialStatePropertyAll(cyangreen),
                            value: _isChecked,
                            onChanged: (value) {
                              setState(() => _isChecked = !_isChecked);
                            },
                          ),
                          Expanded(
                            child: Text(
                              "I accept the Terms of Services and Privacy Policy.",
                              style: TextStyle(
                                fontSize: convertFigmaToUIWidth(16, width),
                                color: textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: "Already have an account? ",
                                style: TextStyle(
                                  fontSize: convertFigmaToUIWidth(16, width),
                                  color: textColor,
                                ),
                              ),
                              TextSpan(
                                text: "Login",
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
