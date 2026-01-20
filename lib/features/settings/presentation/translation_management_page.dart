import 'package:flutter/material.dart';
import 'package:multigateway/app/models/translation_cache_entry.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/settings/presentation/controllers/translation_management_controller.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';
import 'package:signals/signals_flutter.dart';

class TranslationManagementPage extends StatefulWidget {
  const TranslationManagementPage({super.key});

  @override
  State<TranslationManagementPage> createState() =>
      _TranslationManagementPageState();
}

class _TranslationManagementPageState extends State<TranslationManagementPage> {
  late final TranslationManagementController _controller;
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _controller = TranslationManagementController();
    _initFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tl('Translations'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              tl('Compare translations with English'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0.5,
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: FutureBuilder<void>(
          future: _initFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _ErrorState(onRetry: () {
                setState(() {
                  _initFuture = _controller.initialize();
                });
              });
            }
            return Watch((context) {
              final selectedLanguage = _controller.selectedLanguage.value;
              final translations = _controller.translations.value;

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LanguageSelector(
                      languages: _controller.languageOptions,
                      selectedLanguage: selectedLanguage,
                      onChanged: _controller.changeLanguage,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tl(
                        'Review cached translations side-by-side with English and edit them to keep the app wording accurate.',
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _InfoChip(
                          icon: Icons.flag_outlined,
                          label: tl('Editing'),
                          value: _controller.languageLabel(selectedLanguage),
                        ),
                        const SizedBox(width: 8),
                        _InfoChip(
                          icon: Icons.library_books_outlined,
                          label: tl('Entries'),
                          value: translations.length.toString(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: translations.isEmpty
                          ? _EmptyState(
                              languageLabel:
                                  _controller.languageLabel(selectedLanguage),
                            )
                          : ListView.separated(
                              itemCount: translations.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final entry = translations[index];
                                return _TranslationEntryCard(
                                  entry: entry,
                                  targetLabel:
                                      _controller.languageLabel(selectedLanguage),
                                  onEdit: () => _openEditSheet(entry),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            });
          },
        ),
      ),
    );
  }

  Future<void> _openEditSheet(TranslationCacheEntry entry) async {
    final textController = TextEditingController(text: entry.translatedText);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 12,
          right: 12,
          top: 12,
        ),
        child: _EditTranslationSheet(
          controller: textController,
          languageLabel:
              _controller.languageLabel(_controller.selectedLanguage.value),
        ),
      ),
    );
    textController.dispose();

    if (result != null && result.trim().isNotEmpty && mounted) {
      await _controller.updateTranslation(entry, result.trim());
      if (!mounted) return;
      context.showSuccessSnackBar(tl('Translation updated'));
    }
  }
}

class _LanguageSelector extends StatelessWidget {
  final List<LanguageOption> languages;
  final String selectedLanguage;
  final ValueChanged<String> onChanged;

  const _LanguageSelector({
    required this.languages,
    required this.selectedLanguage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.translate_outlined,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tl('Select language to edit'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tl(
                      'Defaults to your current language, unless it is English.',
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedLanguage,
                borderRadius: BorderRadius.circular(10),
                items: languages
                    .map(
                      (lang) => DropdownMenuItem(
                        value: lang.code,
                        child: Text(lang.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    onChanged(value);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TranslationEntryCard extends StatelessWidget {
  final TranslationCacheEntry entry;
  final String targetLabel;
  final VoidCallback onEdit;

  const _TranslationEntryCard({
    required this.entry,
    required this.targetLabel,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LanguageBlock(
              label: 'English',
              value: entry.originalText,
              labelColor: colorScheme.primary,
            ),
            const SizedBox(height: 10),
            _LanguageBlock(
              label: targetLabel,
              value: entry.translatedText,
              labelColor: colorScheme.tertiary,
              timestamp: entry.timestamp,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: Text(tl('Edit translation')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;
  final DateTime? timestamp;

  const _LanguageBlock({
    required this.label,
    required this.value,
    required this.labelColor,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: labelColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (timestamp != null)
              Text(
                _formatTimestamp(timestamp!),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
            ),
          ),
          child: Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime time) {
    final local = time.toLocal();
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${twoDigits(local.month)}-${twoDigits(local.day)} '
        '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
  }
}

class _EditTranslationSheet extends StatelessWidget {
  final TextEditingController controller;
  final String languageLabel;

  const _EditTranslationSheet({
    required this.controller,
    required this.languageLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.edit_note_outlined,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tl('Edit translation'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${tl('Language')}: $languageLabel',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: null,
              decoration: InputDecoration(
                labelText: tl('Translated text'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final newValue = controller.text.trim();
                  if (newValue.isEmpty) {
                    context.showErrorSnackBar(tl('Translation cannot be empty'));
                    return;
                  }
                  Navigator.pop(context, newValue);
                },
                icon: const Icon(Icons.save_outlined),
                label: Text(tl('Save')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String languageLabel;

  const _EmptyState({required this.languageLabel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.language_outlined,
              color: colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            tl('No translations cached for this language yet.'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              tl(
                'Switch to another language or generate translations to start managing $languageLabel.',
              ),
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error),
          const SizedBox(height: 8),
          Text(
            tl('Failed to load translations'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(tl('Retry')),
          ),
        ],
      ),
    );
  }
}
