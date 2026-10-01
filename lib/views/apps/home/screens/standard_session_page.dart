import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tibi/helpers/services/sound_service.dart';
import 'package:tibi/helpers/services/standard/standard_content_service.dart';
import 'package:tibi/helpers/theme/app_colors.dart';
import 'package:tibi/models/standard/standard_content_model.dart';
import 'package:tibi/widgets/mascots/quiz_mascot.dart';

const Color _kOrange = Color(0xFFF27F22);
const Color _kGreen = Color(0xFF188329);
const Color _kRed = Color(0xFFE53E3E);

// Mascotte qui anime une session. L'ordre suit celui de QuizMascotSelector
// (index % 4 → 0=Kadoua, 1=Awa, 2=Tiga, 3=Zaki).
class _Host {
  final int index;
  final String name;
  final Color color;
  const _Host(this.index, this.name, this.color);
}

const _kHosts = [
  _Host(0, 'Kadoua', Color(0xFFE91C8B)),
  _Host(1, 'Awa', Color(0xFF1A8A3C)),
  _Host(2, 'Tiga', Color(0xFFE5A800)),
  _Host(3, 'Zaki', Color(0xFF0099DD)),
];

const _kCorrectLines = [
  'Bravo, c\'est ça !',
  'Excellent, tu gères !',
  'Parfait, continue comme ça !',
  'Super réponse !',
];
const _kWrongLines = [
  'Presque ! Retiens bien celle-ci.',
  'Pas grave, c\'est comme ça qu\'on apprend !',
  'Oups ! La bonne réponse est en vert.',
];

Color _darken(Color c, [double amount = 0.18]) {
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}

// Mode "Standard" : une session de contenu poussée à l'apprenant, carte après
// carte, présentée par les mascottes — sans qu'il ait à choisir un thème.
class StandardSessionPage extends StatefulWidget {
  final String languageId;
  final String languageName;

  const StandardSessionPage({
    super.key,
    required this.languageId,
    required this.languageName,
  });

  @override
  State<StandardSessionPage> createState() => _StandardSessionPageState();
}

class _StandardSessionPageState extends State<StandardSessionPage> {
  final _random = Random();
  final ConfettiController _confetti =
      ConfettiController(duration: const Duration(milliseconds: 1500));

  StandardSession? _session;
  bool _loading = true;
  bool _hasError = false;
  bool _started = false;
  bool _finished = false;
  int _index = 0;

  bool _revealed = false; // carte mot/expression : traduction affichée
  int? _selectedOption; // carte quiz : réponse choisie
  int _correctAnswers = 0;
  String _feedbackLine = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _hasError = false;
      _started = false;
      _finished = false;
      _index = 0;
      _revealed = false;
      _selectedOption = null;
      _correctAnswers = 0;
    });
    try {
      final session =
          await StandardContentService.getNextSession(languageId: widget.languageId);
      if (!mounted) return;
      setState(() {
        _session = session;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasError = true;
      });
    }
  }

  StandardItem get _current => _session!.items[_index];
  bool get _isQuiz => _current.type == StandardItemType.quiz;
  bool get _answered => _selectedOption != null;
  bool get _isCorrect => _selectedOption == _current.answerIndex;
  // Une seule mascotte par session (du début à la fin), choisie de façon
  // stable à partir de l'id de la session : elle change d'une session à l'autre.
  _Host get _host {
    final id = _session?.id ?? '';
    final seed = id.codeUnits.fold<int>(0, (a, c) => a + c);
    return _kHosts[seed % _kHosts.length];
  }
  bool get _stepDone => _isQuiz ? _answered : _revealed;

  void _start() {
    SoundService.playSelect();
    setState(() => _started = true);
  }

  void _reveal() {
    if (_revealed) return;
    SoundService.playSelect();
    setState(() => _revealed = true);
  }

  void _selectOption(int i) {
    if (_answered) return;
    final correct = i == _current.answerIndex;
    if (correct) {
      _correctAnswers++;
      SoundService.playCorrect();
    } else {
      SoundService.playWrong();
    }
    final lines = correct ? _kCorrectLines : _kWrongLines;
    setState(() {
      _selectedOption = i;
      _feedbackLine = lines[_random.nextInt(lines.length)];
    });
  }

  Future<void> _next() async {
    if (!_stepDone) {
      _reveal();
      return;
    }
    if (_index < _session!.items.length - 1) {
      setState(() {
        _index++;
        _revealed = false;
        _selectedOption = null;
      });
      return;
    }
    await StandardContentService.markSessionCompleted(languageId: widget.languageId);
    if (!mounted) return;
    SoundService.playCelebration();
    setState(() => _finished = true);
    _confetti.play();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final accent = _session != null && !_loading ? _host.color : _kOrange;
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              accent.withValues(alpha: 0.16),
              AppColors.bg(context),
              AppColors.bg(context),
            ],
            stops: const [0, 0.45, 1],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _buildBody(context),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confetti,
                  blastDirectionality: BlastDirectionality.explosive,
                  numberOfParticles: 24,
                  maxBlastForce: 18,
                  minBlastForce: 6,
                  gravity: 0.25,
                  colors: [_host.color, _kOrange, const Color(0xFFFFB800), _kGreen],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) return _buildLoading(context);
    if (_hasError || _session == null || _session!.items.isEmpty) {
      return _buildError(context);
    }
    if (_finished) return _buildFinished(context);
    if (!_started) return _buildIntro(context);

    return Column(
      children: [
        _buildTopBar(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.12, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                  child: child,
                ),
              ),
              child: KeyedSubtree(
                key: ValueKey(_current.id),
                child: _isQuiz
                    ? _buildQuizStep(context, _current)
                    : _buildLearnStep(context, _current),
              ),
            ),
          ),
        ),
        _buildBottomArea(context),
      ],
    );
  }

  // ── Intro : les mascottes présentent la session ───────────────────────────

  Widget _buildIntro(BuildContext context) {
    final s = _session!;
    final cards = s.items.length - s.quizCount;
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
            child: _closeButton(context),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 8),
                QuizMascotSelector(questionIndex: _host.index, size: 150),
                const SizedBox(height: 6),
                _nameTag(_host),
                const SizedBox(height: 10),
                _SpeechBubble(
                  color: _host.color,
                  tailOnTop: true,
                  child: Column(
                    children: [
                      Text(
                        'Salut, moi c\'est ${_host.name} ! Je t\'ai préparé une session en ${widget.languageName} 👋',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary(context),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        s.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _infoChip(context, Icons.timer_outlined,
                        '${s.estimatedMinutes} min', _kOrange),
                    _infoChip(context, Icons.style_rounded,
                        '$cards carte${cards > 1 ? 's' : ''}', _host.color),
                    if (s.quizCount > 0)
                      _infoChip(context, Icons.quiz_rounded,
                          '${s.quizCount} quiz', _kGreen),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${_host.name} va te guider tout au long de la session.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: _PushButton(
            label: 'C\'est parti !',
            color: _host.color,
            onTap: _start,
          ),
        ),
      ],
    );
  }

  Widget _infoChip(BuildContext context, IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }

  // ── Barre du haut : fermer + progression segmentée + score ────────────────

  Widget _buildTopBar(BuildContext context) {
    final total = _session!.items.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 10),
      child: Row(
        children: [
          _closeButton(context),
          const SizedBox(width: 4),
          Expanded(
            child: Row(
              children: List.generate(total, (i) {
                final filled = i < _index || (i == _index && _stepDone);
                final isCurrent = i == _index;
                final color = _host.color;
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: isCurrent ? 10 : 8,
                    decoration: BoxDecoration(
                      color: filled ? color : color.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 18),
                const SizedBox(width: 3),
                Text(
                  '$_correctAnswers',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _closeButton(BuildContext context) {
    return IconButton(
      onPressed: Get.back,
      icon: Icon(Icons.close_rounded, color: AppColors.textSecondary(context), size: 26),
    );
  }

  // ── Mascotte + étiquette de nom ───────────────────────────────────────────

  Widget _buildHostHeader(BuildContext context, String line, QuizMascotMood mood) {
    final h = _host;
    return Column(
      children: [
        QuizMascotSelector(questionIndex: h.index, mood: mood, size: 130),
        const SizedBox(height: 6),
        _nameTag(h),
        const SizedBox(height: 8),
        Text(
          line,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _nameTag(_Host h) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: h.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: h.color.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        h.name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 12.5,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ── Carte mot / expression ────────────────────────────────────────────────

  Widget _buildLearnStep(BuildContext context, StandardItem item) {
    final h = _host;
    final isPhrase = item.type == StandardItemType.phrase;
    return Column(
      children: [
        _buildHostHeader(
          context,
          isPhrase
              ? '${h.name} te montre une expression'
              : '${h.name} t\'apprend un nouveau mot',
          QuizMascotMood.speaking,
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: _reveal,
          child: _SpeechBubble(
            color: h.color,
            tailOnTop: true,
            child: Column(
              children: [
                _badge(
                  isPhrase ? Icons.chat_bubble_rounded : Icons.translate_rounded,
                  isPhrase ? 'EXPRESSION' : 'NOUVEAU MOT',
                  h.color,
                ),
                const SizedBox(height: 14),
                Text(
                  item.term ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: _darken(h.color, 0.08),
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: _revealed
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: h.color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: h.color.withValues(alpha: 0.30), width: 1.2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.touch_app_rounded, color: h.color, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Touche pour découvrir la traduction',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: h.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  secondChild: Column(
                    children: [
                      Text(
                        item.translation ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      if (item.example != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.cardAlt(context),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.format_quote_rounded,
                                      size: 16, color: h.color),
                                  const SizedBox(width: 4),
                                  Text(
                                    'En contexte',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                      color: h.color,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.example!,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary(context),
                                ),
                              ),
                              if (item.exampleTranslation != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  item.exampleTranslation!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary(context),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Carte quiz ────────────────────────────────────────────────────────────

  Widget _buildQuizStep(BuildContext context, StandardItem item) {
    final h = _host;
    final mood = !_answered
        ? QuizMascotMood.speaking
        : _isCorrect
            ? QuizMascotMood.correct
            : QuizMascotMood.incorrect;
    return Column(
      children: [
        _buildHostHeader(context, '${h.name} te pose une question', mood),
        const SizedBox(height: 14),
        _SpeechBubble(
          color: h.color,
          tailOnTop: true,
          child: Column(
            children: [
              _badge(Icons.quiz_rounded, 'À TOI DE JOUER', h.color),
              const SizedBox(height: 12),
              Text(
                item.question ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary(context),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ...List.generate(item.options.length, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildOption(context, item, i, h.color),
            )),
      ],
    );
  }

  Widget _buildOption(BuildContext context, StandardItem item, int i, Color hostColor) {
    Color border = AppColors.divider(context);
    Color fill = AppColors.card(context);
    Color letterBg = hostColor.withValues(alpha: 0.12);
    Color letterFg = hostColor;
    IconData? trailing;
    if (_answered) {
      if (i == item.answerIndex) {
        border = _kGreen;
        fill = _kGreen.withValues(alpha: 0.10);
        letterBg = _kGreen;
        letterFg = Colors.white;
        trailing = Icons.check_circle_rounded;
      } else if (i == _selectedOption) {
        border = _kRed;
        fill = _kRed.withValues(alpha: 0.08);
        letterBg = _kRed;
        letterFg = Colors.white;
        trailing = Icons.cancel_rounded;
      }
    }
    final letter = String.fromCharCode(65 + i);
    final faded = _answered && i != item.answerIndex && i != _selectedOption;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: faded ? 0.5 : 1,
      child: _PushSurface(
        onTap: _answered ? null : () => _selectOption(i),
        // Couleur opaque : sinon l'ombre "3D" transparaît sous la réponse.
        color: Color.alphaBlend(fill, AppColors.card(context)),
        borderColor: border,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: letterBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  letter,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: letterFg,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.options[i],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              if (trailing != null) Icon(trailing, color: border, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Zone du bas : bouton ou bandeau de retour du quiz ─────────────────────

  Widget _buildBottomArea(BuildContext context) {
    final isLast = _index == _session!.items.length - 1;
    final h = _host;

    if (_isQuiz && _answered) {
      final color = _isCorrect ? _kGreen : _kRed;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isCorrect ? Icons.celebration_rounded : Icons.lightbulb_rounded,
                  color: color,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${h.name} : $_feedbackLine',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: _darken(color, 0.05),
                    ),
                  ),
                ),
              ],
            ),
            if (!_isCorrect) ...[
              const SizedBox(height: 6),
              Text(
                'Réponse : ${_current.options[_current.answerIndex!]}',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
            const SizedBox(height: 14),
            _PushButton(
              label: isLast ? 'Terminer' : 'Continuer',
              color: color,
              onTap: _next,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: _PushButton(
        label: _isQuiz
            ? 'Choisis une réponse'
            : !_revealed
                ? 'Voir la traduction'
                : isLast
                    ? 'Terminer'
                    : 'Continuer',
        color: h.color,
        onTap: _isQuiz ? null : _next,
      ),
    );
  }

  // ── Fin de session ────────────────────────────────────────────────────────

  Widget _buildFinished(BuildContext context) {
    final quizCount = _session!.quizCount;
    final ratio = quizCount == 0 ? 1.0 : _correctAnswers / quizCount;
    final stars = ratio >= 0.99 ? 3 : (ratio >= 0.5 ? 2 : 1);
    final message = stars == 3
        ? 'Sans faute, on est fiers de toi !'
        : stars == 2
            ? 'Beau travail, tu progresses bien !'
            : 'Bien joué d\'avoir essayé, on continue ensemble !';

    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  QuizMascotSelector(
                    questionIndex: _host.index,
                    mood: QuizMascotMood.correct,
                    size: 150,
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final on = i < stars;
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: 400 + i * 200),
                        curve: Curves.elasticOut,
                        builder: (_, v, child) =>
                            Transform.scale(scale: v, child: child),
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 4, right: 4, bottom: i == 1 ? 14 : 0),
                          child: Icon(
                            Icons.star_rounded,
                            size: i == 1 ? 64 : 50,
                            color: on
                                ? const Color(0xFFFFB800)
                                : AppColors.divider(context),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Session terminée ! 🎉',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: _statTile(context, Icons.menu_book_rounded,
                            _session!.title, 'Session', _kOrange),
                      ),
                      if (quizCount > 0) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statTile(
                              context,
                              Icons.check_circle_rounded,
                              '$_correctAnswers / $quizCount',
                              'Bonnes réponses',
                              _kGreen),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: _PushButton(
            label: 'Session suivante',
            color: _host.color,
            onTap: _load,
          ),
        ),
        TextButton(
          onPressed: Get.back,
          child: Text(
            'Retour à l\'accueil',
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _statTile(BuildContext context, IconData icon, String value,
      String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.30), width: 1.4),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  // ── Chargement / erreur ───────────────────────────────────────────────────

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const QuizMascotSelector(questionIndex: 3, size: 110),
          const SizedBox(height: 16),
          Text(
            'Zaki prépare ta session…',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 3, color: _kOrange),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
            child: _closeButton(context),
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const QuizMascotSelector(
                      questionIndex: 0, mood: QuizMascotMood.incorrect, size: 110),
                  const SizedBox(height: 16),
                  Text(
                    'Oups, impossible de charger la session.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _PushButton(label: 'Réessayer', color: _kOrange, onTap: _load),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Bulle de dialogue (pointe vers la mascotte au-dessus) ────────────────────

class _SpeechBubble extends StatelessWidget {
  final Widget child;
  final Color color;
  final bool tailOnTop;

  const _SpeechBubble({
    required this.child,
    required this.color,
    this.tailOnTop = true,
  });

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.card(context);
    return Column(
      children: [
        if (tailOnTop)
          CustomPaint(
            size: const Size(28, 14),
            painter: _TailPainter(fill: bg, stroke: color.withValues(alpha: 0.45)),
          ),
        Transform.translate(
          offset: const Offset(0, -1.5),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: color.withValues(alpha: 0.45), width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.16),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _TailPainter extends CustomPainter {
  final Color fill;
  final Color stroke;
  const _TailPainter({required this.fill, required this.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height);
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _TailPainter old) =>
      old.fill != fill || old.stroke != stroke;
}

// ── Bouton "3D" : ombre pleine sous le bouton qui s'écrase à l'appui ──────────

class _PushButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _PushButton({required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final c = enabled ? color : color.withValues(alpha: 0.35);
    return _PushSurface(
      onTap: onTap,
      color: c,
      borderColor: c,
      shadowColor: enabled ? _darken(color) : Colors.transparent,
      child: SizedBox(
        height: 54,
        child: Center(
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 15,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}

class _PushSurface extends StatefulWidget {
  final Widget child;
  final Color color;
  final Color borderColor;
  final Color? shadowColor;
  final VoidCallback? onTap;

  const _PushSurface({
    required this.child,
    required this.color,
    required this.borderColor,
    this.shadowColor,
    this.onTap,
  });

  @override
  State<_PushSurface> createState() => _PushSurfaceState();
}

class _PushSurfaceState extends State<_PushSurface> {
  static const double _depth = 4;
  bool _pressed = false;

  void _setPressed(bool v) {
    if (widget.onTap == null) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final shadow = widget.shadowColor ?? _darken(widget.borderColor, 0.06);
    final offset = _pressed ? _depth : 0.0;
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: Padding(
        // Hauteur totale constante : le bouton descend dans son ombre.
        padding: EdgeInsets.only(top: offset, bottom: _depth - offset),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: widget.borderColor, width: 1.8),
            boxShadow: [
              BoxShadow(
                color: shadow,
                offset: Offset(0, _depth - offset),
                blurRadius: 0,
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
