import 'package:flutter/material.dart';

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

  bool get isValid =>
      homeCtrl.text.trim().isNotEmpty && awayCtrl.text.trim().isNotEmpty;

  void _onGoPressed() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Prediction Created"),
        content: Text(
          "You entered: ${homeCtrl.text} vs ${awayCtrl.text}\n\n"
              "Soon: contacting your backend… 🚀",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    homeCtrl.addListener(() => setState(() {}));
    awayCtrl.addListener(() => setState(() {}));
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

            /// GO Button
            ElevatedButton(
              onPressed: isValid ? _onGoPressed : null, // enabled if valid
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("GO"),
            ),
          ],
        ),
      ),
    );
  }
}
