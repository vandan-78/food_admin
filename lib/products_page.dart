import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'add_product_form.dart';
import 'core/app_colors.dart';
import 'core/text_styles.dart';
import 'model/product_model.dart';

class ProductsManagementScreen extends StatefulWidget {
  const ProductsManagementScreen({super.key});

  @override
  State<ProductsManagementScreen> createState() => _ProductsManagementScreenState();
}

class _ProductsManagementScreenState extends State<ProductsManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> products = [];
  final List<AddProductRequest> _products = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final productsSnapshot = await _firestore.collection('products').get();
      setState(() {
        products = productsSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['title'] ?? 'No Name',
            'brand': data['brand'] ?? 'No Brand',
            'price': data['price']?.toDouble() ?? 0.0,
            'category': data['category'] ?? 'No Category',
            'image': data['thumbnail'] ?? '',
            'availabilityStatus': data['availabilityStatus'] ?? 'Unknown',
            'description': data['description'] ?? 'No Description',
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }


  void _addProduct(AddProductRequest product) {
    setState(() {
      _products.add(product);
    });
    // Here you would typically send the product to your backend API
    print('Product added: ${product.title}');
    print('Product data: ${product.toJson()}');
  }

  void _navigateToAddProduct() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddProductForm(
          onProductAdded: _loadProducts, // Just refresh the list
        ),
      ),
    );
  }

  Future<void> _deleteProduct(String productId, String productName) async {
    // Show confirmation dialog
    bool? shouldDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "$productName"? This action will also remove it from all users\' favorites and cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // Step 1: Remove from all users' favorites
        await _removeFromAllUsersFavorites(productId);

        // Step 2: Remove from all users' cart
        await _removeFromAllUsersCart(productId);

        // Step 3: Delete from products collection
        await _firestore.collection('products').doc(productId).delete();

        // Step 4: Remove from local state
        setState(() {
          products.removeWhere((product) => product['id'] == productId);
        });

        // Close loading dialog
        if (mounted) Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"$productName" deleted successfully from all locations'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } catch (e) {
        // Close loading dialog
        if (mounted) Navigator.pop(context);

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete product: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

// Remove product from all users' favorites
  Future<void> _removeFromAllUsersFavorites(String productId) async {
    try {
      // Get all users
      final usersSnapshot = await _firestore.collection('users').get();

      // Create a batch for batch operations
      final batch = _firestore.batch();

      for (final userDoc in usersSnapshot.docs) {
        final userRef = _firestore.collection('users').doc(userDoc.id);

        // Update the favorites array by removing the productId
        batch.update(userRef, {
          'favorites': FieldValue.arrayRemove([productId])
        });
      }

      // Commit the batch
      await batch.commit();

      debugPrint('✅ Removed product $productId from all users favorites');
    } catch (e) {
      debugPrint('❌ Error removing from favorites: $e');
      throw Exception('Failed to remove from users favorites: $e');
    }
  }

// Remove product from all users' cart
  Future<void> _removeFromAllUsersCart(String productId) async {
    try {
      // Get all users
      final usersSnapshot = await _firestore.collection('users').get();

      // Create a batch for batch operations
      final batch = _firestore.batch();
      int cartItemsRemoved = 0;

      for (final userDoc in usersSnapshot.docs) {
        final cartItemRef = _firestore
            .collection('users')
            .doc(userDoc.id)
            .collection('cart')
            .doc(productId);

        // Delete the cart item if it exists
        batch.delete(cartItemRef);
        cartItemsRemoved++;
      }

      // Commit the batch
      await batch.commit();

      debugPrint('✅ Removed product $productId from $cartItemsRemoved users cart');
    } catch (e) {
      debugPrint('❌ Error removing from cart: $e');
      throw Exception('Failed to remove from users cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Products Management',
                    style: TextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your food menu and inventory',
                    style: TextStyles.bodyMedium.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Product'),
                onPressed: _navigateToAddProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Statistics
          _buildProductStats(),
          const SizedBox(height: 24),

          // Products Grid
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : products.isEmpty
                ? _buildEmptyState()
                : _buildProductsGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductStats() {
    final inStockCount = products.where((p) => p['availabilityStatus'] == 'In Stock').length;
    final outOfStockCount = products.length - inStockCount;

    return Row(
      children: [
        _buildStatItem('Total Products', products.length.toString(), Icons.inventory_2_rounded),
        const SizedBox(width: 16),
        _buildStatItem('In Stock', inStockCount.toString(), Icons.check_circle_rounded, Colors.green),
        const SizedBox(width: 16),
        _buildStatItem('Out of Stock', outOfStockCount.toString(), Icons.error_outline_rounded, Colors.red),
      ],
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, [Color? color]) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (color ?? AppColors.orange).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color ?? AppColors.orange, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  title,
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6, // Changed from 6 to 3 for better mobile view
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final isInStock = product['availabilityStatus'] == 'In Stock';
    final productName = product['name'] ?? product['brand'] ?? 'Unknown Product';

    return Stack(
      children: [
        Card(
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                height: 220, // Slightly reduced height
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  image: product['image'] != null && product['image'].isNotEmpty
                      ? DecorationImage(
                    image: CachedNetworkImageProvider(product['image']),
                    fit: BoxFit.cover,
                  )
                      : null,
                  color: product['image'] == null || product['image'].isEmpty
                      ? AppColors.gray100
                      : null,
                ),
                child: product['image'] == null || product['image'].isEmpty
                    ? Center(
                  child: Icon(
                    Icons.fastfood_rounded,
                    size: 40,
                    color: AppColors.gray400,
                  ),
                )
                    : null,
              ),

              // Product Details
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: TextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['category'] ?? 'No Category',
                      style: TextStyles.bodySmall.copyWith(
                        color: AppColors.gray600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${product['price'].toStringAsFixed(2)}',
                          style: TextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.orange,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isInStock ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isInStock ? 'In Stock' : 'Out of Stock',
                            style: TextStyles.labelSmall.copyWith(
                              color: isInStock ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Delete Button
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => _deleteProduct(product['id'], productName),
            child: Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.delete_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.gray400),
          const SizedBox(height: 16),
          Text(
            'No Products Found',
            style: TextStyles.titleLarge.copyWith(
              color: AppColors.gray500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add products to manage your menu',
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.gray400,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add First Product'),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}