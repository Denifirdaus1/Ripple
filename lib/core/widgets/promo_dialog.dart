import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/promo_banner.dart';
import '../services/banner_service.dart';
import '../theme/app_colors.dart';

/// Dialog widget for displaying promotional banners
class PromoDialog extends StatelessWidget {
  final PromoBanner banner;
  final VoidCallback? onClose;

  const PromoDialog({super.key, required this.banner, this.onClose});

  /// Show the promo dialog
  static Future<void> show(BuildContext context, PromoBanner banner) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PromoDialog(
        banner: banner,
        onClose: () {
          BannerService.instance.markBannerSeen(banner.id);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  void _handleBannerTap(BuildContext context) {
    BannerService.instance.markBannerSeen(banner.id);
    Navigator.of(context).pop();

    if (banner.targetRoute != null && banner.targetRoute!.isNotEmpty) {
      context.go(banner.targetRoute!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Banner image
          GestureDetector(
            onTap: () => _handleBannerTap(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: Image.network(
                  banner.imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 300,
                      height: 300,
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 300,
                    height: 300,
                    color: Colors.grey[200],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.broken_image,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          banner.title,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Close button
          Positioned(
            top: -12,
            right: -12,
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.paperWhite,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  size: 20,
                  color: AppColors.inkBlack,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
