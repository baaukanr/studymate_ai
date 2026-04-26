import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'auth_service.dart';

const _collection = 'study_snapshots';

Future<String?> _currentUserDocId() async {
  final user = await AuthService.getCachedUser();
  if (user == null) return null;
  if (user.id.isNotEmpty) return user.id;
  final email = user.email.trim().toLowerCase();
  if (email.isNotEmpty) return email;
  return null;
}

Future<void> pushStudySnapshotFirestore(Map<String, dynamic> payload) async {
  final docId = await _currentUserDocId();
  if (docId == null) {
    debugPrint('[firestore] skip push: user doc id is null');
    return;
  }
  try {
    await FirebaseFirestore.instance.collection(_collection).doc(docId).set({
      ...payload,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    debugPrint('[firestore] push success: doc=$docId');
  } catch (e) {
    debugPrint('[firestore] push failed: doc=$docId error=$e');
  }
}

Future<Map<String, dynamic>?> fetchStudySnapshotFirestore() async {
  final docId = await _currentUserDocId();
  if (docId == null) {
    debugPrint('[firestore] skip fetch: user doc id is null');
    return null;
  }
  try {
    final snap = await FirebaseFirestore.instance.collection(_collection).doc(docId).get();
    final data = snap.data();
    if (data == null) {
      debugPrint('[firestore] fetch success but empty: doc=$docId');
      return null;
    }
    debugPrint('[firestore] fetch success: doc=$docId');
    return {
      'exams': data['exams'] is List ? data['exams'] : const [],
      'plans': data['plans'] is List ? data['plans'] : const [],
      'recentMaterials': data['recentMaterials'] is List ? data['recentMaterials'] : const [],
    };
  } catch (e) {
    debugPrint('[firestore] fetch failed: doc=$docId error=$e');
    return null;
  }
}
