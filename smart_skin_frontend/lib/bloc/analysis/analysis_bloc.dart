import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/api_service.dart';
import 'analysis_event.dart';
import 'analysis_state.dart';

class AnalysisBloc extends Bloc<AnalysisEvent, AnalysisState> {
  final ApiService _api;
  AnalysisBloc({required ApiService api}) : _api = api, super(const AnalysisInitial()) {
    on<SubmitAnalysis>(_submit);
    on<LoadAnalysisHistory>(_loadHistory);
  }
  Future<void> _submit(SubmitAnalysis e, Emitter<AnalysisState> emit) async {
    emit(const AnalysisLoading());
    try {
      final result = await _api.analyzeSkin(e.imagePath);
      emit(AnalysisDone(result));
    } catch (err) { emit(AnalysisError(err.toString())); }
  }
  Future<void> _loadHistory(LoadAnalysisHistory e, Emitter<AnalysisState> emit) async {
    emit(const AnalysisLoading());
    try {
      final list = await _api.getAnalysisHistory();
      emit(AnalysisHistoryLoaded(list));
    } catch (err) { emit(AnalysisError(err.toString())); }
  }
}
