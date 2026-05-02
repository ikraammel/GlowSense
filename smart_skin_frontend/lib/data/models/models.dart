// ─── Skin Analysis Models ───────────────────────────────────────────────────

class SkinProblem {
  final int? id;
  final String problemType;
  final String severity;
  final String? zone;
  final String? description;
  final double? confidence;

  SkinProblem({
    this.id,
    required this.problemType,
    required this.severity,
    this.zone,
    this.description,
    this.confidence,
  });

  factory SkinProblem.fromJson(Map<String, dynamic> j) => SkinProblem(
        id: j['id'],
        problemType: j['problemType'] ?? '',
        severity: j['severity'] ?? 'LEGERE',
        zone: j['zone'],
        description: j['description'],
        confidence: (j['confidence'] as num?)?.toDouble(),
      );

  String get severityLabel {
    switch (severity) {
      case 'LEGERE':   return 'Légère';
      case 'MODEREE':  return 'Modérée';
      case 'SEVERE':   return 'Sévère';
      default:         return severity;
    }
  }

  String get typeLabel {
    const labels = {
      'acne': 'Acné',
      'tache': 'Taches',
      'ride': 'Rides',
      'pore': 'Pores dilatés',
      'deshydratation': 'Déshydratation',
      'rougeur': 'Rougeurs',
      'cicatrice': 'Cicatrices',
      'comedons': 'Comédons',
    };
    return labels[problemType] ?? problemType;
  }
}

class Recommandation {
  final int? id;
  final String category;
  final String title;
  final String? description;
  final String? activeIngredient;
  final int? priority;
  final String? applicationFrequency;
  final String? tips;

  Recommandation({
    this.id,
    required this.category,
    required this.title,
    this.description,
    this.activeIngredient,
    this.priority,
    this.applicationFrequency,
    this.tips,
  });

  factory Recommandation.fromJson(Map<String, dynamic> j) => Recommandation(
        id: j['id'],
        category: j['category'] ?? '',
        title: j['title'] ?? '',
        description: j['description'],
        activeIngredient: j['activeIngredient'],
        priority: j['priority'],
        applicationFrequency: j['applicationFrequency'],
        tips: j['tips'],
      );

  String get categoryLabel {
    const labels = {
      'nettoyant': 'Nettoyant',
      'hydratant': 'Hydratant',
      'traitement': 'Traitement',
      'protection_solaire': 'Protection solaire',
      'gommage': 'Gommage',
      'serum': 'Sérum',
      'alimentation': 'Alimentation',
      'style_de_vie': 'Style de vie',
    };
    return labels[category] ?? category;
  }

  String get categoryEmoji {
    const emojis = {
      'nettoyant': '🧼',
      'hydratant': '💧',
      'traitement': '💊',
      'protection_solaire': '☀️',
      'gommage': '✨',
      'serum': '🧪',
      'alimentation': '🥗',
      'style_de_vie': '🌿',
    };
    return emojis[category] ?? '💄';
  }
}

class SkinAnalysisResult {
  final int id;
  final String? imageUrl;
  final String? detectedSkinType;
  final int? overallScore;
  final int? hydrationScore;
  final int? acneScore;
  final int? pigmentationScore;
  final int? wrinkleScore;
  final int? poreScore;
  final String? analysisDescription;
  final List<SkinProblem> detectedProblems;
  final List<Recommandation> recommandations;
  final DateTime? analyzedAt;

  SkinAnalysisResult({
    required this.id,
    this.imageUrl,
    this.detectedSkinType,
    this.overallScore,
    this.hydrationScore,
    this.acneScore,
    this.pigmentationScore,
    this.wrinkleScore,
    this.poreScore,
    this.analysisDescription,
    this.detectedProblems = const [],
    this.recommandations = const [],
    this.analyzedAt,
  });

  factory SkinAnalysisResult.fromJson(Map<String, dynamic> j) =>
      SkinAnalysisResult(
        id: j['id'],
        imageUrl: j['imageUrl'],
        detectedSkinType: j['detectedSkinType'],
        overallScore: j['overallScore'],
        hydrationScore: j['hydrationScore'],
        acneScore: j['acneScore'],
        pigmentationScore: j['pigmentationScore'],
        wrinkleScore: j['wrinkleScore'],
        poreScore: j['poreScore'],
        analysisDescription: j['analysisDescription'],
        detectedProblems: (j['detectedProblems'] as List? ?? [])
            .map((e) => SkinProblem.fromJson(e))
            .toList(),
        recommandations: (j['recommandations'] as List? ?? [])
            .map((e) => Recommandation.fromJson(e))
            .toList(),
        analyzedAt: j['analyzedAt'] != null ? DateTime.parse(j['analyzedAt']) : null,
      );

  String get skinTypeLabel {
    if (detectedSkinType == null ||
        detectedSkinType == 'INCONNU' ||
        detectedSkinType == 'UNKNOWN') {

      // fallback basé sur IA
      if (analysisDescription?.contains('acne') == true) {
        return 'Peau acnéique';
      }
      if (analysisDescription?.contains('dark spots') == true) {
        return 'Peau à taches pigmentaires';
      }

      return 'Non déterminé';
    }

    const labels = {
      'NORMAL': 'Normale',
      'SEC': 'Sèche',
      'GRAS': 'Grasse',
      'MIXTE': 'Mixte',
      'SENSIBLE': 'Sensible',
      'ACNEIQUE': 'Acnéique',
      'MATURE': 'Mature',
    };

    return labels[detectedSkinType] ?? detectedSkinType!;
  }
}

// ─── Dashboard Models ────────────────────────────────────────────────────────

class ScorePoint {
  final DateTime date;
  final int? overallScore;
  final int? hydrationScore;
  final int? acneScore;
  final int? pigmentationScore;

  ScorePoint({
    required this.date,
    this.overallScore,
    this.hydrationScore,
    this.acneScore,
    this.pigmentationScore,
  });

  factory ScorePoint.fromJson(Map<String, dynamic> j) => ScorePoint(
        date: DateTime.parse(j['date']),
        overallScore: j['overallScore'],
        hydrationScore: j['hydrationScore'],
        acneScore: j['acneScore'],
        pigmentationScore: j['pigmentationScore'],
      );
}

class ProblemFrequency {
  final String problemType;
  final int count;
  final double? averageSeverity;

  ProblemFrequency({
    required this.problemType,
    required this.count,
    this.averageSeverity,
  });

  factory ProblemFrequency.fromJson(Map<String, dynamic> j) => ProblemFrequency(
        problemType: j['problemType'] ?? '',
        count: j['count'] ?? 0,
        averageSeverity: (j['averageSeverity'] as num?)?.toDouble(),
      );
}

class DashboardData {
  final int totalAnalyses;
  final double? averageScore;
  final double? scoreEvolution;
  final int? currentStreak;
  final SkinAnalysisResult? lastAnalysis;
  final List<ScorePoint> scoreHistory;
  final List<ProblemFrequency> topProblems;
  final List<Recommandation> latestRecommandations;
  final int? unreadNotifications;

  DashboardData({
    required this.totalAnalyses,
    this.averageScore,
    this.scoreEvolution,
    this.currentStreak,
    this.lastAnalysis,
    this.scoreHistory = const [],
    this.topProblems = const [],
    this.latestRecommandations = const [],
    this.unreadNotifications,
  });

  factory DashboardData.fromJson(Map<String, dynamic> j) => DashboardData(
        totalAnalyses: j['totalAnalyses'] ?? 0,
        averageScore: (j['averageScore'] as num?)?.toDouble(),
        scoreEvolution: (j['scoreEvolution'] as num?)?.toDouble(),
        currentStreak: j['currentStreak'],
        lastAnalysis: j['lastAnalysis'] != null
            ? SkinAnalysisResult.fromJson(j['lastAnalysis'])
            : null,
        scoreHistory: (j['scoreHistory'] as List? ?? [])
            .map((e) => ScorePoint.fromJson(e))
            .toList(),
        topProblems: (j['topProblems'] as List? ?? [])
            .map((e) => ProblemFrequency.fromJson(e))
            .toList(),
        latestRecommandations: (j['latestRecommandations'] as List? ?? [])
            .map((e) => Recommandation.fromJson(e))
            .toList(),
        unreadNotifications: j['unreadNotifications'],
      );
}

// ─── Coach Model ─────────────────────────────────────────────────────────────

class CoachMessage {
  final int? id;
  final String role; // "user" | "assistant"
  final String content;
  final String? sessionId;
  final DateTime? sentAt;

  CoachMessage({
    this.id,
    required this.role,
    required this.content,
    this.sessionId,
    this.sentAt,
  });

  bool get isUser => role == 'user';

  factory CoachMessage.fromJson(Map<String, dynamic> j) => CoachMessage(
        id: j['id'],
        role: j['role'] ?? 'user',
        content: j['content'] ?? '',
        sessionId: j['sessionId'],
        sentAt: j['sentAt'] != null ? DateTime.parse(j['sentAt']) : null,
      );

  factory CoachMessage.userMessage(String text, {String? sessionId}) =>
      CoachMessage(role: 'user', content: text, sessionId: sessionId, sentAt: DateTime.now());
}

// ─── Product Scan Model ──────────────────────────────────────────────────────

class ProductScanResult {
  final int? id;
  final String? productName;
  final String? brand;
  final bool? compatible;
  final int? compatibilityScore;
  final List<String> positiveIngredients;
  final List<String> negativeIngredients;
  final String? analysisResult;
  final DateTime? scannedAt;

  ProductScanResult({
    this.id,
    this.productName,
    this.brand,
    this.compatible,
    this.compatibilityScore,
    this.positiveIngredients = const [],
    this.negativeIngredients = const [],
    this.analysisResult,
    this.scannedAt,
  });

  factory ProductScanResult.fromJson(Map<String, dynamic> j) => ProductScanResult(
        id: j['id'],
        productName: j['productName'],
        brand: j['brand'],
        compatible: j['compatible'],
        compatibilityScore: j['compatibilityScore'],
        positiveIngredients: (j['positiveIngredients'] as List? ?? [])
            .map((e) => e.toString())
            .toList(),
        negativeIngredients: (j['negativeIngredients'] as List? ?? [])
            .map((e) => e.toString())
            .toList(),
        analysisResult: j['analysisResult'],
        scannedAt: j['scannedAt'] != null ? DateTime.parse(j['scannedAt']) : null,
      );
}

// ─── Notification Model ───────────────────────────────────────────────────────

class AppNotification {
  final int id;
  final String type;
  final String title;
  final String message;
  final bool read;
  final DateTime? createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.read,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'],
        type: j['type'] ?? '',
        title: j['title'] ?? '',
        message: j['message'] ?? '',
        read: j['read'] ?? false,
        createdAt: j['createdAt'] != null ? DateTime.parse(j['createdAt']) : null,
      );

  String get emoji {
    switch (type) {
      case 'ANALYSE_REMINDER':    return '🔍';
      case 'REPORT_READY':        return '📊';
      case 'ROUTINE_REMINDER':    return '⏰';
      case 'NEW_RECOMMENDATION':  return '✨';
      case 'PROGRESS_UPDATE':     return '📈';
      default:                    return '🔔';
    }
  }
}

// ─── Skin Report Model ────────────────────────────────────────────────────────

class SkinReport {
  final int id;
  final String title;
  final double averageOverallScore;
  final double averageHydrationScore;
  final double averageAcneScore;
  final double averagePigmentationScore;
  final String globalSummary;
  final String progressNotes;
  final DateTime generatedAt;
  final String? pdfUrl;

  SkinReport({
    required this.id,
    required this.title,
    required this.averageOverallScore,
    required this.averageHydrationScore,
    required this.averageAcneScore,
    required this.averagePigmentationScore,
    required this.globalSummary,
    required this.progressNotes,
    required this.generatedAt,
    this.pdfUrl,
  });

  factory SkinReport.fromJson(Map<String, dynamic> j) => SkinReport(
        id: j['id'] ?? 0,
        title: j['title']?.toString() ?? '',
        averageOverallScore: (j['averageOverallScore'] as num?)?.toDouble() ?? 0.0,
        averageHydrationScore: (j['averageHydrationScore'] as num?)?.toDouble() ?? 0.0,
        averageAcneScore: (j['averageAcneScore'] as num?)?.toDouble() ?? 0.0,
        averagePigmentationScore: (j['averagePigmentationScore'] as num?)?.toDouble() ?? 0.0,
        globalSummary: j['globalSummary']?.toString() ?? '',
        progressNotes: j['progressNotes']?.toString() ?? '',
        generatedAt: j['generatedAt'] != null ? DateTime.parse(j['generatedAt']) : DateTime.now(),
        pdfUrl: j['pdfUrl']?.toString(),
      );
}
