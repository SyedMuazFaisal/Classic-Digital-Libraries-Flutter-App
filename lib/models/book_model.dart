class SubCourse {
  final String id;
  final String courseId;
  final String? name;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubCourse({
    required this.id,
    required this.courseId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,

  });

  factory SubCourse.fromJson(Map<String, dynamic> json) {
    print('🔍 Parsing subcourse: ${json['name']} (ID: ${json['id']})');
    return SubCourse(
      id: json['id'].toString(),
      courseId: json['course_id'].toString(),
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

}
class Review {
  final String id;
  final String courseId;
  final String userId;
  final String? review;
  final double? rating;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? userName;
  final String? userEmail;

  Review({
    required this.id,
    required this.courseId,
    required this.userId,
    this.review,
    this.rating,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.userEmail,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'].toString(),
      courseId: json['course_id'].toString(),
      userId: json['user_id'].toString(),
      review: json['review'],
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      userName: json['user_name'] ?? json['name'] ?? json['username'],
      userEmail: json['user_email'] ?? json['email'],
    );
  }

  // Generate a display name for the user
  String get displayName {
    if (userName != null && userName!.trim().isNotEmpty) {
      return userName!;
    }
    
    if (userEmail != null && userEmail!.trim().isNotEmpty) {
      // Extract name from email (e.g., "john.doe@example.com" -> "John Doe")
      final emailPart = userEmail!.split('@').first;
      final nameParts = emailPart.split(RegExp(r'[._-]'));
      return nameParts
          .map((part) => part.isNotEmpty 
              ? part[0].toUpperCase() + part.substring(1).toLowerCase() 
              : part)
          .join(' ');
    }
    
    // Fallback to generating a user-friendly name from user ID
    return _generateFriendlyName(userId);
  }

  // Generate a friendly name from user ID
  static String _generateFriendlyName(String userId) {
    final names = [
      'Ahmed Ali', 'Fatima Khan', 'Hassan Sheikh', 'Ayesha Malik', 'Ali Raza',
      'Sadia Ahmed', 'Usman Shah', 'Nimra Qureshi', 'Bilal Ahmad', 'Zainab Ali',
      'Omar Farooq', 'Maryam Hussain', 'Adnan Khan', 'Faiza Sheikh', 'Tariq Mahmood',
      'Samina Bibi', 'Kashif Iqbal', 'Rubina Khatoon', 'Imran Malik', 'Nadia Parveen'
    ];
    
    // Use user ID to generate a consistent name
    final userIdNum = int.tryParse(userId) ?? 0;
    return names[userIdNum % names.length];
  }
}

class Book {
  final String id;
  final String subCourseId;
  final String title;
  final String image;
  final double rating;
  final int reviewCount;
  final List<Review> reviews;
  final List<SubCourse> subcourses;
  final DateTime createdAt;

  Book({
    required this.id,
    required this.subCourseId,
    required this.title,
    required this.image,
    required this.rating,
    this.reviewCount = 0,
    this.reviews = const [],
    this.subcourses = const [],
    required this.createdAt,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    // Debug logging
    print('🔍 Parsing book: ${json['name']}');
    print('🔍 Raw subcourses: ${json['subcourses']}');
    
    List<Review> reviewsList = [];
    if (json['reviews'] != null) {
      reviewsList = (json['reviews'] as List)
          .map((reviewJson) => Review.fromJson(reviewJson))
          .toList();
    }

    List<SubCourse> subcoursesList = [];
    if (json['subcourses'] != null) {
      print('🔍 Found subcourses, parsing...');
      subcoursesList = (json['subcourses'] as List)
          .map((subcourseJson) => SubCourse.fromJson(subcourseJson))
          .toList();
      print('🔍 Parsed ${subcoursesList.length} subcourses');
    } else {
      print('🔍 No subcourses found in JSON');
    }

    return Book(
      id: json['id'].toString(),
      subCourseId: json['sub_course_id']?.toString() ?? json['id'].toString(), // Use book ID as fallback
      title: json['name'] ?? 'Untitled',
      image: json['image'] != null 
          ? 'https://classicdigitallibraries.com/public/courses/${json['image']}'
          : 'https://via.placeholder.com/200x300?text=No+Image',
      rating: _parseRating(json['adjusted_avg_rating']),
      reviewCount: _parseReviewCount(json['review_count']),
      reviews: reviewsList,
      subcourses: subcoursesList,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  static double _parseRating(dynamic rating) {
    if (rating == null) return 0.0;
    if (rating is num) return rating.toDouble();
    if (rating is String) {
      return double.tryParse(rating) ?? 0.0;
    }
    return 0.0;
  }

  static int _parseReviewCount(dynamic count) {
    if (count == null) return 0;
    if (count is num) return count.toInt();
    if (count is String) {
      return int.tryParse(count) ?? 0;
    }
    return 0;
  }
}