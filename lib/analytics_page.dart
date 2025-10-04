// analytics_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'core/app_colors.dart';
import 'core/text_styles.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics & Reports',
            style: TextStyles.headlineSmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Product analytics based on public data',
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, productsSnapshot) {
                final products = productsSnapshot.data?.docs ?? [];

                // Calculate analytics from public product data only
                final totalProducts = products.length;
                final inStockProducts = products.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['availabilityStatus'] == 'In Stock';
                }).length;

                final totalRevenue = products.fold<double>(0, (sum, doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return sum + (data['price'] ?? 0).toDouble();
                });

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Product Analytics Cards
                      Row(
                        children: [
                          _buildAnalyticsCard(
                            'Total Products',
                            totalProducts,
                            Icons.shopping_bag,
                            AppColors.successGradient,
                          ),
                          const SizedBox(width: 16),
                          _buildAnalyticsCard(
                            'In Stock',
                            inStockProducts,
                            Icons.inventory,
                            AppColors.errorGradient2,
                          ),
                          const SizedBox(width: 16),
                          _buildAnalyticsCard(
                            'Out of Stock',
                            totalProducts - inStockProducts,
                            Icons.warning,
                            LinearGradient(
                              colors: [Colors.orange.shade600, Colors.orange.shade400],
                            ),
                          ),
                          const SizedBox(width: 16),
                          _buildAnalyticsCard(
                            'Avg Price',
                            '₹${totalProducts > 0 ? (totalRevenue / totalProducts).round() : 0}',
                            Icons.attach_money,
                            LinearGradient(
                              colors: [AppColors.purple, AppColors.indigo],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Category Distribution
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Products by Category',
                                style: TextStyles.titleMedium.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildCategoryChart(products),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Stock Status
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stock Status Overview',
                                style: TextStyles.titleMedium.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildStockStatus(products),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Admin Notice
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.orange.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.orange.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: AppColors.orange),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Limited Analytics View',
                                    style: TextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.orange,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'User analytics are restricted to maintain privacy. '
                                        'Only product data is available for viewing.',
                                    style: TextStyles.bodySmall.copyWith(
                                      color: AppColors.gray600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _calculateTotalFavorites(List<QueryDocumentSnapshot> users) {
    int total = 0;
    for (final user in users) {
      final data = user.data() as Map<String, dynamic>;
      final favorites = List<String>.from(data['favorites'] ?? []);
      total += favorites.length;
    }
    return total;
  }

  Future<int> _calculateTotalCartItems(List<QueryDocumentSnapshot> users) async {
    int total = 0;
    for (final user in users) {
      final userId = user.id;
      try {
        final cartSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('cart')
            .get();
        total += cartSnapshot.docs.length;
      } catch (e) {
        // If cart collection doesn't exist for this user, continue
        continue;
      }
    }
    return total;
  }

  Widget _buildAnalyticsCard(String title, dynamic value, IconData icon, Gradient gradient) {
    return Expanded(
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value.toString(),
                    style: TextStyles.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyles.bodySmall.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChart(List<QueryDocumentSnapshot> products) {
    final categoryCount = <String, int>{};
    for (final product in products) {
      final data = product.data() as Map<String, dynamic>;
      final category = data['category'] ?? 'Uncategorized';
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }

    return Column(
      children: categoryCount.entries.map((entry) {
        final percentage = products.isNotEmpty ? (entry.value / products.length * 100).round() : 0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  entry.key,
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: LinearProgressIndicator(
                  value: products.isNotEmpty ? entry.value / products.length : 0,
                  backgroundColor: AppColors.gray300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getColorForCategory(entry.key),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '$percentage%',
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.gray600,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '(${entry.value})',
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.gray500,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStockStatus(List<QueryDocumentSnapshot> products) {
    final inStock = products.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['availabilityStatus'] == 'In Stock';
    }).length;

    final outOfStock = products.length - inStock;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '$inStock',
                  style: TextStyles.headlineMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'In Stock',
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '$outOfStock',
                  style: TextStyles.headlineMedium.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Out of Stock',
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getColorForCategory(String category) {
    final colors = <String, Color>{
      'Burger': AppColors.orange,
      'Pizza': Colors.red,
      'Drinks': Colors.blue,
      'Desserts': AppColors.purple,
      'Snacks': Colors.green,
    };
    return colors[category] ?? AppColors.gray500;
  }
}