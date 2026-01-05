// Toolbar module main barrel export
// 
// This module provides an extensible toolbar system that can be used
// anywhere in the application. To use:
// 
// 1. Import this file: import 'package:ripple/core/toolbar/toolbar.dart';
// 2. Use ExtensibleToolbar widget with ToolContext
// 3. Register custom tools with ToolbarRegistry()
//
// Example:
// ```dart
// ExtensibleToolbar(
//   toolContext: ToolContext(
//     buildContext: context,
//     quillController: _controller,
//   ),
// )
// ```

// Domain
export 'domain/entities/entities.dart';

// Registry
export 'toolbar_registry.dart';

// Tools
export 'tools/tools.dart';
export 'tools/default_tools.dart';

// Presentation
export 'presentation/widgets/widgets.dart';
