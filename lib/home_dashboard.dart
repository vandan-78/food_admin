import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'core/app_colors.dart';
import 'core/text_styles.dart';

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          _buildWelcomeHeader(),
          const SizedBox(height: 24),

          // Statistics Grid
          _buildStatisticsGrid(),
          const SizedBox(height: 32),

          // Recent Activity Section
          _buildRecentActivitySection(),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        final userCount = snapshot.data?.size ?? 0;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF4776E6), // Bright Blue
                Color(0xFF8E54E9), // PurpleTeal
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back, Admin!',
                      style: TextStyles.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You have $userCount registered users and growing fast. Manage your food delivery business efficiently.',
                      style: TextStyles.bodyLarge.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Today: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        style: TextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.restaurant_menu_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatisticsGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, usersSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, productsSnapshot) {
            final userCount = usersSnapshot.data?.size ?? 0;
            final productCount = productsSnapshot.data?.size ?? 0;
            final inStockCount = _getInStockCount(productsSnapshot.data);
            final totalRevenue = _calculateTotalRevenue(productsSnapshot.data);

            return GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.6,
              children: [
                _buildStatCard(
                  title: 'Total Users',
                  value: userCount.toString(),
                  subtitle: 'Registered customers',
                  icon: Icons.people_alt_rounded,
                  gradient:  LinearGradient(
                    colors: [Colors.redAccent, Colors.red], // Royal Purple
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                _buildStatCard(
                  title: 'Total Products',
                  value: productCount.toString(),
                  subtitle: 'Menu items',
                  icon: Icons.restaurant_menu_rounded,
                  gradient:  LinearGradient(
                    colors: [Colors.green.shade600, Colors.teal], // Deep Ocean
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                _buildStatCard(
                  title: 'In Stock',
                  value: inStockCount.toString(),
                  subtitle: 'Available items',
                  icon: Icons.inventory_2_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)], // Fresh Blue
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                _buildStatCard(
                  title: 'Total Revenue',
                  value: '₹${totalRevenue.toStringAsFixed(0)}',
                  subtitle: 'Total sales',
                  icon: Icons.attach_money_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD200), Color(0xFFF7971E)], // Golden Yellow
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Live',
                    style: TextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyles.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _buildRecentUsersCard(),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildQuickStatsCard(),
                  const SizedBox(height: 20),
                  _buildPopularProductsCard(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentUsersCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people_alt_rounded, color: AppColors.orange, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Recent Users',
                  style: TextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  'View All',
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .orderBy('createdAt', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }
                if (snapshot.hasError) {
                  return _buildErrorState('Failed to load users');
                }

                final users = snapshot.data?.docs ?? [];

                if (users.isEmpty) {
                  return _buildEmptyState(
                    'No users found',
                    Icons.people_outline_rounded,
                    'Users will appear here once registered',
                  );
                }

                return Column(
                  children: users.map((userDoc) {
                    final user = userDoc.data() as Map<String, dynamic>;
                    return _buildUserListItem(user);
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics_rounded, color: AppColors.orange, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Quick Stats',
                  style: TextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                final totalProducts = snapshot.data?.size ?? 0;
                final outOfStock = _getOutOfStockCount(snapshot.data);
                final averagePrice = _getAveragePrice(snapshot.data);

                return Column(
                  children: [
                    _buildQuickStatItem('Total Products', totalProducts.toString(), Icons.inventory_2_rounded),
                    _buildQuickStatItem('Out of Stock', outOfStock.toString(), Icons.error_outline_rounded),
                    _buildQuickStatItem('Avg Price', '₹${averagePrice.toStringAsFixed(0)}', Icons.attach_money_rounded),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatItem(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.orange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.gray600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularProductsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up_rounded, color: AppColors.orange, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Popular Products',
                  style: TextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .limit(3)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }

                final products = snapshot.data?.docs ?? [];

                if (products.isEmpty) {
                  return _buildEmptyState(
                    'No products',
                    Icons.shopping_bag_outlined,
                    'Add products to see them here',
                  );
                }

                return Column(
                  children: products.map((productDoc) {
                    final product = productDoc.data() as Map<String, dynamic>;
                    return _buildProductListItem(product);
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.person_rounded, color: AppColors.orange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['username']?.toString().isNotEmpty == true
                      ? user['username']!
                      : 'Unknown User',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user['email']?.toString().isNotEmpty == true
                      ? user['email']!
                      : 'No email',
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.gray600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            _formatDate(user['createdAt']),
            style: TextStyles.labelSmall.copyWith(
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductListItem(Map<String, dynamic> product) {
    final productName = product['name'] ?? product['brand'] ?? 'Unknown Product';
    final productPrice = product['price']?.toDouble() ?? 0.0;
    final inStock = product['availabilityStatus'] == 'In Stock';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.fastfood_rounded, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${productPrice.toStringAsFixed(2)}',
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: inStock ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              inStock ? 'In Stock' : 'Out of Stock',
              style: TextStyles.labelSmall.copyWith(
                color: inStock ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.orange),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
          const SizedBox(height: 16),
          Text(
            error,
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, IconData icon, String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.gray400, size: 48),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.gray500,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyles.bodySmall.copyWith(
              color: AppColors.gray400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods
  int _getInStockCount(QuerySnapshot? snapshot) {
    if (snapshot == null) return 0;
    return snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['availabilityStatus'] == 'In Stock';
    }).length;
  }

  int _getOutOfStockCount(QuerySnapshot? snapshot) {
    if (snapshot == null) return 0;
    return snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['availabilityStatus'] != 'In Stock';
    }).length;
  }

  double _calculateTotalRevenue(QuerySnapshot? snapshot) {
    if (snapshot == null) return 0;
    return snapshot.docs.fold<double>(0, (sum, doc) {
      final data = doc.data() as Map<String, dynamic>;
      return sum + (data['price'] ?? 0).toDouble();
    });
  }

  double _getAveragePrice(QuerySnapshot? snapshot) {
    if (snapshot == null || snapshot.docs.isEmpty) return 0;
    final total = _calculateTotalRevenue(snapshot);
    return total / snapshot.docs.length;
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';

    try {
      if (date is Timestamp) {
        final dateTime = date.toDate();
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
      if (date is String) {
        return date.length > 10 ? date.substring(0, 10) : date;
      }
      return date.toString();
    } catch (e) {
      return 'Invalid Date';
    }
  }
}