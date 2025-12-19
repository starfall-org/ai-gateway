import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/ai_agent.dart';
import 'base_repository.dart';

class AgentRepository extends BaseRepository<AIAgent> {
  static const String _boxName = 'agents';
  static const String _selectedKey = 'selected_agent_id';

  // We need a separate box for simple key-value settings like 'selected_agent_id'
  // Or we can store it in the same box with a special key if we are careful,
  // but BaseRepository assumes all values are T.
  // Better to use a separate settings box or stick to SharedPreferences for settings.
  // Since we are migrating to Hive, let's use a settings box.
  final Box settingsBox;

  AgentRepository(super.box, this.settingsBox);

  static Future<AgentRepository> init() async {
    final box = await Hive.openBox<String>(_boxName);
    final settingsBox = await Hive.openBox('agent_settings');
    return AgentRepository(box, settingsBox);
  }

  @override
  String get boxName => _boxName;

  @override
  AIAgent deserializeItem(String json) => AIAgent.fromJsonString(json);

  @override
  String serializeItem(AIAgent item) => item.toJsonString();

  @override
  String getItemId(AIAgent item) => item.id;

  @override
  List<AIAgent> getItems() {
    final items = super.getItems();
    if (items.isEmpty) {
      final defaultAgent = _createDefaultAgent();
      // We can't nicely call async saveItem here since this is sync.
      // But we can construct the list.
      // Ideally, the initialization of default agent should be done in 'init' or async method.
      // For now, we return empty or default, but persisting it synchronously is tricky with Hive if we want to stick to the pattern.
      // Actually Hive writes are async (put) but can be 'awaited'.
      // Let's just return the default agent and rely on the caller or 'getOrInitSelectedAgent' to save it.
      return [defaultAgent];
    }
    return items;
  }

  List<AIAgent> getAgents() => getItems();

  Future<void> addAgent(AIAgent agent) async {
    await saveItem(agent);
    // If no selection yet, select the newly added agent by default
    if (getSelectedAgentId() == null) {
      await setSelectedAgentId(agent.id);
    }
  }

  Future<void> updateAgent(AIAgent agent) async {
    await updateItem(agent);
  }

  Future<void> deleteAgent(String id) async {
    await deleteItem(id);

    // Maintain a valid selection after deletion
    final selectedId = getSelectedAgentId();
    if (selectedId == id) {
      // getItems might return default agent if empty, but that's a transient object.
      // Check box values directly or use getItems filtering.

      // If we just deleted the last one from box, getItems() returns [default] (unsaved).
      if (box.isEmpty) {
        await settingsBox.delete(_selectedKey);
      } else {
        // Select the first available
        final firstKey = box.keys.first;
        await setSelectedAgentId(firstKey.toString());
      }
    }
  }

  // --- Selection helpers ---

  String? getSelectedAgentId() => settingsBox.get(_selectedKey) as String?;

  Future<void> setSelectedAgentId(String id) async {
    await settingsBox.put(_selectedKey, id);
  }

  Future<AIAgent> getOrInitSelectedAgent() async {
    final selectedId = getSelectedAgentId();

    if (selectedId != null) {
      final agent = getItem(selectedId);
      if (agent != null) return agent;
    }

    // Fallback if selection is invalid or missing
    if (box.isNotEmpty) {
      final firstAgent = deserializeItem(box.values.first);
      await setSelectedAgentId(firstAgent.id);
      return firstAgent;
    } else {
      final defaultAgent = _createDefaultAgent();
      await saveItem(defaultAgent);
      await setSelectedAgentId(defaultAgent.id);
      return defaultAgent;
    }
  }

  AIAgent _createDefaultAgent() {
    return AIAgent(
      id: const Uuid().v4(),
      name: 'Basic Agent',
      systemPrompt: '',
    );
  }
}
