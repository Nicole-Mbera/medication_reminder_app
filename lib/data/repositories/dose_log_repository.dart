import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dose_log_model.dart';

class DoseLogRepository {
  final FirebaseFirestore? _customFirestore;
  final Map<String, List<DoseLogModel>> _userLogsMap = {};
  final _logsStreamController =
      StreamController<List<DoseLogModel>>.broadcast();

  DoseLogRepository({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  List<DoseLogModel> _getLogsForUser(String userId) {
    if (!_userLogsMap.containsKey(userId)) {
      _userLogsMap[userId] = [];
    }
    return _userLogsMap[userId]!;
  }

  Stream<List<DoseLogModel>> getDoseLogsStream(String userId) {
    try {
      final db = _firestore;
      if (db != null) {
        return db
            .collection('dose_logs')
            .where('userId', isEqualTo: userId)
            .snapshots()
            .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => DoseLogModel.fromMap(doc.data(), doc.id))
              .toList();
          if (list.isNotEmpty) {
            _userLogsMap[userId] = list;
            return list;
          }
          return _getLogsForUser(userId);
        });
      }
    } catch (_) {}
    Timer.run(() => _logsStreamController.add(List.from(_getLogsForUser(userId))));
    return _logsStreamController.stream;
  }

  Future<void> logDose(DoseLogModel log) async {
    final userLogs = _getLogsForUser(log.userId);

    // Check if a log already exists for this medication on the same date
    final existingIndex = userLogs.indexWhere((l) =>
        l.medicationName == log.medicationName &&
        l.scheduledTime.year == log.scheduledTime.year &&
        l.scheduledTime.month == log.scheduledTime.month &&
        l.scheduledTime.day == log.scheduledTime.day);

    final logId = existingIndex != -1
        ? userLogs[existingIndex].id
        : 'log_${DateTime.now().millisecondsSinceEpoch}';

    final updatedLog = DoseLogModel(
      id: logId,
      medicationId: log.medicationId,
      medicationName: log.medicationName,
      userId: log.userId,
      scheduledTime: log.scheduledTime,
      status: log.status,
      loggedAt: DateTime.now(),
    );

    try {
      final db = _firestore;
      if (db != null) {
        final docRef = db.collection('dose_logs').doc(logId);
        await docRef.set(updatedLog.toMap(), SetOptions(merge: true));
      }
    } catch (_) {}

    if (existingIndex != -1) {
      userLogs[existingIndex] = updatedLog;
    } else {
      userLogs.insert(0, updatedLog);
    }

    _logsStreamController.add(List.from(userLogs));
  }

  double calculateAdherencePercentage(List<DoseLogModel> logs) {
    if (logs.isEmpty) return 0.0;
    final takenCount = logs.where((l) => l.status == 'taken').length;
    return (takenCount / logs.length) * 100.0;
  }

  void dispose() {
    _logsStreamController.close();
  }
}
