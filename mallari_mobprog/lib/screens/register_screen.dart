import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mallari_mobprog/constants.dart';
import 'package:mallari_mobprog/widgets/custom_font.dart';
import 'package:mallari_mobprog/widgets/custom_inkwell_button.dart';
import 'package:mallari_mobprog/widgets/custom_textformfield.dart';
import '../widgets/custom_dialogs.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController mobilenumberController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();

  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

  final RegExp passwordRegEx =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$');

  void register() {
    String firstname = firstnameController.text.trim();
    String lastname = lastnameController.text.trim();
    String mobile = mobilenumberController.text.trim();
    String password = passwordController.text;
    String confirmPassword = confirmpasswordController.text;

    if (firstname.isEmpty) {
      showErrorDialog('First name cannot be empty');
      return;
    }
    if (lastname.isEmpty) {
      showErrorDialog('Last name cannot be empty');
      return;
    }
    if (mobile.isEmpty) {
      showErrorDialog('Mobile number cannot be empty');
      return;
    }
    if (mobile.length != 11 || !RegExp(r'^\d+$').hasMatch(mobile)) {
      showErrorDialog('Mobile number must be exactly 11 digits');
      return;
    }
    if (password.isEmpty) {
      showErrorDialog('Password cannot be empty');
      return;
    }
    if (!passwordRegEx.hasMatch(password)) {
      showErrorDialog(
        'Password must be at least 8 characters, with uppercase, lowercase, number, and special character',
      );
      return;
    }
    if (confirmPassword.isEmpty) {
      showErrorDialog('Please confirm your password');
      return;
    }
    if (password != confirmPassword) {
      showErrorDialog('Passwords do not match');
      return;
    }

    showSuccessDialog(
      'Registration successful!',
      onOk: () {
        Navigator.popAndPushNamed(context, '/login');
      },
    );
  }

  void showErrorDialog(String message) {
    customDialog(
      context,
      title: 'Invalid Input',
      content: message,
    );
  }

  void showSuccessDialog(String message, {VoidCallback? onOk}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Success',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: FB_PRIMARY,
              foregroundColor: FB_SECONDARY,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Okay'),
          ),
        ],
      ),
    ).then((_) {
      if (onOk != null) onOk();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: ScreenUtil().screenHeight,
          width: ScreenUtil().screenWidth,
          padding: EdgeInsets.fromLTRB(
            ScreenUtil().setWidth(25),
            ScreenUtil().setHeight(40),
            ScreenUtil().setWidth(25),
            ScreenUtil().setHeight(10),
          ),
          child: Column(
            children: [
              SizedBox(height: ScreenUtil().setHeight(25)),
              CustomFont(
                text: 'Register Here',
                fontSize: ScreenUtil().setSp(50),
                fontWeight: FontWeight.bold,
                color: FB_PRIMARY,
              ),
              SizedBox(height: ScreenUtil().setHeight(25)),

              /// FIRST NAME
              CustomTextFormField(
                controller: firstnameController,
                validator: (value) => null,
                onSaved: (value) {},
                fontSize: ScreenUtil().setSp(15),
                fontColor: FB_PRIMARY,
                height: ScreenUtil().setHeight(10),
                width: ScreenUtil().setWidth(10),
                hintText: 'First name',
                hintTextSize: ScreenUtil().setSp(15),
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),

              /// LAST NAME
              CustomTextFormField(
                controller: lastnameController,
                validator: (value) => null,
                onSaved: (value) {},
                fontSize: ScreenUtil().setSp(15),
                fontColor: FB_PRIMARY,
                height: ScreenUtil().setHeight(10),
                width: ScreenUtil().setWidth(10),
                hintText: 'Last name',
                hintTextSize: ScreenUtil().setSp(15),
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),

              /// MOBILE NUMBER
              CustomTextFormField(
                controller: mobilenumberController,
                validator: (value) => null,
                onSaved: (value) {},
                fontSize: ScreenUtil().setSp(15),
                fontColor: FB_PRIMARY,
                height: ScreenUtil().setHeight(10),
                width: ScreenUtil().setWidth(10),
                hintText: 'Mobile Number',
                hintTextSize: ScreenUtil().setSp(15),
                maxLength: 11,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),

              /// PASSWORD
              CustomTextFormField(
                controller: passwordController,
                isObscure: _isPasswordHidden,
                validator: (value) => null,
                onSaved: (value) {},
                fontSize: ScreenUtil().setSp(15),
                fontColor: FB_PRIMARY,
                height: ScreenUtil().setHeight(10),
                width: ScreenUtil().setWidth(10),
                hintText: 'Password',
                hintTextSize: ScreenUtil().setSp(15),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordHidden
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: FB_PRIMARY,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordHidden = !_isPasswordHidden;
                    });
                  },
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),

              Text(
                'Password should be 8 characters, a mixture of letters and numbers, at least one special character, uppercase and lowercase letters.',
                style: TextStyle(
                  color: FB_PRIMARY,
                  fontSize: ScreenUtil().setSp(10),
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),

              /// CONFIRM PASSWORD
              CustomTextFormField(
                controller: confirmpasswordController,
                isObscure: _isConfirmPasswordHidden,
                validator: (value) => null,
                onSaved: (value) {},
                fontSize: ScreenUtil().setSp(15),
                fontColor: FB_PRIMARY,
                height: ScreenUtil().setHeight(10),
                width: ScreenUtil().setWidth(10),
                hintText: 'Confirm Password',
                hintTextSize: ScreenUtil().setSp(15),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordHidden
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: FB_PRIMARY,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
                    });
                  },
                ),
              ),
              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'You have an account? ',
                    style: TextStyle(
                      color: FB_PRIMARY,
                      fontSize: ScreenUtil().setSp(15),
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.popAndPushNamed(context, '/login'),
                    child: Text(
                      'Login here',
                      style: TextStyle(
                        color: FB_PRIMARY,
                        fontSize: ScreenUtil().setSp(15),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),

              /// SUBMIT BUTTON
              CustomInkWellButton(
                onTap: register,
                height: ScreenUtil().setHeight(45),
                width: ScreenUtil().screenWidth,
                fontSize: ScreenUtil().setSp(15),
                fontWeight: FontWeight.bold,
                buttonName: 'Submit',
                bgColor: FB_SECONDARY,
                fontColor: FB_PRIMARY,
              ),
            ],
          ),
        ),
      ),
    );
  }
}