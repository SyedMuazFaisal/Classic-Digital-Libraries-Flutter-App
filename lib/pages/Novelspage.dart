import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../controllers/library_controller.dart';
import '../models/book_model.dart';
import 'bookdetailpage.dart';

class NovelsPage extends StatelessWidget {
  final LibraryController controller = Get.put(LibraryController());
  final ScrollController scrollController = ScrollController();

  NovelsPage({super.key}) {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        controller.loadMoreBooks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (controller.showFavoritesOnly.value) {
              // If showing favorites, go back to normal novels view
              controller.toggleView();
            } else {
              // If showing normal novels, go back to home
              Get.back();
            }
          },
        ),
        title: const Text("Classic Digital Libraries", style: TextStyle(fontSize: 20)),
        backgroundColor: const Color(0xff0247bc),
        foregroundColor: Colors.white,
        actions: [
          Obx(() => IconButton(
                icon: Icon(
                  controller.showFavoritesOnly.value
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: controller.toggleView,
              )),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshBooks,
        child: Obx(() {
          final books = controller.loadedBooks;

          return Column(
            children: [
              // 🔍 Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                child: TextField(
                  onChanged: controller.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search novels...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),

              // 📚 Grid View
              Expanded(
                child: books.isEmpty && controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : books.isEmpty && !controller.isLoading.value
                        ? const Center(
                            child: Text(
                              "No Favourite books found",
                              style: TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                          )
                        : GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: books.length + (controller.isLoading.value ? 1 : 0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.62,
                    ),
                    itemBuilder: (context, index) {
                      // Show loading indicator at the end
                      if (index >= books.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final book = books[index];
                      final isFav = controller.isFavorite(book.id);

                      return GestureDetector(
                        onTap: () async {
                          await Get.to(() => BookDetailPage(book: book));
                          if (controller.showFavoritesOnly.value) {
                            controller.refreshBooks();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🔹 70% Image
                              Expanded(
                                flex: 7,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(14)),
                                  child: Image.network(
                                    book.image,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              // 🔸 30% Info
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          RatingBarIndicator(
                                            rating: book.rating,
                                            itemBuilder: (context, _) =>
                                                const Icon(Icons.star, color: Colors.amber),
                                            itemSize: 14,
                                          ),
                                          const SizedBox(width: 2),
                                          Flexible(
                                            child: Text(
                                              "${book.rating.toStringAsFixed(1)} (${book.reviewCount})",
                                              style: const TextStyle(fontSize: 11),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () => controller.toggleFavorite(book.id),
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 4.0),
                                              child: Icon(
                                                isFav ? Icons.favorite : Icons.favorite_border,
                                                color: isFav ? Colors.red : Colors.grey,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
