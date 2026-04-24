import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/api_service.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final ApiService _api;
  DashboardBloc({required ApiService api}) : _api = api, super(const DashboardInitial()) {
    on<LoadDashboard>(_load);
  }
  Future<void> _load(LoadDashboard e, Emitter<DashboardState> emit) async {
    emit(const DashboardLoading());
    try {
      final data = await _api.getDashboard();
      emit(DashboardLoaded(data));
    } catch (err) { emit(DashboardError(err.toString())); }
  }
}
