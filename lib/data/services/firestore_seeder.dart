import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreSeeder {
  static Future<void> seedDatabaseIfEmpty(String userId) async {
    try {
      final db = FirebaseFirestore.instance;

      // Seed Education Content Collection
      try {
        final eduSnapshot = await db
            .collection('education_content')
            .get()
            .timeout(const Duration(seconds: 4));
        if (eduSnapshot.docs.isEmpty) {
          debugPrint('Seeding education_content collection into Firestore...');
          final eduArticles = [
            {
              'title': 'Understanding Type 2 Diabetes',
              'category': 'Diabetes',
              'summary':
                  'A comprehensive guide by the CDC on managing and understanding your diagnosis.',
              'body':
                  'Type 2 diabetes is a chronic condition affecting how your body processes blood sugar (glucose). Taking prescribed medications consistently, tracking glucose, eating fiber-rich meals, and engaging in daily walking keep blood sugar balanced.',
              'iconName': 'water_drop',
              'readTime': '8 min read',
              'articleUrl': 'https://www.cdc.gov/diabetes/about/',
              'keyTakeaways': [
                'Learn the root causes of blood sugar spikes',
                'Understand insulin resistance and daily medication care',
                'Identify early symptoms and emergency signs',
              ],
            },
            {
              'title': 'Managing High Blood Pressure',
              'category': 'Hypertension',
              'summary':
                  'Evidence-based clinical guidelines by the CDC to control hypertension safely.',
              'body':
                  'High blood pressure (hypertension) often presents no early symptoms. Consistent daily adherence to anti-hypertensive treatment, reducing sodium intake, maintaining a calm routine, and visiting your health center regularly prevent stroke and heart complications.',
              'iconName': 'monitor_heart',
              'readTime': '6 min read',
              'articleUrl': 'https://www.cdc.gov/high-blood-pressure/about/',
              'keyTakeaways': [
                'Monitor blood pressure readings at home',
                'Reduce sodium and salt intake in daily meals',
                'Take anti-hypertensives at the exact same hour daily',
              ],
            },
            {
              'title': 'Tips for HIV ART Medication',
              'category': 'HIV/AIDS',
              'summary':
                  'Maintaining strict viral suppression and protecting your immune health.',
              'body':
                  'Antiretroviral therapy (ART) must be taken every day at the scheduled time. High adherence (>95%) prevents viral multiplication, protects CD4 T-cells, and achieves undetectable viral load.',
              'iconName': 'shield',
              'readTime': '5 min read',
              'articleUrl': 'https://www.cdc.gov/hiv/about/',
              'keyTakeaways': [
                'Never skip daily ART doses',
                'Set automated pill reminder alerts',
                'Maintain open communication with your care team',
              ],
            },
            {
              'title': 'Mobility & Physical Activity',
              'category': 'Mobility & Exercise',
              'summary':
                  'Safe, low-impact movements recommended for long-term health and circulation.',
              'body':
                  'Regular physical movement improves circulation, supports cardiovascular health, and reduces joint stiffness. Walking 20 to 30 minutes daily or gentle stretching enhances energy and treatment response.',
              'iconName': 'directions_walk',
              'readTime': '7 min read',
              'articleUrl': 'https://www.cdc.gov/physical-activity-basics/',
              'keyTakeaways': [
                'Aim for 150 minutes of moderate activity per week',
                'Incorporate light stretching between long sitting periods',
                'Stay hydrated before and after exercises',
              ],
            },
          ];

          for (final article in eduArticles) {
            await db
                .collection('education_content')
                .add(article)
                .timeout(const Duration(seconds: 3));
          }
          debugPrint('education_content collection successfully seeded!');
        }
      } catch (e) {
        debugPrint('Notice seeding education_content: $e');
      }

      // Seed Users Collection
      try {
        final userDoc = await db
            .collection('users')
            .doc(userId)
            .get()
            .timeout(const Duration(seconds: 4));
        if (!userDoc.exists) {
          debugPrint('Seeding user document into users collection for $userId...');
          await db.collection('users').doc(userId).set({
            'uid': userId,
            'email': 'patient@medremind.com',
            'fullName': 'Patient User',
            'phoneNumber': '+250 788 123 456',
            'createdAt': FieldValue.serverTimestamp(),
          }).timeout(const Duration(seconds: 3));
        }
      } catch (e) {
        debugPrint('Notice seeding user doc: $e');
      }
    } catch (e) {
      debugPrint('FirestoreSeeder Notice: $e');
    }
  }
}
