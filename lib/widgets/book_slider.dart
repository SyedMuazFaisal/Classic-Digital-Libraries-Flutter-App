import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../pages/home_book_detail_page.dart';

class BookSlider extends StatefulWidget {
  const BookSlider({super.key});

  @override
  State<BookSlider> createState() => _BookSliderState();
}

class _BookSliderState extends State<BookSlider> {
  final ScrollController _scrollController = ScrollController();
  late Timer _timer;
  List<dynamic> books = [];
  double scrollPosition = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBooksFromApi();

    // Auto-scroll
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_scrollController.hasClients && books.isNotEmpty) {
        scrollPosition += 180;
        if (scrollPosition > _scrollController.position.maxScrollExtent) {
          scrollPosition = 0;
        }
        _scrollController.animateTo(
          scrollPosition,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> fetchBooksFromApi() async {
    const url = 'https://classicdigitallibraries.com/public/api/frontend/newNovels';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['new_novels'] != null && decoded['new_novels'] is List) {
          setState(() {
            books = decoded['new_novels'];
            isLoading = false;
          });
        } else {
          print("⚠️ 'new_novels' key missing or not a list");
          setState(() => isLoading = false);
        }
      } else {
        throw Exception('Failed to load books');
      }
    } catch (e) {
      print("❌ Error fetching books: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (context, index) {
          final book = books[index];
          final title = book['name'] ?? 'Untitled';
          final rawImage = (book['image'] ?? '').toString().trim();
          final image = 'https://classicdigitallibraries.com/public/courses/$rawImage';

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeBookDetailPage(
                    title: title,
                    imageUrl: image,
                    rating: 4.0 + (index % 5) * 0.2, // Generate different ratings
                    description: "Experience this amazing novel with rich storytelling and compelling characters. A perfect addition to your reading collection!",
                  ),
                ),
              );
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 220 * 0.7,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        image,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print("⚠️ Failed to load image: $image");
                          return const Icon(Icons.broken_image, color: Colors.white);
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
