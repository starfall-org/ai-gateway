import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:multigateway/core/profile/models/chat_profile.dart';
import 'package:multigateway/core/storage/typeadapter_base.dart';
import 'package:uuid/uuid.dart';

/// Optimized ChatProfileStorage using TypeAdapter for better performance
class ChatProfileStorage extends HiveTypeAdapterStorage<ChatProfile> {
  static const String _prefix = 'chat_profile';
  static const String _selectedKey = '__selected_id__';

  static ChatProfileStorage? _instance;
  static Future<ChatProfileStorage>? _instanceFuture;

  ChatProfileStorage();

  static Future<ChatProfileStorage> init() async {
    final instance = ChatProfileStorage();
    await instance.ensureBoxReady();
    return instance;
  }

  static Future<ChatProfileStorage> get instance async {
    if (_instance != null) return _instance!;
    _instanceFuture ??= init();
    _instance = await _instanceFuture!;
    return _instance!;
  }

  @override
  String get prefix => _prefix;

  @override
  String getItemId(ChatProfile item) => item.id;

  @override
  List<ChatProfile> getItems() {
    final items = super.getItems();
    if (items.isEmpty) {
      // Don't create default profile synchronously
      // Let the caller use getItemsAsync() instead
      return [];
    }
    return items;
  }

  @override
  Future<List<ChatProfile>> getItemsAsync() async {
    final items = await super.getItemsAsync();
    if (items.isEmpty) {
      final defaultProfile = _createDefaultProfile();
      await saveItem(defaultProfile);
      return [defaultProfile];
    }
    return items;
  }

  // Reactive streams
  Stream<ChatProfile> get selectedProfileStream {
    final controller = StreamController<ChatProfile>.broadcast();
    StreamSubscription<void>? sub;
    controller.onListen = () async {
      final profile = await getOrInitSelectedProfile();
      controller.add(profile);
      sub = changes.listen((_) async {
        final p = await getOrInitSelectedProfile();
        controller.add(p);
      });
    };
    controller.onCancel = () async {
      await sub?.cancel();
      sub = null;
    };
    return controller.stream;
  }

  // --- Selection helpers ---

  /// Override deleteItem to maintain valid selection after deletion
  @override
  Future<void> deleteItem(String id) async {
    await super.deleteItem(id);

    // Maintain a valid selection after deletion
    final selectedId = getSelectedProfileId();
    if (selectedId == id) {
      final allIds = getItemIds();

      if (allIds.isEmpty) {
        final box = await openMetaBox();
        await box.delete(_selectedKey);
        // Let listeners know selection disappeared
        changeSignal.value++;
      } else {
        // Select the first available
        await setSelectedProfileId(allIds.first);
      }
    }
  }

  /// Override saveItem to auto-select first profile if none selected
  @override
  Future<void> saveItem(ChatProfile profile) async {
    await super.saveItem(profile);
    // If no selection yet, select the newly added profile by default
    if (getSelectedProfileId() == null) {
      await setSelectedProfileId(profile.id);
    }
  }

  String? getSelectedProfileId() {
    if (!Hive.isBoxOpen(metaBoxName)) return null;
    final box = Hive.box(metaBoxName);
    return box.get(_selectedKey) as String?;
  }

  Future<void> setSelectedProfileId(String id) async {
    final box = Hive.isBoxOpen(metaBoxName)
        ? Hive.box(metaBoxName)
        : await openMetaBox();
    await box.put(_selectedKey, id);
    // Notify listeners so selected profile updates propagate live
    changeSignal.value++;
  }

  Future<ChatProfile> getOrInitSelectedProfile() async {
    final selectedId = getSelectedProfileId();

    if (selectedId != null) {
      final profile = getItem(selectedId);
      if (profile != null) return profile;
    }

    // Fallback if selection is invalid or missing
    final allIds = getItemIds();
    if (allIds.isNotEmpty) {
      final firstProfile = getItem(allIds.first);
      if (firstProfile != null) {
        await setSelectedProfileId(firstProfile.id);
        return firstProfile;
      }
    }

    // Create default profile
    final defaultProfile = _createDefaultProfile();
    await saveItem(defaultProfile);
    await setSelectedProfileId(defaultProfile.id);
    return defaultProfile;
  }

  ChatProfile _createDefaultProfile() {
    return ChatProfile(
      id: const Uuid().v4(),
      name: 'Default Profile',
      config: LlmChatConfig(systemPrompt: '', enableStream: true),
    );
  }
}
