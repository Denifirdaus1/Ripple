import '../domain/entities/entities.dart';
import 'tools.dart';

/// Default built-in toolbar tools
class DefaultTools {
  DefaultTools._();

  // Formatting tools
  static final bold = BoldTool();
  static final italic = ItalicTool();
  static final underline = UnderlineTool();
  static final strike = StrikeTool();
  static final header = HeaderTool();

  // List tools
  static final bulletList = BulletListTool();
  static final numberedList = NumberedListTool();
  static final checkbox = CheckboxTool();

  // Media tools
  static final image = ImageTool();
  static final voice = VoiceTool();

  // AI tools
  static final aiSuggest = AiSuggestTool();

  // Utility tools
  static final undo = UndoTool();
  static final redo = RedoTool();
  static final link = LinkTool();
  static final mention = MentionTool();
  static final notification = NotificationTool();
  static final hideKeyboard = HideKeyboardTool();

  /// All default tools in order
  static List<ToolDefinition> get all => [
    // Quick actions (user priority order)
    aiSuggest,        // AI
    image,            // Image
    voice,            // Voice
    mention,          // Tag/@
    link,             // Link
    undo,             // Undo
    redo,             // Redo
    // Formatting
    bold,
    italic,
    underline,
    strike,
    header,
    // Lists
    bulletList,
    numberedList,
    checkbox,
    // Other utility
    notification,
    hideKeyboard,
  ];
}
