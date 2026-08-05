class FirestoreException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  FirestoreException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() {
    if (code != null) {
      return 'FirestoreException [$code]: $message';
    }
    return 'FirestoreException: $message';
  }
}
