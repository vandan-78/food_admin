import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'core/app_colors.dart';
import 'core/text_styles.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      setState(() {
        users = usersSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'username': data['username'] ?? 'No Name',
            'email': data['email'] ?? 'No Email',
            'createdAt': data['createdAt'] ?? 'Unknown Date',
            'uid': data['uid'] ?? doc.id,
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

  Future<void> _viewUserCart(String userId, String userName) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$userName\'s Cart'),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<QuerySnapshot>(
            future: _firestore
                .collection('users')
                .doc(userId)
                .collection('cart')
                .get(),
            builder: (context, cartSnapshot) {
              if (cartSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final cartItems = cartSnapshot.data?.docs ?? [];

              if (cartItems.isEmpty) {
                return const Center(child: Text('No items in cart'));
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final cartItem = cartItems[index].data() as Map<String, dynamic>;
                  return FutureBuilder<DocumentSnapshot>(
                    future: _firestore
                        .collection('products')
                        .doc(cartItem['productId'].toString())
                        .get(),
                    builder: (context, productSnapshot) {
                      if (productSnapshot.connectionState == ConnectionState.waiting) {
                        return const ListTile(
                          title: Text('Loading...'),
                        );
                      }

                      if (!productSnapshot.hasData || !productSnapshot.data!.exists) {
                        return ListTile(
                          title: Text('Product ID: ${cartItem['productId']}'),
                          subtitle: const Text('Product not found'),
                        );
                      }

                      final productData = productSnapshot.data!.data() as Map<String, dynamic>;
                      final productName = productData['title'] ?? productData['brand'] ?? 'Unknown Product';
                      final productPrice = productData['price']?.toDouble() ?? 0.0;
                      final productImage = productData['thumbnail'] ?? '';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: productImage.isNotEmpty
                              ? CachedNetworkImage(
                            imageUrl: productImage,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 50,
                              height: 50,
                              color: AppColors.gray200,
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.fastfood_rounded,
                              color: AppColors.gray400,
                            ),
                          )
                              : Icon(Icons.fastfood_rounded, color: AppColors.gray400),
                          title: Text(productName),
                          subtitle: Text('Quantity: ${cartItem['quantity'] ?? 1}'),
                          trailing: Text(
                            '₹${productPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.orange,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Users Management',
            style: TextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage all registered users and their cart items',
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: 24),

          // Statistics
          _buildUserStats(),
          const SizedBox(height: 24),

          // Users List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : users.isEmpty
                ? _buildEmptyState()
                : _buildUsersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStats() {
    return Row(
      children: [
        _buildStatItem('Total Users', users.length.toString(), Icons.people_alt_rounded),
        const SizedBox(width: 16),
        _buildStatItem('Active Today', '0', Icons.today_rounded),
        const SizedBox(width: 16),
        _buildStatItem('New This Week', '0', Icons.trending_up_rounded),
      ],
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
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
                color: AppColors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.orange, size: 20),
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

  Widget _buildUsersList() {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.orange.withOpacity(0.1),
              child: Icon(Icons.person_rounded, color: AppColors.orange),
            ),
            title: Text(
              user['username'],
              style: TextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['email']),
                Text(
                  'Joined: ${_formatDate(user['createdAt'])}',
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.shopping_cart_rounded, color: AppColors.orange),
              onPressed: () => _viewUserCart(user['id'], user['username']),
              tooltip: 'View Cart',
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 64, color: AppColors.gray400),
          const SizedBox(height: 16),
          Text(
            'No Users Found',
            style: TextStyles.titleLarge.copyWith(
              color: AppColors.gray500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Users will appear here once they register',
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.gray400,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';
    try {
      if (date is Timestamp) {
        final dateTime = date.toDate();
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
      return date.toString();
    } catch (e) {
      return 'Invalid Date';
    }
  }
}