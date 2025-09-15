import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../models/cart_viewmodel.dart';
import '../cart/cartscreen.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

  const ProductDetailPage({
    Key? key,
    required this.productId,
    required this.productData,
  }) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int selectedImageIndex = 0;
  int quantity = 1;
  final CartViewModel cartVM = Get.put(CartViewModel());

  Widget _buildCleanText(String text, double screenWidth) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Text(
        text.trim(),
        style: TextStyle(
          fontSize: screenWidth * 0.042,
          color: Colors.grey[800],
          height: 1.6,
          letterSpacing: 0.3,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final name = widget.productData['name']?.toString() ?? 'Unknown Product';
    final brand = widget.productData['brand']?.toString() ?? '';
    final price = widget.productData['price']?.toDouble() ?? 0.0;
    final description = widget.productData['description']?.toString() ?? '';
    final ingredients = widget.productData['ingredients']?.toString() ?? '';
    final stockQuantity = widget.productData['stockQuantity']?.toInt() ?? 0;
    final imageUrls = List<String>.from(widget.productData['imageUrls'] ?? []);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[50]!, Colors.white],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // App Bar with images
            SliverAppBar(
              expandedHeight: screenHeight * 0.4,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              leading: Container(
                margin: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF199A8E)),
                  onPressed: () => Get.back(),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.grey[100]!, Colors.grey[50]!],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    child: imageUrls.isNotEmpty
                        ? PageView.builder(
                      itemCount: imageUrls.length,
                      onPageChanged: (index) {
                        setState(() {
                          selectedImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.all(screenWidth * 0.05),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              imageUrls[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: screenWidth * 0.2,
                                    color: Colors.grey[400],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    )
                        : Container(
                      margin: EdgeInsets.all(screenWidth * 0.05),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.image,
                        size: screenWidth * 0.2,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Product details
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.all(screenWidth * 0.05),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image indicators
                      if (imageUrls.length > 1)
                        Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenWidth * 0.02,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: imageUrls.asMap().entries.map((entry) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: selectedImageIndex == entry.key ? 24 : 8,
                                  height: 8,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: selectedImageIndex == entry.key
                                        ? const Color(0xFF199A8E)
                                        : Colors.grey[300],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                      SizedBox(height: screenHeight * 0.02),

                      // Product name and brand
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: screenWidth * 0.065,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                      ),

                      if (brand.isNotEmpty) ...[
                        SizedBox(height: screenHeight * 0.01),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenWidth * 0.015,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF199A8E).withOpacity(0.1),
                                const Color(0xFF199A8E).withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            brand,
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: const Color(0xFF199A8E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],

                      SizedBox(height: screenHeight * 0.025),

                      // Price and stock
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenWidth * 0.02,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF199A8E),
                                  const Color(0xFF17C3B2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF199A8E).withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              'Rs ${price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.01,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: stockQuantity > 5
                                    ? [Colors.green[100]!, Colors.green[50]!]
                                    : stockQuantity > 0
                                    ? [Colors.orange[100]!, Colors.orange[50]!]
                                    : [Colors.red[100]!, Colors.red[50]!],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: stockQuantity > 5
                                    ? Colors.green[200]!
                                    : stockQuantity > 0
                                    ? Colors.orange[200]!
                                    : Colors.red[200]!,
                              ),
                            ),
                            child: Text(
                              stockQuantity > 5
                                  ? 'In Stock ($stockQuantity available)'
                                  : stockQuantity > 0
                                  ? 'Low Stock ($stockQuantity left)'
                                  : 'Out of Stock',
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
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

                      SizedBox(height: screenHeight * 0.03),

                      // Quantity selector
                      if (stockQuantity > 0) ...[
                        Container(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.grey[50]!, Colors.white],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quantity',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: quantity > 1 ? const Color(0xFF199A8E) : Colors.grey[300],
                                      shape: BoxShape.circle,
                                      boxShadow: quantity > 1 ? [
                                        BoxShadow(
                                          color: const Color(0xFF199A8E).withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ] : null,
                                    ),
                                    child: IconButton(
                                      onPressed: quantity > 1 ? () {
                                        setState(() {
                                          quantity--;
                                        });
                                      } : null,
                                      icon: const Icon(Icons.remove),
                                      color: quantity > 1 ? Colors.white : Colors.grey[500],
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.04),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.06,
                                      vertical: screenHeight * 0.015,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: const Color(0xFF199A8E), width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      '$quantity',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.045,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF199A8E),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.04),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: quantity < stockQuantity ? const Color(0xFF199A8E) : Colors.grey[300],
                                      shape: BoxShape.circle,
                                      boxShadow: quantity < stockQuantity ? [
                                        BoxShadow(
                                          color: const Color(0xFF199A8E).withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ] : null,
                                    ),
                                    child: IconButton(
                                      onPressed: quantity < stockQuantity ? () {
                                        setState(() {
                                          quantity++;
                                        });
                                      } : null,
                                      icon: const Icon(Icons.add),
                                      color: quantity < stockQuantity ? Colors.white : Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                      ],

                      if (description.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF199A8E).withOpacity(0.08),
                                blurRadius: 15,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(screenWidth * 0.045),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF199A8E),
                                      const Color(0xFF17C3B2),
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.description_outlined,
                                      color: Colors.white,
                                      size: screenWidth * 0.055,
                                    ),
                                    SizedBox(width: screenWidth * 0.03),
                                    Text(
                                      'Product Description',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.048,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(screenWidth * 0.045),
                                child: _buildCleanText(description, screenWidth),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.025),
                      ],

                      if (ingredients.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF199A8E).withOpacity(0.08),
                                blurRadius: 15,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(screenWidth * 0.045),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF199A8E),
                                      const Color(0xFF17C3B2),
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.science_outlined,
                                      color: Colors.white,
                                      size: screenWidth * 0.055,
                                    ),
                                    SizedBox(width: screenWidth * 0.03),
                                    Text(
                                      'Ingredients & Composition',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.048,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(screenWidth * 0.045),
                                child: _buildCleanText(ingredients, screenWidth),
                              ),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: screenHeight * 0.1), // Space for bottom buttons
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: stockQuantity > 0 ? Container(
        padding: EdgeInsets.all(screenWidth * 0.05),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF199A8E).withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    final imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : '';
                    cartVM.addToCart(
                            widget.productId,
                            name,
                            imageUrl,
                            '${quantity} pcs',
                            price,
                            quantity,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF199A8E),
                    side: const BorderSide(color: Color(0xFF199A8E), width: 2),
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: screenWidth * 0.05),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF199A8E), Color(0xFF17C3B2)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF199A8E).withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    final imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : '';
                          cartVM.addToCart(
                            widget.productId,
                            name,
                            imageUrl,
                            '${quantity} pcs',
                            price,
                            quantity,
                          );
                          Get.to(() => CartScreen()); // Navigate to cart screen
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flash_on, size: screenWidth * 0.05),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        'Buy Now',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ) : null,
    );
  }
}
