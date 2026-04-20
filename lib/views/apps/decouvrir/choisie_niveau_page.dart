import 'dart:math';
import 'package:fasolingo/controller/apps/langue/langue_controller.dart';
import 'package:fasolingo/models/langue/langue_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

enum TreeType { seedling, sapling, fullTree }

class ChoisieNiveauPage extends StatefulWidget {
  const ChoisieNiveauPage({super.key});

  @override
  State<ChoisieNiveauPage> createState() => _ChoisieNiveauPageState();
}

class _ChoisieNiveauPageState extends State<ChoisieNiveauPage>
    with TickerProviderStateMixin {
  late final LanguagesController languagesController;
  late AnimationController _bounceController;
  late AnimationController _floatController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    languagesController = Get.find<LanguagesController>();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      languagesController.loadLanguageLevels();
    });

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF87CEEB).withOpacity(0.5),
      const Color(0xFFFFB6C1).withOpacity(0.5),
      const Color(0xFFFFD700).withOpacity(0.4),
      const Color(0xFFFFA500).withOpacity(0.5),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // --- ARRIÈRE-PLAN DÉGRADÉ LUDIQUE ---
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(159, 255, 178, 71), 
                  Color.fromARGB(166, 255, 227, 89), 
                  Color.fromARGB(152, 136, 216, 176), 
                ],
              ),
            ),
          ),

          ...List.generate(8, (index) => _buildFloatingDecoration(index)),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingDecoration(int index) {
    final random = Random(index + 100);
    final size = random.nextDouble() * 25 + 12;
    final left = random.nextDouble() * MediaQuery.of(context).size.width;
    final delay = random.nextDouble() * 1000;

    final shapes = [
      Icons.star,
      Icons.circle,
      Icons.favorite,
      Icons.auto_awesome,
      Icons.school,
      Icons.emoji_events,
    ];

    final colorsList = [
      Colors.yellow.shade600,
      Colors.white.withOpacity(0.7),
      Colors.pink.shade300,
      Colors.orange.shade300,
      Colors.blue.shade300,
      Colors.purple.shade200,
      Colors.green.shade300,
    ];

    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Positioned(
          left: left,
          top: (index * 70.0 + _floatAnimation.value + delay) % 
               (MediaQuery.of(context).size.height * 0.35) - 20,
          child: Opacity(
            opacity: 0.5,
            child: Transform.rotate(
              angle: random.nextDouble() * pi,
              child: Icon(
                shapes[index % shapes.length],
                size: size,
                color: colorsList[index % colorsList.length],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0, bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                ),
              ),
              const Spacer(),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(195, 255, 178, 71),
                      Color.fromARGB(166, 255, 227, 89),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.language_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Obx(() => Text(
                      languagesController.selectedLanguage.value?.name ?? "Langue",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Obx(() {
            final languageName = languagesController.selectedLanguage.value?.name ?? "Langue";
            return Text(
              "Apprendre $languageName",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.orange.shade800,
                shadows: [
                  Shadow(
                    color: Colors.orange.withOpacity(0.2),
                    offset: const Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 10),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.shade300,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.green.shade700,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  "Les leçons seront adaptées à votre niveau.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          Expanded(
            child: Obx(() {
              final List<dynamic> backendLevels = languagesController.languageLevels;

              return backendLevels.isEmpty
                ? (languagesController.isLoadingLevels.value
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              'assets/lottie/mascot.json',
                              width: 100,
                              height: 100,
                            ),
                            const SizedBox(height: 16),
                            const CircularProgressIndicator(color: Colors.orange),
                          ],
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 12),
                            Text(
                              "Aucun niveau disponible",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ))
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemCount: backendLevels.length,
                    itemBuilder: (context, index) {
                      final level = backendLevels[index];
                      return _buildLevelCard(level: level, index: index);
                    },
                  );
            }),
          ),
          
          Padding(
            padding: const EdgeInsets.only(bottom: 30, top: 16),
            child: Obx(() {
              bool hasLevelSelected = languagesController.selectedLevel.value != null;
              bool isApiLoading = languagesController.isLoading.value;

              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 1.0, end: hasLevelSelected ? 1.03 : 1.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: hasLevelSelected
                        ? [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : [],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasLevelSelected
                            ? const Color(0xFFFF8F00)
                            : Colors.grey.shade300,
                        disabledBackgroundColor: Colors.grey.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: hasLevelSelected
                              ? BorderSide(color: Colors.orange.shade200, width: 2)
                              : BorderSide.none,
                        ),
                        elevation: hasLevelSelected ? 4 : 0,
                      ),
                      onPressed: (!hasLevelSelected || isApiLoading)
                          ? null
                          : () async {
                              if (languagesController.selectedLanguage.value == null) {
                                Get.snackbar(
                                  "Oups",
                                  "Veuillez recommencer la sélection de la langue.",
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                Get.offAllNamed('/selection');
                                return;
                              }

                              bool success = await languagesController.saveLevelSelection();

                              if (success) {
                                Get.offAllNamed('/HomeScreen');
                              } else {
                                print("⚠️ Échec de la synchronisation finale avec le backend");
                              }
                            },
                      child: isApiLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  hasLevelSelected ? "C'EST PARTI !" : "SÉLECTIONNE UN NIVEAU",
                                  style: TextStyle(
                                    color: hasLevelSelected ? Colors.white : Colors.grey.shade500,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    letterSpacing: 1,
                                  ),
                                ),
                                if (hasLevelSelected) ...[
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.rocket_launch_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard({required dynamic level, required int index}) {
    return Obx(() {
      final selected = languagesController.selectedLevel.value;
      String? selectedId;
      if (selected == null) {
        selectedId = null;
      } else if (selected is Map) {
        selectedId = selected['id']?.toString();
      } else {
        selectedId = selected?.id?.toString();
      }

      final String levelId = (level is Map)
          ? (level['id']?.toString() ?? '')
          : (level.id?.toString() ?? '');
      bool isSelected = selectedId != null && selectedId == levelId;

      final String levelName = (level is Map)
          ? (level['name']?.toString() ?? '')
          : (level.name?.toString() ?? '');
      final String levelDescription = (level is Map)
          ? (level['description']?.toString() ?? '')
          : (level.description?.toString() ?? '');

      final treeType = _getTreeType(index, levelName);

      return InkWell(
        onTap: () => languagesController.selectLevel(level),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? _getTreeColor(index) : Colors.grey.shade200,
              width: isSelected ? 3 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _getTreeColor(index).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSelected 
                        ? [_getTreeColor(index), _getTreeColor(index).withOpacity(0.7)]
                        : [Colors.grey.shade100, Colors.grey.shade200],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: _buildTreeIcon(treeType, isSelected),
                ),
              ),
              const SizedBox(width: 14),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      levelName,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? _getTreeColor(index) : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      levelDescription,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [_getTreeColor(index), _getTreeColor(index).withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : Icon(
                        Icons.circle_outlined,
                        color: Colors.grey.shade400,
                        size: 18,
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }

  TreeType _getTreeType(int index, String levelName) {
    final lowerName = levelName.toLowerCase();
    
    if (lowerName.contains('débutant') || lowerName.contains('beginner') || 
        lowerName.contains('starter') || lowerName.contains('novice') || 
        lowerName.contains('a1') || lowerName.contains('a2')) {
      return TreeType.seedling; 
    } else if (lowerName.contains('intermédiaire') || lowerName.contains('intermediate') || 
        lowerName.contains('moyen') || lowerName.contains('intermediaire') || 
        lowerName.contains('b1') || lowerName.contains('b2')) {
      return TreeType.sapling; 
    } else if (lowerName.contains('avancé') || lowerName.contains('advanced') || 
        lowerName.contains('expert') || lowerName.contains('c1') || lowerName.contains('c2')) {
      return TreeType.fullTree; 
    }
    
    if (index == 0) return TreeType.seedling;
    if (index == 1) return TreeType.sapling;
    return TreeType.fullTree;
  }

  Color _getTreeColor(int index) {
    final colors = [
      Colors.green.shade400,  
      Colors.green.shade600,    
      Colors.green.shade800,   
    ];
    return colors[index % colors.length];
  }

  Widget _buildTreeIcon(TreeType type, bool isSelected) {
    final baseColor = _getTreeColor(type.index);
    final color = isSelected ? Colors.white : baseColor;
    
    switch (type) {
      case TreeType.seedling:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grass, color: color, size: 24),
            Icon(Icons.add, color: color.withOpacity(0.5), size: 12),
          ],
        );
      case TreeType.sapling:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.park, color: color, size: 26),
            Icon(Icons.eco, color: color.withOpacity(0.5), size: 14),
          ],
        );
      case TreeType.fullTree:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forest, color: color, size: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.eco, color: color.withOpacity(0.6), size: 10),
                Icon(Icons.eco, color: color.withOpacity(0.6), size: 10),
              ],
            ),
          ],
        );
    }
  }
}

