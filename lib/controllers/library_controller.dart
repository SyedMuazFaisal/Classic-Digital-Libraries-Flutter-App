import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/book_model.dart';
import 'package:get_storage/get_storage.dart';

class LibraryController extends GetxController {
  var showFavoritesOnly = false.obs;
  var searchQuery = ''.obs;
  var isLoading = false.obs;
  var hasMorePages = true.obs;

  RxList<Book> loadedBooks = <Book>[].obs;
  RxList<Book> allBooksCache = <Book>[].obs; // Cache for filtering
  RxSet<String> favoriteBookIds = <String>{}.obs;
  final _storage = GetStorage();
  static const _favKey = 'favoriteBookIds';

  int currentPage = 1;
  int lastPage = 1;

  static const String baseUrl = 'https://classicdigitallibraries.com/public/api/frontend/novels';

  @override
  void onInit() {
    super.onInit();
    // Load favorites from storage
    final storedFavs = _storage.read<List>(_favKey);
    if (storedFavs != null) {
      favoriteBookIds.addAll(storedFavs.map((e) => e.toString()));
    }
    ever(favoriteBookIds, (_) => _saveFavorites());
    loadMoreBooks();
  }

  void _saveFavorites() {
    _storage.write(_favKey, favoriteBookIds.toList());
  }

  Future<void> loadMoreBooks() async {
    if (isLoading.value || !hasMorePages.value) return;

    try {
      isLoading.value = true;

      final response = await http.get(
        Uri.parse('$baseUrl?page=$currentPage'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final coursesData = jsonData['courses'];
        
        if (coursesData != null) {
          final List<dynamic> booksJson = coursesData['data'] ?? [];
          final List<Book> newBooks = booksJson.map((json) => Book.fromJson(json)).toList();
          
          // Update pagination info
          currentPage = coursesData['current_page'] ?? 1;
          lastPage = coursesData['last_page'] ?? 1;
          hasMorePages.value = currentPage < lastPage;
          
          // Add to cache for filtering
          allBooksCache.addAll(newBooks);
          
          // Apply current filters
          _applyFilters();
          
          // Move to next page for next load
          if (hasMorePages.value) {
            currentPage++;
          }
          
          print('✅ Loaded ${newBooks.length} books from page ${currentPage - 1}');
        }
      } else {
        print('❌ API Error: ${response.statusCode}');
        Get.snackbar(
          "Error", 
          "Failed to load books: ${response.statusCode}",
          colorText: Colors.white, 
          backgroundColor: Colors.red
        );
      }
    } catch (e) {
      print('❌ Network Error: $e');
      Get.snackbar(
        "Network Error", 
        "Please check your internet connection",
        colorText: Colors.white, 
        backgroundColor: Colors.red
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilters() {
    List<Book> filteredBooks = List.from(allBooksCache);

    // 1️⃣ Filter by favorites if needed
    if (showFavoritesOnly.value) {
      filteredBooks = filteredBooks.where((book) => favoriteBookIds.contains(book.id)).toList();
    }

    // 2️⃣ Filter by search query if needed
    if (searchQuery.value.isNotEmpty) {
      filteredBooks = filteredBooks.where((book) => 
        book.title.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }

    // Update loaded books (only if we're refreshing, otherwise append)
    if (currentPage == 2) { // First load after refresh
      loadedBooks.assignAll(filteredBooks);
    } else {
      // For search/filter changes, replace all
      loadedBooks.assignAll(filteredBooks);
    }
  }

  void toggleFavorite(String bookId) {
    if (favoriteBookIds.contains(bookId)) {
      favoriteBookIds.remove(bookId);
      Get.snackbar("Removed", "Book removed from favorites",
          colorText: Colors.white, backgroundColor: Colors.orange);
    } else {
      favoriteBookIds.add(bookId);
      Get.snackbar("Added", "Book added to favorites",
          colorText: Colors.white, backgroundColor: Colors.green);
    }
    
    // Re-apply filters if we're showing favorites only
    if (showFavoritesOnly.value) {
      _applyFilters();
    }
  }

  bool isFavorite(String bookId) => favoriteBookIds.contains(bookId);

  void toggleView() {
    showFavoritesOnly.value = !showFavoritesOnly.value;
    _applyFilters();
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
    _applyFilters();
  }

  Future<void> refreshBooks() async {
    currentPage = 1;
    hasMorePages.value = true;
    loadedBooks.clear();
    allBooksCache.clear();
    await loadMoreBooks();
  }
}