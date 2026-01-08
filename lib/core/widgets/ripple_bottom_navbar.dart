import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/app_colors.dart';
import '../services/remote_config_service.dart';

/// Navigation item configuration
class NavItemConfig {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final String configKey;

  const NavItemConfig({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    required this.configKey,
  });
}

/// Custom bottom navigation bar for Ripple app with remote config support
class RippleBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const RippleBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  /// All possible nav items with their config keys
  static const List<NavItemConfig> _allItems = [
    NavItemConfig(
      icon: PhosphorIconsRegular.house,
      activeIcon: PhosphorIconsFill.house,
      label: 'Home',
      route: '/',
      configKey: 'show_todos_tab',
    ),
    NavItemConfig(
      icon: PhosphorIconsRegular.notePencil,
      activeIcon: PhosphorIconsFill.notePencil,
      label: 'Notes',
      route: '/notes',
      configKey: 'show_notes_tab',
    ),
    NavItemConfig(
      icon: PhosphorIconsRegular.timer,
      activeIcon: PhosphorIconsFill.timer,
      label: 'Focus',
      route: '/focus',
      configKey: 'show_focus_tab',
    ),
    NavItemConfig(
      icon: PhosphorIconsRegular.user,
      activeIcon: PhosphorIconsFill.user,
      label: 'Profile',
      route: '/profile',
      configKey: '', // Always shown
    ),
  ];

  /// Get visible items based on remote config
  List<NavItemConfig> get _visibleItems {
    final config = RemoteConfigService.instance;
    return _allItems.where((item) {
      if (item.configKey.isEmpty) return true; // Always show if no config key
      return config.isEnabled(item.configKey);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _visibleItems;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.paperWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // First half of items
              ...items.take((items.length / 2).ceil()).map((item) {
                final index = items.indexOf(item);
                return _NavItem(
                  icon: item.icon,
                  activeIcon: item.activeIcon,
                  label: item.label,
                  isActive: currentIndex == index,
                  onTap: () => onTap(index),
                );
              }),
              // Spacer for the floating add button
              const SizedBox(width: 56),
              // Second half of items
              ...items.skip((items.length / 2).ceil()).map((item) {
                final index = items.indexOf(item);
                return _NavItem(
                  icon: item.icon,
                  activeIcon: item.activeIcon,
                  label: item.label,
                  isActive: currentIndex == index,
                  onTap: () => onTap(index),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// Get route for a given navbar index
  static String getRouteForIndex(int index) {
    final config = RemoteConfigService.instance;
    final visibleItems = _allItems.where((item) {
      if (item.configKey.isEmpty) return true;
      return config.isEnabled(item.configKey);
    }).toList();

    if (index >= 0 && index < visibleItems.length) {
      return visibleItems[index].route;
    }
    return '/';
  }

  /// Get navbar index for a given route
  static int getIndexForRoute(String location) {
    final config = RemoteConfigService.instance;
    final visibleItems = _allItems.where((item) {
      if (item.configKey.isEmpty) return true;
      return config.isEnabled(item.configKey);
    }).toList();

    for (int i = 0; i < visibleItems.length; i++) {
      if (location.startsWith(visibleItems[i].route) &&
          visibleItems[i].route != '/') {
        return i;
      }
    }
    // Default to first tab (usually Home)
    return 0;
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 24,
              color: isActive ? AppColors.rippleBlue : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? AppColors.rippleBlue
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
