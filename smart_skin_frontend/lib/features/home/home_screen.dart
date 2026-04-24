import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../analysis/analysis_screen.dart';
import '../coach/ai_coach_screen.dart';
import '../profile/profile_screen.dart';
import '../products/product_scan_screen.dart';
import 'dashboard_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = const [
    DashboardTab(),
    AnalysisScreen(),
    AICoachScreen(),
    ProductScanScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.home_rounded, Icons.home_outlined, "Home"),
                _navItem(1, Icons.camera_alt_rounded, Icons.camera_alt_outlined, "Scan"),
                _navItem(2, Icons.auto_awesome, Icons.auto_awesome_outlined, "AI"),
                _navItem(3, Icons.qr_code_scanner, Icons.qr_code_scanner, "Product"),
                _navItem(4, Icons.person_rounded, Icons.person_outline_rounded, "Profile"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPink.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? AppColors.deepPink : Colors.grey, size: 24),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(
              fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.deepPink : Colors.grey,
            )),
          ],
        ),
      ),
    );
  }
}
