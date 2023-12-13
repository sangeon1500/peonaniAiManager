import 'package:flutter/material.dart';
import '../components/image_dialog.dart';

class PeonaniDialog {
  static void showModal({
    required BuildContext context,
    required Widget child,
  }) {
    showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: "취소",
      transitionDuration: const Duration(milliseconds: 500),
      transitionBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) =>
          SlideTransition(
        position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
            .animate(animation),
        child: child,
      ),
      context: context,
      pageBuilder: (_, __, ___) =>
          Align(alignment: Alignment.bottomCenter, child: child),
    );
  }

  static void showImage({required BuildContext context, required Image image}) {
    showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: "취소",
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) =>
          AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 300),
        child: child,
      ),
      context: context,
      pageBuilder: (_, __, ___) => Align(
        alignment: Alignment.center,
        child: ImageDialog(
          image: image,
        ),
      ),
    );
  }
}
