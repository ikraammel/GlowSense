import 'package:equatable/equatable.dart';
abstract class CoachEvent extends Equatable {
  const CoachEvent();
  @override List<Object?> get props => [];
}
class SendMessage extends CoachEvent {
  final String message, sessionId;
  const SendMessage({required this.message, required this.sessionId});
  @override List<Object?> get props => [message, sessionId];
}
class LoadHistory extends CoachEvent {
  final String sessionId;
  const LoadHistory(this.sessionId);
  @override List<Object?> get props => [sessionId];
}
