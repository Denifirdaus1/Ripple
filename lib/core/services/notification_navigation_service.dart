import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/notification_logger.dart';

/// Service to handle notification-triggered navigation
class NotificationNavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  /// Pending notification payload to handle when app is ready
  static String? pendingTodoId;
  
  /// Navigate to todo detail page
  static void navigateToTodo(String? todoId) {
    final hasContext = navigatorKey.currentContext != null;
    NotificationLogger.navigationAttempt(todoId, hasContext);
    
    final context = navigatorKey.currentContext;
    if (context == null) {
      NotificationLogger.navigationPending(todoId);
      pendingTodoId = todoId;
      return;
    }
    
    try {
      if (todoId != null && todoId.isNotEmpty) {
        final route = '/todo/$todoId';
        context.go(route);
        NotificationLogger.navigationSuccess(route);
      } else {
        context.go('/');
        NotificationLogger.navigationSuccess('/');
      }
    } catch (e) {
      NotificationLogger.navigationError(e.toString());
      try {
        context.go('/');
      } catch (_) {}
    }
  }
  
  /// Process any pending navigation (called from app.dart after build)
  static void processPendingNavigation(BuildContext context) {
    NotificationLogger.processingPendingNavigation(pendingTodoId);
    
    if (pendingTodoId != null) {
      if (pendingTodoId!.isNotEmpty) {
        final route = '/todo/$pendingTodoId';
        context.go(route);
        NotificationLogger.navigationSuccess(route);
      } else {
        context.go('/');
        NotificationLogger.navigationSuccess('/');
      }
      pendingTodoId = null;
    }
  }
}
