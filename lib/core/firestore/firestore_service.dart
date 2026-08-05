import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sample_app/core/firestore/firestore_exception.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  WriteBatch batch() => _firestore.batch();

  FirebaseFirestore get db => _firestore;

  Future<void> addDocument({
    required String path,
    required Map<String, dynamic> data,
    String? docId,
  }) async {
    try {
      if (docId != null) {
        await _firestore.collection(path).doc(docId).set(data);
      } else {
        await _firestore.collection(path).add(data);
      }
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in addDocument',
        error: e,
        stackTrace: stackTrace,
      );
      throw FirestoreException(
        message: e.message ?? 'Unknown error',
        code: e.code,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Exception in addDocument',
        error: e,
        stackTrace: stackTrace,
      );
      throw FirestoreException(message: e.toString());
    }
  }

  Future<void> updateDocument({
    required String path,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(path).doc(docId).update(data);
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in updateDocument',
        error: e,
        stackTrace: stackTrace,
      );
      throw FirestoreException(
        message: e.message ?? 'Unknown error',
        code: e.code,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Exception in updateDocument',
        error: e,
        stackTrace: stackTrace,
      );
      throw FirestoreException(message: e.toString());
    }
  }

  Future<void> deleteDocument({
    required String path,
    required String docId,
  }) async {
    try {
      await _firestore.collection(path).doc(docId).delete();
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in deleteDocument',
        error: e,
        stackTrace: stackTrace,
      );
      throw FirestoreException(
        message: e.message ?? 'Unknown error',
        code: e.code,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Exception in deleteDocument',
        error: e,
        stackTrace: stackTrace,
      );
      throw FirestoreException(message: e.toString());
    }
  }

  Stream<List<T>> collectionStream<T>({
    required String path,
    required T Function(Map<String, dynamic> data, String documentId) builder,
    Query Function(Query query)? queryBuilder,
    int Function(T lhs, T rhs)? sort,
  }) {
    try {
      Query query = _firestore.collection(path);
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }
      final Stream<QuerySnapshot> snapshots = query.snapshots();
      return snapshots.map((snapshot) {
        final result = snapshot.docs
            .map(
              (snapshot) =>
                  builder(snapshot.data() as Map<String, dynamic>, snapshot.id),
            )
            .toList();
        if (sort != null) {
          result.sort(sort);
        }
        return result;
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Unknown error',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  Stream<T> documentStream<T>({
    required String path,
    required String docId,
    required T Function(Map<String, dynamic>? data, String documentId) builder,
  }) {
    try {
      final DocumentReference reference = _firestore
          .collection(path)
          .doc(docId);
      final Stream<DocumentSnapshot> snapshots = reference.snapshots();
      return snapshots.map(
        (snapshot) =>
            builder(snapshot.data() as Map<String, dynamic>?, snapshot.id),
      );
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Unknown error',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  Future<List<T>> getCollection<T>({
    required String path,
    required T Function(Map<String, dynamic> data, String documentId) builder,
    Query Function(Query query)? queryBuilder,
    int Function(T lhs, T rhs)? sort,
  }) async {
    try {
      Query query = _firestore.collection(path);
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }
      final QuerySnapshot snapshot = await query.get();
      final result = snapshot.docs
          .map((doc) => builder(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      if (sort != null) {
        result.sort(sort);
      }
      return result;
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Unknown error',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  Future<T> getDocument<T>({
    required String path,
    required String docId,
    required T Function(Map<String, dynamic>? data, String documentId) builder,
  }) async {
    try {
      final DocumentReference reference = _firestore
          .collection(path)
          .doc(docId);
      final DocumentSnapshot snapshot = await reference.get();
      return builder(snapshot.data() as Map<String, dynamic>?, snapshot.id);
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Unknown error',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }
}
