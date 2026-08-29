import 'package:flutter/services.dart';
import '../constants.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    this.validator,
    this.onSaved,
    required this.fontSize,
    required this.fontColor,
    required this.height,
    required this.width,
    required this.controller,
    this.isObscure = false,
    this.hintTextSize = 12.0,
    this.hintText = '',
    this.fillColor = const Color.fromARGB(31, 133, 126, 126),
    this.keyboardType = TextInputType.text,
    this.maxLength = 200,
    this.suffixIcon,
  });


  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final TextEditingController? controller;
  final bool isObscure;

  final double fontSize;          
  final Color fontColor;          
  final double height;            
  final double width;             
  final double hintTextSize;    

  final String hintText;
  final Color fillColor;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      onSaved: onSaved,
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      inputFormatters: [
        LengthLimitingTextInputFormatter(maxLength),
      ],
      style: TextStyle(
        fontSize: fontSize,
        color: fontColor,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(
          width,
          height,
          width,
          height,
        ),
        suffixIcon: suffixIcon,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: FB_PRIMARY,
            width: 2,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: FB_PRIMARY,
            width: 2,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        filled: true,
        hintStyle: TextStyle(
          color: FB_LIGHT_PRIMARY,
          fontSize: hintTextSize,
        ),
        hintText: hintText,
        fillColor: fillColor,
      ),
    );
  }
}