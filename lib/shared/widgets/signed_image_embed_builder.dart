import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../../core/services/signed_url_service.dart';

/// Custom image embed builder that supports both public URLs and private storage paths.
///
/// This builder resolves storage paths to signed URLs before displaying,
/// while still supporting regular public URLs for backward compatibility.
class SignedImageEmbedBuilder extends EmbedBuilder {
  final SignedUrlService _signedUrlService = SignedUrlService();

  @override
  String get key => BlockEmbed.imageType;

  @override
  bool get expanded => false;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final imageSource = embedContext.node.value.data;

    if (imageSource is! String) {
      return const SizedBox.shrink();
    }

    return _SignedImageEmbed(
      imageSource: imageSource,
      signedUrlService: _signedUrlService,
    );
  }
}

class _SignedImageEmbed extends StatefulWidget {
  final String imageSource;
  final SignedUrlService signedUrlService;

  const _SignedImageEmbed({
    required this.imageSource,
    required this.signedUrlService,
  });

  @override
  State<_SignedImageEmbed> createState() => _SignedImageEmbedState();
}

class _SignedImageEmbedState extends State<_SignedImageEmbed> {
  String? _resolvedUrl;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _resolveUrl();
  }

  @override
  void didUpdateWidget(_SignedImageEmbed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageSource != widget.imageSource) {
      _resolveUrl();
    }
  }

  Future<void> _resolveUrl() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final url = await widget.signedUrlService.resolveUrl(widget.imageSource);
      if (mounted) {
        setState(() {
          _resolvedUrl = url;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_hasError || _resolvedUrl == null) {
      return Container(
        height: 200,
        color: Colors.grey[200],
        alignment: Alignment.center,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('Failed to load image', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          _resolvedUrl!,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            height: 200,
            color: Colors.grey[200],
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
