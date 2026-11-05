import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Replace with your n8n production webhook URL (workflow must be activated).
const String kWebhookUrl = 'https://uatn8n.dts.ind.in/webhook/flutter-test';

// Only needed if you enabled Header Auth on the Webhook node.
const String? kApiKey = null; // e.g. 'your-secret'

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'n8n Webhook Test',
      theme: ThemeData(colorSchemeSeed: Colors.deepOrange, useMaterial3: true),
      home: const WebhookTestPage(),
    );
  }
}

class N8nService {
  static Future<Map<String, dynamic>> callWebhook(
      Map<String, dynamic> payload) async {
    final response = await http
        .post(
          Uri.parse(kWebhookUrl),
          headers: {
            'Content-Type': 'application/json',
            if (kApiKey != null) 'X-API-Key': kApiKey!,
          },
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('HTTP ${response.statusCode}: ${response.body}');
  }
}

class WebhookTestPage extends StatefulWidget {
  const WebhookTestPage({super.key});

  @override
  State<WebhookTestPage> createState() => _WebhookTestPageState();
}

class _WebhookTestPageState extends State<WebhookTestPage> {
  final _nameController = TextEditingController(text: 'Rahul');
  bool _loading = false;
  String _result = 'Tap the button to call the webhook.';

  Future<void> _send() async {
    setState(() {
      _loading = true;
      _result = 'Calling...';
    });

    try {
      final data = await N8nService.callWebhook({
        'name': _nameController.text.trim(),
        'action': 'signup',
      });
      setState(() => _result =
          const JsonEncoder.withIndent('  ').convert(data));
    } catch (e) {
      setState(() => _result = 'Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('n8n Webhook Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _loading ? null : _send,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Call webhook'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _result,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

