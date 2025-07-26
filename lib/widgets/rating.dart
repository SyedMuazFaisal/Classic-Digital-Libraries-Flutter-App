import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import '../models/book_model.dart';

class RatingReviews extends StatefulWidget {
  final String novelId;
  final List<Review>? reviews;

  const RatingReviews({
    super.key, 
    required this.novelId, 
    this.reviews,
  });

  @override
  State<RatingReviews> createState() => _RatingReviewsState();
}

class _RatingReviewsState extends State<RatingReviews> {
  List<Review> reviews = [];
  double userRating = 0.0;
  final TextEditingController commentController = TextEditingController();
  bool isLoading = false;
  bool showAllReviews = false;

  @override
  void initState() {
    super.initState();
    if (widget.reviews != null) {
      reviews = widget.reviews!;
    } else {
      fetchReviews();
    }
  }

  Future<void> fetchReviews() async {
    setState(() => isLoading = true);
    
    // Try the direct novels API first (which includes reviews)
    try {
      final novelsResponse = await http.get(
        Uri.parse('https://classicdigitallibraries.com/public/api/frontend/novels?page=1'),
        headers: {'Accept': 'application/json'},
      );
      
      if (novelsResponse.statusCode == 200) {
        final novelsJson = jsonDecode(novelsResponse.body);
        final courses = novelsJson['courses']?['data'] ?? [];
        
        // Find the current novel and extract its reviews
        for (var course in courses) {
          if (course['id'].toString() == widget.novelId) {
            final reviewsData = course['reviews'] ?? [];
            
            // Debug: Print first review to see available fields
            if (reviewsData.isNotEmpty) {
              print("📝 Sample review data: ${reviewsData.first}");
            }
            
            setState(() {
              reviews = reviewsData
                  .map<Review>((reviewJson) => Review.fromJson(reviewJson))
                  .toList();
            });
            return; // Found the novel and its reviews
          }
        }
      }
    } catch (e) {
      print("Error fetching from novels API: $e");
    }
    
    // Fallback to the reviews API
    try {
      final url = 'https://classicdigitallibraries.com/public/api/frontend/reviews/${widget.novelId}';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final reviewsData = json['reviews'] ?? [];
        setState(() {
          reviews = reviewsData
              .map<Review>((reviewJson) => Review.fromJson(reviewJson))
              .toList();
        });
      }
    } catch (e) {
      print("Error fetching reviews: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> submitReview() async {
    if (userRating == 0 || commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide both rating and comment'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final url = 'https://classicdigitallibraries.com/public/api/frontend/submitReview';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'novel_id': widget.novelId,
          'email': 'user@example.com',
          'rating': userRating,
          'comment': commentController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          commentController.clear();
          userRating = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh reviews after submission
        fetchReviews();
      }
    } catch (e) {
      print("Error submitting review: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error submitting review. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double get averageRating {
    if (reviews.isEmpty) return 0.0;
    final validRatings = reviews.where((r) => r.rating != null).map((r) => r.rating!);
    if (validRatings.isEmpty) return 0.0;
    return validRatings.reduce((a, b) => a + b) / validRatings.length;
  }

  Map<int, int> get ratingDistribution {
    final distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final review in reviews) {
      if (review.rating != null) {
        final rating = review.rating!.round();
        if (rating >= 1 && rating <= 5) {
          distribution[rating] = distribution[rating]! + 1;
        }
      }
    }
    return distribution;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final validReviews = reviews.where((review) => 
      review.review != null && review.review!.trim().isNotEmpty
    ).toList();

    final displayReviews = showAllReviews 
        ? validReviews 
        : validReviews.take(3).toList();

    final totalRatings = reviews.where((r) => r.rating != null).length;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating Summary Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xff0247bc),
                  const Color(0xff0247bc).withOpacity(0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                // Overall Rating Display
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Overall Rating",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RatingBarIndicator(
                        rating: averageRating,
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemSize: 20,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Based on $totalRatings reviews",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Rating Breakdown
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRatingBar("Excellent", 5, Colors.green),
                      _buildRatingBar("Good", 4, Colors.lightGreen),
                      _buildRatingBar("Average", 3, Colors.orange),
                      _buildRatingBar("Fair", 2, Colors.deepOrange),
                      _buildRatingBar("Poor", 1, Colors.red),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Reviews List
          if (validReviews.isEmpty)
            _buildEmptyState()
          else
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Reviews (${validReviews.length})",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0247bc),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  ...displayReviews.map((review) => _buildReviewCard(review)),
                  
                  if (validReviews.length > 3)
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            showAllReviews = !showAllReviews;
                          });
                        },
                        icon: Icon(
                          showAllReviews ? Icons.expand_less : Icons.expand_more,
                          color: const Color(0xff0247bc),
                        ),
                        label: Text(
                          showAllReviews 
                              ? "Show Less" 
                              : "View All ${validReviews.length} Reviews",
                          style: const TextStyle(
                            color: Color(0xff0247bc),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // Write Review Button
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _showWriteReviewDialog(),
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  "Write a Review",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0247bc),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(String label, int rating, Color color) {
    final count = ratingDistribution[rating] ?? 0;
    final total = reviews.where((r) => r.rating != null).length;
    final percentage = total > 0 ? count / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xff0247bc).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.rate_review_outlined,
              size: 40,
              color: Color(0xff0247bc),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "No reviews yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xff0247bc),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Be the first to share your thoughts!",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xff0247bc),
                      const Color(0xff0247bc).withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xff0247bc),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(review.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (review.rating != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xff0247bc),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        review.rating!.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (review.review != null && review.review!.trim().isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                review.review!,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${review.displayName} rated this ${review.rating ?? 0} stars",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showWriteReviewDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              const Text(
                "Write a Review",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0247bc),
                ),
              ),
              const SizedBox(height: 20),
              
              // Rating Input
              const Text(
                "Your Rating:",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: RatingBar.builder(
                  initialRating: userRating,
                  minRating: 1,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemSize: 40,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      userRating = rating;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              // Comment Input
              const Text(
                "Your Review:",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Share your thoughts about this book...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Color(0xff0247bc), width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 4,
                maxLength: 500,
              ),
              const SizedBox(height: 24),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    submitReview();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0247bc),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    "Submit Review",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return "${date.day}/${date.month}/${date.year}";
    } else if (difference.inDays > 0) {
      return "${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago";
    } else {
      return "Just now";
    }
  }
}
