import 'package:flutter/material.dart';
import 'package:mcp/models/mcp_server.dart';

class McpServerTile extends StatelessWidget {
  final McpServer server;
  final VoidCallback onDelete;

  const McpServerTile({
    super.key,
    required this.server,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(server.name),
      subtitle: Text(server.description ?? ''),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
      onTap: () {
        // Navigate to edit page
      },
    );
  }
}
