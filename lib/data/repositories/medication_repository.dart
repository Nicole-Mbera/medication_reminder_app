import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medication_model.dart';

class MedicationRepository {
  final FirebaseFirestore? _customFirestore;
  final Map<String, List<MedicationModel>> _userMedsMap = {};
  final _medsStreamController =
      StreamController<List<MedicationModel>>.broadcast();

  MedicationRepository({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  List<MedicationModel> _getMedsForUser(String userId) {
    if (!_userMedsMap.containsKey(userId)) {
      _userMedsMap[userId] = [];
    }
    return _userMedsMap[userId]!;
  }

  Stream<List<MedicationModel>> getMedicationsStream(String userId) {
    try {
      final db = _firestore;
      if (db != null) {
        return db
            .collection('medications')
            .where('userId', isEqualTo: userId)
            .snapshots()
            .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => MedicationModel.fromMap(doc.data(), doc.id))
              .toList();
          _userMedsMap[userId] = list;
          return list;
        });
      }
    } catch (_) {}
    Timer.run(() => _medsStreamController.add(List.from(_getMedsForUser(userId))));
    return _medsStreamController.stream;
  }

  Future<List<MedicationModel>> getMedicationsOnce(String userId) async {
    try {
      final db = _firestore;
      if (db != null) {
        final snapshot = await db
            .collection('medications')
            .where('userId', isEqualTo: userId)
            .get();
        final list = snapshot.docs
            .map((doc) => MedicationModel.fromMap(doc.data(), doc.id))
            .toList();
        _userMedsMap[userId] = list;
        return list;
      }
    } catch (_) {}
    return List.from(_getMedsForUser(userId));
  }

  Future<void> addMedication(MedicationModel medication) async {
    final list = _getMedsForUser(medication.userId);
    try {
      final db = _firestore;
      if (db != null) {
        final docRef = db.collection('medications').doc();
        final newMed = medication.copyWith(id: docRef.id);
        await docRef.set(newMed.toMap());
        list.insert(0, newMed);
      } else {
        final newMed = medication.copyWith(
          id: medication.id.isNotEmpty
              ? medication.id
              : 'med_${DateTime.now().millisecondsSinceEpoch}',
        );
        list.insert(0, newMed);
      }
    } catch (_) {
      final newMed = medication.copyWith(
        id: medication.id.isNotEmpty
            ? medication.id
            : 'med_${DateTime.now().millisecondsSinceEpoch}',
      );
      list.insert(0, newMed);
    }
    _medsStreamController.add(List.from(list));
  }

  Future<void> updateMedication(MedicationModel medication) async {
    try {
      final db = _firestore;
      if (db != null) {
        await db
            .collection('medications')
            .doc(medication.id)
            .update(medication.toMap());
      }
    } catch (_) {}

    final list = _getMedsForUser(medication.userId);
    final index = list.indexWhere((m) => m.id == medication.id);
    if (index != -1) {
      list[index] = medication;
      _medsStreamController.add(List.from(list));
    }
  }

  Future<void> deleteMedication(String medicationId) async {
    try {
      final db = _firestore;
      if (db != null) {
        await db.collection('medications').doc(medicationId).delete();
      }
    } catch (_) {}

    for (final list in _userMedsMap.values) {
      list.removeWhere((m) => m.id == medicationId);
    }
  }

  void dispose() {
    _medsStreamController.close();
  }
}