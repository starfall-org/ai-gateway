import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:multigateway/core/mcp/models/mcp_info.dart';
import 'package:multigateway/core/mcp/models/mcp_tools.dart';

class McpProtocolAdapter extends TypeAdapter<McpProtocol> {
  @override
  final int typeId = 12;

  @override
  McpProtocol read(BinaryReader reader) {
    final index = reader.readByte();
    return McpProtocol.values[index];
  }

  @override
  void write(BinaryWriter writer, McpProtocol obj) {
    writer.writeByte(obj.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpProtocolAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class McpInfoAdapter extends TypeAdapter<McpInfo> {
  @override
  final int typeId = 13;

  @override
  McpInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    return McpInfo(
      fields[0] as String?,
      fields[1] as String,
      fields[2] as McpProtocol,
      fields[3] as String?,
      _decodeHeaders(fields[4] as String?),
    );
  }

  @override
  void write(BinaryWriter writer, McpInfo obj) {
    writer
      ..writeByte(5) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.protocol)
      ..writeByte(3)
      ..write(obj.url)
      ..writeByte(4)
      ..write(_encodeHeaders(obj.headers));
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  /// Encode headers map to JSON string
  String? _encodeHeaders(Map<String, String>? headers) {
    if (headers == null) return null;
    try {
      return json.encode(headers);
    } catch (e) {
      return null;
    }
  }

  /// Decode JSON string back to headers map
  Map<String, String>? _decodeHeaders(String? headersJson) {
    if (headersJson == null) return null;
    try {
      final decoded = json.decode(headersJson);
      if (decoded is Map<String, dynamic>) {
        return decoded.map((key, value) => MapEntry(key, value.toString()));
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

class StdioConfigAdapter extends TypeAdapter<StdioConfig> {
  @override
  final int typeId = 14;

  @override
  StdioConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    return StdioConfig(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, StdioConfig obj) {
    writer
      ..writeByte(3) // number of fields
      ..writeByte(0)
      ..write(obj.execBinaryPath)
      ..writeByte(1)
      ..write(obj.execArgs)
      ..writeByte(2)
      ..write(obj.execFilePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StdioConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class McpToolsListAdapter extends TypeAdapter<McpToolsList> {
  @override
  final int typeId = 15;

  @override
  McpToolsList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    return McpToolsList(
      fields[0] as String,
      fields[1] as String,
      _decodeTools(fields[2] as String),
    );
  }

  @override
  void write(BinaryWriter writer, McpToolsList obj) {
    writer
      ..writeByte(3) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(_encodeTools(obj.tools));
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpToolsListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  /// Encode tools list to JSON string
  String _encodeTools(List<Map<String, dynamic>> tools) {
    try {
      return json.encode(tools);
    } catch (e) {
      return '[]';
    }
  }

  /// Decode JSON string back to tools list
  List<Map<String, dynamic>> _decodeTools(String toolsJson) {
    try {
      final decoded = json.decode(toolsJson);
      if (decoded is List) {
        return decoded.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}