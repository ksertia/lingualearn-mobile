import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EvAttachedImage extends StatefulWidget {
  final String ruuid;
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final BoxFit? fit;

  const EvAttachedImage({
    super.key,
    required this.ruuid,
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
  });

  @override
  State<EvAttachedImage> createState() => _EvAttachedImageState();
}

class _EvAttachedImageState extends State<EvAttachedImage> {
  String? _imageUrl;
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchImageUrl();
  }

  Future<void> _fetchImageUrl() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final String apiUrl =
        'https://api.helios.preprod.link2digit.com/helios-core/api/v1/electric-vehicles/${widget.ruuid}/attached-file';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        // Assuming the API returns a JSON object with an 'url' field
        // containing the image URL. Adjust this based on the actual API response.
        if (responseData != null && responseData is Map<String, dynamic> && responseData.containsKey('url')) {
          setState(() {
            _imageUrl = responseData['url'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Failed to extract image URL from the response.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load image: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Error fetching image: $error';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CircularProgressIndicator(); // Or any other loading indicator
    }

    if (_errorMessage.isNotEmpty) {
      return Text('Error: $_errorMessage');
    }

    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: _imageUrl!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit ?? BoxFit.cover,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            image: DecorationImage(
              image: imageProvider,
              fit: widget.fit ?? BoxFit.cover,
            ),
          ),
        ),
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    }

    return const SizedBox.shrink(); // Or a default placeholder if no image
  }
}