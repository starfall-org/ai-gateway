import 'package:flutter/material.dart';

import 'package:metalore/core/profile/profile.dart';
import 'package:mcp/mcp.dart';
import 'package:metalore/core/storage/mcpserver_store.dart';

/// Controller responsible for AI profile and MCP server management
class ProfileController extends ChangeNotifier {
  final AIProfileRepository aiProfileRepository;
  final MCPRepository mcpRepository;

  AIProfile? selectedProfile;
  List<MCPServer> mcpServers = [];

  ProfileController({
    required this.aiProfileRepository,
    required this.mcpRepository,
  });

  Future<void> loadSelectedProfile() async {
    final profile = await aiProfileRepository.getOrInitSelectedProfile();
    selectedProfile = profile;
    notifyListeners();
  }

  Future<void> updateProfile(AIProfile profile) async {
    selectedProfile = profile;
    await aiProfileRepository.updateProfile(profile);
    notifyListeners();
  }

  Future<void> loadMCPServers() async {
    mcpServers = mcpRepository.getItems().whereType<MCPServer>().toList();
    notifyListeners();
  }

  Future<List<String>> snapshotEnabledToolNames(AIProfile profile) async {
    try {
      final mcpRepo = await MCPRepository.init();
      final servers = profile.activeMCPServerIds
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
}
