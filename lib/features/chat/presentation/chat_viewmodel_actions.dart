part of 'chat_viewmodel.dart';

extension ChatViewModelActions on ChatViewModel {
  Future<List<String>> _snapshotEnabledToolNames(AIAgent agent) async {
    try {
      final mcpRepo = await MCPRepository.init();
      final servers = agent.activeMCPServerIds
          .map((id) => mcpRepo.getItem(id))
          .whereType<MCPServer>()
          .toList();
      final names = <String>{};
      for (final s in servers) {
        for (final t in s.tools) {
          if (t.enabled) names.add(t.name);
        }
      }
      return names.toList();
    } catch (_) {
      return const <String>[];
    }
  }

  Future<void> handleSubmitted(String text, BuildContext context) async {
    if (((text.trim().isEmpty) && pendingAttachments.isEmpty) ||
        currentSession == null) {
      return;
    }

    final List<String> attachments = List<String>.from(pendingAttachments);
    textController.clear();

    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      role: ChatRole.user,
      content: text,
      timestamp: DateTime.now(),
      attachments: attachments,
    );

    currentSession = currentSession!.copyWith(
      messages: [...currentSession!.messages, userMessage],
      updatedAt: DateTime.now(),
    );
    isGenerating = true;
    pendingAttachments.clear();
    notify();

    if (currentSession!.messages.length == 1) {
      final base = text.isNotEmpty
          ? text
          : (attachments.isNotEmpty
                ? 'attachments.title_count'.tr(
                    namedArgs: {'count': attachments.length.toString()},
                  )
                : 'drawer.new_chat'.tr());
      final title = base.length > 30 ? '${base.substring(0, 30)}...' : base;
      currentSession = currentSession!.copyWith(title: title);
    }

    await chatRepository!.saveConversation(currentSession!);
    scrollToBottom();

    String modelInput = text;
    if (attachments.isNotEmpty) {
      final names = attachments.map((p) => p.split('/').last).join(', ');
      modelInput =
          '${modelInput.isEmpty ? '' : '$modelInput\n'}[Attachments: $names]';
    }

    // Select provider/model based on preferences
    final providerRepo = await ProviderRepository.init();
    final providersList = providerRepo.getProviders();

    final persist = shouldPersistSelections();
    String providerName;
    String modelName;

    if (persist &&
        currentSession?.providerName != null &&
        currentSession?.modelName != null) {
      providerName = currentSession!.providerName!;
      modelName = currentSession!.modelName!;
    } else {
      providerName =
          selectedProviderName ?? (providersList.isNotEmpty ? providersList.first.name : '');
      modelName = selectedModelName ??
          ((providersList.isNotEmpty && providersList.first.models.isNotEmpty)
              ? providersList.first.models.first.name
              : '');
      // If persistence is enabled, store selection on the conversation
      if (currentSession != null && persist) {
        currentSession = currentSession!.copyWith(
          providerName: providerName,
          modelName: modelName,
          updatedAt: DateTime.now(),
        );
        await chatRepository!.saveConversation(currentSession!);
      }
    }

    // Prepare allowed tool names if persistence is enabled
    List<String>? allowedToolNames;
    if (persist) {
      if (currentSession!.enabledToolNames == null) {
        // Snapshot currently enabled MCP tools from agent for this conversation
        final agent = selectedAgent ??
            AIAgent(
              id: const Uuid().v4(),
              name: 'Default Agent',
              systemPrompt: '',
            );
        final names = await _snapshotEnabledToolNames(agent);
        currentSession = currentSession!.copyWith(
          enabledToolNames: names,
          updatedAt: DateTime.now(),
        );
        await chatRepository!.saveConversation(currentSession!);
      }
      allowedToolNames = currentSession!.enabledToolNames;
    }

    final reply = await ChatService.generateReply(
      userText: modelInput,
      history: currentSession!.messages,
      agent: selectedAgent ??
          AIAgent(
            id: const Uuid().v4(),
            name: 'Default Agent',
            systemPrompt: '',
          ),
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

    currentSession = currentSession!.copyWith(
      messages: [...currentSession!.messages, modelMessage],
      updatedAt: DateTime.now(),
    );
    isGenerating = false;
    notify();

    await chatRepository!.saveConversation(currentSession!);
    scrollToBottom();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> pickAttachments(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );
      final paths = result?.paths.whereType<String>().toList() ?? const [];
      if (paths.isEmpty) return;

      for (final p in paths) {
        if (!pendingAttachments.contains(p)) {
          pendingAttachments.add(p);
        }
      }
      notify();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'chat.unable_pick'.tr(namedArgs: {'error': e.toString()}),
            ),
          ),
        );
      }
    }
  }

  void removeAttachmentAt(int index) {
    if (index < 0 || index >= pendingAttachments.length) return;
    pendingAttachments.removeAt(index);
    notify();
  }

  String getTranscript() {
    if (currentSession == null) return '';
    return currentSession!.messages
        .map((m) {
          final who = m.role == ChatRole.user
              ? 'role.you'.tr(context: scaffoldKey.currentContext!)
              : (m.role == ChatRole.model
                    ? (selectedAgent?.name ?? 'AI')
                    : 'role.system'.tr(context: scaffoldKey.currentContext!));
          return '$who: ${m.content}';
        })
        .join('\n\n');
  }

  Future<void> copyTranscript(BuildContext context) async {
    final txt = getTranscript();
    if (txt.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: txt));

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('chat.copied'.tr())));
    }
  }

  Future<void> clearChat() async {
    if (currentSession == null) return;
    currentSession = currentSession!.copyWith(
      messages: [],
      updatedAt: DateTime.now(),
    );
    notify();
    await chatRepository!.saveConversation(currentSession!);
  }

  Future<void> regenerateLast(BuildContext context) async {
    if (currentSession == null || currentSession!.messages.isEmpty) return;

    final msgs = currentSession!.messages;
    int lastUserIndex = -1;
    for (int i = msgs.length - 1; i >= 0; i--) {
      if (msgs[i].role == ChatRole.user) {
        lastUserIndex = i;
        break;
      }
    }
    if (lastUserIndex == -1) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('chat.no_user_to_regen'.tr())));
      }
      return;
    }

    final userText = msgs[lastUserIndex].content;
    final history = msgs.take(lastUserIndex).toList();

    isGenerating = true;
    notify();

    final providerRepo = await ProviderRepository.init();
    final providersList = providerRepo.getProviders();

    final persist = shouldPersistSelections();
    String providerName;
    String modelName;

    if (persist &&
        currentSession?.providerName != null &&
        currentSession?.modelName != null) {
      providerName = currentSession!.providerName!;
      modelName = currentSession!.modelName!;
    } else {
      providerName =
          selectedProviderName ?? (providersList.isNotEmpty ? providersList.first.name : '');
      modelName = selectedModelName ??
          ((providersList.isNotEmpty && providersList.first.models.isNotEmpty)
              ? providersList.first.models.first.name
              : '');
      if (currentSession != null && persist) {
        currentSession = currentSession!.copyWith(
          providerName: providerName,
          modelName: modelName,
          updatedAt: DateTime.now(),
        );
        await chatRepository!.saveConversation(currentSession!);
      }
    }

    List<String>? allowedToolNames;
    if (persist) {
      if (currentSession!.enabledToolNames == null) {
        final agent = selectedAgent ??
            AIAgent(
              id: const Uuid().v4(),
              name: 'Default Agent',
              systemPrompt: '',
            );
        final names = await _snapshotEnabledToolNames(agent);
        currentSession = currentSession!.copyWith(
          enabledToolNames: names,
          updatedAt: DateTime.now(),
        );
        await chatRepository!.saveConversation(currentSession!);
      }
      allowedToolNames = currentSession!.enabledToolNames;
    }

    final reply = await ChatService.generateReply(
      userText: userText,
      history: history,
      agent: selectedAgent ??
          AIAgent(
            id: const Uuid().v4(),
            name: 'Default Agent',
            systemPrompt: '',
          ),
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

    final newMessages = [...history, msgs[lastUserIndex], modelMessage];

    currentSession = currentSession!.copyWith(
      messages: newMessages,
      updatedAt: DateTime.now(),
    );
    isGenerating = false;
    notify();

    await chatRepository!.saveConversation(currentSession!);
    scrollToBottom();
  }

  Future<void> speakLastModelMessage() async {
    if (currentSession == null || currentSession!.messages.isEmpty) return;
    final lastModel = currentSession!.messages.lastWhere(
      (m) => m.role == ChatRole.model,
      orElse: () => ChatMessage(
        id: '',
        role: ChatRole.model,
        content: '',
        timestamp: DateTime.now(),
      ),
    );
    if (lastModel.content.isEmpty) return;
    tts ??= FlutterTts();
    await tts!.speak(lastModel.content);
  }

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void openEndDrawer() {
    scaffoldKey.currentState?.openEndDrawer();
  }

  void closeEndDrawer() {
    scaffoldKey.currentState?.closeEndDrawer();
  }

  void setInspectingAttachments(List<String> attachments) {
    inspectingAttachments
      ..clear()
      ..addAll(attachments);
    notify();
  }

  void openAttachmentsSidebar(List<String> attachments) {
    setInspectingAttachments(attachments);
    openEndDrawer();
  }

  Future<void> copyMessage(BuildContext context, ChatMessage message) async {
    if (message.content.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: message.content));
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('chat.copied'.tr())));
    }
  }

  Future<void> deleteMessage(ChatMessage message) async {
    if (currentSession == null) return;
    final msgs = List<ChatMessage>.from(currentSession!.messages)
      ..removeWhere((m) => m.id == message.id);
    currentSession = currentSession!.copyWith(
      messages: msgs,
      updatedAt: DateTime.now(),
    );
    notify();
    await chatRepository!.saveConversation(currentSession!);
  }

  Future<void> openEditMessageDialog(BuildContext context, ChatMessage message) async {
    final result = await EditMessageDialog.show(
      context,
      initialContent: message.content,
      initialAttachments: message.attachments,
    );
    if (result == null) return;
    await applyMessageEdit(
      message,
      result.content,
      result.attachments,
      resend: result.resend,
      context: context,
    );
  }

  Future<void> applyMessageEdit(
    ChatMessage original,
    String newContent,
    List<String> newAttachments, {
    bool resend = false,
    BuildContext? context,
  }) async {
    if (currentSession == null) return;

    final msgs = List<ChatMessage>.from(currentSession!.messages);
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

    currentSession = currentSession!.copyWith(
      messages: msgs,
      updatedAt: DateTime.now(),
    );
    notify();
    await chatRepository!.saveConversation(currentSession!);

    if (resend && context != null) {
      await regenerateLast(context);
    }
  }
}
