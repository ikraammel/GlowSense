import 'package:equatable/equatable.dart';
import '../../data/models/coach_model.dart';
abstract class CoachState extends Equatable {
  const CoachState();
  @override List<Object?> get props => [];
}
class CoachInitial extends CoachState { const CoachInitial(); }
class CoachLoading extends CoachState { const CoachLoading(); }
class CoachMessagesUpdated extends CoachState {
  final List<CoachMessageModel> messages;
  const CoachMessagesUpdated(this.messages);
  @override List<Object?> get props => [messages];
}
class CoachError extends CoachState {
  final String message;
  const CoachError(this.message);
  @override List<Object?> get props => [message];
}
