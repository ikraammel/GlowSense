import 'package:equatable/equatable.dart';
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override List<Object?> get props => [];
}
class LoadNotifications extends NotificationEvent { const LoadNotifications(); }
class MarkAllRead extends NotificationEvent { const MarkAllRead(); }
class MarkOneRead extends NotificationEvent {
  final int id;
  const MarkOneRead(this.id);
  @override List<Object?> get props => [id];
}
