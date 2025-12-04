import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const TotoAIApp());

class TotoAIApp extends StatelessWidget {
  const TotoAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toto AI',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TotoHome(),
    );
  }
}

class TotoHome extends StatefulWidget {
  const TotoHome({super.key});

  @override
  State<TotoHome> createState() => _TotoHomeState();
}

class _TotoHomeState extends State<TotoHome> {
  final TextEditingController homeCtrl = TextEditingController();
  final TextEditingController awayCtrl = TextEditingController();

  bool _isLoading = false;
  String? _response;
  bool _isError = false;

  bool get isValid =>
      homeCtrl.text.trim().isNotEmpty &&
          awayCtrl.text.trim().isNotEmpty &&
          !_isLoading;

  @override
  void initState() {
    super.initState();
    homeCtrl.addListener(() => setState(() {}));
    awayCtrl.addListener(() => setState(() {}));
  }

  Future<void> _onGoPressed() async {
    final home = homeCtrl.text.trim();
    final away = awayCtrl.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      // IMPORTANT: use 10.0.2.2 instead of localhost when calling from Android emulator
      final uri = Uri.http(
        '10.0.2.2:8080',
        '/calculation/calculate-europe-odds',
        {
          'home-team': home,
          'away-team': away,
        },
      );

      final response = await http.get(uri);

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _response = response.body;
          _isError = false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _response = 'Server returned status ${response.statusCode}.\n\nBody:\n${response.body}';
          _isError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _response = 'Failed to contact server:\n$e';
        _isError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toto AI'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: homeCtrl,
              decoration: const InputDecoration(
                labelText: "Home Team",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "VS",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: awayCtrl,
              decoration: const InputDecoration(
                labelText: "Away Team",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            // GO Button
            ElevatedButton(
              onPressed: isValid ? _onGoPressed : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text("GO"),
            ),
            const SizedBox(height: 24),

            // Response Display Area
            if (_response != null)
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isError ? Colors.red.shade50 : Colors.green.shade50,
                    border: Border.all(
                      color: _isError ? Colors.red : Colors.green,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _response!,
                      style: TextStyle(
                        fontSize: 14,
                        color: _isError ? Colors.red.shade900 : Colors.black87,
                      ),
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
