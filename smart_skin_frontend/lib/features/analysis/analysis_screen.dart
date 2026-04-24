import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../bloc/analysis/analysis_bloc.dart';
import '../../bloc/analysis/analysis_event.dart';
import '../../bloc/analysis/analysis_state.dart';
import '../../constants/colors.dart';
import '../../data/models/skin_analysis_model.dart';
import 'live_camera_screen.dart';
import '../reports/progress_tracking_screen.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});
  @override State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  File? _selectedImage;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) setState(() => _selectedImage = File(picked.path));
  }

  void _analyze() {
    if (_selectedImage != null) {
      context.read<AnalysisBloc>().add(SubmitAnalysis(_selectedImage!.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text("Skin Analysis", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalysisHistoryScreen())),
          ),
        ],
      ),
      body: BlocConsumer<AnalysisBloc, AnalysisState>(
        listener: (ctx, state) {
          if (state is AnalysisError) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
              content: Text(state.message), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating,
            ));
          }
        },
        builder: (ctx, state) {
          if (state is AnalysisLoading) {
            return const Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primaryPink),
                SizedBox(height: 16),
                Text("Analyzing your skin...", style: TextStyle(color: AppColors.textGrey)),
              ],
            ));
          }
          if (state is AnalysisDone) {
            return _ResultView(result: state.result, onReset: () {
              context.read<AnalysisBloc>().add(const LoadAnalysisHistory());
              setState(() => _selectedImage = null);
            });
          }
          return _UploadView(
            selectedImage: _selectedImage,
            onCamera: () async {
              final path = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LiveCameraScreen()),
              );
              if (path != null) {
                setState(() => _selectedImage = File(path));
              }
            },
            onGallery: () => _pickImage(ImageSource.gallery),
            onAnalyze: _selectedImage != null ? _analyze : null,
          );
        },
      ),
    );
  }
}

class _UploadView extends StatelessWidget {
  final File? selectedImage;
  final VoidCallback onCamera, onGallery;
  final VoidCallback? onAnalyze;

  const _UploadView({this.selectedImage, required this.onCamera, required this.onGallery, this.onAnalyze});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            height: 280,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primaryPink.withOpacity(0.3), width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
            ),
            child: selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.file(selectedImage!, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.face_retouching_natural, size: 50, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      const Text("Upload a clear face photo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      const Text("Good lighting • No glasses • Facing camera",
                          style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                    ],
                  ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _sourceBtn(Icons.camera_alt_rounded, "Camera", onCamera)),
              const SizedBox(width: 12),
              Expanded(child: _sourceBtn(Icons.photo_library_rounded, "Gallery", onGallery)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: onAnalyze,
              icon: const Icon(Icons.auto_awesome),
              label: const Text("Analyze My Skin", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: onAnalyze != null ? AppColors.primaryPink : Colors.grey.shade300,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.privacy_tip_outlined, color: AppColors.accentBlue, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text("Your photos are processed securely and not stored permanently.",
                    style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sourceBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryPink, size: 28),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final SkinAnalysisModel result;
  final VoidCallback onReset;

  const _ResultView({required this.result, required this.onReset});

  @override
  Widget build(BuildContext context) {
    final score = result.overallScore ?? 0;
    final scoreColor = score >= 70 ? AppColors.success : score >= 40 ? AppColors.warning : AppColors.error;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                if (result.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(result.imageUrl!, width: 80, height: 80, fit: BoxFit.cover),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Skin Score", style: TextStyle(color: Colors.white70, fontSize: 14)),
                      Text(score.toString(), style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(result.detectedSkinType, style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Score bars
          _buildScoreBar("Hydration", result.hydrationScore),
          _buildScoreBar("Acne", result.acneScore),
          _buildScoreBar("Pigmentation", result.pigmentationScore),
          _buildScoreBar("Wrinkles", result.wrinkleScore),
          _buildScoreBar("Pores", result.poreScore),
          if (result.analysisDescription.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text("Analysis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200)),
              child: Text(result.analysisDescription, style: const TextStyle(height: 1.5)),
            ),
          ],
          if (result.recommandations.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text("Recommendations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...result.recommandations.map((r) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade100)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.check_circle_outline, color: AppColors.success, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(r.title, style: const TextStyle(fontWeight: FontWeight.bold))),
                ]),
                const SizedBox(height: 4),
                Text(r.description, style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
              ]),
            )),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh),
              label: const Text("New Analysis", style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPink, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildScoreBar(String label, int? score) {
    final s = score ?? 0;
    final color = s >= 70 ? AppColors.success : s >= 40 ? AppColors.warning : AppColors.error;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: s / 100, minHeight: 10, backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 36, child: Text(s.toString(), textAlign: TextAlign.right,
              style: TextStyle(color: color, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

class AnalysisHistoryScreen extends StatefulWidget {
  const AnalysisHistoryScreen({super.key});
  @override State<AnalysisHistoryScreen> createState() => _AnalysisHistoryScreenState();
}

class _AnalysisHistoryScreenState extends State<AnalysisHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AnalysisBloc>().add(const LoadAnalysisHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Analysis History"), backgroundColor: Colors.white,
          foregroundColor: AppColors.textDark, elevation: 0),
      backgroundColor: AppColors.backgroundLight,
      body: BlocBuilder<AnalysisBloc, AnalysisState>(
        builder: (ctx, state) {
          if (state is AnalysisLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primaryPink));
          if (state is AnalysisHistoryLoaded) {
            if (state.analyses.isEmpty) return const Center(child: Text("No analyses yet.", style: TextStyle(color: AppColors.textGrey)));
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.analyses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final a = state.analyses[i];
                final score = a.overallScore ?? 0;
                final c = score >= 70 ? AppColors.success : score >= 40 ? AppColors.warning : AppColors.error;
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProgressTrackingPage(reportId: a.id),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
                    child: Row(
                      children: [
                        if (a.imageUrl != null)
                          ClipRRect(borderRadius: BorderRadius.circular(10),
                              child: Image.network(a.imageUrl!, width: 55, height: 55, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const _HistoryPlaceholder()))
                        else const _HistoryPlaceholder(),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(a.detectedSkinType, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(a.analyzedAt.substring(0, (a.analyzedAt.length).clamp(0, 10)), style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                        ])),
                        Text(score.toString(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: c)),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text("Pull to load history."));
        },
      ),
    );
  }
}

class _HistoryPlaceholder extends StatelessWidget {
  const _HistoryPlaceholder();
  @override
  Widget build(BuildContext context) => Container(
    width: 55, height: 55,
    decoration: BoxDecoration(color: AppColors.primaryPink.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
    child: const Icon(Icons.face_retouching_natural, color: AppColors.primaryPink),
  );
}
