import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../bloc/notification/notification_event.dart';
import '../../bloc/notification/notification_state.dart';
import '../../constants/colors.dart';
import '../../data/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(const LoadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => context.read<NotificationBloc>().add(const MarkAllRead()),
            child: const Text("Mark all read", style: TextStyle(color: AppColors.primaryPink)),
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (ctx, state) {
          if (state is NotificationLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primaryPink));
          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return const Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.notifications_none, size: 60, color: Colors.grey),
                  SizedBox(height: 12),
                  Text("No notifications yet", style: TextStyle(color: AppColors.textGrey, fontSize: 16)),
                ]),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) => _NotifCard(
                notif: state.notifications[i],
                onTap: () => ctx.read<NotificationBloc>().add(MarkOneRead(state.notifications[i].id)),
              ),
            );
          }
          if (state is NotificationError) {
            return Center(child: Text(state.message, style: const TextStyle(color: AppColors.error)));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final NotificationModel notif;
  final VoidCallback onTap;
  const _NotifCard({required this.notif, required this.onTap});

  IconData _iconForType(String type) {
    switch (type) {
      case 'ANALYSE_REMINDER': return Icons.camera_alt_outlined;
      case 'REPORT_READY': return Icons.description_outlined;
      case 'ROUTINE_REMINDER': return Icons.schedule;
      case 'NEW_RECOMMENDATION': return Icons.lightbulb_outline;
      case 'PROGRESS_UPDATE': return Icons.trending_up;
      default: return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead ? Colors.white : AppColors.primaryPink.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notif.isRead ? Colors.grey.shade200 : AppColors.primaryPink.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: notif.isRead ? Colors.grey.shade100 : AppColors.primaryPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_iconForType(notif.type),
                  color: notif.isRead ? Colors.grey : AppColors.deepPink, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notif.title, style: TextStyle(
                    fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold, fontSize: 14,
                  )),
                  const SizedBox(height: 3),
                  Text(notif.message, style: const TextStyle(color: AppColors.textGrey, fontSize: 12), maxLines: 2),
                ],
              ),
            ),
            if (!notif.isRead)
              Container(width: 8, height: 8, decoration: const BoxDecoration(
                  color: AppColors.primaryPink, shape: BoxShape.circle)),
          ],
        ),
      ),
    );
  }
}
