import 'package:flutter/material.dart';
import 'package:llm/models/llm_model/basic_model.dart';
import 'package:llm/models/llm_model/github_model.dart';
import 'package:llm/models/llm_model/googleai_model.dart';
import 'package:llm/models/llm_model/ollama_model.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/llm/presentation/controllers/edit_provider_controller.dart';
import 'package:multigateway/shared/widgets/custom_text_field.dart';

/// Model origin/type enum
enum ModelOrigin {
  openaiAnthropic('OpenAI/Anthropic', Icons.cloud),
  ollama('Ollama', Icons.computer),
  googleAi('Google AI', Icons.public),
  github('GitHub', Icons.code);

  final String label;
  final IconData icon;
  const ModelOrigin(this.label, this.icon);
}

/// Edit sheet for all model types
/// Supports editing: BasicModel, OllamaModel, GoogleAiModel, GitHubModel
class EditModelSheet extends StatefulWidget {
  final AddProviderController controller;
  final Function(dynamic) onShowCapabilities;
  final dynamic modelToEdit;

  const EditModelSheet({
    super.key,
    required this.controller,
    required this.onShowCapabilities,
    this.modelToEdit,
  });

  @override
  State<EditModelSheet> createState() => _EditModelSheetState();
}

class _EditModelSheetState extends State<EditModelSheet> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for BasicModel
  late TextEditingController _basicIdController;
  late TextEditingController _basicDisplayNameController;
  late TextEditingController _basicOwnedByController;

  // Controllers for OllamaModel
  late TextEditingController _ollamaNameController;
  late TextEditingController _ollamaModelController;
  late TextEditingController _ollamaParameterSizeController;
  late TextEditingController _ollamaQuantizationController;

  // Controllers for GoogleAiModel
  late TextEditingController _googleNameController;
  late TextEditingController _googleDisplayNameController;
  late TextEditingController _googleInputTokenLimitController;
  late TextEditingController _googleOutputTokenLimitController;
  late TextEditingController _googleTemperatureController;
  late TextEditingController _googleMaxTemperatureController;
  late TextEditingController _googleTopPController;
  late TextEditingController _googleTopKController;
  bool _googleThinking = false;

  // Controllers for GitHubModel
  late TextEditingController _githubIdController;
  late TextEditingController _githubNameController;
  late TextEditingController _githubMaxInputTokensController;
  late TextEditingController _githubMaxOutputTokensController;

  ModelOrigin _selectedOrigin = ModelOrigin.openaiAnthropic;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _detectModelType();
  }

  void _initControllers() {
    _basicIdController = TextEditingController();
    _basicDisplayNameController = TextEditingController();
    _basicOwnedByController = TextEditingController();

    _ollamaNameController = TextEditingController();
    _ollamaModelController = TextEditingController();
    _ollamaParameterSizeController = TextEditingController();
    _ollamaQuantizationController = TextEditingController();

    _googleNameController = TextEditingController();
    _googleDisplayNameController = TextEditingController();
    _googleInputTokenLimitController = TextEditingController();
    _googleOutputTokenLimitController = TextEditingController();
    _googleTemperatureController = TextEditingController();
    _googleMaxTemperatureController = TextEditingController();
    _googleTopPController = TextEditingController();
    _googleTopKController = TextEditingController();

    _githubIdController = TextEditingController();
    _githubNameController = TextEditingController();
    _githubMaxInputTokensController = TextEditingController();
    _githubMaxOutputTokensController = TextEditingController();
  }

  void _detectModelType() {
    final model = widget.modelToEdit;
    if (model == null) return;

    if (model is BasicModel) {
      _selectedOrigin = ModelOrigin.openaiAnthropic;
      _basicIdController.text = model.id;
      _basicDisplayNameController.text = model.displayName;
      _basicOwnedByController.text = model.ownedBy;
    } else if (model is OllamaModel) {
      _selectedOrigin = ModelOrigin.ollama;
      _ollamaNameController.text = model.name;
      _ollamaModelController.text = model.model;
      _ollamaParameterSizeController.text = model.parameterSize;
      _ollamaQuantizationController.text = model.quantizationLevel;
    } else if (model is GoogleAiModel) {
      _selectedOrigin = ModelOrigin.googleAi;
      _googleNameController.text = model.name;
      _googleDisplayNameController.text = model.displayName;
      _googleInputTokenLimitController.text = model.inputTokenLimit.toString();
      _googleOutputTokenLimitController.text = model.outputTokenLimit
          .toString();
      _googleTemperatureController.text = model.temperature.toString();
      _googleMaxTemperatureController.text = model.maxTemperature.toString();
      _googleTopPController.text = model.topP.toString();
      _googleTopKController.text = model.topK.toString();
      _googleThinking = model.thinking;
    } else if (model is GitHubModel) {
      _selectedOrigin = ModelOrigin.github;
      _githubIdController.text = model.id;
      _githubNameController.text = model.name;
      _githubMaxInputTokensController.text = model.maxInputTokens.toString();
      _githubMaxOutputTokensController.text = model.maxOutputTokens.toString();
    }
  }

  @override
  void dispose() {
    _basicIdController.dispose();
    _basicDisplayNameController.dispose();
    _basicOwnedByController.dispose();

    _ollamaNameController.dispose();
    _ollamaModelController.dispose();
    _ollamaParameterSizeController.dispose();
    _ollamaQuantizationController.dispose();

    _googleNameController.dispose();
    _googleDisplayNameController.dispose();
    _googleInputTokenLimitController.dispose();
    _googleOutputTokenLimitController.dispose();
    _googleTemperatureController.dispose();
    _googleMaxTemperatureController.dispose();
    _googleTopPController.dispose();
    _googleTopKController.dispose();

    _githubIdController.dispose();
    _githubNameController.dispose();
    _githubMaxInputTokensController.dispose();
    _githubMaxOutputTokensController.dispose();

    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    dynamic newModel;
    switch (_selectedOrigin) {
      case ModelOrigin.openaiAnthropic:
        newModel = BasicModel(
          id: _basicIdController.text.trim(),
          displayName: _basicDisplayNameController.text.trim().isEmpty
              ? _basicIdController.text.trim()
              : _basicDisplayNameController.text.trim(),
          ownedBy: _basicOwnedByController.text.trim().isEmpty
              ? 'user'
              : _basicOwnedByController.text.trim(),
        );
        break;
      case ModelOrigin.ollama:
        newModel = OllamaModel(
          name: _ollamaNameController.text.trim(),
          model: _ollamaModelController.text.trim(),
          parameterSize: _ollamaParameterSizeController.text.trim(),
          quantizationLevel: _ollamaQuantizationController.text.trim(),
        );
        break;
      case ModelOrigin.googleAi:
        newModel = GoogleAiModel(
          name: _googleNameController.text.trim(),
          displayName: _googleDisplayNameController.text.trim().isEmpty
              ? _googleNameController.text.trim()
              : _googleDisplayNameController.text.trim(),
          inputTokenLimit:
              int.tryParse(_googleInputTokenLimitController.text.trim()) ?? 0,
          outputTokenLimit:
              int.tryParse(_googleOutputTokenLimitController.text.trim()) ?? 0,
          supportedGenerationMethods: ['generateContent'],
          thinking: _googleThinking,
          temperature:
              double.tryParse(_googleTemperatureController.text.trim()) ?? 1.0,
          maxTemperature:
              double.tryParse(_googleMaxTemperatureController.text.trim()) ??
              2.0,
          topP: double.tryParse(_googleTopPController.text.trim()) ?? 0.95,
          topK: int.tryParse(_googleTopKController.text.trim()) ?? 64,
        );
        break;
      case ModelOrigin.github:
        newModel = GitHubModel(
          id: _githubIdController.text.trim(),
          name: _githubNameController.text.trim(),
          supportedInputModalities: ['text'],
          supportedOutputModalities: ['text'],
          maxInputTokens:
              int.tryParse(_githubMaxInputTokensController.text.trim()) ?? 0,
          maxOutputTokens:
              int.tryParse(_githubMaxOutputTokensController.text.trim()) ?? 0,
        );
        break;
    }

    if (widget.modelToEdit != null) {
      widget.controller.updateModel(widget.modelToEdit!, newModel);
    } else {
      widget.controller.addModelDirectly(newModel);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Origin selector with save button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                children: [
                  Expanded(child: _buildOriginSelector()),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: Icon(
                      widget.modelToEdit != null ? Icons.save : Icons.add,
                      size: 18,
                    ),
                    label: Text(
                      widget.modelToEdit != null ? tl('Save') : tl('Add'),
                    ),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildFormFields(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOriginSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    final isEditing = widget.modelToEdit != null;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: ModelOrigin.values.map((origin) {
          final isSelected = _selectedOrigin == origin;
          return Expanded(
            child: GestureDetector(
              onTap: isEditing
                  ? null
                  : () => setState(() => _selectedOrigin = origin),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      origin.icon,
                      size: 18,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      origin.label.split('/').first,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFormFields() {
    switch (_selectedOrigin) {
      case ModelOrigin.openaiAnthropic:
        return _buildBasicModelFields();
      case ModelOrigin.ollama:
        return _buildOllamaModelFields();
      case ModelOrigin.googleAi:
        return _buildGoogleAiModelFields();
      case ModelOrigin.github:
        return _buildGitHubModelFields();
    }
  }

  Widget _buildBasicModelFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _basicIdController,
          label: tl('Model ID'),
          hint: tl('e.g., gpt-4-turbo, claude-3-opus'),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return tl('Model ID is required');
            }
            return null;
          },
          prefixIcon: Icons.tag,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _basicDisplayNameController,
          label: tl('Display Name'),
          hint: tl('e.g., GPT-4 Turbo, Claude 3 Opus'),
          prefixIcon: Icons.label,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _basicOwnedByController,
          label: tl('Owned By'),
          hint: tl('e.g., openai, anthropic'),
          prefixIcon: Icons.business,
        ),
      ],
    );
  }

  Widget _buildOllamaModelFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _ollamaNameController,
          label: tl('Name'),
          hint: tl('e.g., llama3.2'),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return tl('Name is required');
            }
            return null;
          },
          prefixIcon: Icons.label,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _ollamaModelController,
          label: tl('Model ID'),
          hint: tl('e.g., llama3.2:latest'),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return tl('Model ID is required');
            }
            return null;
          },
          prefixIcon: Icons.tag,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _ollamaParameterSizeController,
          label: tl('Parameter Size'),
          hint: tl('e.g., 3B, 7B, 70B'),
          prefixIcon: Icons.memory,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _ollamaQuantizationController,
          label: tl('Quantization'),
          hint: tl('e.g., Q4_0, Q5_1'),
          prefixIcon: Icons.compress,
        ),
      ],
    );
  }

  Widget _buildGoogleAiModelFields() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _googleNameController,
          label: tl('Model ID'),
          hint: tl('e.g., gemini-1.5-pro'),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return tl('Model ID is required');
            }
            return null;
          },
          prefixIcon: Icons.tag,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _googleDisplayNameController,
          label: tl('Display Name'),
          hint: tl('e.g., Gemini 1.5 Pro'),
          prefixIcon: Icons.label,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _googleInputTokenLimitController,
                label: tl('Input Tokens'),
                hint: 'e.g., 2000000',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.text_fields,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                controller: _googleOutputTokenLimitController,
                label: tl('Output Tokens'),
                hint: 'e.g., 8192',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.text_snippet,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _googleTemperatureController,
                label: tl('Temperature'),
                hint: '0-2',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                prefixIcon: Icons.thermostat,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                controller: _googleMaxTemperatureController,
                label: tl('Max Temp'),
                hint: '0-2',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                prefixIcon: Icons.thermostat,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _googleTopPController,
                label: tl('Top P'),
                hint: '0-1',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                prefixIcon: Icons.filter_list,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                controller: _googleTopKController,
                label: tl('Top K'),
                hint: '1-100',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.filter_list,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: SwitchListTile(
            title: Text(tl('Thinking Mode')),
            subtitle: Text(
              tl('Enable extended thinking for complex tasks'),
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            value: _googleThinking,
            onChanged: (value) => setState(() => _googleThinking = value),
            secondary: Icon(Icons.psychology, color: colorScheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildGitHubModelFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _githubIdController,
          label: tl('Model ID'),
          hint: tl('e.g., gpt-4o'),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return tl('Model ID is required');
            }
            return null;
          },
          prefixIcon: Icons.tag,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _githubNameController,
          label: tl('Name'),
          hint: tl('e.g., GPT-4o'),
          prefixIcon: Icons.label,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _githubMaxInputTokensController,
                label: tl('Max Input Tokens'),
                hint: 'e.g., 128000',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.text_fields,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                controller: _githubMaxOutputTokensController,
                label: tl('Max Output Tokens'),
                hint: 'e.g., 16384',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.text_snippet,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
