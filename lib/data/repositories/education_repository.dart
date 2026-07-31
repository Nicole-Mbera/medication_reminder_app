import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/education_content_model.dart';

class EducationRepository {
  final FirebaseFirestore? _customFirestore;
  final List<EducationContentModel> _inMemoryEducation = [
    const EducationContentModel(
      id: 'edu_1',
      title: 'Understanding Type 2 Diabetes',
      category: 'Diabetes',
      summary:
          'A comprehensive guide by the CDC on managing and understanding your diagnosis.',
      body:
          'Type 2 diabetes is a chronic condition affecting how your body processes blood sugar (glucose). Taking prescribed medications consistently, tracking glucose, eating fiber-rich meals, and engaging in daily walking keep blood sugar balanced.',
      iconName: 'water_drop',
      readTime: '8 min read',
      articleUrl: 'https://www.cdc.gov/diabetes/about/',
      keyTakeaways: [
        'Learn the root causes of blood sugar spikes',
        'Understand insulin resistance and daily medication care',
        'Identify early symptoms and emergency signs',
      ],
    ),
    const EducationContentModel(
      id: 'edu_2',
      title: 'Managing High Blood Pressure',
      category: 'Hypertension',
      summary:
          'Evidence-based clinical guidelines by the CDC to control hypertension safely.',
      body:
          'High blood pressure (hypertension) often presents no early symptoms. Consistent daily adherence to anti-hypertensive treatment, reducing sodium intake, maintaining a calm routine, and visiting your health center regularly prevent stroke and heart complications.',
      iconName: 'monitor_heart',
      readTime: '6 min read',
      articleUrl: 'https://www.cdc.gov/high-blood-pressure/about/',
      keyTakeaways: [
        'Monitor blood pressure readings at home',
        'Reduce sodium and salt intake in daily meals',
        'Take anti-hypertensives at the exact same hour daily',
      ],
    ),
    const EducationContentModel(
      id: 'edu_3',
      title: 'Tips for HIV ART Medication',
      category: 'HIV/AIDS',
      summary:
          'Maintaining strict viral suppression and protecting your immune health.',
      body:
          'Antiretroviral therapy (ART) must be taken every day at the scheduled time. High adherence (>95%) prevents viral multiplication, protects CD4 T-cells, and achieves undetectable viral load.',
      iconName: 'shield',
      readTime: '5 min read',
      articleUrl: 'https://www.cdc.gov/hiv/about/',
      keyTakeaways: [
        'Never skip daily ART doses',
        'Set automated pill reminder alerts',
        'Maintain open communication with your care team',
      ],
    ),
    const EducationContentModel(
      id: 'edu_4',
      title: 'Mobility & Physical Activity',
      category: 'Mobility & Exercise',
      summary:
          'Safe, low-impact movements recommended for long-term health and circulation.',
      body:
          'Regular physical movement improves circulation, supports cardiovascular health, and reduces joint stiffness. Walking 20 to 30 minutes daily or gentle stretching enhances energy and treatment response.',
      iconName: 'directions_walk',
      readTime: '7 min read',
      articleUrl: 'https://www.cdc.gov/physical-activity-basics/',
      keyTakeaways: [
        'Aim for 150 minutes of moderate activity per week',
        'Incorporate light stretching between long sitting periods',
        'Stay hydrated before and after exercises',
      ],
    ),
  ];

  EducationRepository({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  Future<List<EducationContentModel>> getArticles() async {
    try {
      final db = _firestore;
      if (db != null) {
        final snapshot = await db.collection('education_content').get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => EducationContentModel.fromMap(doc.data(), doc.id))
              .toList();
        }
      }
    } catch (_) {}
    return _inMemoryEducation;
  }
}
