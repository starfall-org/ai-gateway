# Project Structure Refactoring Summary

## Overview
Refactored the MultiGateway project to move conversation/message models and storage to the core layer, and properly separate MCP, speech, and profile modules from the LLM feature.

## Changes Made

### 1. New Core Modules Created

#### `lib/core/chat/` - Conversation & Message Management
- **Models:**
  - `models/conversation.dart` - Conversation model (moved from `lib/features/home/domain/models/`)
  - `models/message.dart` - ChatMessage and MessageContent models (moved from `lib/features/home/domain/models/`)
- **Storage:**
  - `storage/conversation_repository.dart` - ConversationRepository (replaces ChatRepository)
- **Export:**
  - `chat.dart` - Public API for chat module

**Why:** Conversations and messages are now shared across features (home/ and settings/userdata), so they belong in core.

#### `lib/core/mcp/` - MCP Server Management
- **Storage:**
  - `storage/mcp_server_repository.dart` - McpServerStorage wrapping McpServer from mcp package
- **Export:**
  - `mcp.dart` - Public API for MCP module

**Why:** Separates MCP management from LLM feature; MCP is a cross-cutting concern.

#### `lib/core/profile/` - AI Profile Management
- **Storage:**
  - `storage/ai_profile_repository.dart` - ChatProfileStorage (replaces ChatProfileStorage from old location)
- **Export:**
  - `profile.dart` - Public API for profile module

**Why:** Profiles are independent of LLM feature and used across the app.

#### `lib/core/speech/` - Speech Service Management
- **Storage:**
  - `storage/speech_service_repository.dart` - SpeechServiceRepository (replaces TTSRepository)
- **Export:**
  - `speech.dart` - Public API for speech module

**Why:** Speech services are independent and should be accessible from any feature.

#### `lib/core/llm/` - LLM Provider Management
- **Export:**
  - `llm.dart` - Public API for LLM module

**Why:** Consolidates LLM provider models and storage exports.

#### `lib/core/` - Core Module Aggregator
- **Export:**
  - `core.dart` - Single import point for all core modules

**Why:** Simplifies imports across the app; use `import 'package:multigateway/core/core.dart'` instead of multiple imports.

### 2. Updated Imports

#### Home Feature (`lib/features/home/`)
- **Before:**
  ```dart
  import '../../../../core/profile/profile.dart';
  import '../../../../core/llm/data/provider_info_storage.dart';
  import '../../../../core/storage/mcpserver_store.dart';
  import '../../../../core/speech/speech.dart';
  ```
- **After:**
  ```dart
  import '../../../../core/core.dart';
  ```

#### LLM Feature Controllers
- **edit_profile_controller.dart** - Updated to use `ChatProfile` and `LlmChatConfig`
- **edit_mcpserver_controller.dart** - Updated to use `McpServerStorage`
- **edit_provider_controller.dart** - Updated to use `LlmProviderInfoStorage`

### 3. Repository Method Naming

Standardized repository method names across all modules:

| Module | Add | Update | Get | Delete |
|--------|-----|--------|-----|--------|
| Conversation | `saveConversation()` | `saveConversation()` | `getConversations()` | `deleteConversation()` |
| MCP | `addMcpServer()` | `updateMcpServer()` | `getMcpServers()` | `deleteMcpServer()` |
| Profile | `addProfile()` | `updateProfile()` | `getProfiles()` | `deleteProfile()` |
| Speech | `addService()` | `updateService()` | `getServices()` | `deleteService()` |

### 4. Model Class Names

Standardized model class names:

| Old Name | New Name | Location |
|----------|----------|----------|
| `ChatRepository` | `ConversationRepository` | `lib/core/chat/storage/` |
| `ChatProfile` | `ChatProfile` | `lib/core/profile/models/` |
| `AiConfig` | `LlmChatConfig` | `lib/core/profile/models/` |
| `TTSRepository` | `SpeechServiceRepository` | `lib/core/speech/storage/` |

### 5. File Structure

```
lib/core/
├── chat/
│   ├── models/
│   │   ├── conversation.dart
│   │   └── message.dart
│   ├── storage/
│   │   └── conversation_repository.dart
│   └── chat.dart
├── llm/
│   ├── models/
│   ├── storage/
│   └── llm.dart
├── mcp/
│   ├── models/
│   ├── storage/
│   │   └── mcp_server_repository.dart
│   └── mcp.dart
├── profile/
│   ├── models/
│   ├── storage/
│   │   └── ai_profile_repository.dart
│   └── profile.dart
├── speech/
│   ├── models/
│   ├── storage/
│   │   └── speech_service_repository.dart
│   └── speech.dart
├── storage/
│   └── base.dart
└── core.dart
```

## Benefits

1. **Shared Models** - Conversation/message models can now be used by both home/ and settings/userdata features
2. **Clear Separation** - MCP, speech, and profile are now clearly separated from LLM feature
3. **Simplified Imports** - Single `import 'package:multigateway/core/core.dart'` replaces multiple imports
4. **Better Organization** - Each module has clear responsibility and public API
5. **Scalability** - Easy to add new features that need access to conversations, profiles, or MCP servers

## Migration Guide for Features

### Using Conversation Models
```dart
import 'package:multigateway/core/core.dart';

// Create repository
final repo = await ConversationRepository.init();

// Use models
final conversation = Conversation(...);
await repo.saveConversation(conversation);
```

### Using AI Profiles
```dart
import 'package:multigateway/core/core.dart';

// Create repository
final repo = await ChatProfileStorage.init();

// Use models
final profile = ChatProfile(...);
await repo.addProfile(profile);
```

### Using MCP Servers
```dart
import 'package:multigateway/core/core.dart';

// Create repository
final repo = await McpServerStorage.init();

// Use models
final servers = repo.getMcpServers();
```

### Using Speech Services
```dart
import 'package:multigateway/core/core.dart';

// Create repository
final repo = await SpeechServiceRepository.init();

// Use models
final services = repo.getServices();
```

## Next Steps

1. Run code generation: `dart run build_runner build --delete-conflicting-outputs`
2. Update any remaining imports in features that reference old paths
3. Test all features to ensure functionality is preserved
4. Update documentation to reflect new structure
