import 'package:flutter/material.dart';
import 'package:get/get.dart';

const Color _hOrange  = Color(0xFFFF7043);
const Color _hOrange2 = Color(0xFFFFB74D);
const Color _hPurple  = Color(0xFF7C3AED);
const Color _hBlue    = Color(0xFF0EA5E9);
const Color _hGreen   = Color(0xFF10B981);
const Color _hBg      = Color(0xFFF6F8FF);

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  int _selectedCategory = 0;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  static const _categories = [
    _HelpCategory(label: 'Tout',          icon: Icons.apps_rounded,               color: _hOrange),
    _HelpCategory(label: 'Démarrage',     icon: Icons.rocket_launch_rounded,       color: _hPurple),
    _HelpCategory(label: 'Apprentissage', icon: Icons.menu_book_rounded,           color: _hBlue),
    _HelpCategory(label: 'Abonnement',    icon: Icons.workspace_premium_rounded,   color: _hOrange),
    _HelpCategory(label: 'Compte',        icon: Icons.manage_accounts_rounded,     color: _hGreen),
    _HelpCategory(label: 'Technique',     icon: Icons.build_circle_rounded,        color: Color(0xFFF59E0B)),
  ];

  static const _faqs = <_FaqItem>[
    // Démarrage
    _FaqItem(
      category: 1,
      question: "Comment créer un compte ?",
      answer:
          "Téléchargez l'application et appuyez sur « S'inscrire ». Renseignez votre prénom, e-mail et mot de passe. Vous recevrez un e-mail de confirmation pour activer votre compte.",
    ),
    _FaqItem(
      category: 1,
      question: "Comment choisir une langue à apprendre ?",
      answer:
          "Après la connexion, rendez-vous dans l'onglet Accueil > « Mes langues » puis appuyez sur « Ajouter une langue ». Sélectionnez la langue souhaitée, puis choisissez votre niveau de départ.",
    ),
    _FaqItem(
      category: 1,
      question: "Puis-je apprendre plusieurs langues en même temps ?",
      answer:
          "Oui ! Vous pouvez ajouter jusqu'à 2 langues simultanément. Depuis votre accueil, faites glisser les cartes de langue pour naviguer entre elles.",
    ),
    _FaqItem(
      category: 1,
      question: "Comment réinitialiser mon mot de passe ?",
      answer:
          "Sur l'écran de connexion, appuyez sur « Mot de passe oublié ? », saisissez votre e-mail et suivez les instructions reçues. Le lien de réinitialisation est valable 30 minutes.",
    ),

    // Apprentissage
    _FaqItem(
      category: 2,
      question: "Comment fonctionne la structure d'apprentissage ?",
      answer:
          "L'apprentissage est organisé en 4 niveaux : Modules > Parcours > Étapes > Contenu. Complétez chaque étape pour débloquer la suivante et progresser dans votre parcours.",
    ),
    _FaqItem(
      category: 2,
      question: "Qu'est-ce qu'un quiz et comment le réussir ?",
      answer:
          "Un quiz est une étape d'évaluation à choix multiples. Lisez bien chaque question, sélectionnez la bonne réponse et validez. Une fois toutes les questions répondues, votre étape est marquée comme terminée.",
    ),
    _FaqItem(
      category: 2,
      question: "Comment suivre ma progression ?",
      answer:
          "Depuis l'accueil, la section « En ce moment » affiche votre module en cours et votre progression en pourcentage. Les cartes de langue montrent également votre avancement global pour chaque langue.",
    ),
    _FaqItem(
      category: 2,
      question: "Les leçons sont-elles disponibles hors ligne ?",
      answer:
          "Les leçons textuelles sont disponibles hors ligne après un premier chargement. Les vidéos et audios nécessitent une connexion internet pour être lues correctement.",
    ),

    // Abonnement
    _FaqItem(
      category: 3,
      question: "Comment souscrire à un abonnement ?",
      answer:
          "Allez dans Paramètres > « Gérer mon abonnement » ou appuyez sur la bannière Premium depuis l'accueil. Choisissez un plan mensuel ou annuel et suivez les étapes de paiement.",
    ),
    _FaqItem(
      category: 3,
      question: "Quels modes de paiement sont acceptés ?",
      answer:
          "Nous acceptons Orange Money, Moov Money et les principales cartes bancaires (Visa, Mastercard). Le paiement est sécurisé et vos données financières ne sont jamais stockées.",
    ),
    _FaqItem(
      category: 3,
      question: "Comment annuler mon abonnement ?",
      answer:
          "Rendez-vous dans Paramètres > « Mon Abonnement » puis appuyez sur « Résilier l'abonnement ». Votre accès Premium reste actif jusqu'à la fin de la période en cours, sans remboursement au prorata.",
    ),
    _FaqItem(
      category: 3,
      question: "Mon abonnement se renouvelle-t-il automatiquement ?",
      answer:
          "Oui, sauf si vous résiliez avant la date de fin. Vous recevrez une notification 3 jours avant le renouvellement pour vous rappeler l'échéance.",
    ),

    // Compte
    _FaqItem(
      category: 4,
      question: "Comment modifier mon profil ?",
      answer:
          "Dans Paramètres, appuyez sur le bouton d'édition dans la section en-tête de votre profil. Vous pouvez modifier votre photo, prénom, nom et e-mail.",
    ),
    _FaqItem(
      category: 4,
      question: "Comment créer un sous-compte pour mon enfant ?",
      answer:
          "Allez dans Paramètres > « Rattacher un compte ». Appuyez sur « + Ajouter » et renseignez les informations de votre enfant. Le sous-compte peut ensuite être géré depuis « Parcours du compte rattaché ».",
    ),
    _FaqItem(
      category: 4,
      question: "Comment changer la langue de l'interface ?",
      answer:
          "Dans Paramètres > « Préférences » > « Langue de l'interface », sélectionnez la langue souhaitée parmi les options disponibles. La modification prend effet immédiatement.",
    ),
    _FaqItem(
      category: 4,
      question: "Comment supprimer mon compte ?",
      answer:
          "La suppression de compte est définitive et entraîne la perte de toute votre progression. Contactez notre support à support@fasolingo.app en indiquant votre demande. Votre compte sera supprimé sous 7 jours ouvrés.",
    ),

    // Technique
    _FaqItem(
      category: 5,
      question: "L'application ne se charge pas, que faire ?",
      answer:
          "Vérifiez d'abord votre connexion internet. Si le problème persiste, fermez complètement l'application et relancez-la. Vous pouvez aussi vider le cache depuis les paramètres de votre téléphone > Applications > Fasolingo > Vider le cache.",
    ),
    _FaqItem(
      category: 5,
      question: "Comment mettre à jour l'application ?",
      answer:
          "Rendez-vous sur le Play Store (Android) ou l'App Store (iOS) et cherchez « Fasolingo ». Si une mise à jour est disponible, le bouton « Mettre à jour » apparaîtra. Nous recommandons de toujours utiliser la dernière version.",
    ),
    _FaqItem(
      category: 5,
      question: "Je n'entends pas le son des leçons audio, pourquoi ?",
      answer:
          "Vérifiez que le volume de votre appareil n'est pas en mode silencieux. Dans l'application, assurez-vous que l'audio n'est pas désactivé. Sur iOS, vérifiez que le bouton de silence physique n'est pas activé.",
    ),
  ];

  List<_FaqItem> get _filtered {
    final items = _selectedCategory == 0
        ? _faqs
        : _faqs.where((f) => f.category == _selectedCategory).toList();
    if (_searchQuery.isEmpty) return items;
    final q = _searchQuery.toLowerCase();
    return items
        .where((f) =>
            f.question.toLowerCase().contains(q) ||
            f.answer.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _hBg,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [_buildSliverAppBar()],
        body: Column(
          children: [
            _buildSearchBar(),
            _buildCategoryRow(),
            Expanded(child: _buildFaqList()),
          ],
        ),
      ),
    );
  }

  // ─── Sliver AppBar ────────────────────────────────────────────────────────

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      backgroundColor: _hOrange,
      leading: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: GestureDetector(
          onTap: Get.back,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 17),
          ),
        ),
      ),
      title: const Text(
        "Centre d'aide",
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17),
      ),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_hOrange, _hOrange2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    "Comment pouvons-nous\nvous aider ?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${_faqs.length} questions & réponses",
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Search ───────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _searchQuery = v.trim()),
        style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
        decoration: InputDecoration(
          hintText: 'Rechercher une question...',
          hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          prefixIcon:
              Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: Icon(Icons.close_rounded,
                      color: Colors.grey.shade400, size: 18),
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ─── Category pills ───────────────────────────────────────────────────────

  Widget _buildCategoryRow() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final cat = _categories[i];
            final isSelected = _selectedCategory == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                decoration: BoxDecoration(
                  color: isSelected
                      ? cat.color
                      : cat.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cat.icon,
                      size: 15,
                      color: isSelected
                          ? Colors.white
                          : cat.color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat.label,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : cat.color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── FAQ list ─────────────────────────────────────────────────────────────

  Widget _buildFaqList() {
    final items = _filtered;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 52, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'Aucun résultat',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500),
            ),
            const SizedBox(height: 6),
            Text(
              'Essayez un autre mot-clé ou une autre catégorie.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: items.length + 1,
      itemBuilder: (_, i) {
        if (i == items.length) return _buildContactCard();
        return _buildFaqTile(items[i], i);
      },
    );
  }

  Widget _buildFaqTile(_FaqItem item, int index) {
    final cat = _categories[item.category];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding:
              const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedAlignment: Alignment.topLeft,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
          collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cat.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(cat.icon, size: 17, color: cat.color),
          ),
          title: Text(
            item.question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          iconColor: _hOrange,
          collapsedIconColor: Colors.grey.shade400,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _hBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.answer,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Contact card ─────────────────────────────────────────────────────────

  Widget _buildContactCard() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [_hOrange, _hOrange2]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.support_agent_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Vous n'avez pas trouvé ?",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Notre équipe est là pour vous aider.",
                      style: TextStyle(
                          color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildContactBtn(
                  icon: Icons.mail_outline_rounded,
                  label: 'E-mail',
                  onTap: () => Get.snackbar(
                    'Support',
                    'support@fasolingo.app',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.black87,
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildContactBtn(
                  icon: Icons.chat_rounded,
                  label: 'Chat live',
                  onTap: () => Get.snackbar(
                    'Bientôt disponible',
                    'Le chat en direct arrive prochainement.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.black87,
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Disponible du lundi au vendredi · 8h–18h (GMT+0)',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 17),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data classes ─────────────────────────────────────────────────────────────

class _HelpCategory {
  final String label;
  final IconData icon;
  final Color color;
  const _HelpCategory(
      {required this.label, required this.icon, required this.color});
}

class _FaqItem {
  final int category;
  final String question;
  final String answer;
  const _FaqItem(
      {required this.category,
      required this.question,
      required this.answer});
}
