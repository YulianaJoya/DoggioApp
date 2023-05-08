import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DogBreedInfoPage extends StatelessWidget {
  final int breedId;
  final String breedName;

  const DogBreedInfoPage({required this.breedId, required this.breedName});

  Future<Map<String, dynamic>> fetchDogBreedDetails() async {
    final response = await http.get(Uri.parse('https://api.thedogapi.com/v1/breeds/$breedId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch dog breed details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dog Breed Information: $breedName'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchDogBreedDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Failed to fetch dog breed details'),
            );
          } else {
            final breedDetails = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  breedName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (breedDetails.containsKey('description'))
                  Text(
                    'Description: ${breedDetails['description']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                const SizedBox(height: 16),
                if (breedDetails.containsKey('temperament'))
                  Text(
                    'Temperament: ${breedDetails['temperament']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                const SizedBox(height: 16),
                // Add more details as needed
              ],
            );
          }
        },
      ),
    );
  }
}
