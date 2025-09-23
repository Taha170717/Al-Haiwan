import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../../models/cart_viewmodel.dart';
import '../cart/cartscreen.dart';
import 'product_detail_page.dart'; // Import ProductDetailPage

class CategoryProductsPage extends StatefulWidget {
  final String categoryName;

  const CategoryProductsPage({Key? key, required this.categoryName}) : super(key: key);

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late final CartViewModel cartVM;

  @override
  void initState() {
    super.initState();
    cartVM = Get.find<CartViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF199A8E)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.categoryName,
          style: TextStyle(
            color: const Color(0xFF199A8E),
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight * 0.06),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.008,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xFF199A8E).withOpacity(0.3)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF199A8E)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.012,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Obx(() => cartVM.itemCount > 0 ? FloatingActionButton(
        onPressed: () => Get.to(() => CartScreen()),
        backgroundColor: const Color(0xFF199A8E),
        child: Stack(
          children: [
            const Icon(Icons.shopping_cart, color: Colors.white),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '${cartVM.itemCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ) : const SizedBox.shrink()),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('category', isEqualTo: widget.categoryName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF199A8E)),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: screenWidth * 0.15,
                    color: Colors.red[300],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Error loading products',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      color: Colors.red[300],
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: screenWidth * 0.2,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'No products found in ${widget.categoryName}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Filter products based on search query
          final filteredDocs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = data['name']?.toString().toLowerCase() ?? '';
            final brand = data['brand']?.toString().toLowerCase() ?? '';
            return searchQuery.isEmpty ||
                name.contains(searchQuery) ||
                brand.contains(searchQuery);
          }).toList();

          if (filteredDocs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: screenWidth * 0.15,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'No products match your search',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.all(screenWidth * 0.03),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: screenWidth * 0.03,
                mainAxisSpacing: screenHeight * 0.015,
                childAspectRatio: 0.8,
              ),
              itemCount: filteredDocs.length,
              itemBuilder: (context, index) {
                final doc = filteredDocs[index];
                final data = doc.data() as Map<String, dynamic>;
                return _buildProductCard(data, screenWidth, screenHeight, doc.id);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> data, double screenWidth, double screenHeight, String productId) {
    final name = data['name']?.toString() ?? 'Unknown Product';
    final brand = data['brand']?.toString() ?? '';
    final price = data['price']?.toDouble() ?? 0.0;
    final stockQuantity = data['stockQuantity']?.toInt() ?? 0;
    final imageUrls = List<String>.from(data['imageUrls'] ?? []);
    final imageUrl = imageUrls.isNotEmpty ? imageUrls.first : '';

    return GestureDetector(
      onTap: () => Get.to(() => ProductDetailPage(productId: productId, productData: data)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.grey[100]!, Colors.grey[50]!],
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF199A8E)),
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.grey[200]!, Colors.grey[100]!],
                              ),
                            ),
                            child: Icon(
                              Icons.image_not_supported,
                              size: screenWidth * 0.12,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      )
                          : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.grey[200]!, Colors.grey[100]!],
                          ),
                        ),
                        child: Icon(
                          Icons.image,
                          size: screenWidth * 0.12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _showProductBottomSheet(context, data, productId),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_shopping_cart,
                          color: Color(0xFF199A8E),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.025),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: screenWidth * 0.032,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    if (brand.isNotEmpty) ...[
                      SizedBox(height: screenHeight * 0.002),
                      Flexible(
                        child: Text(
                          brand,
                          style: TextStyle(
                            fontSize: screenWidth * 0.028,
                            color: const Color(0xFF199A8E),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],

                    const Spacer(),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\Rs-${price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF199A8E),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.002),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.015,
                            vertical: screenHeight * 0.002,
                          ),
                          decoration: BoxDecoration(
                            color: stockQuantity > 5
                                ? Colors.green[100]
                                : stockQuantity > 0
                                ? Colors.orange[100]
                                : Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            stockQuantity > 5
                                ? 'In Stock'
                                : stockQuantity > 0
                                ? 'Low Stock'
                                : 'Out of Stock',
                            style: TextStyle(
                              fontSize: screenWidth * 0.022,
                              fontWeight: FontWeight.w600,
                              color: stockQuantity > 5
                                  ? Colors.green[700]
                                  : stockQuantity > 0
                                  ? Colors.orange[700]
                                  : Colors.red[700],
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
  }

  void _showProductBottomSheet(BuildContext context, Map<String, dynamic> data, String productId) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: screenHeight * 0.3,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: screenHeight * 0.015),
              width: screenWidth * 0.12,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: screenWidth * 0.2,
                          height: screenWidth * 0.1,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey[100],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: data['imageUrls'] != null && (data['imageUrls'] as List).isNotEmpty
                                ? Image.network(
                              (data['imageUrls'] as List).first,
                              fit: BoxFit.cover,
                            )
                                : Icon(Icons.image, color: Colors.grey[400]),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['name'] ?? 'Unknown Product',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: screenHeight * 0.005),
                              Text(
                                '\Rs-${(data['price']?.toDouble() ?? 0.0).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color: const Color(0xFF199A8E),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final imageUrls = data['imageUrls'] as List<dynamic>? ?? [];
                              final imageUrl = imageUrls.isNotEmpty ? imageUrls.first.toString() : '';

                              await cartVM.addToCart(
                                productId,
                                data['name']?.toString() ?? 'Unknown Product',
                                imageUrl,
                                '1 unit',
                                data['price']?.toDouble() ?? 0.0,
                                1,
                              );

                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF199A8E),
                              side: const BorderSide(color: Color(0xFF199A8E)),
                              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              'Add to Cart',
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final imageUrls = data['imageUrls'] as List<dynamic>? ?? [];
                              final imageUrl = imageUrls.isNotEmpty ? imageUrls.first.toString() : '';

                              await cartVM.addToCart(
                                productId,
                                data['name']?.toString() ?? 'Unknown Product',
                                imageUrl,
                                '1 unit',
                                data['price']?.toDouble() ?? 0.0,
                                1,
                              );

                              Navigator.pop(context);
                              Get.to(() => CartScreen());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF199A8E),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              'Buy Now',
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                              ),
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
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
