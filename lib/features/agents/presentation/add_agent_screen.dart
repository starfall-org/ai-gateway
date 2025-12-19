import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/storage/agent_repository.dart';
import '../../../core/storage/mcp_repository.dart';
import '../../../core/models/ai_agent.dart';
import '../../../core/models/mcp/mcp_server.dart';
import 'agent_detailed_screen.dart';

enum _PersistOverride { followGlobal, forceOn, forceOff }

class AddAgentScreen extends StatefulWidget {
  final AIAgent? agent;

  const AddAgentScreen({super.key, this.agent});

  @override
  State<AddAgentScreen> createState() => _AddAgentScreenState();
}

class _AddAgentScreenState extends State<AddAgentScreen> {
  final _nameController = TextEditingController();
  final _promptController = TextEditingController();

  bool _enableStream = true;
  bool _isTopPEnabled = false;
  double _topPValue = 1.0;
  bool _isTopKEnabled = false;
  double _topKValue = 40.0;
  bool _isTemperatureEnabled = false;
  double _temperatureValue = 0.7;
  int _contextWindowValue = 60000;
  int _conversationLengthValue = 10;
  int _maxTokensValue = 4000;
  List<MCPServer> _availableMCPServers = [];
  final List<String> _selectedMCPServerIds = [];

  // Persist selection override for this agent: null => follow global; true/false => override
  _PersistOverride _persistOverride = _PersistOverride.followGlobal;

  @override
  void initState() {
    super.initState();
    if (widget.agent != null) {
      final a = widget.agent!;
      _nameController.text = a.name;
      _promptController.text = a.systemPrompt;
      _enableStream = a.enableStream;
      if (a.topP != null) {
        _isTopPEnabled = true;
        _topPValue = a.topP!;
      }
      if (a.topK != null) {
        _isTopKEnabled = true;
        _topKValue = a.topK!;
      }
      if (a.temperature != null) {
        _isTemperatureEnabled = true;
        _temperatureValue = a.temperature!;
      }
      _contextWindowValue = a.contextWindow;
      _conversationLengthValue = a.conversationLength;
      _maxTokensValue = a.maxTokens;
      _selectedMCPServerIds.addAll(a.activeMCPServerIds);

      if (a.persistChatSelection == null) {
        _persistOverride = _PersistOverride.followGlobal;
      } else {
        _persistOverride = a.persistChatSelection!
            ? _PersistOverride.forceOn
            : _PersistOverride.forceOff;
      }
    }
    _loadMCPServers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _loadMCPServers() async {
    final mcpRepo = await MCPRepository.init();
    setState(() {
      _availableMCPServers = mcpRepo.getMCPServers();
    });
  }

  Future<void> _saveAgent() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('agents.name'.tr())));
      return;
    }

    final repository = await AgentRepository.init();
    final newAgent = AIAgent(
      id: widget.agent?.id ?? const Uuid().v4(),
      name: _nameController.text,
      systemPrompt: _promptController.text,
      enableStream: _enableStream,
      topP: _isTopPEnabled ? _topPValue : null,
      topK: _isTopKEnabled ? _topKValue : null,
      temperature: _isTemperatureEnabled ? _temperatureValue : null,
      contextWindow: _contextWindowValue,
      conversationLength: _conversationLengthValue,
      maxTokens: _maxTokensValue,
      activeMCPServerIds: _selectedMCPServerIds,
      persistChatSelection: _persistOverride == _PersistOverride.followGlobal
          ? null
          : (_persistOverride == _PersistOverride.forceOn),
    );

    if (widget.agent != null) {
      await repository.updateAgent(newAgent);
    } else {
      await repository.addAgent(newAgent);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.agent != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'agents.edit_agent'.tr() : 'agents.add_new_agent'.tr(),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'agents.agent_details'.tr(),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AgentDetailedScreen(agent: widget.agent!),
                  ),
                );
              },
            ),
          IconButton(icon: const Icon(Icons.check), onPressed: _saveAgent),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'agents.name'.tr(),
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // System Prompt
              TextField(
                controller: _promptController,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: 'agents.system_prompt'.tr(),
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 100),
                    child: Icon(Icons.description_outlined),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Parameters Section
              Text(
                'agents.parameters'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Text('agents.stream'.tr()),
                        subtitle: Text('agents.stream_desc'.tr()),
                        value: _enableStream,
                        onChanged: (value) =>
                            setState(() => _enableStream = value),
                      ),
                      const Divider(),

                      // Top P
                      SwitchListTile(
                        title: Text('agents.top_p'.tr()),
                        value: _isTopPEnabled,
                        onChanged: (value) =>
                            setState(() => _isTopPEnabled = value),
                      ),
                      if (_isTopPEnabled)
                        _buildSlider(
                          value: _topPValue,
                          min: 0,
                          max: 1,
                          divisions: 20,
                          label: _topPValue.toStringAsFixed(2),
                          onChanged: (v) => setState(() => _topPValue = v),
                        ),

                      const Divider(),
                      // Top K
                      SwitchListTile(
                        title: Text('agents.top_k'.tr()),
                        value: _isTopKEnabled,
                        onChanged: (value) =>
                            setState(() => _isTopKEnabled = value),
                      ),
                      if (_isTopKEnabled)
                        _buildSlider(
                          value: _topKValue,
                          min: 1,
                          max: 100,
                          divisions: 99,
                          label: _topKValue.round().toString(),
                          onChanged: (v) => setState(() => _topKValue = v),
                        ),

                      const Divider(),
                      // Temperature
                      SwitchListTile(
                        title: Text('agents.temperature'.tr()),
                        value: _isTemperatureEnabled,
                        onChanged: (value) =>
                            setState(() => _isTemperatureEnabled = value),
                      ),
                      if (_isTemperatureEnabled)
                        _buildSlider(
                          value: _temperatureValue,
                          min: 0,
                          max: 2,
                          divisions: 20,
                          label: _temperatureValue.toStringAsFixed(2),
                          onChanged: (v) =>
                              setState(() => _temperatureValue = v),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Context window etc.
              _buildNumberField(
                label: 'agents.context_window'.tr(),
                value: _contextWindowValue,
                onChanged: (v) => _contextWindowValue = v,
                icon: Icons.window_outlined,
              ),
              const SizedBox(height: 16),
              _buildNumberField(
                label: 'agents.conversation_length'.tr(),
                value: _conversationLengthValue,
                onChanged: (v) => _conversationLengthValue = v,
                icon: Icons.history_outlined,
              ),
              const SizedBox(height: 16),
              _buildNumberField(
                label: 'agents.max_tokens'.tr(),
                value: _maxTokensValue,
                onChanged: (v) => _maxTokensValue = v,
                icon: Icons.token_outlined,
              ),

              const SizedBox(height: 32),

              // Active MCP Servers
              if (_availableMCPServers.isNotEmpty) ...[
                Text(
                  'agents.mcp_servers'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: _availableMCPServers.map((server) {
                      return CheckboxListTile(
                        title: Text(server.name),
                        value: _selectedMCPServerIds.contains(server.id),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedMCPServerIds.add(server.id);
                            } else {
                              _selectedMCPServerIds.remove(server.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Persist chat selection override
              Text(
                'agents.persist_selection'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<_PersistOverride>(
                  segments: [
                    ButtonSegment(
                      value: _PersistOverride.followGlobal,
                      label: Text(
                        'agents.persist_disable'.tr(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    ButtonSegment(
                      value: _PersistOverride.forceOn,
                      label: Text(
                        'agents.persist_on'.tr(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    ButtonSegment(
                      value: _PersistOverride.forceOff,
                      label: Text(
                        'agents.persist_off'.tr(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                  selected: {_persistOverride},
                  onSelectionChanged: (Set<_PersistOverride> newSelection) {
                    setState(() => _persistOverride = newSelection.first);
                  },
                  showSelectedIcon: false,
                ),
              ),
              const SizedBox(height: 48),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _saveAgent,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'common.save'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlider({
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: label,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(
              label,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
    required IconData icon,
  }) {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
      ),
      controller: TextEditingController(text: value.toString()),
      onChanged: (text) {
        final val = int.tryParse(text);
        if (val != null) onChanged(val);
      },
    );
  }
}
