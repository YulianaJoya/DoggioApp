import 'dart:convert';
import 'package:doggio_app/DogBreedInfoPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

class DogBreedList extends StatefulWidget {
  const DogBreedList({super.key});

  @override
  _DogBreedListState createState() => _DogBreedListState();
}

class _DogBreedListState extends State<DogBreedList> {
  List<String> breedList = [];
  Map<String, int> breedIds = {};
  Map<int, List<String>> breedImages = {};

  @override
  void initState() {
    super.initState();
    fetchDogBreeds();
  }

  Future<void> fetchDogBreeds() async {
    final response = await http.get(Uri.parse('https://api.thedogapi.com/v1/breeds'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      breedList = data.map<String>((breed) => breed['name'] as String).toList();
      breedIds = { for (var breed in data) breed['name'] as String : breed['id'] as int };
      fetchDogBreedImages();
    } else {
      throw Exception('Failed to fetch dog breeds');
    }
  }

  Future<void> fetchDogBreedImages() async {
    for (final breed in breedList) {
      final breedId = breedIds[breed];
      if (breedId != null) {
        final response = await http.get(Uri.parse('https://api.thedogapi.com/v1/images/search?breed_id=$breedId'));

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          final List<String> images = data.map<String>((image) => image['url'] as String).toList();
          breedImages[breedId] = images;
        } else {
          throw Exception('Failed to fetch dog breed images');
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dog Breed Images'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: breedList.length,
        itemBuilder: (BuildContext context, int index) {
          final breed = breedList[index];
          final breedId = breedIds[breed];
          final images = breedId != null ? breedImages[breedId] ?? [] : [];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DogBreedInfoPage(
                    breedId: breedId!,
                    breedName: breed,
                  ),
                ),
              );
            },
            child: images.isNotEmpty
                ? CachedNetworkImage(
              imageUrl: images[0],
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            )
                : Container(),
          );
        },
      ),
    );
  }
}



