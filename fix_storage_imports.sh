#!/bin/bash

# Find all .dart files in lib/
FILES=$(find lib -name "*.dart")

for f in $FILES; do
  # Replace database_storage
  sed -i "s|package:database_storage/database_storage.dart|package:metalore/core/storage/base.dart|g" "$f"

  # Replace chat_history
  sed -i "s|package:chat_history/chat_history.dart|package:metalore/features/home/domain/domain.dart|g" "$f"
  sed -i "s|package:chat_history/chat_store.dart|package:metalore/features/home/domain/data/chat_store.dart|g" "$f"
  sed -i "s|package:chat_history/conversation.dart|package:metalore/features/home/domain/models/conversation.dart|g" "$f"
  sed -i "s|package:chat_history/message.dart|package:metalore/features/home/domain/models/message.dart|g" "$f"
  sed -i "s|package:chat_history/chat_service.dart|package:metalore/features/home/domain/services/chat_service.dart|g" "$f"

  # Replace repositories previously exported by packages (which are now removed from exports)
  # ProviderInfoStorage
  if grep -q "ProviderInfoStorage" "$f"; then
      # If it imports llm.dart but doesn't import provider_info_storage, add it.
      # This is tricky with sed. Better to just add the import if it's missing and the class is used.
      # But simpler: check if it imports llm.dart, and if so, assume it might need the storage if it uses the class.
      # Actually, let's just REPLACE usage.
      # If the file uses ProviderInfoStorage, it needs the new import.
      # Most files probably don't import provider_info_storage.dart explicitely if they used the barrel file.
      # So we need to ADD the import if ProviderInfoStorage is found.
      # Or easier: If we see `import 'package:llm/llm.dart';`, we append the specific storage import if the file contains "ProviderInfoStorage".
      :
  fi
  
  # Manual replacements for specific known paths if any leftover
  
  # MCPRepository
  # Was in mcp.dart. Now needs explicit import.
  
  # AIProfileRepository
  # Was in profiles.dart. Now needs explicit import.
  
  # TTSRepository
  # Was in speech.dart. Now needs explicit import.
done
