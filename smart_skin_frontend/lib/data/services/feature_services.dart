import '../models/models.dart';
import '../models/skin_analysis_model.dart';
import '../models/product_scan_model.dart';
import 'api_service.dart';

class DashboardApiService {
  final ApiService _api;
  DashboardApiService(this._api);

  Future<DashboardData> getDashboard() async {
    final result = await _api.getDashboard();
    return DashboardData(
      totalAnalyses: result.totalAnalyses,
      averageScore: result.averageScore,
      scoreEvolution: result.scoreEvolution,
      currentStreak: result.currentStreak,
      unreadNotifications: result.unreadNotifications,
      lastAnalysis: result.lastAnalysis != null ? _mapSkinAnalysis(result.lastAnalysis!) : null,
      scoreHistory: result.scoreHistory.map((e) => ScorePoint(
        date: DateTime.tryParse(e.date) ?? DateTime.now(),
        overallScore: e.score,
      )).toList(),
      topProblems: result.topProblems.map((e) => ProblemFrequency(
        problemType: e.problem,
        count: e.count,
      )).toList(),
      latestRecommandations: result.latestRecommandations.map((e) => Recommandation(
        category: e.productType ?? '',
        title: e.title,
        description: e.description,
      )).toList(),
    );
  }

  SkinAnalysisResult _mapSkinAnalysis(SkinAnalysisModel m) {
    return SkinAnalysisResult(
      id: m.id ?? 0,
      imageUrl: m.imageUrl,
      detectedSkinType: m.detectedSkinType,
      overallScore: m.overallScore,
      hydrationScore: m.hydrationScore,
      acneScore: m.acneScore,
      pigmentationScore: m.pigmentationScore,
      wrinkleScore: m.wrinkleScore,
      poreScore: m.poreScore,
      analysisDescription: m.analysisDescription,
      analyzedAt: m.analyzedAt != null ? DateTime.tryParse(m.analyzedAt!) : null,
      detectedProblems: m.detectedProblems.map((p) => SkinProblem(
        problemType: p.name,
        severity: p.severity,
        description: p.description,
      )).toList(),
      recommandations: m.recommandations.map((r) => Recommandation(
        category: r.productType ?? '',
        title: r.title,
        description: r.description,
      )).toList(),
    );
  }
}

class CoachApiService {
  final ApiService _api;
  CoachApiService(this._api);

  Future<CoachMessage> sendMessage(String message, {String? sessionId}) async {
    final result = await _api.chatWithCoach(message, sessionId ?? "");
    return CoachMessage(
      role: result.role,
      content: result.content,
      sessionId: result.sessionId,
      sentAt: result.sentAt != null ? DateTime.tryParse(result.sentAt!) : null,
    );
  }

  Future<List<CoachMessage>> getHistory(String sessionId) async {
    final results = await _api.getCoachHistory(sessionId);
    return results.map((result) => CoachMessage(
      role: result.role,
      content: result.content,
      sessionId: result.sessionId,
      sentAt: result.sentAt != null ? DateTime.tryParse(result.sentAt!) : null,
    )).toList();
  }
}

class ProductApiService {
  final ApiService _api;
  ProductApiService(this._api);

  Future<ProductScanResult> scanByIngredients({
    required String productName,
    String? brand,
    String? barcode,
    String? ingredients,
  }) async {
    final request = ProductScanRequestModel(
      productName: productName,
      brand: brand,
      barcode: barcode,
      ingredients: ingredients ?? "",
    );

    final result = await _api.scanProduct(request);
    return _mapProductScan(result);
  }

  Future<List<ProductScanResult>> getHistory({int page = 0, int size = 10}) async {
    final results = await _api.getProductHistory(page: page, size: size);
    return results.map((result) => _mapProductScan(result)).toList();
  }

  ProductScanResult _mapProductScan(ProductScanModel result) {
    return ProductScanResult(
      id: result.id,
      productName: result.productName,
      brand: result.brand,
      compatible: result.compatibilityScore != null && result.compatibilityScore! >= 70,
      compatibilityScore: result.compatibilityScore,
      positiveIngredients: result.beneficialIngredients,
      negativeIngredients: result.harmfulIngredients,
      analysisResult: result.summary,
      scannedAt: result.scannedAt != null ? DateTime.tryParse(result.scannedAt!) : null,
    );
  }
}

class NotificationApiService {
  final ApiService _api;
  NotificationApiService(this._api);

  Future<List<AppNotification>> getNotifications({int page = 0, int size = 20}) async {
    final results = await _api.getNotifications(page: page, size: size);
    return results.map((result) => AppNotification(
      id: result.id,
      type: result.type,
      title: result.title,
      message: result.message,
      read: result.isRead,
      createdAt: result.createdAt != null ? DateTime.tryParse(result.createdAt!) : null,
    )).toList();
  }

  Future<int> getUnreadCount() async {
    return await _api.getUnreadCount();
  }

  Future<void> markAllAsRead() async {
    await _api.markAllRead();
  }
}

class ReportApiService {
  final ApiService _api;
  ReportApiService(this._api);

  Future<List<SkinReport>> getReports() async {
    // Placeholder to use _api and avoid warning. 
    // Implementation can be added when ApiService supports reports.
    return [];
  }
}
