import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tibi/helpers/services/contents/content_service.dart';
import 'package:tibi/helpers/theme/app_colors.dart';
import 'package:tibi/models/contents/content_model.dart';
import 'package:tibi/models/themes/sub_theme_model.dart';
import 'package:tibi/views/apps/home/screens/StepContentScreen.dart';

const Color _kOrange = Color(0xFFF27F22);

class SubThemeCard extends StatefulWidget {
  final SubThemeModel subTheme;
  final int themeIdx;
  final int subThemeIdx;
  final String userId;
  final bool Function() isSubscriptionActive;
  final void Function(BuildContext context) onSubscriptionRequired;

  const SubThemeCard({
    super.key,
    required this.subTheme,
    required this.themeIdx,
    required this.subThemeIdx,
    required this.userId,
    required this.isSubscriptionActive,
    required this.onSubscriptionRequired,
  });

  @override
  State<SubThemeCard> createState() => _SubThemeCardState();
}

class _ContentStyle {
  final IconData icon;
  final Color color;
  final String label;
  const _ContentStyle(this.icon, this.color, this.label);
}

class _SubThemeCardState extends State<SubThemeCard> {
  final ContentService _contentService = ContentService();
  bool _expanded = false;
  bool _loading = false;
  bool _error = false;
  List<ContentModel> _contents = [];

  Future<void> _loadContents() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final list =
          await _contentService.getContentsBySubTheme(widget.subTheme.id);
      list.sort((a, b) => a.index.compareTo(b.index));
      if (!mounted) return;
      setState(() {
        _contents = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  void _handleTap() {
    setState(() => _expanded = !_expanded);
    if (_expanded && _contents.isEmpty && !_loading) {
      _loadContents();
    }
  }

  void _openContent(int index) {
    if (!widget.isSubscriptionActive()) {
      widget.onSubscriptionRequired(context);
      return;
    }
    Get.to(
      () => StepContentScreen(
        subThemeId: widget.subTheme.id,
        userId: widget.userId,
        initialIndex: index,
      ),
      transition: Transition.rightToLeft,
    );
  }

  _ContentStyle _styleFor(String contentType) {
    switch (contentType) {
      case 'course':
        return const _ContentStyle(
            Icons.menu_book_rounded, Color(0xFF5B6BF2), 'COURS');
      case 'video':
        return const _ContentStyle(
            Icons.videocam_rounded, Color(0xFF9C6BF2), 'VIDÉO');
      case 'exercise':
        return const _ContentStyle(
            Icons.edit_rounded, Color(0xFFE08A2E), 'EXERCICE');
      case 'resource':
        return const _ContentStyle(
            Icons.description_rounded, Color(0xFF3FAE6B), 'RESSOURCE');
      default:
        return _ContentStyle(
            Icons.circle_rounded, _kOrange, contentType.toUpperCase());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: _kOrange.withValues(alpha: 0.20), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: _kOrange.withValues(alpha: 0.10),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 5, color: _kOrange),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: _expanded
                        ? _buildExpandedBody(context)
                        : const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.themeIdx + 1}.${widget.subThemeIdx + 1} — ${widget.subTheme.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                if (widget.subTheme.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.subTheme.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary(context),
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          AnimatedRotation(
            duration: const Duration(milliseconds: 200),
            turns: _expanded ? 0.25 : 0,
            child: const Icon(Icons.chevron_right_rounded,
                color: _kOrange, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedBody(BuildContext context) {
    if (_loading) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          children: List.generate(
            2,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.cardAlt(context),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_error) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Impossible de charger les contenus.',
                style: TextStyle(
                    fontSize: 12.5, color: AppColors.textSecondary(context)),
              ),
            ),
            TextButton(
              onPressed: _loadContents,
              child: const Text('Réessayer',
                  style:
                      TextStyle(color: _kOrange, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    }

    if (_contents.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Text(
          'Aucun contenu pour le moment.',
          style: TextStyle(
              fontSize: 12.5, color: AppColors.textSecondary(context)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        children: [
          const Divider(height: 18),
          for (int i = 0; i < _contents.length; i++)
            _buildContentRow(context, i, isLast: i == _contents.length - 1),
        ],
      ),
    );
  }

  Widget _buildContentRow(BuildContext context, int index,
      {required bool isLast}) {
    final content = _contents[index];
    final style = _styleFor(content.contentType);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 16,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: const BoxDecoration(
                    color: _kOrange,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: _kOrange.withValues(alpha: 0.30),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 4 : 10),
              child: GestureDetector(
                onTap: () => _openContent(index),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardAlt(context),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: style.color.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(style.icon, color: style.color, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              style.label,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                                color: style.color,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              content.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
