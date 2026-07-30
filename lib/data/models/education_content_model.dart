import 'package:equatable/equatable.dart';

class EducationContentModel extends Equatable {
  final String id;
  final String title;
  final String category; // 'Diabetes', 'Hypertension', 'HIV/AIDS', 'Mobility & Exercise'
  final String summary;
  final String body;
  final String iconName;
  final String readTime;
  final String articleUrl;
  final List<String> keyTakeaways;

  const EducationContentModel({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.body,
    required this.iconName,
    this.readTime = '5 min read',
    this.articleUrl = 'https://www.cdc.gov/diabetes/about/',
    this.keyTakeaways = const [],
  });

  factory EducationContentModel.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {
    return EducationContentModel(
      id: docId,
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      summary: map['summary'] ?? '',
      body: map['body'] ?? '',
      iconName: map['iconName'] ?? 'water_drop',
      readTime: map['readTime'] ?? '5 min read',
      articleUrl: map['articleUrl'] ?? 'https://www.cdc.gov/diabetes/about/',
      keyTakeaways: List<String>.from(map['keyTakeaways'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'summary': summary,
      'body': body,
      'iconName': iconName,
      'readTime': readTime,
      'articleUrl': articleUrl,
      'keyTakeaways': keyTakeaways,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        category,
        summary,
        body,
        iconName,
        readTime,
        articleUrl,
        keyTakeaways
      ];
}
