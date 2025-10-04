import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'core/app_colors.dart';
import 'core/text_styles.dart';

class OrdersManagementScreen extends StatefulWidget {
  const OrdersManagementScreen({super.key});

  @override
  State<OrdersManagementScreen> createState() => _OrdersManagementScreenState();
}

class _OrdersManagementScreenState extends State<OrdersManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      List<Map<String, dynamic>> allOrders = [];

      final usersSnapshot = await _firestore.collection('users').get();

      for (final userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();
        final cartSnapshot = await _firestore
            .collection('users')
            .doc(userDoc.id)
            .collection('cart')
            .get();

        for (final cartDoc in cartSnapshot.docs) {
          final cartData = cartDoc.data();
          final productId = cartData['productId'];

          if (productId != null) {
            final productDoc = await _firestore
                .collection('products')
                .doc(productId.toString())
                .get();

            if (productDoc.exists) {
              final productData = productDoc.data()!;
              allOrders.add({
                'orderId': '${userDoc.id}_${cartDoc.id}',
                'userId': userDoc.id,
                'username': userData['username'] ?? 'Unknown User',
                'email': userData['email'] ?? 'No Email',
                'productId': productId,
                'productName': productData['title'] ?? productData['brand'] ?? 'Unknown Product',
                'productImage': productData['thumbnail'] ?? '',
                'productPrice': productData['price']?.toDouble() ?? 0.0,
                'quantity': cartData['quantity'] ?? 1,
                'addedAt': cartData['addedAt'] ?? 'Unknown Date',
                'status': 'Pending', // You can add status field
              });
            }
          }
        }
      }

      setState(() {
        orders = allOrders;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Orders Management',
            style: TextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage all customer orders and cart items',
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: 24),

          // Statistics
          _buildOrderStats(),
          const SizedBox(height: 24),

          // Orders List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : orders.isEmpty
                ? _buildEmptyState()
                : _buildOrdersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStats() {
    final pendingCount = orders.where((order) => order['status'] == 'Pending').length;
    final totalValue = orders.fold<double>(0, (sum, order) {
      return sum + (order['productPrice'] * order['quantity']);
    });

    return Row(
      children: [
        _buildStatItem('Total Orders', orders.length.toString(), Icons.shopping_cart_rounded),
        const SizedBox(width: 16),
        _buildStatItem('Pending', pendingCount.toString(), Icons.pending_actions_rounded, Colors.orange),
        const SizedBox(width: 16),
        _buildStatItem('Total Value', '₹${totalValue.toStringAsFixed(0)}', Icons.attach_money_rounded, Colors.green),
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

  Widget _buildOrdersList() {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final totalPrice = order['productPrice'] * order['quantity'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: order['productImage'] != null && order['productImage'].isNotEmpty
                    ? DecorationImage(
                  image: CachedNetworkImageProvider(order['productImage']),
                  fit: BoxFit.cover,
                )
                    : null,
                color: order['productImage'] == null || order['productImage'].isEmpty
                    ? AppColors.gray100
                    : null,
              ),
              child: order['productImage'] == null || order['productImage'].isEmpty
                  ? Icon(Icons.fastfood_rounded, color: AppColors.gray400)
                  : null,
            ),
            const SizedBox(width: 16),

            // Order Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order['productName'],
                    style: TextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'By: ${order['username']}',
                    style: TextStyles.bodySmall.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Qty: ${order['quantity']}',
                        style: TextStyles.bodySmall.copyWith(
                          color: AppColors.gray600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '₹${totalPrice.toStringAsFixed(2)}',
                        style: TextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status and Actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order['status'],
                    style: TextStyles.labelSmall.copyWith(
                      color: _getStatusColor(order['status']),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(order['addedAt']),
                  style: TextStyles.labelSmall.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.gray600;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.gray400),
          const SizedBox(height: 16),
          Text(
            'No Orders Found',
            style: TextStyles.titleLarge.copyWith(
              color: AppColors.gray500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Orders will appear here when customers add items to cart',
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.gray400,
            ),
            textAlign: TextAlign.center,
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