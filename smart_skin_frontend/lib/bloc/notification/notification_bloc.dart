import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/api_service.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final ApiService _api;
  NotificationBloc({required ApiService api}) : _api = api, super(const NotificationInitial()) {
    on<LoadNotifications>(_load);
    on<MarkAllRead>(_markAll);
    on<MarkOneRead>(_markOne);
  }
  Future<void> _load(LoadNotifications e, Emitter<NotificationState> emit) async {
    emit(const NotificationLoading());
    try {
      final list = await _api.getNotifications();
      emit(NotificationsLoaded(list));
    } catch (err) { emit(NotificationError(err.toString())); }
  }
  Future<void> _markAll(MarkAllRead e, Emitter<NotificationState> emit) async {
    try {
      await _api.markAllRead();
      add(const LoadNotifications());
    } catch (_) {}
  }
  Future<void> _markOne(MarkOneRead e, Emitter<NotificationState> emit) async {
    try {
      await _api.markOneRead(e.id);
      add(const LoadNotifications());
    } catch (_) {}
  }
}
