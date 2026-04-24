import 'package:equatable/equatable.dart';
import '../../data/models/notification_model.dart';
abstract class NotificationState extends Equatable {
  const NotificationState();
  @override List<Object?> get props => [];
}
class NotificationInitial extends NotificationState { const NotificationInitial(); }
class NotificationLoading extends NotificationState { const NotificationLoading(); }
class NotificationsLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  const NotificationsLoaded(this.notifications);
  @override List<Object?> get props => [notifications];
}
class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);
  @override List<Object?> get props => [message];
}
