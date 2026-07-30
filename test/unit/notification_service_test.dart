import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:medremind/data/models/dose_log_model.dart';
import 'package:medremind/data/repositories/dose_log_repository.dart';

void main() {
  group('DoseLogRepository Adherence Logic Unit Tests', () {
    late DoseLogRepository repo;

    setUp(() {
      final fakeFirestore = FakeFirebaseFirestore();
      repo = DoseLogRepository(firestore: fakeFirestore);
    });

    test('calculateAdherencePercentage returns 100% for empty logs', () {
      final pct = repo.calculateAdherencePercentage([]);
      expect(pct, 100.0);
    });

    test(
      'calculateAdherencePercentage calculates correct ratio for taken vs missed',
      () {
        final logs = [
          DoseLogModel(
            id: '1',
            medicationId: 'm1',
            medicationName: 'Med 1',
            userId: 'u1',
            scheduledTime: DateTime.now(),
            status: 'taken',
            loggedAt: DateTime.now(),
          ),
          DoseLogModel(
            id: '2',
            medicationId: 'm1',
            medicationName: 'Med 1',
            userId: 'u1',
            scheduledTime: DateTime.now(),
            status: 'taken',
            loggedAt: DateTime.now(),
          ),
          DoseLogModel(
            id: '3',
            medicationId: 'm1',
            medicationName: 'Med 1',
            userId: 'u1',
            scheduledTime: DateTime.now(),
            status: 'taken',
            loggedAt: DateTime.now(),
          ),
          DoseLogModel(
            id: '4',
            medicationId: 'm1',
            medicationName: 'Med 1',
            userId: 'u1',
            scheduledTime: DateTime.now(),
            status: 'missed',
            loggedAt: DateTime.now(),
          ),
        ];

        final pct = repo.calculateAdherencePercentage(logs);
        expect(pct, 75.0); // 3 taken out of 4 total = 75%
      },
    );
  });
}
