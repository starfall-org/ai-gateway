#!/bin/bash

# Find all .dart files in lib/
FILES=$(find lib -name "*.dart")

for f in $FILES; do
  # Profiles
  sed -i "s|import '.*core/profile/models/profile.dart';|import 'package:profiles/profiles.dart';|g" "$f"
  sed -i "s|import '.*core/profile/data/ai_profile_store.dart';|import 'package:profiles/profiles.dart';|g" "$f"
  
  # MCP
  sed -i "s|import '.*core/mcp/models/mcp_server.dart';|import 'package:mcp/mcp.dart';|g" "$f"
  sed -i "s|import '.*core/mcp/data/mcpserver_store.dart';|import 'package:mcp/mcp.dart';|g" "$f"
  
  # LLM
  sed -i "s|import '.*core/llm/models/llm_provider/provider_info.dart';|import 'package:llm/llm.dart';|g" "$f"
  sed -i "s|import '.*core/llm/data/provider_info_storage.dart';|import 'package:llm/llm.dart';|g" "$f"
  
  # Speech
  sed -i "s|import '.*core/speechservice/speechservice.dart';|import 'package:speech/speech.dart';|g" "$f"
  sed -i "s|import '.*core/speechservice/data/speechservice_store.dart';|import 'package:speech/speech.dart';|g" "$f"
  
  # Chat History (from domain)
  sed -i "s|import '.*domain/models/conversation.dart';|import 'package:chat_history/chat_history.dart';|g" "$f"
  sed -i "s|import '.*domain/models/message.dart';|import 'package:chat_history/chat_history.dart';|g" "$f"
  sed -i "s|import '.*domain/data/chat_store.dart';|import 'package:chat_history/chat_history.dart';|g" "$f"
  sed -i "s|import '.*domain/services/chat_service.dart';|import 'package:chat_history/chat_history.dart';|g" "$f"
  sed -i "s|import '.*domain/services/tts_service.dart';|import 'package:speech/speech.dart';|g" "$f"
  sed -i "s|import '.*domain/utils/chat_logic_utils.dart';|import 'package:chat_history/chat_history.dart';|g" "$f"

  # Generic core replacements
  sed -i "s|import '.*core/storage/base.dart';|import 'package:database_storage/database_storage.dart';|g" "$f"
done
