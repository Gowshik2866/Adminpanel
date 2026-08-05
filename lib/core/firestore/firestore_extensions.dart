import 'package:cloud_firestore/cloud_firestore.dart';

extension FirestoreDateTimeExtension on Timestamp {
  DateTime toDateTime() => toDate();
}

extension DateTimeFirestoreExtension on DateTime {
  Timestamp toTimestamp() => Timestamp.fromDate(this);
}

extension SafeMapHelper on Map<String, dynamic> {
  String safeString(String key, {String defaultValue = ''}) {
    return this[key]?.toString() ?? defaultValue;
  }

  int safeInt(String key, {int defaultValue = 0}) {
    final val = this[key];
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) return int.tryParse(val) ?? defaultValue;
    return defaultValue;
  }
  
  double safeDouble(String key, {double defaultValue = 0.0}) {
    final val = this[key];
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? defaultValue;
    return defaultValue;
  }

  bool safeBool(String key, {bool defaultValue = false}) {
    final val = this[key];
    if (val is bool) return val;
    if (val is String) return val.toLowerCase() == 'true';
    return defaultValue;
  }
  
  DateTime? safeDateTime(String key) {
    final val = this[key];
    if (val is Timestamp) return val.toDate();
    if (val is String) return DateTime.tryParse(val);
    return null;
  }
}
