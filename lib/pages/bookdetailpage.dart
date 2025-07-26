import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../controllers/library_controller.dart';
import '../models/book_model.dart';
import '../widgets/rating.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import '../controllers/auth_controller.dart';

class BookDetailPage extends StatefulWidget {
  final Book book;
  final LibraryController controller = Get.find();

  BookDetailPage({super.key, required this.book});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  Book? currentBook;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    currentBook = widget.book;
    _refreshBookData();
  }

  Future<void> _refreshBookData() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      // Fetch fresh book data from the API
      final response = await http.get(
        Uri.parse('https://classicdigitallibraries.com/public/api/frontend/novels?page=1'),
        headers: {'Accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final coursesData = jsonData['courses'];
        
        if (coursesData != null) {
          final List<dynamic> booksJson = coursesData['data'] ?? [];
          
          // Find the current book by ID
          for (var bookJson in booksJson) {
            if (bookJson['id'].toString() == widget.book.id) {
              final updatedBook = Book.fromJson(bookJson);
              setState(() {
                currentBook = updatedBook;
              });
              print('✅ Refreshed book data for: ${updatedBook.title}');
              print('✅ Found ${updatedBook.subcourses.length} subcourses');
              break;
            }
          }
        }
      }
    } catch (e) {
      print('❌ Error refreshing book data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = currentBook ?? widget.book;
    
    // Debug logging to see what's in the book data
    print('🔍 Book ID: ${book.id}');
    print('🔍 Book Title: ${book.title}');
    print('🔍 Subcourses count: ${book.subcourses.length}');
    print('🔍 Subcourses: ${book.subcourses.map((s) => '${s.id}: ${s.name}').toList()}');
    
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xff0247bc),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff0247bc),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.network(
                            book.image,
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
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _refreshBookData,
                  ),
                  Obx(() => IconButton(
                        icon: Icon(
                          widget.controller.isFavorite(book.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.controller.isFavorite(book.id)
                              ? Colors.red
                              : Colors.white,
                        ),
                        onPressed: () {
                          widget.controller.toggleFavorite(book.id);
                        },
                      )),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        book.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Color.fromARGB(255, 62, 62, 62)),
                          const SizedBox(width: 6),
                          Text(
                            'Released at: ' + _formatDate(book.createdAt),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 73, 73, 73),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RatingBarIndicator(
                            rating: book.rating,
                            itemBuilder: (context, _) =>
                                const Icon(Icons.star, color: Colors.amber),
                            itemSize: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            book.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Show all subcourses as buttons
                      if (book.subcourses.isEmpty)
                        Column(
                          children: [
                            const Text(
                              'Available Subcourses:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: const Text(
                                'No subcourses found for this book yet.\nCheck back later for updates!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (book.subcourses.isNotEmpty)
                        Column(
                          children: [
                            const Text(
                              'Available Subcourses:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...book.subcourses.map((subcourse) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _navigateToSubcourseEpisodes(subcourse);
                                },
                                icon: const Icon(Icons.menu_book, color: Colors.white, size: 24),
                                label: Text(
                                  subcourse.name ?? "Read Now",
                                  style: const TextStyle(color: Colors.white, fontSize: 18),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff0247bc),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                ),
                              ),
                            )).toList(),
                          ],
                        ),
                      const SizedBox(height: 30),
                      RatingReviews(
                        novelId: book.id, 
                        reviews: book.reviews,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToSubcourseEpisodes(SubCourse subcourse) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubcourseEpisodesPage(
          subcourse: subcourse,
          bookTitle: widget.book.title,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
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
      namaSiswa: json['namaSiswa'] ?? json['nama_siswa'] ?? json['author'] ?? 'Unknown',
      episode: json['episode'] ?? json['title'] ?? json['name'] ?? 'Untitled',
      folder: json['folder'] ?? json['content'] ?? json['url'],
      audio: json['audio'],
      position: json['position']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

class SubcourseEpisodesPage extends StatefulWidget {
  final SubCourse subcourse;
  final String bookTitle;

  const SubcourseEpisodesPage({
    super.key,
    required this.subcourse,
    required this.bookTitle,
  });

  @override
  State<SubcourseEpisodesPage> createState() => _SubcourseEpisodesPageState();
}

class _SubcourseEpisodesPageState extends State<SubcourseEpisodesPage> {
  List<Episode>? episodes;
  bool isLoadingEpisodes = true;
  String? episodeError;

  @override
  void initState() {
    super.initState();
    _loadEpisodes();
  }

  Future<void> _loadEpisodes() async {
    setState(() {
      isLoadingEpisodes = true;
      episodeError = null;
      episodes = null;
    });
    try {
      final episodesList = await _fetchEpisodesFromAPI(widget.subcourse.id);
      setState(() {
        episodes = episodesList;
        isLoadingEpisodes = false;
      });
    } catch (e) {
      setState(() {
        episodeError = "Failed to load episodes: $e";
        isLoadingEpisodes = false;
      });
    }
  }

  Future<List<Episode>> _fetchEpisodesFromAPI(String subcourseId) async {
    final url = 'https://classicdigitallibraries.com/public/api/frontend/subcourses/$subcourseId';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> episodesJson = [];
      if (data['biodatas'] != null) {
        episodesJson = data['biodatas'] as List;
      } else if (data['data'] != null) {
        episodesJson = data['data'] as List;
      } else if (data['episodes'] != null) {
        episodesJson = data['episodes'] as List;
      }
      return episodesJson.map<Episode>((json) => Episode.fromJson(json)).toList();
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subcourse.name ?? 'Episodes'),
        backgroundColor: const Color(0xff0247bc),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.bookTitle} - ${widget.subcourse.name}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildEpisodesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEpisodesList() {
    if (isLoadingEpisodes) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (episodeError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              episodeError!,
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEpisodes,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (episodes == null || episodes!.isEmpty) {
      return const Center(
        child: Text(
          'No episodes found for this subcourse.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return ListView.builder(
      itemCount: episodes!.length,
      itemBuilder: (context, index) {
        final episode = episodes![index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.menu_book, color: Color(0xff0247bc)),
            title: Text(episode.episode),
            subtitle: Text('By: ${episode.namaSiswa}'),
            onTap: () async {
              if (episode.folder != null && episode.folder!.isNotEmpty) {
                if (AuthController.sessionCookie != null) {
                  final cookieParts = AuthController.sessionCookie!.split('=');
                  if (cookieParts.length == 2) {
                    final cookieManager = WebViewCookieManager();
                    await cookieManager.setCookie(
                      WebViewCookie(
                        name: cookieParts[0],
                        value: cookieParts[1],
                        domain: 'classicdigitallibraries.com',
                        path: '/',
                      ),
                    );
                  }
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EpisodeWebViewPage(episode: episode),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No web content available for this episode.')),
                );
              }
            },
          ),
        );
      },
    );
  }
}

class EpisodeWebViewPage extends StatelessWidget {
  final Episode episode;
  const EpisodeWebViewPage({super.key, required this.episode});

  @override
  Widget build(BuildContext context) {
    String url = episode.id.toString();
    if (!url.startsWith('http')) {
      url = 'https://classicdigitallibraries.com/public/read_novel/$url';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(episode.episode),
        backgroundColor: const Color(0xff0247bc),
      ),
      body: url.isNotEmpty
          ? WebViewWidget(controller: WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..loadRequest(Uri.parse(url)))
          : const Center(child: Text('No web content available for this episode.')),
    );
  }
}

