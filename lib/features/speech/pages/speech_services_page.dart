import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/speech/speech.dart';
import 'package:multigateway/features/speech/ui/views/edit_speech_service_screen.dart';
import 'package:multigateway/features/speech/ui/widgets/speech_service_tile.dart';

class SpeechServicesPage extends StatefulWidget {
  const SpeechServicesPage({super.key});

  @override
  State<SpeechServicesPage> createState() => _SpeechServicesPageState();
}

class _SpeechServicesPageState extends State<SpeechServicesPage> {
  List<SpeechService> _profiles = [];
  bool _isLoading = true;
  late TTSRepository _repository;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    _repository = await TTSRepository.init();
    setState(() {
      _profiles = _repository.getProfiles();
      _isLoading = false;
    });
  }

  Future<void> _deleteProfile(String id) async {
    await _repository.deleteProfile(id);
    _loadProfiles();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final SpeechService item = _profiles.removeAt(oldIndex);
      _profiles.insert(newIndex, item);
    });
    _repository.saveOrder(_profiles.map((e) => e.id).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tl('Speech Services')),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddSpeechServiceScreen(),
                ),
              );
              if (result == true) {
                _loadProfiles();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _profiles.isEmpty
                ? Center(child: Text(tl('No speech services configured')))
                : ReorderableListView.builder(
                    itemCount: _profiles.length,
                    onReorder: _onReorder,
                    itemBuilder: (context, index) => SpeechServiceTile(
                      key: ValueKey(_profiles[index].id),
                      service: _profiles[index],
                      onDelete: () => _deleteProfile(_profiles[index].id),
                    ),
                  ),
      ),
    );
  }
}
