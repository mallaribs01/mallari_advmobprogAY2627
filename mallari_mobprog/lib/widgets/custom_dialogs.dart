import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mallari_mobprog/constants.dart';
import 'package:mallari_mobprog/widgets/custom_font.dart';

/// SIMPLE OKAY DIALOG
void customDialog(
  BuildContext context, {
  required String title,
  required String content,
}) {
  AlertDialog alertDialog = AlertDialog(
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    content: Text(content),
    actions: [
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: FB_SECONDARY,
          foregroundColor: FB_PRIMARY,
        ),
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Okay'),
      ),
    ],
  );

  showDialog(context: context, builder: (context) => alertDialog);
}

/// YES / NO OPTION DIALOG
void customOptionDialog(
  BuildContext context, {
  required String title,
  required String content,
  required Function onYes,
}) {
  AlertDialog alertDialog = AlertDialog(
    title: CustomFont(text: title, fontSize: 30.sp),
    content: CustomFont(text: content),
    actions: [
      OutlinedButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const CustomFont(text: 'No'),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: FB_DARK_PRIMARY,
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          Navigator.of(context).pop();
          onYes();
        },
        child: const CustomFont(text: 'Yes', color: FB_TEXT_COLOR_WHITE),
      ),
    ],
  );

  showDialog(context: context, builder: (context) => alertDialog);
}

/// IMAGE PREVIEW DIALOG (ENHANCEMENT 3)
/// Handles BOTH Network & Asset Images
void customShowImageDialog(
  BuildContext context, {
  required String imagePath,
  bool isAsset = false,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 350.h,
                width: double.infinity,
                color: FB_SECONDARY,
                child: isAsset
                    ? Image.asset(imagePath, fit: BoxFit.contain)
                    : CachedNetworkImage(
                        imageUrl: imagePath,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(color: FB_PRIMARY),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
              ),
            ),

            /// CLOSE BUTTON
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: FB_PRIMARY, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      );
    },
  );
}
