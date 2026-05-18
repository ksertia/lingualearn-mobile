import 'package:fasolingo/widgets/decouvrir_page/decouverte/answer_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fasolingo/helpers/constant/app_constant.dart';

class StepDiscoveryImage extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String? answerType;
  final String? answerValue;

  const StepDiscoveryImage({
    super.key,
    required this.title,
    required this.imageUrl,
    this.answerType,
    this.answerValue,
  });

  @override
  State<StepDiscoveryImage> createState() => _StepDiscoveryImageState();
}

class _StepDiscoveryImageState extends State<StepDiscoveryImage> {
  late String _currentImageUrl;

  bool _hasError = false;
  bool _isLoaded = false;

  bool _triedHttpsFallback = false;
  bool _triedPortFallback = false;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = _formatFullImageUrl(widget.imageUrl);
  }

  @override
  void didUpdateWidget(covariant StepDiscoveryImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.imageUrl != widget.imageUrl) {
      _currentImageUrl = _formatFullImageUrl(widget.imageUrl);
      _hasError = false;
      _isLoaded = false;
      _triedHttpsFallback = false;
      _triedPortFallback = false;
    }
  }

  String _formatFullImageUrl(String path,
      {bool forceHttps = false, bool forcePort4001 = false}) {
    final String trimmedPath = path.trim();
    if (trimmedPath.isEmpty) return trimmedPath;

    Uri uri;

    if (trimmedPath.startsWith('http://') ||
        trimmedPath.startsWith('https://')) {
      uri = Uri.parse(trimmedPath);
    } else {
      String serverBase = AppConstant.baseURl.replaceAll('/api/v1', '');

      if (forcePort4001) {
        serverBase = serverBase.replaceAll(':4000', ':4001');
      } else if (serverBase.contains(':4001')) {
        serverBase = serverBase.replaceAll(':4001', ':4000');
      }

      final String normalizedBase =
          serverBase.replaceAll('https://', 'http://');

      final String fullUrl = normalizedBase +
          (trimmedPath.startsWith('/') ? trimmedPath : '/$trimmedPath');

      uri = Uri.parse(fullUrl);
    }

    final String scheme = forceHttps ? 'https' : uri.scheme;

    int port = uri.port;
    if (forcePort4001) {
      port = 4001;
    }

    final String fullUri = uri.replace(scheme: scheme, port: port).toString();
    return Uri.encodeFull(fullUri);
  }

  void _tryPortFallback() {
    if (_triedPortFallback) return;

    final fallback = _formatFullImageUrl(
      widget.imageUrl,
      forcePort4001: true,
      forceHttps: _currentImageUrl.startsWith('https://'),
    );

    if (fallback != _currentImageUrl) {
      setState(() {
        _currentImageUrl = fallback;
        _triedPortFallback = true;
      });
    }
  }

  void _tryHttpsFallback() {
    if (_triedHttpsFallback || !_currentImageUrl.startsWith('http://')) return;

    final httpsUrl =
        _formatFullImageUrl(widget.imageUrl, forceHttps: true);

    if (httpsUrl != _currentImageUrl) {
      setState(() {
        _currentImageUrl = httpsUrl;
        _triedHttpsFallback = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Titre en badge pill
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFF8F00).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(
                color: const Color(0xFFFF8F00).withValues(alpha: 0.30),
              ),
            ),
            child: Text(
              widget.title.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFFF8F00),
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),

        SizedBox(height: 14.h),

        // Image
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: _buildImageFrame(_currentImageUrl),
          ),
        ),

        // Section réponse (sans flèche)
        if (widget.answerValue?.isNotEmpty ?? false)
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 18.h),
            child: AnswerSection(
              answerType: widget.answerType,
              answerValue: widget.answerValue,
            ),
          ),
      ],
    );
  }

  Widget _buildImageFrame(String url) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,

          /// ✅ LOADING
          loadingBuilder: (context, child, progress) {
            if (progress == null) {
              if (!_isLoaded) {
                Future.microtask(() {
                  if (mounted) {
                    setState(() {
                      _isLoaded = true;
                      _hasError = false;
                    });
                  }
                });
              }
              return child;
            }

            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          },

          /// ❌ ERROR CONTROLLED
          errorBuilder: (context, error, stackTrace) {
            debugPrint('❌ erreur image: $url');

            if (!_triedPortFallback && url.contains(':4000')) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _tryPortFallback();
              });
              return const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              );
            }

            if (!_triedHttpsFallback && url.startsWith('http://')) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _tryHttpsFallback();
              });
              return const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              );
            }

            if (!_hasError) {
              Future.microtask(() {
                if (mounted) {
                  setState(() {
                    _hasError = true;
                  });
                }
              });
            }

            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          },
        ),
      ),
    );
  }
}