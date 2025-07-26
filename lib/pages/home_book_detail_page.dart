import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../widgets/rating.dart';

class HomeBookDetailPage extends StatefulWidget {
  final String title;
  final String imageUrl;
  final double rating;
  final String? description;
  final String? bookId;

  const HomeBookDetailPage({
    super.key,
    required this.title,
    required this.imageUrl,
    this.rating = 4.0,
    this.description,
    this.bookId,
  });

  @override
  State<HomeBookDetailPage> createState() => _HomeBookDetailPageState();
}

class _HomeBookDetailPageState extends State<HomeBookDetailPage> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 🔵 Sliver AppBar with Book Image and Background
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xff0247bc),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  color: Color(0xff0247bc),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.network(
                        widget.imageUrl,
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 100, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                iconSize: 28,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    key: ValueKey(isFavorite),
                    color: isFavorite ? Colors.red : Colors.white,
                    size: 28,
                  ),
                ),
                onPressed: () {
                  print('Favorite button pressed! Current state: $isFavorite'); // Debug print
                  setState(() {
                    isFavorite = !isFavorite;
                    print('New state: $isFavorite'); // Debug print
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(isFavorite ? 'Added to favorites!' : 'Removed from favorites!'),
                        ],
                      ),
                      backgroundColor: isFavorite ? Colors.green : Colors.orange,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),

          // 📘 Book Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 📕 Title
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ⭐ Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RatingBarIndicator(
                        rating: widget.rating,
                        itemBuilder: (context, _) =>
                            const Icon(Icons.star, color: Colors.amber),
                        itemSize: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      const Text("(120 reviews)", style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 📖 Read Now Button
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement Read Now logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening book for reading...')),
                      );
                    },
                    icon: const Icon(Icons.menu_book, color: Colors.white, size: 32),
                    label: const Text(
                      "Read Now",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff0247bc),
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 📄 Description (if available)
                  if (widget.description != null && widget.description!.isNotEmpty) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Description",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.description!,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 📊 Book Stats
                  _buildBookStats(),

                  const SizedBox(height: 24),

                  // 💬 Reviews Section
                  if (widget.bookId != null)
                    RatingReviews(novelId: widget.bookId!)
                  else
                    _buildReviewsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Pages", "256"),
          _buildStatItem("Language", "Urdu"),
          _buildStatItem("Genre", "Fiction"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xff0247bc),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    final reviews = [
      {
        "name": "Ahmad Ali",
        "rating": 5.0,
        "comment": "Excellent book! Really enjoyed reading it.",
        "date": "2 days ago"
      },
      {
        "name": "Fatima Khan",
        "rating": 4.0,
        "comment": "Great story with amazing characters.",
        "date": "1 week ago"
      },
      {
        "name": "Hassan Sheikh",
        "rating": 4.5,
        "comment": "Highly recommended for fiction lovers.",
        "date": "2 weeks ago"
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Reviews",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...reviews.map((review) => _buildReviewCard(review)),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                review['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              RatingBarIndicator(
                rating: review['rating'].toDouble(),
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: Colors.amber),
                itemSize: 14,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            review['comment'],
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            review['date'],
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
} 