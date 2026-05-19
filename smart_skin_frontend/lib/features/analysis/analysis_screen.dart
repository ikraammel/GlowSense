import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../bloc/analysis/analysis_bloc.dart';
import '../../bloc/analysis/analysis_event.dart';
import '../../bloc/analysis/analysis_state.dart';
import '../../bloc/dashboard/dashboard_bloc.dart';
import '../../bloc/dashboard/dashboard_event.dart';
import '../../constants/colors.dart';
import '../../data/models/skin_analysis_model.dart';
import '../../data/services/api_service.dart';
import 'live_camera_screen.dart';
import '../reports/progress_tracking_screen.dart';
import '../products/product_scan_screen.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});
  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
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
        title: const Text("Skin Analysis",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AnalysisHistoryScreen())),
          ),
        ],
      ),
      body: BlocConsumer<AnalysisBloc, AnalysisState>(
        listener: (ctx, state) {
          if (state is AnalysisError) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ));
          }
          // Rafraîchir le Dashboard dès que l'analyse est terminée
          if (state is AnalysisDone) {
            context.read<DashboardBloc>().add(const LoadDashboard());
          }
        },
        builder: (ctx, state) {
          if (state is AnalysisLoading) {
            return const Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primaryPink),
                SizedBox(height: 16),
                Text("Analyzing your skin...",
                    style: TextStyle(color: AppColors.textGrey)),
              ],
            ));
          }
          if (state is AnalysisDone) {
            return _ResultView(
                result: state.result,
                onReset: () {
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

  const _UploadView(
      {this.selectedImage,
      required this.onCamera,
      required this.onGallery,
      this.onAnalyze});

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
              border: Border.all(
                  color: AppColors.primaryPink.withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5))
              ],
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
                        child: const Icon(Icons.face_retouching_natural,
                            size: 50, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      const Text("Upload a clear face photo",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      const Text("Good lighting • No glasses • Facing camera",
                          style: TextStyle(
                              color: AppColors.textGrey, fontSize: 13)),
                    ],
                  ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                  child:
                      _sourceBtn(Icons.camera_alt_rounded, "Camera", onCamera)),
              const SizedBox(width: 12),
              Expanded(
                  child: _sourceBtn(
                      Icons.photo_library_rounded, "Gallery", onGallery)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: onAnalyze,
              icon: const Icon(Icons.auto_awesome),
              label: const Text("Analyze My Skin",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: onAnalyze != null
                    ? AppColors.primaryPink
                    : Colors.grey.shade300,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
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
                Icon(Icons.privacy_tip_outlined,
                    color: AppColors.accentBlue, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                      "Your photos are processed securely and not stored permanently.",
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
          ],
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

  Color getPredictionColor(String? p) {
    switch (p?.toLowerCase()) {
      case "acne":
        return Colors.red;
      case "dark spots":
        return Colors.brown;
      case "wrinkles":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String get topProblem {
    final probabilities = result.modelProbabilities ?? {};
    if (probabilities.isNotEmpty) {
      return probabilities.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key
          .toLowerCase();
    }
    if ((result.modelPrediction ?? '').trim().isNotEmpty) {
      return result.modelPrediction!.toLowerCase();
    }
    if (result.detectedProblems.isNotEmpty) {
      return result.detectedProblems.first.name.toLowerCase();
    }
    return 'general';
  }

  double? get topProblemPercentage {
    final probabilities = result.modelProbabilities ?? {};
    if (probabilities.isEmpty) return result.modelConfidence;
    return probabilities.entries.reduce((a, b) => a.value >= b.value ? a : b).value;
  }

  String get pharmaSkinType => _toHfSkinType(result.detectedSkinType);

  String get pharmaProblem => _toHfProblem(topProblem);

  List<RecommendationModel> get groqRecommendationsForTopProblem {
    final recommendations = result.recommandations;
    if (recommendations.isEmpty) return _fallbackGroqLikeRecommendations(topProblem);

    final keywords = _problemKeywords(topProblem);
    final filtered = recommendations.where((recommendation) {
      final text = [
        recommendation.title,
        recommendation.description,
        recommendation.productType,
      ].join(' ').toLowerCase();
      return keywords.any(text.contains);
    }).toList();

    final base = filtered.isNotEmpty ? filtered : recommendations;
    final completed = [
      ...base,
      ...recommendations.where((recommendation) => !base.contains(recommendation)),
    ];
    if (completed.length < 3) {
      completed.addAll(_fallbackGroqLikeRecommendations(topProblem));
    }
    return completed.take(4).toList();
  }

  List<String> _problemKeywords(String problem) {
    final normalized = problem.toLowerCase();
    if (normalized.contains('acne')) {
      return ['acne', 'bouton', 'imperfection', 'sebum', 'zinc', 'niacinamide'];
    }
    if (normalized.contains('dark') ||
        normalized.contains('spot') ||
        normalized.contains('tache') ||
        normalized.contains('pigment')) {
      return ['tache', 'spot', 'pigment', 'eclat', 'vitamine c', 'reglisse'];
    }
    if (normalized.contains('wrinkle') ||
        normalized.contains('ride') ||
        normalized.contains('age')) {
      return ['ride', 'wrinkle', 'age', 'elasticite', 'bakuchiol', 'retinol'];
    }
    if (normalized.contains('pore')) {
      return ['pore', 'sebum', 'exfol', 'niacinamide', 'texture'];
    }
    return [normalized];
  }

  String _toHfSkinType(String skinType) {
    final normalized = skinType.toLowerCase().trim();
    if (normalized.contains('gras') || normalized.contains('oily')) {
      return 'Grasse';
    }
    if (normalized.contains('sec') || normalized.contains('dry')) {
      return 'S\u00E8che';
    }
    if (normalized.contains('mix') || normalized.contains('combination')) {
      return 'Mixte';
    }
    if (normalized.contains('sensible') || normalized.contains('sensitive')) {
      return 'Sensible';
    }
    if (normalized.contains('mature') ||
        normalized.contains('ride') ||
        normalized.contains('wrinkle')) {
      return 'Mature';
    }
    return 'Sensible';
  }

  String _toHfProblem(String problem) {
    final normalized = problem.toLowerCase().trim();
    if (normalized.contains('acne') ||
        normalized.contains('acn\u00E9') ||
        normalized.contains('bouton') ||
        normalized.contains('imperfection')) {
      return 'Acn\u00E9';
    }
    if (normalized.contains('blackhead') ||
        normalized.contains('comedon') ||
        normalized.contains('com\u00E9don') ||
        normalized.contains('point noir')) {
      return 'Points Noirs';
    }
    if (normalized.contains('pore')) {
      return 'Pores';
    }
    if (normalized.contains('dark') ||
        normalized.contains('spot') ||
        normalized.contains('tache') ||
        normalized.contains('pigment')) {
      return 'Hyperpigmentation';
    }
    if (normalized.contains('wrinkle') ||
        normalized.contains('ride') ||
        normalized.contains('age') ||
        normalized.contains('\u00E2ge')) {
      return 'Rides';
    }
    if (normalized.contains('hydrat') ||
        normalized.contains('dry') ||
        normalized.contains('sec')) {
      return 'D\u00E9shydratation';
    }
    if (normalized.contains('red') ||
        normalized.contains('rouge') ||
        normalized.contains('rosace')) {
      return 'Rougeurs';
    }
    if (normalized.contains('cernes') ||
        normalized.contains('poches') ||
        normalized.contains('eye')) {
      return 'Cernes/Poches';
    }
    return 'Acn\u00E9';
  }

  String _toPharmaSkinType(String skinType) {
    final normalized = skinType.toLowerCase().trim();
    if (normalized.contains('gras') || normalized.contains('oily')) {
      return 'Grasse';
    }
    if (normalized.contains('sec') || normalized.contains('dry')) {
      return 'Sèche';
    }
    if (normalized.contains('mix') || normalized.contains('combination')) {
      return 'Mixte';
    }
    if (normalized.contains('sensible') || normalized.contains('sensitive')) {
      return 'Sensible';
    }
    if (normalized.contains('mature') ||
        normalized.contains('ride') ||
        normalized.contains('wrinkle')) {
      return 'Mature';
    }
    return 'Sensible';
  }

  String _toPharmaProblem(String problem) {
    final normalized = problem.toLowerCase().trim();
    if (normalized.contains('acne') ||
        normalized.contains('acné') ||
        normalized.contains('bouton') ||
        normalized.contains('imperfection')) {
      return 'Acné';
    }
    if (normalized.contains('blackhead') ||
        normalized.contains('comedon') ||
        normalized.contains('comédon') ||
        normalized.contains('point noir')) {
      return 'Points Noirs';
    }
    if (normalized.contains('pore')) {
      return 'Pores';
    }
    if (normalized.contains('dark') ||
        normalized.contains('spot') ||
        normalized.contains('tache') ||
        normalized.contains('pigment')) {
      return 'Hyperpigmentation';
    }
    if (normalized.contains('wrinkle') ||
        normalized.contains('ride') ||
        normalized.contains('age') ||
        normalized.contains('âge')) {
      return 'Rides';
    }
    if (normalized.contains('hydrat') ||
        normalized.contains('dry') ||
        normalized.contains('sec')) {
      return 'Déshydratation';
    }
    if (normalized.contains('red') ||
        normalized.contains('rouge') ||
        normalized.contains('rosace')) {
      return 'Rougeurs';
    }
    if (normalized.contains('cernes') ||
        normalized.contains('poches') ||
        normalized.contains('eye')) {
      return 'Cernes/Poches';
    }
    return 'Acné';
  }

  List<RecommendationModel> _fallbackGroqLikeRecommendations(String problem) {
    final normalized = problem.toLowerCase();
    if (normalized.contains('dark') ||
        normalized.contains('spot') ||
        normalized.contains('tache') ||
        normalized.contains('pigment')) {
      return [
        RecommendationModel(
          title: 'Serum vitamine C et reglisse',
          description:
              'Aide a attenuer les taches et a uniformiser progressivement le teint.',
          productType: 'Serum naturel',
          priority: 'HIGH',
        ),
        RecommendationModel(
          title: 'Masque doux a l aloe vera',
          description:
              'Apaise la peau et soutient la barriere cutanee pendant le traitement des taches.',
          productType: 'Masque bio',
          priority: 'MEDIUM',
        ),
        RecommendationModel(
          title: 'Protection solaire minerale SPF 30+',
          description:
              'Indispensable pour limiter l apparition de nouvelles taches pigmentaires.',
          productType: 'Protection naturelle',
          priority: 'HIGH',
        ),
      ];
    }
    if (normalized.contains('wrinkle') ||
        normalized.contains('ride') ||
        normalized.contains('age')) {
      return [
        RecommendationModel(
          title: 'Huile de rose musquee et bakuchiol',
          description:
              'Soutient l elasticite et lisse l apparence des ridules en douceur.',
          productType: 'Soin nuit naturel',
          priority: 'HIGH',
        ),
        RecommendationModel(
          title: 'Creme nourrissante au karite',
          description:
              'Renforce le confort cutane et aide la peau mature a rester souple.',
          productType: 'Creme bio',
          priority: 'MEDIUM',
        ),
        RecommendationModel(
          title: 'Serum acide hyaluronique vegetal',
          description:
              'Repulpe visiblement la peau et ameliore l hydratation de surface.',
          productType: 'Serum naturel',
          priority: 'HIGH',
        ),
      ];
    }
    if (normalized.contains('pore')) {
      return [
        RecommendationModel(
          title: 'Gel nettoyant tea tree et aloe vera',
          description:
              'Nettoie l exces de sebum sans agresser la barriere cutanee.',
          productType: 'Nettoyant naturel',
          priority: 'HIGH',
        ),
        RecommendationModel(
          title: 'Serum niacinamide et zinc',
          description:
              'Aide a affiner le grain de peau et a reduire l apparence des pores.',
          productType: 'Serum naturel',
          priority: 'HIGH',
        ),
        RecommendationModel(
          title: 'Hydrolat d hamamelis',
          description:
              'Tonifie la peau et complete une routine pour pores visibles.',
          productType: 'Lotion naturelle',
          priority: 'MEDIUM',
        ),
      ];
    }
    return [
      RecommendationModel(
        title: 'Gel nettoyant aloe vera et tea tree',
        description:
            'Purifie les peaux a imperfections tout en gardant une routine douce.',
        productType: 'Nettoyant naturel',
        priority: 'HIGH',
      ),
      RecommendationModel(
        title: 'Serum niacinamide et zinc',
        description:
            'Aide a reguler le sebum et a calmer les imperfections visibles.',
        productType: 'Serum naturel',
        priority: 'HIGH',
      ),
      RecommendationModel(
        title: 'Creme legere au jojoba',
        description:
            'Hydrate sans effet gras et aide a proteger la barriere cutanee.',
        productType: 'Creme bio',
        priority: 'MEDIUM',
      ),
      RecommendationModel(
        title: 'Protection solaire minerale SPF 30+',
        description:
            'Protege la peau sensibilisee par les imperfections et les actifs.',
        productType: 'Protection naturelle',
        priority: 'HIGH',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final score = result.overallScore ?? 0;

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
                    child: Image.network(result.imageUrl!,
                        width: 80, height: 80, fit: BoxFit.cover),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Skin Score",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 14)),
                      Text(score.toString(),
                          style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Text(result.skinTypeLabel,
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Gérer modèle indisponible
          if (result.modelWasAvailable == false) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Analyse IA indisponible, résultats estimés.",
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],

          // Section Détection IA (Python Model)
          if (result.modelWasAvailable == true &&
              result.modelPrediction != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFCE93D8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.biotech, color: Color(0xFF7B1FA2), size: 18),
                      SizedBox(width: 8),
                      Text("Détection IA",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7B1FA2))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          (result.modelPrediction ?? "unknown").toUpperCase(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: getPredictionColor(result.modelPrediction),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7B1FA2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${(result.modelConfidence ?? 0).toStringAsFixed(1)}%",
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...(result.modelProbabilities ?? {})
                      .entries
                      .map((e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                SizedBox(
                                    width: 120,
                                    child: Text(e.key,
                                        style: const TextStyle(fontSize: 12))),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: e.value / 100,
                                      minHeight: 8,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation(
                                          getPredictionColor(e.key)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                    width: 45,
                                    child: Text(
                                        "${e.value.toStringAsFixed(1)}%",
                                        style: const TextStyle(fontSize: 11),
                                        textAlign: TextAlign.right)),
                              ],
                            ),
                          )),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),
          if (result.analysisDescription.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text("Analysis",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200)),
              child: Text(result.analysisDescription,
                  style: const TextStyle(height: 1.5)),
            ),
          ],
          const SizedBox(height: 22),
          _GroqNaturalRecommendationsSection(
            recommendations: groqRecommendationsForTopProblem,
            problem: topProblem,
            percentage: topProblemPercentage,
          ),
          const SizedBox(height: 18),
          _PharmaRecommendationsSection(
            skinType: pharmaSkinType,
            problem: pharmaProblem,
            fallbackRecommendations: groqRecommendationsForTopProblem,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh),
              label: const Text("New Analysis",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _GroqNaturalRecommendationsSection extends StatelessWidget {
  final List<RecommendationModel> recommendations;
  final String problem;
  final double? percentage;

  const _GroqNaturalRecommendationsSection({
    required this.recommendations,
    required this.problem,
    this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8F5E9)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.eco_outlined,
                    color: AppColors.success, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Recommandations bio",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ProblemBadge(problem: problem, percentage: percentage),
          const SizedBox(height: 14),
          if (recommendations.isEmpty)
            const Text(
              "Aucune recommandation naturelle disponible pour cette analyse.",
              style: TextStyle(color: AppColors.textGrey, fontSize: 13),
            )
          else
            ...recommendations.map((recommendation) =>
                _GroqRecommendationCard(recommendation: recommendation)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductScanScreen()),
              ),
              icon: const Icon(Icons.qr_code_scanner, size: 18),
              label: const Text("Verifier les ingredients d'un produit"),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.deepPink,
                side: BorderSide(
                    color: AppColors.primaryPink.withValues(alpha: 0.7)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PharmaRecommendationsSection extends StatefulWidget {
  final String skinType;
  final String problem;
  final List<RecommendationModel> fallbackRecommendations;

  const _PharmaRecommendationsSection({
    required this.skinType,
    required this.problem,
    required this.fallbackRecommendations,
  });

  @override
  State<_PharmaRecommendationsSection> createState() =>
      _PharmaRecommendationsSectionState();
}

class _PharmaRecommendationsSectionState
    extends State<_PharmaRecommendationsSection> {
  late Future<List<Map<String, dynamic>>> _future;
  bool _usesGroqFallback = false;

  @override
  void initState() {
    super.initState();
    _future = _loadRecommendations();
  }

  Future<List<Map<String, dynamic>>> _loadRecommendations() async {
    try {
      final products = await context.read<ApiService>().getPharmaRecommendations(
            skinType: widget.skinType,
            problem: widget.problem,
          );
      if (products.isNotEmpty) return products.take(4).toList();
    } catch (_) {
      // The UI falls back to the existing Groq recommendations below.
    }

    _usesGroqFallback = true;
    return widget.fallbackRecommendations.take(4).map((recommendation) {
      return {
        'name': recommendation.title,
        'description': recommendation.description,
        'category': recommendation.productType,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final products = snapshot.data ?? [];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE3F2FD)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.medical_services_outlined,
                        color: AppColors.accentBlue, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Produits pharmaceutiques",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 2),
                        Text("Selon le type de peau et le probleme principal",
                            style: TextStyle(
                                color: AppColors.textGrey, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _ProblemBadge(problem: widget.problem),

              const SizedBox(height: 14),
              if (isLoading)
                const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primaryPink),
                )
              else if (products.isEmpty)
                const Text(
                  "Aucun produit pharmaceutique disponible pour ces parametres.",
                  style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                )
              else
                ...products.map((product) => _PharmaProductCard(
                      product: product,
                      usesGroqFallback: _usesGroqFallback,
                    )),
            ],
          ),
        );
      },
    );
  }
}

class _GroqRecommendationCard extends StatelessWidget {
  final RecommendationModel recommendation;

  const _GroqRecommendationCard({required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.eco_outlined,
                    color: AppColors.success, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recommendation.productType.isNotEmpty
                            ? recommendation.productType
                            : "Bio naturel",
                        style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(recommendation.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(recommendation.description,
              style: const TextStyle(
                  color: AppColors.textDark, height: 1.35, fontSize: 13)),
        ],
      ),
    );
  }
}

class _PharmaProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool usesGroqFallback;

  const _PharmaProductCard({
    required this.product,
    required this.usesGroqFallback,
  });

  String? _value(List<String> keys) {
    for (final key in keys) {
      final value = product[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final name = _value(['name', 'product_name', 'productName', 'title']) ??
        'Produit recommande';
    final description =
        _value(['description', 'desc', 'summary', 'reason', 'details']) ?? '';
    final brand = _value(['brand', 'marque', 'category']);
    final image = _value(['image', 'image_url', 'imageUrl', 'photo']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: image != null
                ? Image.network(
                    image,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _PharmaIcon(),
                  )
                : const _PharmaIcon(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (brand != null) ...[
                  Text(brand,
                      style: const TextStyle(
                          color: AppColors.accentBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                  const SizedBox(height: 2),
                ],
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark)),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(description,
                      style: const TextStyle(
                          color: AppColors.textGrey,
                          height: 1.35,
                          fontSize: 13)),
                ],

              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PharmaIcon extends StatelessWidget {
  const _PharmaIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      color: AppColors.accentBlue.withValues(alpha: 0.12),
      child: const Icon(Icons.medication_outlined,
          color: AppColors.accentBlue, size: 24),
    );
  }
}

class _ProblemBadge extends StatelessWidget {
  final String problem;
  final double? percentage;

  const _ProblemBadge({required this.problem, this.percentage});

  @override
  Widget build(BuildContext context) {
    final label = percentage == null
        ? problem
        : "$problem - ${percentage!.toStringAsFixed(1)}%";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primaryPink.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.analytics_outlined,
              color: AppColors.primaryPink, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                  color: AppColors.deepPink,
                  fontWeight: FontWeight.w700,
                  fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class AnalysisHistoryScreen extends StatefulWidget {
  const AnalysisHistoryScreen({super.key});
  @override
  State<AnalysisHistoryScreen> createState() => _AnalysisHistoryScreenState();
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
      appBar: AppBar(
          title: const Text("Analysis History"),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textDark,
          elevation: 0),
      backgroundColor: AppColors.backgroundLight,
      body: BlocBuilder<AnalysisBloc, AnalysisState>(
        builder: (ctx, state) {
          if (state is AnalysisLoading)
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryPink));
          if (state is AnalysisHistoryLoaded) {
            if (state.analyses.isEmpty)
              return const Center(
                  child: Text("No analyses yet.",
                      style: TextStyle(color: AppColors.textGrey)));
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.analyses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final a = state.analyses[i];
                final score = a.overallScore ?? 0;
                final c = score >= 70
                    ? AppColors.success
                    : score >= 40
                        ? AppColors.warning
                        : AppColors.error;
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
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8)
                        ]),
                    child: Row(
                      children: [
                        if (a.imageUrl != null)
                          ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(a.imageUrl!,
                                  width: 55,
                                  height: 55,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const _HistoryPlaceholder()))
                        else
                          const _HistoryPlaceholder(),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(a.detectedSkinType,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  a.analyzedAt.substring(
                                      0, (a.analyzedAt.length).clamp(0, 10)),
                                  style: const TextStyle(
                                      color: AppColors.textGrey, fontSize: 12)),
                            ])),
                        Text(score.toString(),
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: c)),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right,
                            color: Colors.grey, size: 20),
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
        width: 55,
        height: 55,
        decoration: BoxDecoration(
            color: AppColors.primaryPink.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.face_retouching_natural,
            color: AppColors.primaryPink),
      );
}
