import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EpisodesPage extends StatefulWidget {
final String subCourseId;
  const EpisodesPage({super.key, required this.subCourseId});

  @override
  State<EpisodesPage> createState() => _EpisodesPageState();
}

class _EpisodesPageState extends State<EpisodesPage> {
  bool isLoading = true;
  String? error;
  List<Episode> episodes = [];

  @override
  void initState() {
    super.initState();
    fetchEpisodes();
  }

  Future<void> fetchEpisodes() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final url = 'https://classicdigitallibraries.com/public/api/frontend/subcourses/${widget.subCourseId}';
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List episodesJson = data['biodatas'] ?? [];
        episodes = episodesJson.map((e) => Episode.fromJson(e)).toList();
      } else {
        error = 'Failed to load episodes.';
      }
    } catch (e) {
      error = 'Error: $e';
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Episodes'),
        backgroundColor: const Color(0xff0247bc),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              : episodes.isEmpty
                  ? const Center(child: Text('No episodes found.'))
                  : ListView.separated(
                      itemCount: episodes.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final ep = episodes[index];
                        return ListTile(
                          leading: const Icon(Icons.menu_book, color: Color(0xff0247bc)),
                          title: Text(ep.episode),
                          subtitle: Text('By: ${ep.namaSiswa}'),
                          // onTap: () {}, // Extend for webview or detail
                        );
                      },
                    ),
    );
  }
}

class Episode {
  final int id;
  final String namaSiswa;
  final String episode;
  final String? folder;
  final String? audio;
  final String? position;
  final String? createdAt;
  final String? updatedAt;

  Episode({
    required this.id,
    required this.namaSiswa,
    required this.episode,
    this.folder,
    this.audio,
    this.position,
    this.createdAt,
    this.updatedAt,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      namaSiswa: json['namaSiswa'] ?? '',
      episode: json['episode'] ?? '',
      folder: json['folder'],
      audio: json['audio'],
      position: json['position']?.toString(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
} 