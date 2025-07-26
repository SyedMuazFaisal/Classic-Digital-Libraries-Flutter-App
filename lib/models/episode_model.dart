class Episode {
  final int id;
  final String namaSiswa; // Novel name
  final String episode; // Episode title
  final String isNew;
  final String folder; // URL to 3D flip book
  final String subCourseId;
  final String? audio;
  final String courseId;
  final String position;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Course course;
  final SubCourse subcourse;

  Episode({
    required this.id,
    required this.namaSiswa,
    required this.episode,
    required this.isNew,
    required this.folder,
    required this.subCourseId,
    this.audio,
    required this.courseId,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
    required this.course,
    required this.subcourse,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'],
      namaSiswa: json['namaSiswa'] ?? '',
      episode: json['episode'] ?? '',
      isNew: json['is_new'] ?? '0',
      folder: json['folder'] ?? '',
      subCourseId: json['sub_course_id']?.toString() ?? '',
      audio: json['audio'],
      courseId: json['course_id']?.toString() ?? '',
      position: json['position']?.toString() ?? '0',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      course: Course.fromJson(json['course']),
      subcourse: SubCourse.fromJson(json['subcourse']),
    );
  }

  // Get clean title without author name repeated
  String get cleanTitle {
    String title = episode;
    // Remove episode number patterns like "Epi 19", "Episode 19", etc.
    title = title.replaceAll(RegExp(r'\s+(Epi|Episode)\s+\d+', caseSensitive: false), '');
    // If title is still very long, try to get just the book name
    if (title.length > 50) {
      return namaSiswa.length > 40 ? namaSiswa.substring(0, 37) + '...' : namaSiswa;
    }
    return title;
  }

  // Get episode number
  String get episodeNumber {
    final match = RegExp(r'(Epi|Episode)\s+(\d+)', caseSensitive: false).firstMatch(episode);
    return match?.group(2) ?? position;
  }

  // Get the base URL for the image
  String get imageUrl {
    if (course.image.startsWith('http')) {
      return course.image;
    }
    return 'https://classicdigitallibraries.com/public/courses/${course.image}';
  }

  bool get isNewEpisode => isNew == '1';
}

class Course {
  final int id;
  final String name;
  final String image;
  final DateTime createdAt;
  final DateTime updatedAt;

  Course({
    required this.id,
    required this.name,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class SubCourse {
  final int id;
  final String courseId;
  final String name;
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
    return SubCourse(
      id: json['id'],
      courseId: json['course_id']?.toString() ?? '',
      name: json['name'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
} 