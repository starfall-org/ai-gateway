import 'package:mcp/models/mcp_server.dart';
import 'package:mcp/mcp.dart';
import 'package:metalore/core/storage/base.dart';

class MCPRepository extends HiveBaseStorage<MCPServer> {
  static const String _prefix = 'mcp';

  MCPRepository();

  static Future<MCPRepository> init() async {
    return MCPRepository();
  }

  @override
  String get prefix => _prefix;

  @override
  String getItemId(MCPServer item) => item.id;

  @override
  Map<String, dynamic> serializeToFields(MCPServer item) {
    return item.toJson();
  }

  @override
  MCPServer deserializeFromFields(String id, Map<String, dynamic> fields) {
    return MCPServer.fromJson(fields);
  }
}
