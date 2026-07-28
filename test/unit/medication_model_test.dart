import 'package:flutter_test/flutter_test.dart';
import 'package:medremind/data/models/medication_model.dart';

void main() {
  group('MedicationModel Unit Tests', () {
    final now = DateTime(2026, 7, 26, 12, 0);
    final med = MedicationModel(
      id: 'med_999',
      userId: 'user_456',
      name: 'Metformin',
      dosage: '500mg',
      frequency: 'Daily',
      times: const ['08:00', '20:00'],
      instructions: 'Take with meal',
      inventoryCount: 42,
      createdAt: now,
    );

    test('toMap converts MedicationModel correctly to Firestore map', () {
      final map = med.toMap();
      expect(map['id'], 'med_999');
      expect(map['userId'], 'user_456');
      expect(map['name'], 'Metformin');
      expect(map['dosage'], '500mg');
      expect(map['times'], ['08:00', '20:00']);
      expect(map['inventoryCount'], 42);
      expect(map['createdAt'], now.toIso8601String());
    });

    test('fromMap constructs valid MedicationModel from map data', () {
      final map = {
        'userId': 'user_456',
        'name': 'Metformin',
        'dosage': '500mg',
        'frequency': 'Daily',
        'times': ['08:00', '20:00'],
        'instructions': 'Take with meal',
        'inventoryCount': 42,
        'createdAt': now.toIso8601String(),
      };

      final restored = MedicationModel.fromMap(map, 'med_999');
      expect(restored.id, 'med_999');
      expect(restored.name, 'Metformin');
      expect(restored.inventoryCount, 42);
      expect(restored.times.length, 2);
    });

    test('copyWith updates specified fields correctly', () {
      final updated = med.copyWith(inventoryCount: 41, name: 'Metformin XR');
      expect(updated.inventoryCount, 41);
      expect(updated.name, 'Metformin XR');
      expect(updated.dosage, '500mg'); // Unchanged
    });
  });
}