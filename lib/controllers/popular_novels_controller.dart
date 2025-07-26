import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/book_model.dart';

class PopularNovelsController extends GetxController {
  var isLoading = false.obs;
  var popularBooks = <Book>[].obs;
  
  static const String popularNovelsUrl = 'https://classicdigitallibraries.com/public/api/frontend/popularNovels';

  @override
  void onInit() {
    super.onInit();
    fetchPopularNovels();
  }

  Future<void> fetchPopularNovels() async {
    try {
      isLoading.value = true;

      final response = await http.get(
        Uri.parse(popularNovelsUrl),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final popularNovelsData = jsonData['popular_novels'];
        
        if (popularNovelsData != null && popularNovelsData['data'] != null) {
          final List<dynamic> booksJson = popularNovelsData['data'];
          final List<Book> books = booksJson.map((json) => Book.fromJson(json)).toList();
          
          popularBooks.assignAll(books);
          print('✅ Loaded ${books.length} popular novels');
        }
      } else {
        throw Exception('Failed to load popular novels: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching popular novels: $e');
      Get.snackbar(
        "Error", 
        "Failed to load popular novels",
        colorText: Colors.white, 
        backgroundColor: Colors.red
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPopularNovels() async {
    await fetchPopularNovels();
  }
}