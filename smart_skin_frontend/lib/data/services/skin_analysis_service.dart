import 'dart:io';
import '../models/models.dart';
import 'api_service.dart';

class SkinAnalysisApiService {
  final ApiService _api;
  SkinAnalysisApiService(this._api);

  /// Upload image and get AI analysis
  Future<SkinAnalysisResult> analyzeImage(File imageFile) async {
    final result = await _api.analyzeSkin(imageFile.path);
    // Mapping from SkinAnalysisModel to SkinAnalysisResult
    return SkinAnalysisResult(
      id: result.id ?? 0,
      imageUrl: result.imageUrl,
      detectedSkinType: result.detectedSkinType,
      overallScore: result.overallScore,
      hydrationScore: result.hydrationScore,
      acneScore: result.acneScore,
      pigmentationScore: result.pigmentationScore,
      wrinkleScore: result.wrinkleScore,
      poreScore: result.poreScore,
      analysisDescription: result.analysisDescription,
      analyzedAt: result.analyzedAt != null ? DateTime.parse(result.analyzedAt!) : null,
      detectedProblems: result.detectedProblems.map((p) => SkinProblem(
        problemType: p.name,
        severity: p.severity,
        description: p.description,
      )).toList(),
      recommandations: result.recommandations.map((r) => Recommandation(
        category: r.productType ?? '',
        title: r.title,
        description: r.description,
        priority: r.priority == 'HIGH' ? 1 : 2,
      )).toList(),
    );
  }

  /// Get paginated analysis history
  Future<List<SkinAnalysisResult>> getHistory({int page = 0, int size = 10}) async {
    final results = await _api.getAnalysisHistory(page: page, size: size);
    return results.map((result) => SkinAnalysisResult(
      id: result.id ?? 0,
      imageUrl: result.imageUrl,
      detectedSkinType: result.detectedSkinType,
      overallScore: result.overallScore,
      analyzedAt: result.analyzedAt != null ? DateTime.parse(result.analyzedAt!) : null,
    )).toList();
  }

  /// Get recent analyses
  Future<List<SkinAnalysisResult>> getRecent({int limit = 5}) async {
    final results = await _api.getRecentAnalyses(limit: limit);
    return results.map((result) => SkinAnalysisResult(
      id: result.id ?? 0,
      imageUrl: result.imageUrl,
      detectedSkinType: result.detectedSkinType,
      overallScore: result.overallScore,
      analyzedAt: result.analyzedAt != null ? DateTime.parse(result.analyzedAt!) : null,
    )).toList();
  }
}
