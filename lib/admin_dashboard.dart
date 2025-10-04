import 'package:flutter/material.dart';
import 'package:food_admin_app/admin_login.dart';
import 'package:food_admin_app/products_page.dart';
import 'package:food_admin_app/service/auth_service.dart';
import 'package:food_admin_app/user_page.dart';
import 'core/app_colors.dart';
import 'core/text_styles.dart';
import 'home_dashboard.dart';
import 'order_screen.dart';

class MainAdminDashboard extends StatefulWidget {
  const MainAdminDashboard({super.key});

  @override
  State<MainAdminDashboard> createState() => _MainAdminDashboardState();
}

class _MainAdminDashboardState extends State<MainAdminDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardHome(),
    const UsersManagementScreen(),
    const ProductsManagementScreen(),
    const OrdersManagementScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
        title: Text(
          _getAppBarTitle(),
          style: TextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      drawer: _buildDrawer(),
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          Container(
            height: 180,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Icon(
                    Icons.restaurant_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Food Delivery',
                  style: TextStyles.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Admin Panel',
                  style: TextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          _buildDrawerItem(
            icon: Icons.dashboard_rounded,
            title: 'Dashboard',
            isSelected: _currentIndex == 0,
            onTap: () => _navigateToPage(0),
          ),
          _buildDrawerItem(
            icon: Icons.people_alt_rounded,
            title: 'Users Management',
            isSelected: _currentIndex == 1,
            onTap: () => _navigateToPage(1),
          ),
          _buildDrawerItem(
            icon: Icons.inventory_2_rounded,
            title: 'Products Management',
            isSelected: _currentIndex == 2,
            onTap: () => _navigateToPage(2),
          ),
          _buildDrawerItem(
            icon: Icons.shopping_cart_rounded,
            title: 'Orders Management',
            isSelected: _currentIndex == 3,
            onTap: () => _navigateToPage(3),
          ),

          const Divider(height: 40),

          _buildDrawerItem(
            icon: Icons.logout_rounded,
            title: 'Logout',
            isSelected: false,
            onTap: () async {
              // Close dialog first
              Navigator.pop(context);

              // Show loading
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logging out...'),
                  backgroundColor: Colors.orange,
                ),
              );

              // Perform logout
              await AuthService.logout();

              // Navigate to login screen after a small delay
              if (mounted) {
                Future.delayed(const Duration(milliseconds: 300), () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
                        (route) => false,
                  );
                });
              }
            },
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.orange.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: AppColors.orange.withOpacity(0.3)) : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: color ?? (isSelected ? AppColors.orange : AppColors.gray600),
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyles.bodyMedium.copyWith(
            color: color ?? (isSelected ? AppColors.orange : AppColors.textPrimary),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.orange,
            shape: BoxShape.circle,
          ),
        )
            : null,
        onTap: () {
          onTap();
          Navigator.pop(context); // Close drawer
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => _navigateToPage(index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.orange,
        unselectedItemColor: AppColors.gray500,
        selectedLabelStyle: TextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyles.labelSmall,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_rounded),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_rounded),
            label: 'Orders',
          ),
        ],
      ),
    );
  }

  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Dashboard Overview';
      case 1:
        return 'Users Management';
      case 2:
        return 'Products Management';
      case 3:
        return 'Orders Management';
      default:
        return 'Food Delivery Admin';
    }
  }
}