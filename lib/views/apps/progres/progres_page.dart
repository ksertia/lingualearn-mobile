import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:fasolingo/controller/apps/langue/langue_controller.dart';
import 'package:fasolingo/controller/apps/session_controller.dart';

const Color _prOrange  = Color(0xFFFF7043);
const Color _prOrange2 = Color(0xFFFFB74D);
const Color _prGreen   = Color(0xFF22C55E);
const Color _prBlue    = Color(0xFF0EA5E9);
const Color _prLocked  = Color(0xFF9E9E9E);

class ProgresPage extends StatefulWidget {
  const ProgresPage({super.key});

  @override
  State<ProgresPage> createState() => _ProgresPageState();
}

class _ProgresPageState extends State<ProgresPage> {
  String languageName = 'Langue';
  String levelName = 'Niveau';
  bool isLoadingProgression = true;

  int totalXp = 0;
  int totalTimeSpent = 0;
  int quizScore = 0;
  int currentLevelXp = 0;
  int targetXp = 1000;

  int completedModules = 0;
  int inProgressModules = 0;
  int lockedModules = 0;
  int totalModules = 0;

  @override
  void initState() {
    super.initState();
    _loadProgressionData();
  }

  Future<void> _loadProgressionData() async {
    try {
      final langController = Get.find<LanguagesController>();
      final session = Get.find<SessionController>();
      final progression = await langController.loadProgression();

      if (progression != null && mounted) {
        if (progression['language'] != null) {
          languageName = progression['language']['name'] ?? 'Langue';
        }
        if (progression['overallProgress'] != null) {
          final overall = progression['overallProgress'];
          totalXp = overall['totalXp'] ?? 0;
          totalTimeSpent = overall['totalTimeMinutes'] ?? 0;
        }
        if (progression['levels'] != null) {
          final levels = progression['levels'] as List;
          final selectedId = session.selectedLevelId.value;
          for (var level in levels) {
            if (level['id']?.toString() == selectedId) {
              levelName = level['name'] ?? 'Niveau';
              if (level['userProgress'] != null) {
                currentLevelXp = level['userProgress']['totalXp'] ?? 0;
              }
              if (level['modules'] != null) {
                for (var module in level['modules']) {
                  totalModules++;
                  String status = 'locked';
                  if (module['userProgress'] != null) {
                    status = module['userProgress']['status'] ?? 'locked';
                    if (status == 'completed') {
                      completedModules++;
                    } else if (status == 'started' || status == 'unlocked') {
                      inProgressModules++;
                    } else {
                      lockedModules++;
                    }
                    if (module['userProgress']['quizScore'] != null) {
                      quizScore = module['userProgress']['quizScore'];
                    }
                  } else {
                    lockedModules++;
                  }
                }
              }
              break;
            }
          }
        }
        setState(() => isLoadingProgression = false);
      }
    } catch (_) {
      setState(() => isLoadingProgression = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    if (isLoadingProgression) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: _prOrange),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: _prOrange,
          onRefresh: () async {
            setState(() {
              isLoadingProgression = true;
              totalXp = 0; totalTimeSpent = 0; quizScore = 0;
              currentLevelXp = 0; completedModules = 0;
              inProgressModules = 0; lockedModules = 0; totalModules = 0;
            });
            await _loadProgressionData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroCard(),
                const SizedBox(height: 22),
                _buildSectionTitle('Mes exploits', Icons.emoji_events_rounded, _prOrange),
                const SizedBox(height: 12),
                _buildStatsRow(),
                const SizedBox(height: 22),
                _buildSectionTitle('Progression des modules', Icons.bar_chart_rounded, _prBlue),
                const SizedBox(height: 12),
                _buildModuleProgress(),
                const SizedBox(height: 22),
                _buildSectionTitle('Repartition', Icons.pie_chart_rounded, _prGreen),
                const SizedBox(height: 12),
                _buildRings(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    final progress = (currentLevelXp / targetXp).clamp(0.0, 1.0);
    final pct = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_prOrange, _prOrange2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _prOrange.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ma Progression',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _heroChip(languageName, Icons.language_rounded),
                        const SizedBox(width: 8),
                        _heroChip(levelName, Icons.layers_rounded),
                      ],
                    ),
                  ],
                ),
              ),
              Lottie.asset('assets/lottie/mascot.json', width: 72, height: 72),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'XP du niveau',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
              ),
              Text(
                '$currentLevelXp / $targetXp XP',
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Container(
                  height: 12,
                  color: Colors.white.withValues(alpha: 0.25),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Encore ${targetXp - currentLevelXp} XP pour le prochain niveau',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.80), fontSize: 12),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$pct%',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _statCard(Icons.bolt_rounded, '$totalXp XP', 'Total XP', _prOrange),
        const SizedBox(width: 12),
        _statCard(Icons.timer_rounded, '${totalTimeSpent}m', 'Temps', _prBlue),
        const SizedBox(width: 12),
        _statCard(Icons.quiz_rounded, '$quizScore%', 'Quiz', _prGreen),
      ],
    );
  }

  Widget _statCard(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.15), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.10),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleProgress() {
    final items = [
      _ModuleStat('Termines', completedModules, totalModules, _prGreen, Icons.check_circle_rounded),
      _ModuleStat('En cours', inProgressModules, totalModules, _prOrange, Icons.play_circle_rounded),
      _ModuleStat('Verrouilles', lockedModules, totalModules, _prLocked, Icons.lock_rounded),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: items.map((item) {
          final fraction = totalModules > 0 ? item.count / totalModules : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(item.icon, color: item.color, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.label,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
                          ),
                          Text(
                            '${item.count} / $totalModules',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: fraction.clamp(0.0, 1.0),
                          minHeight: 7,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(item.color),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRings() {
    final completedFrac = totalModules > 0 ? completedModules / totalModules : 0.0;
    final progressFrac  = totalModules > 0 ? inProgressModules / totalModules : 0.0;
    final lockedFrac    = totalModules > 0 ? lockedModules / totalModules : 0.0;

    return Row(
      children: [
        _ringCard('Termines', completedModules, completedFrac, _prGreen),
        const SizedBox(width: 12),
        _ringCard('En cours', inProgressModules, progressFrac, _prOrange),
        const SizedBox(width: 12),
        _ringCard('Verrouilles', lockedModules, lockedFrac, _prLocked),
      ],
    );
  }

  Widget _ringCard(String label, int count, double value, Color color) {
    final pct = (value * 100).round();
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.15), width: 1.5),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              height: 72,
              width: 72,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: value.clamp(0.0, 1.0),
                    strokeWidth: 7,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                  Text(
                    '$pct%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$count',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleStat {
  final String label;
  final int count;
  final int total;
  final Color color;
  final IconData icon;
  const _ModuleStat(this.label, this.count, this.total, this.color, this.icon);
}
