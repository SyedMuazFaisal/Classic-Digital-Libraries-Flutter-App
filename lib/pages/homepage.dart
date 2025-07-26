 import 'package:cdl/pages/Novelspage.dart';
import 'package:cdl/pages/accountpage.dart';
import 'package:cdl/pages/whatsnewpage.dart';
import 'package:cdl/pages/bookdetailpage.dart';
  import '../widgets/book_slider.dart';
import '../widgets/whats_new_slider.dart';
import '../controllers/popular_novels_controller.dart';
import '../models/book_model.dart';


  import 'package:flutter/material.dart';
  import 'dart:async';
import 'package:get/get.dart';

  void main() {
    runApp(const CDLApp());
  }

  class CDLApp extends StatelessWidget {
    const CDLApp({super.key});

    @override
    Widget build(BuildContext context) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Classic Digital Libraries',
        home: BottomNavPage(),
      );
    }
  }

  class BottomNavPage extends StatefulWidget {
    const BottomNavPage({super.key});

    @override
    State<BottomNavPage> createState() => _BottomNavPageState();
  }

  class _BottomNavPageState extends State<BottomNavPage> {
    int currentIndex = 0;

    void _goToHome() {
      setState(() {
        currentIndex = 0;
      });
    }

    List<Widget> get pages => [
      const HomePage(),
      NovelsPage(),
      WhatsNewPage(onBackToHome: _goToHome),
       AccountPage(),
    ];
    

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: SafeArea(child: pages[currentIndex]),
        bottomNavigationBar: ClipRRect(
          
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: Container(
            height: 65,
            decoration: BoxDecoration(
              color: const Color(0xff0247bc),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) => setState(() => currentIndex = index),
              type: BottomNavigationBarType.fixed, 
              backgroundColor: Color(0xff0247bc),
              elevation: 0,
              selectedItemColor: Colors.yellow,
              unselectedItemColor: Colors.white,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(icon: Icon(Icons.library_books), label: "Novels"),
                BottomNavigationBarItem(icon: Icon(Icons.fiber_new), label: "What's New"),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
              ],
            ),
          ),
        ),
      );
    }
  }

  class HomePage extends StatefulWidget {
    const HomePage({super.key});

    @override
    State<HomePage> createState() => _HomePageState();
  }

  class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
    final PageController _sliderController = PageController();
    final PageController _testimonialController = PageController();
    final PopularNovelsController popularController = Get.put(PopularNovelsController());

    int _sliderIndex = 0;
    int _testimonialIndex = 0;

    late final Timer _sliderTimer;
    late final Timer _testimonialTimer;

    @override
    void initState() {
      super.initState();

      _sliderTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        setState(() {
          _sliderIndex = (_sliderIndex + 1) % 2;
          _sliderController.animateToPage(
            _sliderIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });
      });

      _testimonialTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        setState(() {
          _testimonialIndex = (_testimonialIndex + 1) % 5;
          _testimonialController.animateToPage(
            _testimonialIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });
      });
    }

    @override
    void dispose() {
      _sliderTimer.cancel();
      _testimonialTimer.cancel();
      _sliderController.dispose();
      _testimonialController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16, right: 10, left: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xff0247bc),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 40,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Classic Digital Libraries",
                        style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search Novels...',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Slider
            SizedBox(
              height: 250,
              child: PageView(
                controller: _sliderController,
                children: [
                  _sliderImage(
                    imageUrl: 'https://images.theconversation.com/files/45159/original/rptgtpxd-1396254731.jpg',
                    title: 'Ayat Noor',
                    subtitle: 'Har Safha Ik Nai Duniya, Ik Nai Kahani',
                  ),
                  _sliderImage(
                    imageUrl: 'https://static.vecteezy.com/system/resources/thumbnails/044/280/984/small/stack-of-books-on-a-brown-background-concept-for-world-book-day-photo.jpg',
                    title: 'Anaya Ahmed',
                    subtitle: 'Jahan Mohobbat Lafzon Mein Dhalti Hai',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            _buildFeatures(),
            const SizedBox(height: 16),
            // After features, show WhatsNewSlider with heading 'New Arrivals':
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text("What's New", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            const WhatsNewSlider(),
            const SizedBox(height: 16),
            _buildPopularAndNewArrivals(),
            const SizedBox(height: 16),
            _buildTestimonials(),
          ],
        ),
      );
    }

    Widget _sliderImage({required String imageUrl, required String title, required String subtitle}) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black.withOpacity(0.4),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => NovelsPage())),
                child: const Text("Read Now"),
              ),
            ],
          ),
        ),
      );
    }

Widget _buildFeatures() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth;
          int crossAxisCount = maxWidth < 400 ? 2 : maxWidth < 600 ? 3 : 4;
          double spacing = 12;
          double totalSpacing = spacing * (crossAxisCount - 1);
          double itemWidth = (maxWidth - totalSpacing) / crossAxisCount;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              _featureBoxWithIndex(0, Icons.auto_stories, "Instant Reading", itemWidth),
              _featureBoxWithIndex(1, Icons.fiber_new, "Latest Releases", itemWidth, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const WhatsNewPage()));
              }),
              _featureBoxWithIndex(2, Icons.group, "Community", itemWidth),
              _featureBoxWithIndex(3, Icons.lock_clock, "24/7 Access", itemWidth),

            ],
          );
        },
      ),
      const SizedBox(height: 24),
      // In _buildFeatures(), restore BookSlider and heading:
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("New Arrivals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const WhatsNewPage()));
              },
              child: const Text(
                "View All",
                style: TextStyle(
                  color: Color(0xff0247bc),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      const BookSlider(),
    ],
  );
}

Widget _featureBoxWithIndex(int index, IconData icon, String label, double width, {VoidCallback? onTap}) {
  final gradients = [
    [Color(0xFF0D47A1), Color(0xFF1976D2)],
    [Color(0xFF1B5E20), Color(0xFF388E3C)],
    [Color(0xFFB71C1C), Color(0xFFD32F2F)],
    [Color(0xFF311B92), Color(0xFF512DA8)],
    
  ];

  final boxColors = gradients[index % gradients.length];

  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: boxColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: boxColors[1].withOpacity(0.7),
            offset: const Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

  

    Widget _buildPopularAndNewArrivals() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Popular Novels", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () => popularController.refreshPopularNovels(),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text("Refresh"),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xff0247bc),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Obx(() {
            if (popularController.isLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (popularController.popularBooks.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "No popular novels available",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: popularController.popularBooks.length > 8 
                  ? 8 
                  : popularController.popularBooks.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 20,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (context, index) {
                final Book book = popularController.popularBooks[index];
                
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => BookDetailPage(book: book),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Book Image - 70%
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 180,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              book.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.book,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // "Popular" Badge
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'POPULAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // Bottom content
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                            ),
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
                                    ...List.generate(5, (starIndex) {
                                      if (starIndex < book.rating.floor()) {
                                        return const Icon(Icons.star, color: Colors.amber, size: 16);
                                      } else if (starIndex < book.rating) {
                                        return const Icon(Icons.star_half, color: Colors.amber, size: 16);
                                      } else {
                                        return const Icon(Icons.star_border, color: Colors.amber, size: 16);
                                      }
                                    }),
                                    const SizedBox(width: 4),
                                    Text(
                                      "(${book.reviewCount})",
                                      style: const TextStyle(fontSize: 12),
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
            );
          }),
        ],
      );
    }

    Widget _buildTestimonials() {
      final testimonials = [
        {
          "name": "Fatima Ali",
          "city": "Lahore",
          "text": "Yaar sach mein,itne maze ka content kahin or nhi milta . Urdu Novels zabardast hai!",
          "image": "https://classicdigitallibraries.com/public/frontAssets/image/testimonials/testimonial-02.jpg"
        },
        {
          "name": "Ali Raza",
          "city": "Karachi",
          "text": "Main roz raat ko aik Novel parhta hoon is app sey. Har kahani dil ko choo jati hai!",
          "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTsJCMuTQ2ACNXTNLvAAleJkaIoSHg0T5HNPw&s"
        },
        {
          "name": "Sadia Malik",
          "city": "Islamabad",
          "text": "Bachpan sey novels ka craze thaa lekin is site ney to meri reading life hee next level pe le gayi hai!",
          "image": "https://classicdigitallibraries.com/public/frontAssets/image/testimonials/testimonial-02.jpg"
        },
        {
          "name": "Hassan Javed",
          "city": "Faisalabad",
          "text": "Storylines itni realistic hoti hain ke lagta hai jaise sab meri ankhon ke saamne ho raha ho.",
          "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQiNfCEQ7yYx1o0ZeFcKycklQYDkoBhCelJlA&s"
        },
        {
          "name": "Nimra Khan",
          "city": "Multan",
          "text": "Na sirf stories best hain , balkay App ka design bhi bht user-friendly hai.Great job team!",
          "image": "https://classicdigitallibraries.com/public/frontAssets/image/testimonials/testimonial-03.jpg"
        },
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text("Client Testimonials", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 150,
            child: PageView.builder(
              controller: _testimonialController,
              itemCount: testimonials.length,
              itemBuilder: (context, index) {
                return _testimonialCard(testimonials[index]);
              },
            ),
          ),
          const SizedBox(height: 8),
          _buildDotIndicator(testimonials.length, _testimonialIndex),
        ],
      );
    }

    Widget _testimonialCard(Map<String, String> testimonial) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.yellow.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(testimonial['image']!),
              radius: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('"${testimonial['text']}"', style: const TextStyle(fontStyle: FontStyle.italic)),
                  const SizedBox(height: 8),
                  Text("- ${testimonial['name']} - ${testimonial['city']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildDotIndicator(int count, int activeIndex) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == activeIndex ? Colors.blue : Colors.grey,
            ),
          );
        }),
      );
    }
  }