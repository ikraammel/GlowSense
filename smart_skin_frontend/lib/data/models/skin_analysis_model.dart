class SkinProblemModel {
  final String name;
  final String severity;
  final String description;

  SkinProblemModel({
    required this.name,
    required this.severity,
    this.description = '',
  });

  factory SkinProblemModel.fromJson(Map<String, dynamic> json) => SkinProblemModel(
        name: json['name']?.toString() ?? '',
        severity: json['severity']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
      );
}

class RecommendationModel {
  final String title;
  final String description;
  final String productType;
  final String priority;

  RecommendationModel({
    required this.title,
    required this.description,
    this.productType = '',
    this.priority = '',
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) =>
      RecommendationModel(
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        productType: json['productType']?.toString() ?? '',
        priority: json['priority']?.toString() ?? '',
      );
}

class SkinAnalysisModel {
  final int? id;
  final String? imageUrl;
  final String detectedSkinType;
  final int? overallScore;
  final int? hydrationScore;
  final int? acneScore;
  final int? pigmentationScore;
  final int? wrinkleScore;
  final int? poreScore;
  final String analysisDescription;
  final List<SkinProblemModel> detectedProblems;
  final List<RecommendationModel> recommandations;
  final String analyzedAt;

  SkinAnalysisModel({
    this.id,
    this.imageUrl,
    this.detectedSkinType = '',
    this.overallScore,
    this.hydrationScore,
    this.acneScore,
    this.pigmentationScore,
    this.wrinkleScore,
    this.poreScore,
    this.analysisDescription = '',
    this.detectedProblems = const [],
    this.recommandations = const [],
    this.analyzedAt = '',
  });

  factory SkinAnalysisModel.fromJson(Map<String, dynamic> json) =>
      SkinAnalysisModel(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
        imageUrl: json['imageUrl']?.toString(),
        detectedSkinType: json['detectedSkinType']?.toString() ?? '',
        overallScore: json['overallScore'] is int ? json['overallScore'] : int.tryParse(json['overallScore']?.toString() ?? ''),
        hydrationScore: json['hydrationScore'] is int ? json['hydrationScore'] : int.tryParse(json['hydrationScore']?.toString() ?? ''),
        acneScore: json['acneScore'] is int ? json['acneScore'] : int.tryParse(json['acneScore']?.toString() ?? ''),
        pigmentationScore: json['pigmentationScore'] is int ? json['pigmentationScore'] : int.tryParse(json['pigmentationScore']?.toString() ?? ''),
        wrinkleScore: (json['wrinkleScore'] ?? json['wrainkleScore']) is int 
            ? (json['wrinkleScore'] ?? json['wrainkleScore']) 
            : int.tryParse((json['wrinkleScore'] ?? json['wrainkleScore'])?.toString() ?? ''),
        poreScore: json['poreScore'] is int ? json['poreScore'] : int.tryParse(json['poreScore']?.toString() ?? ''),
        analysisDescription: json['analysisDescription']?.toString() ?? '',
        detectedProblems: (json['detectedProblems'] as List? ?? [])
            .map((e) => SkinProblemModel.fromJson(e))
            .toList(),
        recommandations: (json['recommandations'] as List? ?? [])
            .map((e) => RecommendationModel.fromJson(e))
            .toList(),
        analyzedAt: json['analyzedAt']?.toString() ?? '',
      );
}

class ScorePointModel {
  final String date;
  final int score;
  ScorePointModel({required this.date, required this.score});
  factory ScorePointModel.fromJson(Map<String, dynamic> json) =>
      ScorePointModel(
        date: json['date']?.toString() ?? '',
        score: json['score'] is int ? json['score'] : int.tryParse(json['score']?.toString() ?? '') ?? 0,
      );
}

class ProblemFrequencyModel {
  final String problem;
  final int count;
  ProblemFrequencyModel({required this.problem, required this.count});
  factory ProblemFrequencyModel.fromJson(Map<String, dynamic> json) =>
      ProblemFrequencyModel(
        problem: json['problem']?.toString() ?? '',
        count: json['count'] is int ? json['count'] : int.tryParse(json['count']?.toString() ?? '') ?? 0,
      );
}

class DashboardModel {
  final int totalAnalyses;
  final double averageScore;
  final double? scoreEvolution;
  final int currentStreak;
  final SkinAnalysisModel? lastAnalysis;
  final List<ScorePointModel> scoreHistory;
  final List<ProblemFrequencyModel> topProblems;
  final List<RecommendationModel> latestRecommandations;
  final int unreadNotifications;

  DashboardModel({
    this.totalAnalyses = 0,
    this.averageScore = 0,
    this.scoreEvolution,
    this.currentStreak = 0,
    this.lastAnalysis,
    this.scoreHistory = const [],
    this.topProblems = const [],
    this.latestRecommandations = const [],
    this.unreadNotifications = 0,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
        totalAnalyses: json['totalAnalyses'] is int ? json['totalAnalyses'] : int.tryParse(json['totalAnalyses']?.toString() ?? '') ?? 0,
        averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
        scoreEvolution: (json['scoreEvolution'] as num?)?.toDouble(),
        currentStreak: json['currentStreak'] is int ? json['currentStreak'] : int.tryParse(json['currentStreak']?.toString() ?? '') ?? 0,
        lastAnalysis: json['lastAnalysis'] != null
            ? SkinAnalysisModel.fromJson(json['lastAnalysis'])
            : null,
        scoreHistory: (json['scoreHistory'] as List? ?? [])
            .map((e) => ScorePointModel.fromJson(e))
            .toList(),
        topProblems: (json['topProblems'] as List? ?? [])
            .map((e) => ProblemFrequencyModel.fromJson(e))
            .toList(),
        latestRecommandations: (json['latestRecommandations'] as List? ?? [])
            .map((e) => RecommendationModel.fromJson(e))
            .toList(),
        unreadNotifications: json['unreadNotifications'] is int ? json['unreadNotifications'] : int.tryParse(json['unreadNotifications']?.toString() ?? '') ?? 0,
      );
}
