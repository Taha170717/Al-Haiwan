import 'package:al_haiwan/admin/views/bottom_nav_pages/products/update_products.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/stock_controller.dart';
import 'add_products.dart';

class AdminProducts extends StatefulWidget {
  const AdminProducts({super.key});

  @override
  State<AdminProducts> createState() => _AdminProductsState();
}

class _AdminProductsState extends State<AdminProducts> {
  String searchQuery = '';
  String selectedFilter = 'All';
  String selectedCategory = 'All';
  final StockController stockController = Get.put(StockController());

  static const Color primary = Color(0xFF199A8E);

  TextStyle _nameStyleFor(String name) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;
    final isDesktop = screenWidth > 1024;

    final length = name.trim().length;
    double size;

    if (isDesktop) {
      if (length <= 16) {
        size = 18;
      } else if (length <= 24) {
        size = 16;
      } else {
        size = 14;
      }
    } else if (isWeb) {
      if (length <= 16) {
        size = 16;
      } else if (length <= 24) {
        size = 14;
      } else {
        size = 13;
      }
    } else {
      if (length <= 16) {
        size = screenWidth * 0.04;
      } else if (length <= 24) {
        size = screenWidth * 0.035;
      } else {
        size = screenWidth * 0.032;
      }
    }

    return TextStyle(
      fontWeight: FontWeight.w800,
      fontSize: size,
      letterSpacing: 0.2,
      height: 1.2,
    );
  }

  Color _stockColor(int qty) {
    if (qty <= 0) return Colors.red.shade600;
    if (qty <= 5) return Colors.orange.shade700;
    return Colors.green.shade700;
  }

  String _stockLabel(int qty) {
    if (qty <= 0) return 'Out of stock';
    if (qty <= 5) return 'Low stock';
    return 'In stock';
  }

  List<QueryDocumentSnapshot> _filterProducts(List<QueryDocumentSnapshot> products) {
    return products.where((doc) {
      final name = (doc['name'] ?? '').toString().toLowerCase();
      final brand = (doc['brand'] ?? '').toString().toLowerCase();
      final category = (doc['category'] ?? '').toString();
      final int stockQty = (doc['stockQuantity'] ?? 0) is int
          ? (doc['stockQuantity'] ?? 0) as int
          : int.tryParse((doc['stockQuantity'] ?? '0').toString()) ?? 0;

      // Search filter
      bool matchesSearch = name.contains(searchQuery) || brand.contains(searchQuery);

      // Stock filter
      bool matchesStockFilter = true;
      switch (selectedFilter) {
        case 'Low Stock':
          matchesStockFilter = stockQty > 0 && stockQty <= 5;
          break;
        case 'Out of Stock':
          matchesStockFilter = stockQty <= 0;
          break;
        case 'In Stock':
          matchesStockFilter = stockQty > 5;
          break;
        case 'All':
        default:
          matchesStockFilter = true;
      }

      // Category filter
      bool matchesCategoryFilter = selectedCategory == 'All' || category == selectedCategory;

      return matchesSearch && matchesStockFilter && matchesCategoryFilter;
    }).toList();
  }

  // Helper method to get count for each filter
  int _getFilterCount(List<QueryDocumentSnapshot> products, String filter) {
    return products.where((doc) {
      final name = (doc['name'] ?? '').toString().toLowerCase();
      final brand = (doc['brand'] ?? '').toString().toLowerCase();
      final category = (doc['category'] ?? '').toString();
      final int stockQty = (doc['stockQuantity'] ?? 0) is int
          ? (doc['stockQuantity'] ?? 0) as int
          : int.tryParse((doc['stockQuantity'] ?? '0').toString()) ?? 0;

      // Search filter
      bool matchesSearch =
          name.contains(searchQuery) || brand.contains(searchQuery);

      // Stock filter based on the filter parameter
      bool matchesStockFilter = true;
      switch (filter) {
        case 'Low Stock':
          matchesStockFilter = stockQty > 0 && stockQty <= 5;
          break;
        case 'Out of Stock':
          matchesStockFilter = stockQty <= 0;
          break;
        case 'In Stock':
          matchesStockFilter = stockQty > 5;
          break;
        case 'All':
        default:
          matchesStockFilter = true;
      }

      // Category filter
      bool matchesCategoryFilter =
          selectedCategory == 'All' || category == selectedCategory;

      return matchesSearch && matchesStockFilter && matchesCategoryFilter;
    }).length;
  }

  // Helper method to get count for each category
  int _getCategoryCount(List<QueryDocumentSnapshot> products, String category) {
    return products.where((doc) {
      final name = (doc['name'] ?? '').toString().toLowerCase();
      final brand = (doc['brand'] ?? '').toString().toLowerCase();
      final docCategory = (doc['category'] ?? '').toString();
      final int stockQty = (doc['stockQuantity'] ?? 0) is int
          ? (doc['stockQuantity'] ?? 0) as int
          : int.tryParse((doc['stockQuantity'] ?? '0').toString()) ?? 0;

      // Search filter
      bool matchesSearch =
          name.contains(searchQuery) || brand.contains(searchQuery);

      // Stock filter
      bool matchesStockFilter = true;
      switch (selectedFilter) {
        case 'Low Stock':
          matchesStockFilter = stockQty > 0 && stockQty <= 5;
          break;
        case 'Out of Stock':
          matchesStockFilter = stockQty <= 0;
          break;
        case 'In Stock':
          matchesStockFilter = stockQty > 5;
          break;
        case 'All':
        default:
          matchesStockFilter = true;
      }

      // Category filter based on the category parameter
      bool matchesCategoryFilter = category == 'All' || docCategory == category;

      return matchesSearch && matchesStockFilter && matchesCategoryFilter;
    }).length;
  }

  Widget _buildFilterChips() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isWeb = screenWidth > 800;
    final isDesktop = screenWidth > 1024;

    final stockFilters = ['All', 'In Stock', 'Low Stock', 'Out of Stock'];
    final categories = [
      'All',
      'Deworming',
      'Vaccines',
      'Pain Relief',
      'Skin & Coat',
      'Eye/Ear Drops',
      'Supplements',
      'Pet Food',
      'Grooming',
      'Toys',
      'Cleaning'
    ];

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .orderBy('name')
          .snapshots(),
      builder: (context, snapshot) {
        final products =
            snapshot.hasData ? snapshot.data!.docs : <QueryDocumentSnapshot>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stock Status Filters
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 24 : screenWidth * 0.03),
              child: Text(
                'Stock Status',
                style: TextStyle(
                  fontSize: isWeb ? 14 : screenWidth * 0.035,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            SizedBox(height: isWeb ? 8 : screenHeight * 0.008),
            SizedBox(
              height: isWeb ? 40 : screenHeight * 0.05,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                    horizontal: isWeb ? 24 : screenWidth * 0.03),
                itemCount: stockFilters.length,
                itemBuilder: (context, index) {
                  final filter = stockFilters[index];
                  final isSelected = selectedFilter == filter;
                  final count = _getFilterCount(products, filter);

                  return Padding(
                    padding:
                        EdgeInsets.only(right: isWeb ? 12 : screenWidth * 0.02),
                    child: FilterChip(
                      label: Text(
                        '$filter ($count)',
                        style: TextStyle(
                          fontSize: isWeb ? 14 : screenWidth * 0.032,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : primary,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selectedFilter = filter;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: primary,
                      checkmarkColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? primary : primary.withOpacity(0.3),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            isWeb ? 20 : screenWidth * 0.06),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isWeb ? 16 : screenWidth * 0.025,
                        vertical: isWeb ? 8 : screenHeight * 0.008,
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: isWeb ? 16 : screenHeight * 0.015),

            // Category Filters
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 24 : screenWidth * 0.03),
              child: Text(
                'Category',
                style: TextStyle(
                  fontSize: isWeb ? 14 : screenWidth * 0.035,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            SizedBox(height: isWeb ? 8 : screenHeight * 0.008),
            SizedBox(
              height: isWeb ? 40 : screenHeight * 0.05,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                    horizontal: isWeb ? 24 : screenWidth * 0.03),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category;
                  final count = _getCategoryCount(products, category);

                  return Padding(
                    padding:
                        EdgeInsets.only(right: isWeb ? 12 : screenWidth * 0.02),
                    child: FilterChip(
                      label: Text(
                        '$category ($count)',
                        style: TextStyle(
                          fontSize: isWeb ? 14 : screenWidth * 0.032,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : primary,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: primary,
                      checkmarkColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? primary : primary.withOpacity(0.3),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            isWeb ? 20 : screenWidth * 0.06),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isWeb ? 16 : screenWidth * 0.025,
                        vertical: isWeb ? 8 : screenHeight * 0.008,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1024;
    final isWeb = screenWidth > 800;

    final dividerColor = Colors.grey.shade300;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: isWeb ? screenWidth * 0.015 : screenWidth * 0.02),
          child: Text(
            'Products & Stock',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: primary,
              fontFamily: "bolditalic",
              letterSpacing: 0.3,
              fontSize: isDesktop ? 28 : isTablet ? 24 : screenWidth * 0.06,
            ),
          ),
        ),
        centerTitle: false,
        actions: [
          // Low Stock Alert Badge
          Obx(() {
            final lowStockProducts = stockController.lowStockProducts;
            return lowStockProducts != null && lowStockProducts.isNotEmpty
                ? Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.warning_amber_rounded,
                            color: Colors.orange.shade700,
                            size: isWeb ? 28 : screenWidth * 0.06),
                        onPressed: () => _showLowStockAlert(context),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding:
                              EdgeInsets.all(isWeb ? 4 : screenWidth * 0.01),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            borderRadius: BorderRadius.circular(
                                isWeb ? 10 : screenWidth * 0.02),
                          ),
                          constraints: BoxConstraints(
                            minWidth: isWeb ? 20 : screenWidth * 0.04,
                            minHeight: isWeb ? 20 : screenWidth * 0.04,
                          ),
                          child: Text(
                            '${lowStockProducts.length}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isWeb ? 12 : screenWidth * 0.025,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink();
          }),
          // Stock History Button
          IconButton(
            icon: Icon(Icons.history,
                color: primary,
                size: isWeb ? 28 : screenWidth * 0.06),
            onPressed: () => _showStockHistory(context),
          ),
          SizedBox(width: isWeb ? 16 : screenWidth * 0.02),
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Search bar (UI polish only)
          Padding(
            padding: EdgeInsets.fromLTRB(
                isWeb ? 24 : screenWidth * 0.03,
                isWeb ? 20 : screenHeight * 0.015,
                isWeb ? 24 : screenWidth * 0.03,
                isWeb ? 12 : screenHeight * 0.01
            ),
            child: // Constrained width for better web layout
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 800 : double.infinity,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isWeb ? 12 : screenWidth * 0.035),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() => searchQuery = value.toLowerCase());
                  },
                  decoration: InputDecoration(
                    hintText: "Search product...",
                    hintStyle: TextStyle(fontSize: isWeb ? 16 : screenWidth * 0.04),
                    prefixIcon: Icon(Icons.search, size: isWeb ? 24 : screenWidth * 0.06),
                    suffixIcon: searchQuery.isEmpty
                        ? null
                        : IconButton(
                      tooltip: 'Clear',
                      icon: Icon(Icons.close, size: isWeb ? 24 : screenWidth * 0.06),
                      onPressed: () {
                        setState(() => searchQuery = '');
                      },
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        vertical: isWeb ? 16 : screenHeight * 0.015),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(isWeb ? 12 : screenWidth * 0.035),
                      borderSide: BorderSide(color: dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(isWeb ? 12 : screenWidth * 0.035),
                      borderSide: BorderSide(color: dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(isWeb ? 12 : screenWidth * 0.035),
                      borderSide: const BorderSide(color: primary, width: 1.4),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  style: TextStyle(fontSize: isWeb ? 16 : screenWidth * 0.04),
                ),
              ),
            ),
          ),
          SizedBox(height: isWeb ? 8 : screenHeight * 0.005),

          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 1200 : double.infinity,
            ),
            child: _buildFilterChips(),
          ),
          SizedBox(height: isWeb ? 16 : screenHeight * 0.015),

          // Product list from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .orderBy('name')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load products'));
                }
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final products = _filterProducts(snapshot.data!.docs);

                if (products.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: isWeb ? 48 : screenWidth * 0.06),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: isWeb ? 120 : screenWidth * 0.22,
                            height: isWeb ? 120 : screenWidth * 0.22,
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.inventory_2_outlined,
                                color: primary,
                                size: isWeb ? 60 : screenWidth * 0.12),
                          ),
                          SizedBox(height: isWeb ? 24 : screenHeight * 0.02),
                          Text(
                            "No products found",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: isWeb ? 18 : screenWidth * 0.04,
                              color: Colors.grey.shade900,
                            ),
                          ),
                          SizedBox(height: isWeb ? 8 : screenHeight * 0.008),
                          Text(
                            "Try a different search or add a new product.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isWeb ? 14 : screenWidth * 0.035,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: isWeb ? 24 : screenHeight * 0.02),
                          OutlinedButton.icon(
                            onPressed: () {
                              Get.to(() => AddProducts(productId: '', existingData: {}));
                            },
                            icon: Icon(Icons.add, size: isWeb ? 20 : screenWidth * 0.05),
                            label: Text('Add Product',
                                style: TextStyle(fontSize: isWeb ? 16 : screenWidth * 0.04)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primary,
                              side: const BorderSide(color: primary),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(isWeb ? 8 : screenWidth * 0.025)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: isWeb ? 24 : screenWidth * 0.035,
                                  vertical: isWeb ? 12 : screenHeight * 0.012),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Header with count + list
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          isWeb ? 32 : screenWidth * 0.04,
                          0,
                          isWeb ? 32 : screenWidth * 0.04,
                          isWeb ? 12 : screenHeight * 0.01),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Showing ${products.length} item${products.length == 1 ? '' : 's'}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                            fontSize: isWeb ? 14 : screenWidth * 0.032,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: // Constrained width for better web layout
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isDesktop ? 1200 : double.infinity,
                          ),
                          child: ListView.separated(
                            padding: EdgeInsets.fromLTRB(
                                isWeb ? 24 : screenWidth * 0.03,
                                0,
                                isWeb ? 24 : screenWidth * 0.03,
                                isWeb ? 24 : screenHeight * 0.015),
                            itemCount: products.length,
                            physics: const BouncingScrollPhysics(),
                            cacheExtent: 800,
                            separatorBuilder: (_, __) => SizedBox(height: isWeb ? 16 : screenHeight * 0.012),
                            itemBuilder: (context, index) {
                              final product = products[index];
                              final productId = product.id;

                              final name = (product['name'] ?? '').toString();
                              final brand = (product['brand'] ?? '').toString();
                              final num rawPrice = product['price'] ?? 0;
                              final double price = rawPrice.toDouble();
                              // Safe stock access - check if field exists first
                              final productData = product.data() as Map<String, dynamic>;
                              final int stockQty = productData.containsKey('stockQuantity')
                                  ? (productData['stockQuantity'] is int
                                  ? productData['stockQuantity'] as int
                                  : int.tryParse(productData['stockQuantity'].toString()) ?? 0)
                                  : productData.containsKey('stock')
                                  ? (productData['stock'] is int
                                  ? productData['stock'] as int
                                  : int.tryParse(productData['stock'].toString()) ?? 0)
                                  : 0;

                              final int soldCount = productData.containsKey('soldCount')
                                  ? (productData['soldCount'] is int
                                  ? productData['soldCount'] as int
                                  : int.tryParse(productData['soldCount'].toString()) ?? 0)
                                  : 0;

                              final imageUrls = product.data() is Map<String, dynamic>
                                  ? (product['imageUrls'] as List<dynamic>?)
                                  : null;

                              final String? imageUrl = (imageUrls != null && imageUrls.isNotEmpty)
                                  ? imageUrls.first.toString()
                                  : null;

                              return Dismissible(
                                key: Key(productId),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.red.shade400, Colors.red.shade700],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(isWeb ? 12 : screenWidth * 0.04),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : screenWidth * 0.05),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: isWeb ? 14 : screenWidth * 0.035,
                                        ),
                                      ),
                                      SizedBox(width: isWeb ? 8 : screenWidth * 0.02),
                                      Icon(Icons.delete,
                                          color: Colors.white,
                                          size: isWeb ? 20 : screenWidth * 0.05),
                                    ],
                                  ),
                                ),
                                confirmDismiss: (_) async {
                                  final res = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(isWeb ? 12 : screenWidth * 0.035)),
                                      title: Text('Delete product?',
                                          style: TextStyle(fontSize: isWeb ? 18 : screenWidth * 0.045)),
                                      content: Text('Are you sure you want to delete "$name"?',
                                          style: TextStyle(fontSize: isWeb ? 16 : screenWidth * 0.04)),
                                      actionsPadding: EdgeInsets.fromLTRB(
                                          isWeb ? 24 : screenWidth * 0.04,
                                          0,
                                          isWeb ? 24 : screenWidth * 0.04,
                                          isWeb ? 16 : screenHeight * 0.015),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: Text('Cancel',
                                              style: TextStyle(fontSize: isWeb ? 16 : screenWidth * 0.04)),
                                        ),
                                        FilledButton(
                                          style: FilledButton.styleFrom(
                                            backgroundColor: Colors.red.shade600,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: Text('Delete',
                                              style: TextStyle(fontSize: isWeb ? 16 : screenWidth * 0.04)),
                                        ),
                                      ],
                                    ),
                                  );
                                  return res ?? false;
                                },
                                onDismissed: (_) async {
                                  await FirebaseFirestore.instance
                                      .collection('products')
                                      .doc(productId)
                                      .delete();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Product deleted successfully')),
                                    );
                                  }
                                },
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(isWeb ? 12 : screenWidth * 0.04),
                                    onTap: () {
                                      // Quick access to edit on card tap
                                      Get.to(() => AddProducts(
                                        productId: productId,
                                        existingData: product.data() as Map<String, dynamic>,
                                      ));
                                    },
                                    child: Card(
                                      elevation: 2.5,
                                      shadowColor: Colors.black12,
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(isWeb ? 12 : screenWidth * 0.04),
                                        side: BorderSide(color: dividerColor),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(isWeb ? 16 : screenWidth * 0.03),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            // Image
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(isWeb ? 8 : screenWidth * 0.03),
                                              child: SizedBox(
                                                width: isDesktop ? 80 : isTablet ? 60 : screenWidth * 0.15,
                                                height: isDesktop ? 80 : isTablet ? 60 : screenWidth * 0.15,
                                                child: (imageUrl != null &&
                                                        (imageUrl.contains(
                                                                'firebasestorage.googleapis.com') ||
                                                            imageUrl.contains(
                                                                'ik.imagekit.io') ||
                                                            imageUrl.startsWith(
                                                                'https://') // generic check for remote images
                                                        ))
                                                    ? Image.network(
                                                        imageUrl,
                                                        fit: BoxFit.cover,
                                                        filterQuality:
                                                            FilterQuality.low,
                                                        cacheWidth: 232,
                                                        cacheHeight: 232,
                                                        gaplessPlayback: true,
                                                        loadingBuilder:
                                                            (context, child,
                                                                progress) {
                                                          if (progress == null)
                                                            return child;
                                                          return Container(
                                                            color: Colors
                                                                .grey.shade200,
                                                            child: Center(
                                                              child: SizedBox(
                                                                width: isWeb
                                                                    ? 20
                                                                    : screenWidth *
                                                                        0.045,
                                                                height: isWeb
                                                                    ? 20
                                                                    : screenWidth *
                                                                        0.045,
                                                                child: const CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        2),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          print(
                                                              'Image load error for $imageUrl: $error');
                                                          return Container(
                                                            color: Colors
                                                                .grey.shade100,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .refresh,
                                                                    color: Colors
                                                                        .grey
                                                                        .shade600,
                                                                    size: isWeb
                                                                        ? 16
                                                                        : screenWidth *
                                                                            0.04),
                                                                Text(
                                                                    'Tap to retry',
                                                                    style: TextStyle(
                                                                        fontSize: isWeb
                                                                            ? 10
                                                                            : screenWidth *
                                                                                0.02,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade600)),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      )
                                                    : Container(
                                                        color: Colors.grey.shade100,
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                            Icon(
                                                                Icons
                                                                    .add_photo_alternate_outlined,
                                                                color: Colors
                                                                    .grey
                                                                    .shade400,
                                                                size: isWeb
                                                                    ? 20
                                                                    : screenWidth *
                                                                        0.05),
                                                            Text('No Image',
                                                                style: TextStyle(
                                                                  fontSize: isWeb ? 10 : screenWidth * 0.02,
                                                                    color: Colors
                                                                        .grey
                                                                        .shade400)),
                                                          ],
                                                      ),
                                                      ),
                                              ),
                                            ),
                                            SizedBox(width: isWeb ? 16 : screenWidth * 0.03),

                                            // Texts
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // Product name
                                                  Text(
                                                    name,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: _nameStyleFor(name),
                                                  ),
                                                  SizedBox(height: isWeb ? 8 : screenHeight * 0.008),

                                                  // Brand chip + Price badge
                                                  LayoutBuilder(
                                                    builder: (context, constraints) {
                                                      return Wrap(
                                                        spacing: isWeb ? 8 : screenWidth * 0.015,
                                                        runSpacing: isWeb ? 4 : screenHeight * 0.005,
                                                        children: [
                                                          // Brand tag
                                                          if (brand.isNotEmpty)
                                                            ConstrainedBox(
                                                              constraints: BoxConstraints(
                                                                maxWidth: constraints.maxWidth * 0.45,
                                                              ),
                                                              child: Container(
                                                                padding: EdgeInsets.symmetric(
                                                                    horizontal: isWeb ? 8 : screenWidth * 0.02,
                                                                    vertical: isWeb ? 4 : screenHeight * 0.005),
                                                                decoration: BoxDecoration(
                                                                  color: primary.withOpacity(0.08),
                                                                  borderRadius: BorderRadius.circular(isWeb ? 6 : screenWidth * 0.02),
                                                                  border: Border.all(color: primary.withOpacity(0.2)),
                                                                ),
                                                                child: Text(
                                                                  brand,
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  style: TextStyle(
                                                                    fontSize: isWeb ? 12 : screenWidth * 0.029,
                                                                    fontWeight: FontWeight.w700,
                                                                    color: primary,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),

                                                          // Price pill
                                                          ConstrainedBox(
                                                            constraints: BoxConstraints(
                                                              maxWidth: constraints.maxWidth * 0.5,
                                                            ),
                                                            child: Container(
                                                              padding: EdgeInsets.symmetric(
                                                                  horizontal: isWeb ? 8 : screenWidth * 0.02,
                                                                  vertical: isWeb ? 4 : screenHeight * 0.005),
                                                              decoration: BoxDecoration(
                                                                gradient: const LinearGradient(
                                                                  colors: [primary, Color(0xFF147E75)],
                                                                ),
                                                                borderRadius: BorderRadius.circular(isWeb ? 6 : screenWidth * 0.02),
                                                              ),
                                                              child: Text(
                                                                'Rs ${price.toStringAsFixed(2)}',
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: isWeb ? 12 : screenWidth * 0.029,
                                                                  fontWeight: FontWeight.w800,
                                                                  letterSpacing: 0.2,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                  SizedBox(height: isWeb ? 12 : screenHeight * 0.01),

                                                  // Stock badge and sold count
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Wrap(
                                                          spacing: isWeb ? 8 : screenWidth * 0.015,
                                                          runSpacing: isWeb ? 4 : screenHeight * 0.005,
                                                          children: [
                                                            Container(
                                                              padding: EdgeInsets.symmetric(
                                                                  horizontal: isWeb ? 8 : screenWidth * 0.02,
                                                                  vertical: isWeb ? 4 : screenHeight * 0.005),
                                                              decoration: BoxDecoration(
                                                                color: _stockColor(stockQty).withOpacity(0.12),
                                                                borderRadius: BorderRadius.circular(isWeb ? 6 : screenWidth * 0.02),
                                                                border: Border.all(color: _stockColor(stockQty).withOpacity(0.3)),
                                                              ),
                                                              child: Text(
                                                                '${_stockLabel(stockQty)} • $stockQty',
                                                                style: TextStyle(
                                                                  fontSize: isWeb ? 12 : screenWidth * 0.029,
                                                                  fontWeight: FontWeight.w700,
                                                                  color: _stockColor(stockQty),
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              padding: EdgeInsets.symmetric(
                                                                  horizontal: isWeb ? 8 : screenWidth * 0.02,
                                                                  vertical: isWeb ? 4 : screenHeight * 0.005),
                                                              decoration: BoxDecoration(
                                                                color: Colors.blue.withOpacity(0.12),
                                                                borderRadius: BorderRadius.circular(isWeb ? 6 : screenWidth * 0.02),
                                                                border: Border.all(color: Colors.blue.withOpacity(0.3)),
                                                              ),
                                                              child: Text(
                                                                'Sold: $soldCount',
                                                                style: TextStyle(
                                                                  fontSize: isWeb ? 12 : screenWidth * 0.029,
                                                                  fontWeight: FontWeight.w700,
                                                                  color: Colors.blue,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: isWeb ? 8 : screenHeight * 0.008),

                                                  // Quick stock adjustment buttons
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Quick adjust:',
                                                        style: TextStyle(
                                                          fontSize: isWeb ? 12 : screenWidth * 0.028,
                                                          fontWeight: FontWeight.w600,
                                                          color: Colors.grey.shade600,
                                                        ),
                                                      ),
                                                      SizedBox(width: isWeb ? 8 : screenWidth * 0.015),
                                                      Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          // Decrease stock button
                                                          GestureDetector(
                                                            onTap: stockQty > 0 ? () => _adjustStock(productId, name, -1) : null,
                                                            child: Container(
                                                              width: isWeb ? 28 : screenWidth * 0.06,
                                                              height: isWeb ? 28 : screenWidth * 0.06,
                                                              decoration: BoxDecoration(
                                                                color: stockQty > 0 ? Colors.red.shade100 : Colors.grey.shade200,
                                                                borderRadius: BorderRadius.circular(isWeb ? 6 : screenWidth * 0.015),
                                                                border: Border.all(
                                                                  color: stockQty > 0 ? Colors.red.shade300 : Colors.grey.shade400,
                                                                ),
                                                              ),
                                                              child: Icon(
                                                                Icons.remove,
                                                                size: isWeb ? 16 : screenWidth * 0.035,
                                                                color: stockQty > 0 ? Colors.red.shade700 : Colors.grey.shade500,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: isWeb ? 8 : screenWidth * 0.015),
                                                          // Increase stock button
                                                          GestureDetector(
                                                            onTap: () => _adjustStock(productId, name, 1),
                                                            child: Container(
                                                              width: isWeb ? 28 : screenWidth * 0.06,
                                                              height: isWeb ? 28 : screenWidth * 0.06,
                                                              decoration: BoxDecoration(
                                                                color: Colors.green.shade100,
                                                                borderRadius: BorderRadius.circular(isWeb ? 6 : screenWidth * 0.015),
                                                                border: Border.all(color: Colors.green.shade300),
                                                              ),
                                                              child: Icon(
                                                                Icons.add,
                                                                size: isWeb ? 16 : screenWidth * 0.035,
                                                                color: Colors.green.shade700,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),

                                            SizedBox(width: isWeb ? 12 : screenWidth * 0.015),

                                            // Edit and Stock Management buttons
                                            Column(
                                              children: [
                                                // Edit button
                                                Tooltip(
                                                  message: 'Edit',
                                                  child: Ink(
                                                    decoration: BoxDecoration(
                                                      color: primary.withOpacity(0.08),
                                                      borderRadius: BorderRadius.circular(isWeb ? 8 : screenWidth * 0.025),
                                                    ),
                                                    child: IconButton(
                                                      icon: Icon(Icons.edit,
                                                          color: primary,
                                                          size: isWeb ? 20 : screenWidth * 0.045),
                                                      splashRadius: isWeb ? 24 : screenWidth * 0.055,
                                                      onPressed: () {
                                                        Get.to(() => UpdateProducts(
                                                          productId: productId,
                                                          existingData: product.data() as Map<String, dynamic>,
                                                        ));
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: isWeb ? 4 : screenHeight * 0.005),
                                                Tooltip(
                                                  message: 'Manage Stock',
                                                  child: Ink(
                                                    decoration: BoxDecoration(
                                                      color: Colors.orange.shade100,
                                                      borderRadius: BorderRadius.circular(isWeb ? 8 : screenWidth * 0.025),
                                                    ),
                                                    child: IconButton(
                                                      icon: Icon(Icons.inventory,
                                                          color: Colors.orange.shade700,
                                                          size: isWeb ? 20 : screenWidth * 0.045),
                                                      splashRadius: isWeb ? 24 : screenWidth * 0.055,
                                                      onPressed: () => _showStockManagementDialog(context, productId, name, stockQty),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => AddProducts(productId: '', existingData: {})),
        backgroundColor: const Color(0xFF199A8E),
        tooltip: 'Add product',
        child: Icon(Icons.add,
            color: Colors.white,
            size: isWeb ? 28 : screenWidth * 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isWeb ? 12 : screenWidth * 0.035),
        ),
      ),
    );
  }

  void _adjustStock(String productId, String productName, int adjustment) async {
    // Get current stock first
    final docSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .get();

    if (docSnapshot.exists) {
      // Safe stock access - check if field exists first
      final docData = docSnapshot.data() as Map<String, dynamic>?;
      final currentStock =
          (docData != null && docData.containsKey('stockQuantity'))
              ? (docData['stockQuantity'] is int
                  ? docData['stockQuantity'] as int
                  : int.tryParse(docData['stockQuantity'].toString()) ?? 0)
              : docData != null && docData.containsKey('stock')
                  ? (docData['stock'] is int
                      ? docData['stock'] as int
                      : int.tryParse(docData['stock'].toString()) ?? 0)
                  : 0;

      final newStock = currentStock + adjustment;
      if (newStock >= 0) {
        // Use the StockController's updateProductStock method
        await stockController.updateProductStock(productId, newStock,
            reason: 'Quick adjustment from admin panel');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Stock ${adjustment > 0 ? 'increased' : 'decreased'} for $productName'),
              backgroundColor: adjustment > 0
                  ? Colors.green.shade600
                  : Colors.orange.shade600,
            ),
          );
        }
      }
    }
  }

  void _showStockManagementDialog(BuildContext context, String productId, String productName, int currentStock) {
    final TextEditingController stockController = TextEditingController();
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Manage Stock - $productName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Stock: $currentStock'),
            SizedBox(height: 16),
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'New Stock Quantity',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newStock = int.tryParse(stockController.text);
              if (newStock != null) {
                await this.stockController.updateProductStock(
                    productId,
                    newStock,
                    reason: reasonController.text.isEmpty
                        ? 'Manual stock update'
                        : reasonController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Stock updated for $productName')),
                );
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showLowStockAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
            SizedBox(width: 8),
            Text('Low Stock Alert'),
          ],
        ),
        content: Obx(() {
          final lowStockProducts = stockController.lowStockProducts;
          if (lowStockProducts == null || lowStockProducts.isEmpty) {
            return Text('No low stock products found.');
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: lowStockProducts.map((product) {
              if (product == null || product.name.isEmpty)
                return const SizedBox.shrink();
              return ListTile(
                title: Text(product.name),
                subtitle: Text('Stock: ${product.stock}'),
                trailing: Icon(Icons.warning, color: Colors.orange.shade700),
              );
            }).toList(),
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showStockHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Stock History'),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: Obx(() {
            final stockLogs = stockController.stockLogs;
            if (stockLogs.isEmpty) {
              return Center(child: Text('No stock history found.'));
            }
            return ListView.builder(
              itemCount: stockLogs.length,
              itemBuilder: (context, index) {
                final history = stockLogs[index];
                if (history == null ||
                    history.productName == null ||
                    history.productName.isEmpty) {
                  return const SizedBox.shrink();
                }
                return ListTile(
                  title: Text(history.productName),
                  subtitle: Text(
                      '${history.action ?? ""} - ${history.reason ?? 'No reason provided'}'),
                  trailing: Text(
                    '${history.previousStock ?? ''} → ${history.newStock ?? ''}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
