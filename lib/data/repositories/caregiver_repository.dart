import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/caregiver_model.dart';

class CaregiverRepository {
  final FirebaseFirestore? _customFirestore;
  final Map<String, List<CaregiverModel>> _userCaregiversMap = {};
  final _caregiversStreamController =
      StreamController<List<CaregiverModel>>.broadcast();

  CaregiverRepository({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  List<CaregiverModel> _getCaregiversForUser(String userId) {
    if (!_userCaregiversMap.containsKey(userId)) {
      _userCaregiversMap[userId] = [];
    }
    return _userCaregiversMap[userId]!;
  }

  Stream<List<CaregiverModel>> getCaregiversStream(String userId) {
    try {
      final db = _firestore;
      if (db != null) {
        return db
            .collection('caregivers')
            .where('userId', isEqualTo: userId)
            .snapshots()
            .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => CaregiverModel.fromMap(doc.data(), doc.id))
              .toList();
          _userCaregiversMap[userId] = list;
          return list;
        });
      }
    } catch (_) {}
    Timer.run(() =>
        _caregiversStreamController.add(List.from(_getCaregiversForUser(userId))));
    return _caregiversStreamController.stream;
  }

  Future<void> addCaregiver(CaregiverModel caregiver) async {
    final list = _getCaregiversForUser(caregiver.userId);
    try {
      final db = _firestore;
      if (db != null) {
        final docRef = db.collection('caregivers').doc();
        final newCg = CaregiverModel(
          id: docRef.id,
          userId: caregiver.userId,
          name: caregiver.name,
          relationship: caregiver.relationship,
          email: caregiver.email,
          status: caregiver.status,
          createdAt: DateTime.now(),
        );
        await docRef.set(newCg.toMap());
        list.add(newCg);
      } else {
        final newCg = CaregiverModel(
          id: 'cg_${DateTime.now().millisecondsSinceEpoch}',
          userId: caregiver.userId,
          name: caregiver.name,
          relationship: caregiver.relationship,
          email: caregiver.email,
          status: caregiver.status,
          createdAt: DateTime.now(),
        );
        list.add(newCg);
      }
    } catch (_) {
      final newCg = CaregiverModel(
        id: 'cg_${DateTime.now().millisecondsSinceEpoch}',
        userId: caregiver.userId,
        name: caregiver.name,
        relationship: caregiver.relationship,
        email: caregiver.email,
        status: caregiver.status,
        createdAt: DateTime.now(),
      );
      list.add(newCg);
    }
    _caregiversStreamController.add(List.from(list));
  }

  Future<void> sendEmergencyAlert(String userId) async {
    try {
      final db = _firestore;
      if (db != null) {
        await db.collection('alerts').add({
          'userId': userId,
          'type': 'EMERGENCY_ASSISTANCE',
          'timestamp': FieldValue.serverTimestamp(),
          'message': 'Patient has requested urgent assistance!',
        });
      }
    } catch (_) {}
  }

  void dispose() {
    _caregiversStreamController.close();
  }
}
