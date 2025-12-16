import 'package:flutter/material.dart';
import 'core/routes.dart';
import 'features/agents/presentation/agent_list_screen.dart';
import 'features/chat/presentation/chat_screen.dart';
import 'features/providers/presentation/providers_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/settings/presentation/appearance_screen.dart';
import 'features/tts/views/tts_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.chat:
      return MaterialPageRoute(builder: (_) => const ChatScreen());
    case AppRoutes.agents:
      return MaterialPageRoute(builder: (_) => const AgentListScreen());
    case AppRoutes.settings:
      return MaterialPageRoute(builder: (_) => const SettingsScreen());
    case AppRoutes.providers:
      return MaterialPageRoute(builder: (_) => const ProvidersScreen());
    case AppRoutes.appearance:
      return MaterialPageRoute(builder: (_) => const AppearanceScreen());
    case AppRoutes.tts:
      return MaterialPageRoute(builder: (_) => const TTSScreen());
    default:
      return MaterialPageRoute(builder: (_) => const ChatScreen());
  }
}
