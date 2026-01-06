import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';

class AddSpeechServiceScreen extends StatefulWidget {
  const AddSpeechServiceScreen({super.key});

  @override
  State<AddSpeechServiceScreen> createState() => _AddSpeechServiceScreenState();
}

class _AddSpeechServiceScreenState extends State<AddSpeechServiceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tl('Add Speech Service')),
      ),
      body: const Center(
        child: Text('Add Speech Service Form'),
      ),
    );
  }
}
