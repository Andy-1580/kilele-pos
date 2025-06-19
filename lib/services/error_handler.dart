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
