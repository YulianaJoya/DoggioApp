import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DogFactPage extends StatefulWidget {
  const DogFactPage({Key? key}) : super(key: key);

  @override
  _DogFactPageState createState() => _DogFactPageState();
}

class _DogFactPageState extends State<DogFactPage> {
  List<String> _dogFacts = [];

  Future<void> _getDogFacts() async {
    final response = await http.get(Uri.parse('http://dog-api.kinduff.com/api/facts?number=5'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      setState(() {
        _dogFacts = List<String>.from(data['facts'].map((fact) => fact.toString()));
      });
    } else {
      setState(() {
        _dogFacts = ['Error loading dog facts'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dog Facts'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _getDogFacts,
              child: const Text('Get Dog Facts'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _dogFacts.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Text(
                      _dogFacts[index],
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}