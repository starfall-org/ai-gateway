import 'package:flutter/material.dart';
import '../../../core/models/ai_model.dart';
import '../presentation/add_provider_viewmodel.dart';

class AddModelDrawer extends StatefulWidget {
  final AddProviderViewModel viewModel;
  final Function(AIModel) onShowCapabilities;
  const AddModelDrawer({
    super.key,
    required this.viewModel,
    required this.onShowCapabilities,
  });

  @override
  State<AddModelDrawer> createState() => _AddModelDrawerState();
}

class _AddModelDrawerState extends State<AddModelDrawer> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
