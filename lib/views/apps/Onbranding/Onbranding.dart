import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/helpers/storage/local_storage.dart'; // Import nécessaire
import 'package:fasolingo/models/user_model.dart';          // Import nécessaire
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const Color _obOrange  = Color(0xFFFF7043);
const Color _obOrange2 = Color(0xFFFFB74D);
const Color _obCyan     = Color(0xFF0EA5E9);
const Color _obCard     = Color(0xFFF6F7F9);
const Color _obText     = Color(0xFF1A1A1A);
const Color _obSub      = Color(0xFF888888);

class OnboardingTibiPro extends StatefulWidget {
  const OnboardingTibiPro({super.key});

  @override
  State<OnboardingTibiPro> createState() => _OnboardingTibiProState();
}

class _OnboardingTibiProState extends State<OnboardingTibiPro> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();
    _checkStatus(); 
  }

  void _checkStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final String? storedToken = LocalStorage.getAuthToken();

    if (storedToken == null || storedToken.isEmpty || storedToken == "null") {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final session = Get.find<SessionController>();
      session.token.value = storedToken;

      final response = await session.dio.get('/users/me');

      if (response.statusCode != 200) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Support API avec ou sans wrapper { success, data }
      final dynamic raw = response.data;
      final Map<String, dynamic> userData =
          (raw is Map && raw.containsKey('data') && raw['data'] is Map)
              ? Map<String, dynamic>.from(raw['data'] as Map)
              : Map<String, dynamic>.from(raw as Map);

      final UserModel loggedInUser = UserModel.fromJson(userData);
      session.updateUser(loggedInUser, storedToken);

      final String langId  = loggedInUser.selectedLanguageId ?? '';
      final String levelId = loggedInUser.selectedLevelId    ?? '';

      if (langId.isNotEmpty && levelId.isNotEmpty) {
        Get.offAllNamed(
          '/HomeScreen',
          arguments: {'languageId': langId, 'levelId': levelId},
        );
      } else if (langId.isNotEmpty) {
        Get.offAllNamed('/selection');
      } else {
        Get.offAllNamed('/bienvenue');
      }
    } catch (e) {
      debugPrint("Erreur Auto-Login : $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: _obOrange),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Tes cercles de design (Positioned...)
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _obOrange.withValues(alpha: 0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _obCyan.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      const Spacer(),
                      _buildSegmentedProgress(),
                      const Spacer(),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) => setState(() => _currentPage = page),
                    children: [
                      _buildActivityStep(),
                      _buildTopicStep(),
                      _buildGoalStep(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Tes Widgets de Steps (inchangés) ---

  Widget _buildActivityStep() {
    return _StepLayout(
      title: 'A quel point es-tu expose a la langue ?',
      child: Column(
        children: [
          _buildSelectableTile('Rarement', 'Je ne l\'entends jamais', Icons.visibility_off_rounded, false),
          _buildSelectableTile('Parfois', 'Je l\'entends lors de fetes', Icons.celebration_rounded, false),
          _buildSelectableTile('Souvent', 'Ma famille la parle a la maison', Icons.home_rounded, true),
          _buildSelectableTile('Quotidiennement', 'C\'est ma langue principale', Icons.forum_rounded, false),
        ],
      ),
    );
  }

  Widget _buildTopicStep() {
    return _StepLayout(
      title: 'Que veux-tu apprendre en priorite ?',
      child: Column(
        children: [
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 20,
            children: [
              _buildTopicCard('Salutations', Icons.handshake_rounded, false, rotation: -0.06),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: _buildTopicCard('Famille', Icons.people_rounded, true, rotation: 0.12),
              ),
              _buildTopicCard('Commerce', Icons.shopping_cart_rounded, false, rotation: 0.05),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: _buildTopicCard('Contes', Icons.menu_book_rounded, false, rotation: -0.10),
              ),
              _buildTopicCard('Culture', Icons.account_balance_rounded, false, rotation: 0.04),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalStep() {
    final session = Get.find<SessionController>();
    return _StepLayout(
      title: 'Reste concentre, et gagne ton defi.',
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.72,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_obOrange, _obOrange2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: _obOrange.withValues(alpha: 0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.flag_rounded, size: 28, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'A ce rythme, tu maitriseras les bases dans 21 jours !',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _buildProgressCircle(),
            const SizedBox(height: 28),
            _buildStatLine('Vocabulaire', 0.7, _obOrange, '150 mots'),
            _buildStatLine('Prononciation', 0.4, _obCyan, '40%'),
            const Spacer(),
            _buildPrimaryButton('C\'EST PARTI', () {
              session.vientDeLaDecouverte = true;
              Get.toNamed('/step');
            }, true),
            const SizedBox(height: 12),
            _buildPrimaryButton('J\'AI DEJA UN COMPTE', () {
              session.vientDeLaDecouverte = false;
              Get.toNamed('/login');
            }, false),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // --- Méthodes de Build UI (inchangées) ---
  Widget _buildTopicCard(String label, IconData icon, bool selected, {double rotation = 0}) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: selected ? _obOrange : _obCard,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: selected ? Colors.transparent : Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: selected
              ? [BoxShadow(color: _obOrange.withValues(alpha: 0.30), blurRadius: 18, offset: const Offset(0, 6))]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 34, color: selected ? Colors.white : _obOrange),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : _obText,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectableTile(String title, String subtitle, IconData icon, bool selected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selected ? _obOrange : _obCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? Colors.transparent : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: selected
            ? [BoxShadow(color: _obOrange.withValues(alpha: 0.25), blurRadius: 14, offset: const Offset(0, 5))]
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: selected
                  ? Colors.white.withValues(alpha: 0.25)
                  : _obOrange.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: selected ? Colors.white : _obOrange, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: selected ? Colors.white : _obText,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: selected ? Colors.white.withValues(alpha: 0.80) : _obSub,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPress, bool isFull) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: isFull
          ? GestureDetector(
              onTap: onPress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_obOrange, _obOrange2],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: _obOrange.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            )
          : OutlinedButton(
              onPressed: onPress,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _obOrange, width: 1.8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  color: _obOrange,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ),
    );
  }

  Widget _buildSegmentedProgress() {
    return Row(
      children: List.generate(10, (index) {
        final bool isCurrent = index == (_currentPage * 3 + 1);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          height: 4,
          width: isCurrent ? 28 : 6,
          decoration: BoxDecoration(
            color: isCurrent ? _obOrange : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildProgressCircle() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 130,
          height: 130,
          child: CircularProgressIndicator(
            value: 0.65,
            strokeWidth: 10,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(_obCyan),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '65%',
              style: TextStyle(
                color: _obText,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Pret',
              style: TextStyle(color: _obSub, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatLine(String label, double val, Color color, String trailing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _obText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                trailing,
                style: TextStyle(color: _obSub, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: val,
              color: color,
              backgroundColor: Colors.grey.shade200,
              minHeight: 7,
            ),
          ),
        ],
      ),
    );
  }
}

// Layout Helper
class _StepLayout extends StatelessWidget {
  final String title;
  final Widget child;
  const _StepLayout({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _obText,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 28),
          child,
        ],
      ),
    );
  }
}