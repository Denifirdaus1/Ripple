import 'package:flutter/material.dart';
import '../../core/services/signed_url_service.dart';

/// A widget that displays images from either public URLs or private storage paths.
///
/// This widget handles:
/// - Public URLs: Displays directly
/// - Storage paths: Generates signed URL first, then displays
/// - Loading states and error handling
class SignedImageWidget extends StatefulWidget {
  /// The image source - can be a full URL or a storage path
  /// Storage paths format: "bucket-name/path/to/file"
  final String imageSource;

  /// Widget to show while loading
  final Widget? placeholder;

  /// Widget to show on error
  final Widget? errorWidget;

  /// BoxFit for the image
  final BoxFit fit;

  /// Optional width constraint
  final double? width;

  /// Optional height constraint
  final double? height;

  const SignedImageWidget({
    super.key,
    required this.imageSource,
    this.placeholder,
    this.errorWidget,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  State<SignedImageWidget> createState() => _SignedImageWidgetState();
}

class _SignedImageWidgetState extends State<SignedImageWidget> {
  final SignedUrlService _signedUrlService = SignedUrlService();
  String? _resolvedUrl;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _resolveUrl();
  }

  @override
  void didUpdateWidget(SignedImageWidget oldWidget) {
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
      final url = await _signedUrlService.resolveUrl(widget.imageSource);
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

  Widget _buildPlaceholder() {
    return widget.placeholder ??
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
  }

  Widget _buildErrorWidget() {
    return widget.errorWidget ??
        Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildPlaceholder();
    }

    if (_hasError || _resolvedUrl == null) {
      return _buildErrorWidget();
    }

    return Image.network(
      _resolvedUrl!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );
  }
}
