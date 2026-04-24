import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/colors.dart';
import '../../data/models/models.dart';
import '../../data/services/api_service.dart';
import '../../data/services/local_storage_service.dart';

class ProgressTrackingPage extends StatefulWidget {
  final int? reportId;
  const ProgressTrackingPage({super.key, this.reportId});

  @override
  State<ProgressTrackingPage> createState() => _ProgressTrackingPageState();
}

class _ProgressTrackingPageState extends State<ProgressTrackingPage> {
  bool _isLoading = true;
  SkinReport? _report;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final api = context.read<ApiService>();
      // If we have an ID, fetch it, otherwise fetch the latest or generate one
      // For now, let's assume we fetch by ID if provided
      if (widget.reportId != null) {
        // Implementation for fetching specific report would go here
        // For demonstration, we'll fetch all and find it or just show a placeholder
        // Since we don't have getReportById yet in ApiService, we'll use a mock/placeholder
        // in a real app, you'd add: Future<SkinReport> getReport(int id) to ApiService
      }
      
      // Fallback: load latest dashboard data to simulate a report if none exists
      final dash = await api.getDashboard();
      setState(() {
        _report = SkinReport(
          id: widget.reportId ?? 0,
          title: "Skin Analysis Report",
          averageOverallScore: (dash.averageScore).toDouble(),
          averageHydrationScore: (dash.lastAnalysis?.hydrationScore ?? 0).toDouble(),
          averageAcneScore: (dash.lastAnalysis?.acneScore ?? 0).toDouble(),
          averagePigmentationScore: (dash.lastAnalysis?.pigmentationScore ?? 0).toDouble(),
          globalSummary: dash.lastAnalysis?.analysisDescription ?? "No summary available.",
          progressNotes: "Based on your last ${dash.totalAnalyses} analyses.",
          generatedAt: DateTime.now(),
        );
      });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Progress Tracking", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primaryPink));
    if (_error != null) return Center(child: Text(_error!, style: const TextStyle(color: AppColors.error)));
    if (_report == null) return const Center(child: Text("No report data found."));

    return RefreshIndicator(
      onRefresh: _loadReport,
      color: AppColors.primaryPink,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _overallCard(_report!),
            const SizedBox(height: 24),
            _metrics(_report!),
            const SizedBox(height: 24),
            _buildSectionTitle("AI Summary"),
            const SizedBox(height: 12),
            _progress(_report!),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
    );
  }

  Widget _overallCard(SkinReport r) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.primaryPink.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Overall Score", style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  r.averageOverallScore.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(r.progressNotes, style: const TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.auto_awesome, size: 60, color: Colors.white24),
        ],
      ),
    );
  }

  Widget _metrics(SkinReport r) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _metricCard("Hydration", r.averageHydrationScore, Icons.water_drop, Colors.blue),
        _metricCard("Acne", r.averageAcneScore, Icons.bug_report, Colors.red),
        _metricCard("Pigmentation", r.averagePigmentationScore, Icons.wb_sunny, Colors.orange),
        _metricCard("Health", r.averageOverallScore, Icons.favorite, Colors.green),
      ],
    );
  }

  Widget _metricCard(String title, double value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
          Text(value.toStringAsFixed(0),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _progress(SkinReport r) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Text(
        r.globalSummary,
        style: const TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.5),
      ),
    );
  }
}
