import 'package:equatable/equatable.dart';
import '../../data/models/skin_analysis_model.dart';
abstract class AnalysisState extends Equatable {
  const AnalysisState();
  @override List<Object?> get props => [];
}
class AnalysisInitial extends AnalysisState { const AnalysisInitial(); }
class AnalysisLoading extends AnalysisState { const AnalysisLoading(); }
class AnalysisDone extends AnalysisState {
  final SkinAnalysisModel result;
  const AnalysisDone(this.result);
  @override List<Object?> get props => [result];
}
class AnalysisHistoryLoaded extends AnalysisState {
  final List<SkinAnalysisModel> analyses;
  const AnalysisHistoryLoaded(this.analyses);
  @override List<Object?> get props => [analyses];
}
class AnalysisError extends AnalysisState {
  final String message;
  const AnalysisError(this.message);
  @override List<Object?> get props => [message];
}
