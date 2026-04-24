import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/dashboard/dashboard_bloc.dart';
import '../../bloc/dashboard/dashboard_event.dart';
import '../../bloc/dashboard/dashboard_state.dart';
import '../../constants/colors.dart';
import '../analysis/analysis_screen.dart';
import '../products/product_scan_screen.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});
  @override State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const LoadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final userName = authState is AuthAuthenticated ? authState.user.firstName : 'there';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            return RefreshIndicator(
              color: AppColors.primaryPink,
              onRefresh: () async => context.read<DashboardBloc>().add(const LoadDashboard()),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Text("Good morning,", style: TextStyle(fontSize: 16, color: AppColors.textGrey)),
                    Text("$userName ✨", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 24),

                    // Skin Health Card
                    if (state is DashboardLoaded)
                      _buildSkinHealthCard(state.data.lastAnalysis?.overallScore ?? 0)
                    else if (state is DashboardLoading)
                      _buildLoadingCard()
                    else
                      _buildSkinHealthCard(0),

                    const SizedBox(height: 30),
                    const Text("Quick Actions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 16),

                    // Quick Actions Row
                    Row(
                      children: [
                        _buildQuickAction(
                          context,
                          Icons.camera_alt_rounded,
                          "Scan Skin",
                          "Analyze now",
                          const Color(0xFFFCE4EC), // Light Pink
                          const AnalysisScreen(),
                        ),
                        const SizedBox(width: 15),
                        _buildQuickAction(
                          context,
                          Icons.qr_code_scanner_rounded,
                          "Scan Product",
                          "Check safety",
                          const Color(0xFFE3F2FD), // Light Blue
                          const ProductScanScreen(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                    const Text("Daily Tip", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 16),

                    // Daily Tip Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9), // Light Green
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.wb_sunny_outlined, size: 40, color: Colors.orangeAccent),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("UV Protection", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                SizedBox(height: 4),
                                Text(
                                  "Even on cloudy days, UV rays can reach your skin. Always apply SPF 30+ to prevent premature aging.",
                                  style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkinHealthCard(int score) {
    String message = "Start your first analysis!";
    if (score >= 80) message = "Great progress! Your skin is glowing.";
    else if (score >= 50) message = "Good effort! Follow your routine for better results.";
    else if (score > 0) message = "Time for some self-care. Check your recommendations.";

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPink.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Your Skin Health", style: TextStyle(fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 4),
                Text("$score%", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 12),
                Text(message, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
          const Icon(Icons.auto_awesome, size: 60, color: Colors.white24),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(24)),
      child: const Center(child: CircularProgressIndicator(color: AppColors.primaryPink)),
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String title, String subtitle, Color color, Widget screen) {
    return Expanded(
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(icon, size: 28, color: AppColors.deepPink),
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textGrey), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
