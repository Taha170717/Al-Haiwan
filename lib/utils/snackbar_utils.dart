import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnackbarType { success, error, warning, info }

class SnackbarUtils {
  static void showSnackbar({
    required String title,
    required String message,
    required SnackbarType type,
    Duration? duration,
    bool isDismissible = true,
  }) {
    Color backgroundColor;
    Color iconColor;
    IconData icon;

    switch (type) {
      case SnackbarType.success:
        backgroundColor = Color(0xFF4CAF50);
        iconColor = Colors.white;
        icon = Icons.check_circle_rounded;
        break;
      case SnackbarType.error:
        backgroundColor = Color(0xFFE53E3E);
        iconColor = Colors.white;
        icon = Icons.error_rounded;
        break;
      case SnackbarType.warning:
        backgroundColor = Color(0xFFFF9800);
        iconColor = Colors.white;
        icon = Icons.warning_rounded;
        break;
      case SnackbarType.info:
        backgroundColor = Color(0xFF199A8E);
        iconColor = Colors.white;
        icon = Icons.info_rounded;
        break;
    }

    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      icon: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.all(16),
      borderRadius: 16,
      duration: duration ?? Duration(seconds: 4),
      animationDuration: Duration(milliseconds: 800),
      forwardAnimationCurve: Curves.elasticOut,
      reverseAnimationCurve: Curves.fastOutSlowIn,
      boxShadows: [
        BoxShadow(
          color: backgroundColor.withOpacity(0.3),
          spreadRadius: 2,
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
      mainButton: isDismissible
          ? TextButton(
        onPressed: () => Get.closeCurrentSnackbar(),
        child: Icon(
          Icons.close_rounded,
          color: Colors.white.withOpacity(0.8),
          size: 20,
        ),
      )
          : null,
    );
  }

  // Convenience methods for different types
  static void showSuccess(String title, String message, {Duration? duration}) {
    showSnackbar(
      title: title,
      message: message,
      type: SnackbarType.success,
      duration: duration,
    );
  }

  static void showError(String title, String message, {Duration? duration}) {
    showSnackbar(
      title: title,
      message: message,
      type: SnackbarType.error,
      duration: duration,
    );
  }

  static void showWarning(String title, String message, {Duration? duration}) {
    showSnackbar(
      title: title,
      message: message,
      type: SnackbarType.warning,
      duration: duration,
    );
  }

  static void showInfo(String title, String message, {Duration? duration}) {
    showSnackbar(
      title: title,
      message: message,
      type: SnackbarType.info,
      duration: duration,
    );
  }

  // Special methods for common use cases
  static void showCopied(String item) {
    showSuccess(
      "Copied Successfully",
      "$item has been copied to clipboard",
      duration: Duration(seconds: 2),
    );
  }

  static void showNetworkError() {
    showError(
      "Network Error",
      "Please check your internet connection and try again",
    );
  }

  static void showValidationError(String field) {
    showWarning(
      "Missing Information",
      "Please enter $field",
      duration: Duration(seconds: 3),
    );
  }

  static void showLoading(String message) {
    showInfo(
      "Please Wait",
      message,
      duration: Duration(seconds: 2),
    );
  }
}