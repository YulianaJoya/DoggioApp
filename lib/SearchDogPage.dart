import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchDogPage extends StatefulWidget {
  const SearchDogPage({super.key});

  @override
  _SearchDogPageState createState() => _SearchDogPageState();
}

class _SearchDogPageState extends State<SearchDogPage> {
  final TextEditingController _controller = TextEditingController();
  String _breed = '';
  String _imageUrl = '';
  String _traits = '';
  String _height = '';
  String _weight = '';
  String _lifeSpan = '';

  void _search() async {
    final response = await http.get(
      Uri.parse('https://api.thedogapi.com/v1/breeds/search?q=$_breed'),
      headers: {
        'x-api-key': 'live_lsJ7cYgIlemB2LjP9cQNgja6IzbKiXKUdaUZjNjd67dKzBebmbeUA3RWBId5RER2',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data != null && data.isNotEmpty) {
        final breedId = data[0]['id'];

        final imageResponse = await http.get(
          Uri.parse('https://api.thedogapi.com/v1/images/search?breed_ids=$breedId&include_breeds=true'),
          headers: {
            'x-api-key': 'live_lsJ7cYgIlemB2LjP9cQNgja6IzbKiXKUdaUZjNjd67dKzBebmbeUA3RWBId5RER2',
          },
        );

        if (imageResponse.statusCode == 200) {
          final imageData = jsonDecode(imageResponse.body);

          if (imageData != null && imageData.isNotEmpty && imageData[0]['url'] != null) {
            _imageUrl = imageData[0]['url'];
          } else {
            _imageUrl = '';
          }
        } else {
          _imageUrl = '';
          _traits = '';
          _height = '';
          _weight = '';
          _lifeSpan = '';
          return;
        }

        if (data != null && data.isNotEmpty && data[0]['temperament'] != null) {
          _traits = data[0]['temperament'];
        } else {
          _traits = '';
        }

        if (data != null && data.isNotEmpty && data[0]['height'] != null) {
          _height = data[0]['height']['metric'];
        } else {
          _height = '';
        }

        if (data != null && data.isNotEmpty && data[0]['weight'] != null) {
          _weight = data[0]['weight']['metric'];
        } else {
          _weight = '';
        }

        if (data != null && data.isNotEmpty && data[0]['life_span'] != null) {
          _lifeSpan = data[0]['life_span'];
        } else {
          _lifeSpan = '';
        }
      } else {
        _imageUrl = '';
        _traits = '';
        _height = '';
        _weight = '';
        _lifeSpan = '';
      }
    } else {
      _imageUrl = '';
      _traits = '';
      _height = '';
      _weight = '';
      _lifeSpan = '';
    }
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doggio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Enter a dog breed',
                ),
                onChanged: (value) {
                  _breed = value;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _search,
                child: const Text('Search'),
              ),
              const SizedBox(height: 16),
              _imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: _imageUrl,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              )
                  : const SizedBox.shrink(),
              const SizedBox(height: 16),
              Text('Traits: $_traits'),
              const SizedBox(height: 16),
              _height.isNotEmpty
                  ? Text('Height: $_height')
                  : const SizedBox.shrink(),
              _weight.isNotEmpty
                  ? Text('Weight: $_weight')
                  : const SizedBox.shrink(),
              _lifeSpan.isNotEmpty
                  ? Text('Life Span: $_lifeSpan')
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

}