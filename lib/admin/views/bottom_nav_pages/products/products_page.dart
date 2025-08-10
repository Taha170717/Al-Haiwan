import 'package:al_haiwan/admin/views/bottom_nav_pages/products/update_products.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_products.dart';

class AdminProducts extends StatefulWidget {
  const AdminProducts({super.key});

  @override
  State<AdminProducts> createState() => _AdminProductsState();
}

class _AdminProductsState extends State<AdminProducts> {
  String searchQuery = '';

  static const Color primary = Color(0xFF199A8E);

  TextStyle _nameStyleFor(String name) {
    final length = name.trim().length;
    double size;
    if (length <= 16) {
      size = 16;
    } else if (length <= 24) {
      size = 14;
    } else {
      size = 13;
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

  @override
  Widget build(BuildContext context) {
    final dividerColor = Colors.grey.shade300;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Products',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: primary,
              fontFamily: "bolditalic",
              letterSpacing: 0.3,
            ),
          ),
        ),
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Search bar (UI polish only)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
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
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchQuery.isEmpty
                      ? null
                      : IconButton(
                    tooltip: 'Clear',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() => searchQuery = '');
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: primary, width: 1.4),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),

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

                final products = snapshot.data!.docs.where((doc) {
                  final name = (doc['name'] ?? '').toString().toLowerCase();
                  final brand = (doc['brand'] ?? '').toString().toLowerCase();
                  return name.contains(searchQuery) || brand.contains(searchQuery);
                }).toList();

                if (products.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.inventory_2_outlined, color: primary, size: 46),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            "No products found",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.grey.shade900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Try a different search or add a new product.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () {
                              Get.to(() => AddProducts(productId: '', existingData: {}));
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Product'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primary,
                              side: const BorderSide(color: primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Showing ${products.length} item${products.length == 1 ? '' : 's'}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        itemCount: products.length,
                        physics: const BouncingScrollPhysics(),
                        cacheExtent: 800,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final productId = product.id;

                          final name = (product['name'] ?? '').toString();
                          final brand = (product['brand'] ?? '').toString();
                          final num rawPrice = product['price'] ?? 0;
                          final double price = rawPrice.toDouble();
                          final int stockQty = (product['stockQuantity'] ?? 0) is int
                              ? (product['stockQuantity'] ?? 0) as int
                              : int.tryParse((product['stockQuantity'] ?? '0').toString()) ?? 0;

                          final imageUrls = product.data() is Map<String, dynamic>
                              ? (product['imageUrls'] as List<dynamic>?)
                              : null;

                          final String imageUrl = (imageUrls != null && imageUrls.isNotEmpty)
                              ? imageUrls.first.toString()
                              : 'https://via.placeholder.com/150';

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
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: const [
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.delete, color: Colors.white),
                                ],
                              ),
                            ),
                            confirmDismiss: (_) async {
                              final res = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  title: const Text('Delete product?'),
                                  content: Text('Are you sure you want to delete "$name"?'),
                                  actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.red.shade600,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('Delete'),
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
                                borderRadius: BorderRadius.circular(16),
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
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(color: dividerColor),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // Image
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: SizedBox(
                                            width: 58,
                                            height: 58,
                                            child: Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              filterQuality: FilterQuality.low,
                                              cacheWidth: 232,
                                              cacheHeight: 232,
                                              gaplessPlayback: true,
                                              loadingBuilder: (context, child, progress) {
                                                if (progress == null) return child;
                                                return Container(
                                                  color: Colors.grey.shade200,
                                                  child: const Center(
                                                    child: SizedBox(
                                                      width: 18,
                                                      height: 18,
                                                      child: CircularProgressIndicator(strokeWidth: 2),
                                                    ),
                                                  ),
                                                );
                                              },
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey.shade200,
                                                  child: const Icon(Icons.broken_image, color: Colors.grey),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),

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
                                              const SizedBox(height: 6),

                                              // Brand chip + Price badge
                                              Row(
                                                children: [
                                                  // Brand tag
                                                  if (brand.isNotEmpty)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: primary.withOpacity(0.08),
                                                        borderRadius: BorderRadius.circular(8),
                                                        border: Border.all(color: primary.withOpacity(0.2)),
                                                      ),
                                                      child: Text(
                                                        brand,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 11.5,
                                                          fontWeight: FontWeight.w700,
                                                          color: primary,
                                                        ),
                                                      ),
                                                    ),
                                                  const SizedBox(width: 8),

                                                  // Price pill
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      gradient: const LinearGradient(
                                                        colors: [primary, Color(0xFF147E75)],
                                                      ),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      'Rs ${price.toStringAsFixed(2)}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11.5,
                                                        fontWeight: FontWeight.w800,
                                                        letterSpacing: 0.2,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),

                                              // Stock badge
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: _stockColor(stockQty).withOpacity(0.12),
                                                      borderRadius: BorderRadius.circular(8),
                                                      border: Border.all(color: _stockColor(stockQty).withOpacity(0.3)),
                                                    ),
                                                    child: Text(
                                                      '${_stockLabel(stockQty)} • $stockQty',
                                                      style: TextStyle(
                                                        fontSize: 11.5,
                                                        fontWeight: FontWeight.w700,
                                                        color: _stockColor(stockQty),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(width: 8),

                                        // Edit button
                                        Tooltip(
                                          message: 'Edit',
                                          child: Ink(
                                            decoration: BoxDecoration(
                                              color: primary.withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: IconButton(
                                              icon: const Icon(Icons.edit, color: primary),
                                              splashRadius: 22,
                                              onPressed: () {
                                                Get.to(() => UpdateProducts(
                                                  productId: productId,
                                                  existingData: product.data() as Map<String, dynamic>,
                                                ));
                                              },
                                            ),
                                          ),
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
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(() => AddProducts(productId: '', existingData: {}));
        },
        backgroundColor: primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}