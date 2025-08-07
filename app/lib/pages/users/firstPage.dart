import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant.dart';
import '../../controllers/getDataController.dart';
import '../../components/bannerCard.dart';
import '../../components/productCard.dart';
import '../users/searchPage.dart';
import '../users/allCategory.dart';
import '../users/allProduct.dart';
import '../../models/products.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> with TickerProviderStateMixin {
  final GetDataController _ctrl = Get.find<GetDataController>();
  final PageController _bannerController = PageController(viewportFraction: 0.9);
  Timer? _bannerTimer;
  int _bannerPage = 0;
  int _selectedTab = 0;
  List<Product> _topRated = [];

  @override
  void initState() {
    super.initState();
    // Fetch products then compute top-rated
    _ctrl.getProduct().then((_) => _computeTopRated());
    // Banner auto-scroll every 4 seconds
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_bannerController.hasClients) return;
      final all = _ctrl.productResponse?.products ?? [];
      final slides = min(3, all.length) + 1;
      _bannerPage = (_bannerPage + 1) % slides;
      _bannerController.animateToPage(
        _bannerPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _computeTopRated() async {
    final all = _ctrl.productResponse?.products ?? [];
    final entries = await Future.wait(all.map((p) async {
      final id = int.tryParse(p.product_id ?? '') ?? 0;
      final res = await _ctrl.getReviews(id);
      return MapEntry(p, (res['average_rating'] as double?) ?? 0.0);
    }));
    entries.sort((a, b) => b.value.compareTo(a.value));
    setState(() {
      _topRated = entries.map((e) => e.key).take(min(3, entries.length)).toList();
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Silver Skin',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: secondaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: textColor),
            onPressed: () => Get.to(() => const SearchPage()),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: GetBuilder<GetDataController>(
          builder: (_) {
            final all = _ctrl.productResponse?.products ?? [];
            final cats = _ctrl.categoriesResponse?.categories ?? [];
            if (_ctrl.productResponse == null) {
              return const Center(child: CircularProgressIndicator());
            }
            // Random top products
            final topRandom = ([...all]..shuffle(Random()))
                .take(min(3, all.length))
                .toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Slider
                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      controller: _bannerController,
                      itemCount: min(3, all.length) + 1,
                      itemBuilder: (ctx, i) {
                        if (i == 0) return _buildWelcome();
                        return BannerCard(product: all[i - 1]);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Shop by Category (compact)
                  if (cats.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Shop by Category',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: cats.length,
                        itemBuilder: (ctx, i) {
                          final c = cats[i];
                          return GestureDetector(
                            onTap: () => Get.to(
                              () => const AllCategoryPage(),
                              arguments: c,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: boxColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                c.categoryTitle ?? 'Category',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: textColor,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Toggle Buttons: Top Products / Top Rated
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildTabButton('Products', 0),
                        const SizedBox(width: 16),
                        _buildTabButton('Top Rated', 1),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Display selected list
                  if (_selectedTab == 0) ...[
                    for (var p in topRandom)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ProductCard(
                          key: ValueKey(p.product_id),
                          product: p,
                        ),
                      ),
                  ] else ...[
                    for (var p in _topRated)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ProductCard(
                          key: ValueKey(p.product_id),
                          product: p,
                        ),
                      ),
                  ],
                  const SizedBox(height: 20),

                  // Explore More
                  Center(
                    child: ElevatedButton(
                      onPressed: () => Get.to(() => const AllProductPage()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Explore More Products',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final selected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? accentColor : boxColor,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcome() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
      ),
      child: Stack(
        children: [
          const Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to Silver Skin',
                  style: TextStyle(
                    color: Color(0xFF4A4A4A),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Your Best Destination for Perfect Coffee Accessories',
                  style: TextStyle(
                    color: Color(0xFF6E6E6E),
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: ElevatedButton(
              onPressed: () => Get.to(() => const AllProductPage()),
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor,
                padding: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 2,
              ),
              child: const Text(
                'Explore',
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}