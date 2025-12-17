import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Jokes App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
      ),
      home: const JokeScreen(),
    );
  }
}

class JokeScreen extends StatefulWidget {
  const JokeScreen({super.key});

  @override
  State<JokeScreen> createState() => _JokeScreenState();
}

class _JokeScreenState extends State<JokeScreen> {
  String? _setup;
  String? _punchline;
  String? _type;
  bool _isLoading = false;

  // Type selection
  String? _selectedType;
  final List<String> _types = ['general', 'programming', 'knock-knock'];

  Future<void> fetchJoke() async {
    setState(() => _isLoading = true);

    try {
      // Choose endpoint based on selected type
      final url = _selectedType != null
          ? 'https://official-joke-api.appspot.com/jokes/${_selectedType!}/random'
          : 'https://official-joke-api.appspot.com/random_joke';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // If type-specific endpoint, data is a list
        final joke = _selectedType != null ? data[0] : data;

        setState(() {
          _setup = joke['setup'];
          _punchline = joke['punchline'];
          _type = joke['type'];
        });
      } else {
        setState(() {
          _setup = "Oops! Couldn't fetch a joke.";
          _punchline = null;
          _type = null;
        });
      }
    } catch (e) {
      setState(() {
        _setup = "Network error!";
        _punchline = null;
        _type = null;
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    fetchJoke(); // fetch a random joke on start
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('😂 Random Jokes')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Dropdown for type selection
              DropdownButton<String>(
                value: _selectedType,
                hint: const Text("Select joke type"),
                items: _types.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                  fetchJoke();
                },
              ),

              const SizedBox(height: 30),

              // Joke content
              _isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        if (_type != null)
                          Text(
                            "Category: $_type",
                            style: const TextStyle(
                                fontSize: 18, fontStyle: FontStyle.italic),
                          ),
                        if (_setup != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            _setup!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                        if (_punchline != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            _punchline!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: fetchJoke,
                          child: const Text('Get Another Joke'),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
