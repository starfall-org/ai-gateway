import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/chat/message.dart';
import '../../../core/models/chat/conversation.dart';
import '../../../core/models/ai/profile.dart';
import '../../../shared/translate/tl.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../services/chat_service.dart';
import '../utils/chat_logic_utils.dart';
import '../ui/widgets/edit_message_sheet.dart';

/// Controller responsible for message operations
class MessageController extends ChangeNotifier {
  bool isGenerating = false;

  void setGenerating(bool value) {
    isGenerating = value;
    notifyListeners();
  }

  Future<void> sendMessage({
    required String text,
    required List<String> attachments,
    required Conversation currentSession,
    required AIProfile profile,
    required String providerName,
    required String modelName,
    required bool enableStream,
    required Function(Conversation) onSessionUpdate,
    required Function() onScrollToBottom,
    required Function() isNearBottom,
    List<String>? allowedToolNames,
  }) async {
    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      role: ChatRole.user,
      content: text,
      timestamp: DateTime.now(),
      attachments: attachments,
    );

    var session = currentSession.copyWith(
      messages: [...currentSession.messages, userMessage],
      updatedAt: DateTime.now(),
    );

    isGenerating = true;
    notifyListeners();

    // Generate title if first message
    if (session.messages.length == 1) {
      final title = ChatLogicUtils.generateTitle(text, attachments);
      session = session.copyWith(title: title);
    }

    onSessionUpdate(session);

    final modelInput = ChatLogicUtils.formatAttachmentsForPrompt(
      text,
      attachments,
    );

    if (enableStream) {
      await _handleStreamResponse(
        userText: modelInput,
        history: session.messages.take(session.messages.length - 1).toList(),
        profile: profile,
        providerName: providerName,
        modelName: modelName,
        currentSession: session,
        onSessionUpdate: onSessionUpdate,
        onScrollToBottom: onScrollToBottom,
        isNearBottom: isNearBottom,
        allowedToolNames: allowedToolNames,
      );
    } else {
      await _handleNonStreamResponse(
        userText: modelInput,
        history: session.messages.take(session.messages.length - 1).toList(),
        profile: profile,
        providerName: providerName,
        modelName: modelName,
        currentSession: session,
        onSessionUpdate: onSessionUpdate,
        onScrollToBottom: onScrollToBottom,
        allowedToolNames: allowedToolNames,
      );
    }
  }

  Future<void> _handleStreamResponse({
    required String userText,
    required List<ChatMessage> history,
    required AIProfile profile,
    required String providerName,
    required String modelName,
    required Conversation currentSession,
    required Function(Conversation) onSessionUpdate,
    required Function() onScrollToBottom,
    required Function() isNearBottom,
    List<String>? allowedToolNames,
  }) async {
    final stream = ChatService.generateStream(
      userText: userText,
      history: history,
      profile: profile,
      providerName: providerName,
      modelName: modelName,
      allowedToolNames: allowedToolNames,
    );

    final modelId = const Uuid().v4();
    var acc = '';
    final placeholder = ChatMessage(
      id: modelId,
      role: ChatRole.model,
      content: '',
      timestamp: DateTime.now(),
    );

    var session = currentSession.copyWith(
      messages: [...currentSession.messages, placeholder],
      updatedAt: DateTime.now(),
    );
    onSessionUpdate(session);

    try {
      DateTime lastUpdate = DateTime.now();
      const throttleDuration = Duration(milliseconds: 100);

      await for (final chunk in stream) {
        if (chunk.isEmpty) continue;
        acc += chunk;

        final now = DateTime.now();
        if (now.difference(lastUpdate) < throttleDuration) {
          continue;
        }

        final wasAtBottom = isNearBottom();

        final msgs = List<ChatMessage>.from(session.messages);
        final idx = msgs.indexWhere((m) => m.id == modelId);
        if (idx != -1) {
          final old = msgs[idx];
          msgs[idx] = ChatMessage(
            id: old.id,
            role: old.role,
            content: acc,
            timestamp: old.timestamp,
            attachments: old.attachments,
            reasoningContent: old.reasoningContent,
            aiMedia: old.aiMedia,
          );
          session = session.copyWith(
            messages: msgs,
            updatedAt: DateTime.now(),
          );
          onSessionUpdate(session);

          if (wasAtBottom) {
            onScrollToBottom();
          }
          lastUpdate = now;
        }
      }

      // Final update
      final msgs = List<ChatMessage>.from(session.messages);
      final idx = msgs.indexWhere((m) => m.id == modelId);
      if (idx != -1) {
        final old = msgs[idx];
        if (old.content != acc) {
          msgs[idx] = ChatMessage(
            id: old.id,
            role: old.role,
            content: acc,
            timestamp: old.timestamp,
            attachments: old.attachments,
            reasoningContent: old.reasoningContent,
            aiMedia: old.aiMedia,
          );
          session = session.copyWith(
            messages: msgs,
            updatedAt: DateTime.now(),
          );
          onSessionUpdate(session);
        }
      }
    } finally {
      isGenerating = false;
      notifyListeners();
      if (isNearBottom()) {
        onScrollToBottom();
      }
    }
  }

  Future<void> _handleNonStreamResponse({
    required String userText,
    required List<ChatMessage> history,
    required AIProfile profile,
    required String providerName,
    required String modelName,
    required Conversation currentSession,
    required Function(Conversation) onSessionUpdate,
    required Function() onScrollToBottom,
    List<String>? allowedToolNames,
  }) async {
    final reply = await ChatService.generateReply(
      userText: userText,
      history: history,
      profile: profile,
      providerName: providerName,
      modelName: modelName,
      allowedToolNames: allowedToolNames,
    );

    final modelMessage = ChatMessage(
      id: const Uuid().v4(),
      role: ChatRole.model,
      content: reply,
      timestamp: DateTime.now(),
    );

    final session = currentSession.copyWith(
      messages: [...currentSession.messages, modelMessage],
      updatedAt: DateTime.now(),
    );

    isGenerating = false;
    notifyListeners();

    onSessionUpdate(session);
    onScrollToBottom();
  }

  Future<String?> regenerateLast({
    required Conversation currentSession,
    required AIProfile profile,
    required String providerName,
    required String modelName,
    required bool enableStream,
    required Function(Conversation) onSessionUpdate,
    required Function() onScrollToBottom,
    required Function() isNearBottom,
    List<String>? allowedToolNames,
  }) async {
    if (currentSession.messages.isEmpty) return null;

    final msgs = currentSession.messages;
    int lastUserIndex = -1;
    for (int i = msgs.length - 1; i >= 0; i--) {
      if (msgs[i].role == ChatRole.user) {
        lastUserIndex = i;
        break;
      }
    }

    if (lastUserIndex == -1) {
      return tl('No user message found to regenerate');
    }

    final userText = msgs[lastUserIndex].content;
    final history = msgs.take(lastUserIndex).toList();

    isGenerating = true;
    notifyListeners();

    final baseMessages = [...history, msgs[lastUserIndex]];
    var session = currentSession.copyWith(
      messages: baseMessages,
      updatedAt: DateTime.now(),
    );

    if (enableStream) {
      await _handleStreamResponse(
        userText: userText,
        history: history,
        profile: profile,
        providerName: providerName,
        modelName: modelName,
        currentSession: session,
        onSessionUpdate: onSessionUpdate,
        onScrollToBottom: onScrollToBottom,
        isNearBottom: isNearBottom,
        allowedToolNames: allowedToolNames,
      );
    } else {
      await _handleNonStreamResponse(
        userText: userText,
        history: history,
        profile: profile,
        providerName: providerName,
        modelName: modelName,
        currentSession: session,
        onSessionUpdate: onSessionUpdate,
        onScrollToBottom: onScrollToBottom,
        allowedToolNames: allowedToolNames,
      );
    }

    return null;
  }

  Future<void> copyMessage(BuildContext context, ChatMessage message) async {
    if (message.content.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: message.content));
    if (context.mounted) {
      context.showSuccessSnackBar(tl('Transcript copied'));
    }
  }

  Future<void> deleteMessage({
    required ChatMessage message,
    required Conversation currentSession,
    required Function(Conversation) onSessionUpdate,
  }) async {
    final msgs = List<ChatMessage>.from(currentSession.messages)
      ..removeWhere((m) => m.id == message.id);

    final session = currentSession.copyWith(
      messages: msgs,
      updatedAt: DateTime.now(),
    );

    onSessionUpdate(session);
  }

  Future<void> openEditMessageDialog(
    BuildContext context,
    ChatMessage message,
    Conversation currentSession,
    Function(Conversation) onSessionUpdate,
    Function(BuildContext) regenerateCallback,
  ) async {
    final result = await EditMessageSheet.show(
      context,
      initialContent: message.content,
      initialAttachments: message.attachments,
    );
    if (result == null) return;
    if (!context.mounted) return;

    await applyMessageEdit(
      original: message,
      newContent: result.content,
      newAttachments: result.attachments,
      resend: result.resend,
      currentSession: currentSession,
      onSessionUpdate: onSessionUpdate,
      regenerateCallback: result.resend ? () => regenerateCallback(context) : null,
    );
  }

  Future<void> applyMessageEdit({
    required ChatMessage original,
    required String newContent,
    required List<String> newAttachments,
    bool resend = false,
    required Conversation currentSession,
    required Function(Conversation) onSessionUpdate,
    Function()? regenerateCallback,
  }) async {
    final msgs = List<ChatMessage>.from(currentSession.messages);
    final idx = msgs.indexWhere((m) => m.id == original.id);
    if (idx == -1) return;

    final updated = ChatMessage(
      id: original.id,
      role: original.role,
      content: newContent,
      timestamp: original.timestamp,
      attachments: newAttachments,
      reasoningContent: original.reasoningContent,
      aiMedia: original.aiMedia,
    );
    msgs[idx] = updated;

    final session = currentSession.copyWith(
      messages: msgs,
      updatedAt: DateTime.now(),
    );

    onSessionUpdate(session);

    if (resend && regenerateCallback != null) {
      regenerateCallback();
    }
  }
}
