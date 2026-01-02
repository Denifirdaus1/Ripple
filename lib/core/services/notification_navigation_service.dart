import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Service to handle notification-triggered navigation
/// Uses a global navigator key to navigate from outside widget tree
class NotificationNavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  /// Pending notification payload to handle when app is ready
  static String? pendingTodoId;
  
  /// Navigate to todo/schedule page
  static void navigateToTodo(String? todoId) {
    if (todoId == null || todoId.isEmpty) {
      debugPrint('NotificationNavigationService: No todoId provided, navigating to home');
    }
    
    debugPrint('NotificationNavigationService: Navigating to todo schedule');
    
    // Get the current navigator context
    final context = navigatorKey.currentContext;
    if (context == null) {
      // App not ready yet, save for later
      debugPrint('NotificationNavigationService: App not ready, saving for later');
      pendingTodoId = todoId;
      return;
    }
    
    // Navigate to home (which contains the calendar/schedule view)
    // Using go_router's go() method
    try {
      context.go('/');
      debugPrint('NotificationNavigationService: Navigation successful');
    } catch (e) {
      debugPrint('NotificationNavigationService: Navigation error: $e');
    }
  }
  
  /// Process any pending navigation (called from main shell after login)
  static void processPendingNavigation(BuildContext context) {
    if (pendingTodoId != null) {
      debugPrint('NotificationNavigationService: Processing pending navigation');
      context.go('/');
      pendingTodoId = null;
    }
  }
}
