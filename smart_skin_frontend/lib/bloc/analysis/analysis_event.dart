import 'package:equatable/equatable.dart';
abstract class AnalysisEvent extends Equatable {
  const AnalysisEvent();
  @override List<Object?> get props => [];
}
class SubmitAnalysis extends AnalysisEvent {
  final String imagePath;
  const SubmitAnalysis(this.imagePath);
  @override List<Object?> get props => [imagePath];
}
class LoadAnalysisHistory extends AnalysisEvent { const LoadAnalysisHistory(); }
