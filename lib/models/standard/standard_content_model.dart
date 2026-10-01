// Contenu du mode "Standard" : l'apprenant ne choisit pas de thème, le
// contenu lui est poussé session par session. En attendant le web service,
// ces objets sont construits à partir de données moquées
// (voir StandardContentService).

// 'vocabulary' : un mot + sa traduction (+ exemple facultatif)
// 'phrase'     : une expression complète + traduction
// 'quiz'       : question à choix multiple sur ce qui vient d'être vu
enum StandardItemType { vocabulary, phrase, quiz }

class StandardItem {
  final String id;
  final StandardItemType type;
  // vocabulary / phrase
  final String? term;
  final String? translation;
  final String? example;
  final String? exampleTranslation;
  // quiz
  final String? question;
  final List<String> options;
  final int? answerIndex;

  const StandardItem({
    required this.id,
    required this.type,
    this.term,
    this.translation,
    this.example,
    this.exampleTranslation,
    this.question,
    this.options = const [],
    this.answerIndex,
  });

  factory StandardItem.fromJson(Map<String, dynamic> json) {
    final rawType = json['type']?.toString() ?? '';
    return StandardItem(
      id: json['id']?.toString() ?? '',
      type: StandardItemType.values.firstWhere(
        (t) => t.name == rawType,
        orElse: () => StandardItemType.vocabulary,
      ),
      term: json['term']?.toString(),
      translation: json['translation']?.toString(),
      example: json['example']?.toString(),
      exampleTranslation: json['exampleTranslation']?.toString(),
      question: json['question']?.toString(),
      options: (json['options'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      answerIndex: json['answerIndex'] is int
          ? json['answerIndex'] as int
          : int.tryParse('${json['answerIndex']}'),
    );
  }
}

// Une session = une petite capsule de contenu (quelques cartes puis un quiz).
class StandardSession {
  final String id;
  final String title;
  final int estimatedMinutes;
  final List<StandardItem> items;

  const StandardSession({
    required this.id,
    required this.title,
    required this.estimatedMinutes,
    required this.items,
  });

  int get quizCount =>
      items.where((i) => i.type == StandardItemType.quiz).length;

  factory StandardSession.fromJson(Map<String, dynamic> json) {
    return StandardSession(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      estimatedMinutes: json['estimatedMinutes'] is int
          ? json['estimatedMinutes'] as int
          : int.tryParse('${json['estimatedMinutes']}') ?? 3,
      items: (json['items'] as List? ?? [])
          .map((e) => StandardItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}
