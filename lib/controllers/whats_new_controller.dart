import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/episode_model.dart';

class WhatsNewController extends GetxController {
  var isLoading = false.obs;
  var episodes = <Episode>[].obs;
  var searchQuery = ''.obs;
  var filteredEpisodes = <Episode>[].obs;
  
  static const String newEpisodesUrl = 'https://classicdigitallibraries.com/public/api/frontend/newepisodes';

  @override
  void onInit() {
    super.onInit();
    fetchNewEpisodes();
    
    // Listen to search query changes
    ever(searchQuery, (_) => filterEpisodes());
    ever(episodes, (_) => filterEpisodes());
  }

  Future<void> fetchNewEpisodes() async {
    try {
      isLoading.value = true;

      final response = await http.get(
        Uri.parse(newEpisodesUrl),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final newEpisodesData = jsonData['new_episodes'];
        
        if (newEpisodesData != null && newEpisodesData is List) {
          final List<Episode> episodesList = newEpisodesData
              .map((json) => Episode.fromJson(json))
              .toList();
          
          episodes.assignAll(episodesList);
          print('✅ Loaded ${episodesList.length} new episodes');
        }
      } else {
        throw Exception('Failed to load new episodes: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching new episodes: $e');
      Get.snackbar(
        "Error", 
        "Failed to load new episodes",
        colorText: Colors.white, 
        backgroundColor: Colors.red
      );
    } finally {
      isLoading.value = false;
    }
  }

  void filterEpisodes() {
    if (searchQuery.value.isEmpty) {
      filteredEpisodes.assignAll(episodes);
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredEpisodes.assignAll(
        episodes.where((episode) =>
          episode.namaSiswa.toLowerCase().contains(query) ||
          episode.episode.toLowerCase().contains(query) ||
          episode.cleanTitle.toLowerCase().contains(query)
        ).toList()
      );
    }
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  Future<void> refreshEpisodes() async {
    await fetchNewEpisodes();
  }

  // Get episodes for slider (limit to first 10)
  List<Episode> get sliderEpisodes {
    return episodes.take(10).toList();
  }

  // Open episode in 3D flip book
  void openEpisode(Episode episode) {
    // For now, show a snackbar with the URL
    // Later this can be integrated with a webview or external browser
    Get.snackbar(
      "Opening Episode",
      "Episode: ${episode.cleanTitle}",
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    
    print("📖 Episode URL: ${episode.folder}");
    // TODO: Add webview integration or launch external browser
    // You can use url_launcher package: await launch(episode.folder);
  }
} 