import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mallari_mobprog/widgets/custom_textformfield.dart';
import 'package:mallari_mobprog/widgets/custom_inkwell_button.dart';
import 'package:mallari_mobprog/widgets/custom_dialogs.dart';
import 'package:mallari_mobprog/screens/home_screen.dart';
import 'package:mallari_mobprog/services/user_service.dart';
import 'package:mallari_mobprog/models/user.dart';

import '../constants.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() =>
      _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final TextEditingController usernameController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final _formKey =
      GlobalKey<FormState>();

  bool _isPasswordHidden = true;
  bool _isLoading = false;

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final User user =
          await UserService().login(
        usernameController.text.trim(),
        passwordController.text.trim(),
      );

      final prefs =
          await SharedPreferences.getInstance();

      // Save login status.
      await prefs.setBool(
        'isLoggedIn',
        true,
      );

      // Save complete user data.
      await prefs.setString(
        'user',
        jsonEncode(user.toJson()),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            user: user,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      customDialog(
        context,
        title: 'Login Failed',
        content:
            'Invalid username or password.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: ScreenUtil().screenHeight,
          width: ScreenUtil().screenWidth,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: ScreenUtil().screenWidth,
                  height:
                      ScreenUtil().setHeight(40),
                  color: FB_SECONDARY,
                ),

                Padding(
                  padding:
                      EdgeInsets.symmetric(
                    horizontal:
                        ScreenUtil().setWidth(25),
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/CCITConnect_Logo.png',
                        height:
                            ScreenUtil().setHeight(200),
                      ),

                      SizedBox(
                        height:
                            ScreenUtil().setHeight(30),
                      ),

                      CustomTextFormField(
                        height:
                            ScreenUtil().setHeight(10),
                        width:
                            ScreenUtil().setWidth(10),
                        controller:
                            usernameController,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return 'Enter your username';
                          }
                          return null;
                        },
                        fontSize:
                            ScreenUtil().setSp(15),
                        fontColor: FB_PRIMARY,
                        hintTextSize:
                            ScreenUtil().setSp(15),
                        hintText: 'Username',
                      ),

                      SizedBox(
                        height:
                            ScreenUtil().setHeight(10),
                      ),

                      CustomTextFormField(
                        height:
                            ScreenUtil().setHeight(10),
                        width:
                            ScreenUtil().setWidth(10),
                        controller:
                            passwordController,
                        isObscure:
                            _isPasswordHidden,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return 'Enter your password';
                          }
                          return null;
                        },
                        fontSize:
                            ScreenUtil().setSp(15),
                        fontColor: FB_PRIMARY,
                        hintTextSize:
                            ScreenUtil().setSp(15),
                        hintText: 'Password',
                        suffixIcon:
                            IconButton(
                          icon: Icon(
                            _isPasswordHidden
                                ? Icons
                                    .visibility_off
                                : Icons.visibility,
                            color: FB_PRIMARY,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordHidden =
                                  !_isPasswordHidden;
                            });
                          },
                        ),
                      ),

                      SizedBox(
                        height:
                            ScreenUtil().setHeight(50),
                      ),

                      CustomInkWellButton(
                        onTap: login,
                        height:
                            ScreenUtil().setHeight(40),
                        width:
                            ScreenUtil().screenWidth,
                        buttonName: _isLoading
                            ? 'Logging in...'
                            : 'Login',
                        fontSize:
                            ScreenUtil().setSp(15),
                        bgColor: FB_SECONDARY,
                        fontColor: FB_PRIMARY,
                      ),
                    ],
                  ),
                ),

                Container(
                  width:
                      ScreenUtil().screenWidth,
                  height:
                      ScreenUtil().setHeight(40),
                  color: FB_SECONDARY,
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        'You do not have an account? ',
                        style: TextStyle(
                          color: FB_PRIMARY,
                          fontSize:
                              ScreenUtil().setSp(15),
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(
                          context,
                          '/register',
                        ),
                        child: Text(
                          'Register here',
                          style: TextStyle(
                            color: FB_PRIMARY,
                            fontSize:
                                ScreenUtil().setSp(15),
                            fontWeight:
                                FontWeight.bold,
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
      ),
    );
  }
}