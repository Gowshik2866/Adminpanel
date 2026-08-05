import 'package:cloud_firestore/cloud_firestore.dart';

/// Converts a Firestore Timestamp to a DateTime and vice versa
/// Useful for modeling if using built-in serialization, 
/// but can also be used manually in fromMap/toMap.
class TimestampConverter {
  const TimestampConverter();

  DateTime fromJson(Timestamp timestamp) {
    return timestamp.toDate();
  }

  Timestamp toJson(DateTime date) {
    return Timestamp.fromDate(date);
  }
}
