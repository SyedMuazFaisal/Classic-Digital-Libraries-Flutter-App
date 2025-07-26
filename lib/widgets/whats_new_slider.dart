import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/whats_new_controller.dart';
import '../models/episode_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WhatsNewSlider extends StatefulWidget {
  const WhatsNewSlider({super.key});

  @override
  State<WhatsNewSlider> createState() => _WhatsNewSliderState();
}

class _WhatsNewSliderState extends State<WhatsNewSlider> {
  final ScrollController _scrollController = ScrollController();
  final WhatsNewController controller = Get.put(WhatsNewController());
  late Timer _timer;
  double scrollPosition = 0;

  @override
  void initState() {
    super.initState();

    // Auto-scroll
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_scrollController.hasClients && controller.sliderEpisodes.isNotEmpty) {
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

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox(
          height: 220,
          child: Center(
            child: CircularProgressIndicator(
              color: Color(0xff0247bc),
            ),
          ),
        );
      }

      final episodes = controller.sliderEpisodes;

      if (episodes.isEmpty) {
        return const SizedBox(
          height: 220,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'No new episodes available',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }

      return SizedBox(
        height: 220,
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: episodes.length,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemBuilder: (context, index) {
            final Episode episode = episodes[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EpisodeWebViewPage(episodeId: episode.id, episodeTitle: episode.episode),
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
                child: Stack(
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 220 * 0.7,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.network(
                              episode.imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print("⚠️ Failed to load image: ${episode.imageUrl}");
                                return Container(
                                  color: Colors.grey.shade800,
                                  child: const Icon(
                                    Icons.book,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  episode.cleanTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Episode ${episode.episodeNumber}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // "NEW" Badge
                    if (episode.isNewEpisode)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    // Episode number badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Ep ${episode.episodeNumber}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
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
    });
  }
}

class EpisodeWebViewPage extends StatelessWidget {
  final int episodeId;
  final String episodeTitle;
  const EpisodeWebViewPage({super.key, required this.episodeId, required this.episodeTitle});

  @override
  Widget build(BuildContext context) {
    final url = 'https://classicdigitallibraries.com/public/read_novel/$episodeId';
    return Scaffold(
      appBar: AppBar(
        title: Text(episodeTitle),
        backgroundColor: const Color(0xff0247bc),
      ),
      body: WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(url)),
      ),
    );
  }
} 