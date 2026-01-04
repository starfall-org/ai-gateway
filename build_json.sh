#!/bin/bash

dart run build_runner build --delete-conflicting-outputs &
cd llm && dart run build_runner build --delete-conflicting-outputs &
cd ../mcp && dart run build_runner build --delete-conflicting-outputs

clear