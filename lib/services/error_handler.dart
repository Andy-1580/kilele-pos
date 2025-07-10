import 'package:flutter/material.dart';

class ErrorHandler {
  static void handleError(BuildContext context, dynamic error) {
    String message = 'An unexpected error occurred';

    if (error is NetworkException) {
      message = 'Network error. Please check your connection.';
    } else if (error is ValidationException) {
      message = error.message;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Network error']);
}

class ValidationException implements Exception {
  final String message;
  ValidationException([this.message = 'Validation error']);
}
