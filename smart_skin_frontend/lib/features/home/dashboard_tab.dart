import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/dashboard/dashboard_bloc.dart';
import '../../bloc/dashboard/dashboard_event.dart';
import '../../bloc/dashboard/dashboard_state.dart';
import '../../constants/colors.dart';
import '../../data/models/skin_analysis_model.dart';
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
    final userName = authState is AuthAuthenticated 
        ? (authState.user.onboardingName ?? authState.user.firstName) 
        : 'à toi';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            final lastAnalysis = state is DashboardLoaded ? state.data.lastAnalysis : null;

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
                    const Text("Bienvenue,", style: TextStyle(fontSize: 16, color: AppColors.textGrey)),
                    Text("$userName ✨", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 24),

                    // Skin Health Card
                    if (state is DashboardLoaded)
                      _buildSkinHealthCard(lastAnalysis)
                    else if (state is DashboardLoading)
                      _buildLoadingCard()
                    else
                      _buildSkinHealthCard(null),

                    // ✅ Section Analyse détaillée (Problèmes détectés par l'IA)
                    if (lastAnalysis != null && lastAnalysis.detectedProblems.isNotEmpty) ...[
                      const SizedBox(height: 30),
                      const Text("Analyse de la peau", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      const SizedBox(height: 16),
                      _buildProblemsList(lastAnalysis.detectedProblems),
                    ],

                    const SizedBox(height: 30),
                    const Text("Actions Rapides", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 16),

                    // Quick Actions Row
                    Row(
                      children: [
                        _buildQuickAction(
                          context,
                          Icons.camera_alt_rounded,
                          "Scanner Peau",
                          "Analyser maintenant",
                          const Color(0xFFFCE4EC),
                          const AnalysisScreen(),
                        ),
                        const SizedBox(width: 15),
                        _buildQuickAction(
                          context,
                          Icons.qr_code_scanner_rounded,
                          "Scanner Produit",
                          "Vérifier la sécurité",
                          const Color(0xFFE3F2FD),
                          const ProductScanScreen(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                    const Text("Conseil du Jour", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 16),

                    // Daily Tip Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
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
                                Text("Protection UV", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                SizedBox(height: 4),
                                Text(
                                  "Même par temps nuageux, les rayons UV peuvent atteindre votre peau. Appliquez toujours un SPF 30+ pour prévenir le vieillissement prématuré.",
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

  Widget _buildSkinHealthCard(SkinAnalysisModel? lastAnalysis) {
    final score = lastAnalysis?.overallScore ?? 0;
    final skinType = lastAnalysis?.skinTypeLabel ?? "Non analysé";

    String message = "Commencez votre première analyse !";
    if (score >= 80) message = "Excellents progrès ! Votre peau est en bonne santé.";
    else if (score >= 50) message = "Bel effort ! Suivez votre routine pour de meilleurs résultats.";
    else if (score > 0) message = "Il est temps de prendre soin de vous. Consultez vos recommandations.";

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Santé de votre peau", style: TextStyle(fontSize: 14, color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text("$score%", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const Icon(Icons.auto_awesome, size: 50, color: Colors.white24),
            ],
          ),
          const SizedBox(height: 12),
          Text(skinType, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 4),
          Text(message, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildProblemsList(List<SkinProblemModel> problems) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: problems.map((p) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: _getSeverityColor(p.severity), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "${p.typeLabel} : ${p.severityLabel}",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textDark),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high': return AppColors.error;
      case 'medium': return AppColors.warning;
      case 'low': return AppColors.success;
      default: return AppColors.textGrey;
    }
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
