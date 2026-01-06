import 'package:multigateway/features/home/domain/domain.dart';
import 'package:llm/llm.dart';
import 'package:mcp/mcp.dart';
import 'package:multigateway/core/profile/profile.dart';
import 'package:multigateway/core/speech/speech.dart';

import 'package:multigateway/core/llm/data/provider_info_storage.dart';
import 'package:multigateway/core/storage/mcpserver_store.dart';

import 'package:multigateway/app/storage/appearance.dart';
import 'package:multigateway/app/storage/preferences.dart';
import 'package:multigateway/app/storage/default_options.dart';

/// Centralized service locator for application repositories and services.
/// Handles initialization and dependency management without external libraries.
class AppServices {
  // Singleton instance
  static final AppServices _instance = AppServices._internal();
  static AppServices get instance => _instance;

  AppServices._internal();

  // Repositories
  late final AppearanceStorage appearanceSp;
  late final PreferencesStorage preferencesSp;
  late final ChatRepository chatRepository;
  late final ChatProfileStorage aiProfileRepository;
  late final LlmProviderInfoStorage pInfStorage;
  late final DefaultOptionsStorage defaultOptionsRepository;
  late final McpServerStorage McpServerStorage;
  late final TTSRepository ttsRepository;
  late final TTSService ttsService;

  /// Initializes all repositories. Should be called before runApp.
  static Future<void> init() async {
    // Initialize repositories sequentially or in parallel as needed
    // Some might depend on Hive being initialized first (handled in main)

    // Core settings first
    _instance.appearanceSp = await AppearanceStorage.init();
    _instance.preferencesSp = await PreferencesStorage.init();

    // Feature repositories
    _instance.pInfStorage = await LlmProviderInfoStorage.init();
    _instance.defaultOptionsRepository = await DefaultOptionsStorage.init();
    _instance.chatRepository = await ChatRepository.init();
    _instance.aiProfileRepository = await ChatProfileStorage.init();
    _instance.McpServerStorage = await McpServerStorage.init();
    _instance.ttsRepository = await TTSRepository.init();

    // Services
    _instance.ttsService = TTSService();
  }
}
