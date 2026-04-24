import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/coach_model.dart';
import '../../data/services/api_service.dart';
import 'coach_event.dart';
import 'coach_state.dart';

class CoachBloc extends Bloc<CoachEvent, CoachState> {
  final ApiService _api;
  final List<CoachMessageModel> messages = [];

  CoachBloc({required ApiService api}) : _api = api, super(const CoachInitial()) {
    on<SendMessage>(_send);
    on<LoadHistory>(_loadHistory);
  }

  Future<void> _send(SendMessage e, Emitter<CoachState> emit) async {
    messages.add(CoachMessageModel(role: 'user', content: e.message, sessionId: e.sessionId));
    emit(CoachMessagesUpdated(List.from(messages)));
    emit(const CoachLoading());
    try {
      final reply = await _api.chatWithCoach(e.message, e.sessionId);
      messages.add(reply);
      emit(CoachMessagesUpdated(List.from(messages)));
    } catch (err) {
      if (messages.isNotEmpty && messages.last.isUser) messages.removeLast();
      emit(CoachError(err.toString()));
    }
  }

  Future<void> _loadHistory(LoadHistory e, Emitter<CoachState> emit) async {
    emit(const CoachLoading());
    try {
      final history = await _api.getCoachHistory(e.sessionId);
      messages.clear();
      messages.addAll(history);
      emit(CoachMessagesUpdated(List.from(messages)));
    } catch (err) { emit(CoachError(err.toString())); }
  }
}
