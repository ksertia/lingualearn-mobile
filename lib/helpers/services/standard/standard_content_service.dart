import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tibi/models/standard/standard_content_model.dart';

// Mode "Standard" : le contenu est poussé à l'apprenant session après session,

class StandardContentService {
  static const _kCursorPrefix = 'standard_session_cursor_';
  static final _random = Random();

  // Titre de la prochaine session, pour l'aperçu sur l'accueil.
  static Future<StandardSession> peekNextSession({required String languageId}) async {
    final cursor = await _readCursor(languageId);
    return StandardSession.fromJson(_mockSessions[cursor % _mockSessions.length]);
  }

  // Séquentiel : on parcourt les sessions dans l'ordre (le curseur est
  // mémorisé par langue). Aléatoire : les réponses des quiz sont mélangées à
  // chaque fois pour que la même session ne se rejoue pas à l'identique.
  static Future<StandardSession> getNextSession({required String languageId}) async {
    await Future.delayed(const Duration(milliseconds: 500)); // simule le réseau
    final cursor = await _readCursor(languageId);
    final session =
        StandardSession.fromJson(_mockSessions[cursor % _mockSessions.length]);
    return StandardSession(
      id: session.id,
      title: session.title,
      estimatedMinutes: session.estimatedMinutes,
      items: session.items.map(_shuffleQuiz).toList(),
    );
  }

  // Appelé en fin de session : la prochaine ouverture servira la suivante.
  static Future<void> markSessionCompleted({required String languageId}) async {
    final prefs = await SharedPreferences.getInstance();
    final cursor = prefs.getInt('$_kCursorPrefix$languageId') ?? 0;
    await prefs.setInt('$_kCursorPrefix$languageId', cursor + 1);
  }

  static Future<int> _readCursor(String languageId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_kCursorPrefix$languageId') ?? 0;
  }

  static StandardItem _shuffleQuiz(StandardItem item) {
    if (item.type != StandardItemType.quiz || item.answerIndex == null) return item;
    final correct = item.options[item.answerIndex!];
    final shuffled = [...item.options]..shuffle(_random);
    return StandardItem(
      id: item.id,
      type: item.type,
      question: item.question,
      options: shuffled,
      answerIndex: shuffled.indexOf(correct),
    );
  }

  // ── Données moquées (dioula) ───────────────────────────────────────────────

  static const List<Map<String, dynamic>> _mockSessions = [
    {
      'id': 'mock-session-1',
      'title': 'Saluer au fil de la journée',
      'estimatedMinutes': 3,
      'items': [
        {
          'id': 's1-1',
          'type': 'phrase',
          'term': 'I ni sɔgɔma',
          'translation': 'Bonjour (le matin)',
          'example': 'I ni sɔgɔma, n teri !',
          'exampleTranslation': 'Bonjour, mon ami !',
        },
        {
          'id': 's1-2',
          'type': 'phrase',
          'term': 'I ni tile',
          'translation': 'Bonjour (l\'après-midi)',
        },
        {
          'id': 's1-3',
          'type': 'phrase',
          'term': 'I ni wula',
          'translation': 'Bonsoir',
        },
        {
          'id': 's1-4',
          'type': 'quiz',
          'question': 'Comment dit-on « Bonjour » le matin ?',
          'options': ['I ni sɔgɔma', 'I ni wula', 'I ni tile'],
          'answerIndex': 0,
        },
      ],
    },
    {
      'id': 'mock-session-2',
      'title': 'Prendre des nouvelles',
      'estimatedMinutes': 3,
      'items': [
        {
          'id': 's2-1',
          'type': 'phrase',
          'term': 'I ka kɛnɛ wa ?',
          'translation': 'Tu vas bien ?',
        },
        {
          'id': 's2-2',
          'type': 'phrase',
          'term': 'Tɔɔrɔ si tɛ',
          'translation': 'Il n\'y a pas de mal (ça va)',
        },
        {
          'id': 's2-3',
          'type': 'vocabulary',
          'term': 'I ni ce',
          'translation': 'Merci',
          'example': 'I ni ce kosɛbɛ !',
          'exampleTranslation': 'Merci beaucoup !',
        },
        {
          'id': 's2-4',
          'type': 'quiz',
          'question': 'Que signifie « I ka kɛnɛ wa ? »',
          'options': ['Tu vas bien ?', 'Comment t\'appelles-tu ?', 'Au revoir'],
          'answerIndex': 0,
        },
        {
          'id': 's2-5',
          'type': 'quiz',
          'question': 'Comment dit-on « Merci » ?',
          'options': ['I ni ce', 'I ni wula', 'Tɔɔrɔ si tɛ'],
          'answerIndex': 0,
        },
      ],
    },
    {
      'id': 'mock-session-3',
      'title': 'Compter jusqu\'à cinq',
      'estimatedMinutes': 4,
      'items': [
        {'id': 's3-1', 'type': 'vocabulary', 'term': 'kelen', 'translation': 'un (1)'},
        {'id': 's3-2', 'type': 'vocabulary', 'term': 'fila', 'translation': 'deux (2)'},
        {'id': 's3-3', 'type': 'vocabulary', 'term': 'saba', 'translation': 'trois (3)'},
        {'id': 's3-4', 'type': 'vocabulary', 'term': 'naani', 'translation': 'quatre (4)'},
        {'id': 's3-5', 'type': 'vocabulary', 'term': 'duuru', 'translation': 'cinq (5)'},
        {
          'id': 's3-6',
          'type': 'quiz',
          'question': 'Quel mot signifie « trois » ?',
          'options': ['saba', 'fila', 'duuru', 'kelen'],
          'answerIndex': 0,
        },
        {
          'id': 's3-7',
          'type': 'quiz',
          'question': 'Que signifie « naani » ?',
          'options': ['quatre', 'deux', 'cinq', 'un'],
          'answerIndex': 0,
        },
      ],
    },
    {
      'id': 'mock-session-4',
      'title': 'La famille proche',
      'estimatedMinutes': 3,
      'items': [
        {'id': 's4-1', 'type': 'vocabulary', 'term': 'fa', 'translation': 'père'},
        {'id': 's4-2', 'type': 'vocabulary', 'term': 'ba', 'translation': 'mère'},
        {
          'id': 's4-3',
          'type': 'vocabulary',
          'term': 'den',
          'translation': 'enfant',
          'example': 'N den don.',
          'exampleTranslation': 'C\'est mon enfant.',
        },
        {
          'id': 's4-4',
          'type': 'quiz',
          'question': 'Comment dit-on « mère » ?',
          'options': ['ba', 'fa', 'den'],
          'answerIndex': 0,
        },
      ],
    },
  ];
}
