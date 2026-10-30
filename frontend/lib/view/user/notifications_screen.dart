import 'package:flutter/material.dart';
import '../../const/app_colors.dart';
import '../../model/notification_model.dart';
import '../../repo/notification_repo.dart';

class NotificationsScreen extends StatefulWidget {
  NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationRepo notificationRepo = NotificationRepo();
  List<NotificationModel> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    setState(() {
      isLoading = true;
    });

    try {
      final items = await notificationRepo.getNotifications();
      setState(() {
        notifications = items;
        isLoading = false;
      });
    } catch (_) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> markAllRead() async {
    final success = await notificationRepo.markAllAsRead();
    if (success) {
      setState(() {
        notifications = notifications.map((n) {
          return NotificationModel(
            id: n.id,
            userId: n.userId,
            title: n.title,
            message: n.message,
            type: n.type,
            isRead: true,
            createdAt: n.createdAt,
          );
        }).toList();
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All notifications marked as read'),
          backgroundColor: AppColors.successColor,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> markSingleRead(NotificationModel item) async {
    if (item.isRead) return;

    await notificationRepo.markAsRead(item.id);
    setState(() {
      final index = notifications.indexWhere((n) => n.id == item.id);
      if (index != -1) {
        notifications[index] = NotificationModel(
          id: item.id,
          userId: item.userId,
          title: item.title,
          message: item.message,
          type: item.type,
          isRead: true,
          createdAt: item.createdAt,
        );
      }
    });
  }

  Future<void> deleteNotification(int id) async {
    final success = await notificationRepo.deleteNotification(id);
    if (success) {
      setState(() {
        notifications.removeWhere((n) => n.id == id);
      });
    }
  }

  Future<void> clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Clear All Notifications', style: TextStyle(color: AppColors.primaryText)),
          content: Text('Are you sure you want to remove all notifications?', style: TextStyle(color: AppColors.secondaryText)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorColor),
              onPressed: () => Navigator.pop(context, true),
              child: Text('Clear', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final success = await notificationRepo.clearAllNotifications();
      if (success) {
        setState(() {
          notifications.clear();
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('All notifications cleared'),
            backgroundColor: AppColors.cardColor,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  IconData getNotificationIcon(String type) {
    if (type == 'booking') {
      return Icons.directions_car_rounded;
    } else if (type == 'promotion') {
      return Icons.local_offer_outlined;
    } else {
      return Icons.notifications_active_outlined;
    }
  }

  Color getNotificationColor(String type) {
    if (type == 'booking') {
      return AppColors.successColor;
    } else if (type == 'promotion') {
      return AppColors.warningColor;
    } else {
      return AppColors.primaryColor;
    }
  }

  String formatTime(String rawDate) {
    if (rawDate.isEmpty) return 'Recent';
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      final diff = DateTime.now().difference(dt);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return 'Recent';
    }
  }

  @override
  Widget build(BuildContext context) {
    final int unreadCount = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (unreadCount > 0)
            IconButton(
              icon: Icon(Icons.done_all_rounded, color: AppColors.primaryColor),
              tooltip: 'Mark all as read',
              onPressed: markAllRead,
            ),
          if (notifications.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep_outlined, color: AppColors.secondaryText),
              tooltip: 'Clear all',
              onPressed: clearAll,
            ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              )
            : notifications.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.cardColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.notifications_off_outlined,
                              color: AppColors.secondaryText,
                              size: 54,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'No Notifications Yet',
                            style: TextStyle(
                              color: AppColors.primaryText,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'You are all caught up! New updates about your car rentals and special deals will appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 24),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.cardColor,
                              foregroundColor: AppColors.primaryText,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: AppColors.borderColor),
                              ),
                            ),
                            icon: Icon(Icons.refresh, size: 18),
                            label: Text('Refresh'),
                            onPressed: loadNotifications,
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    color: AppColors.primaryColor,
                    backgroundColor: AppColors.cardColor,
                    onRefresh: loadNotifications,
                    child: ListView.separated(
                      padding: EdgeInsets.all(16),
                      itemCount: notifications.length,
                      separatorBuilder: (context, index) => SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = notifications[index];
                        final IconData icon = getNotificationIcon(item.type);
                        final Color color = getNotificationColor(item.type);
                        final String timeStr = formatTime(item.createdAt);

                        return Dismissible(
                          key: Key('notif_${item.id}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: AppColors.errorColor.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(Icons.delete_outline, color: Colors.white, size: 26),
                          ),
                          onDismissed: (_) {
                            deleteNotification(item.id);
                          },
                          child: GestureDetector(
                            onTap: () => markSingleRead(item),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: item.isRead
                                    ? AppColors.cardColor
                                    : AppColors.cardColor.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: item.isRead
                                      ? AppColors.borderColor
                                      : color.withValues(alpha: 0.5),
                                  width: item.isRead ? 1 : 1.5,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Icon Badge
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(icon, color: color, size: 22),
                                  ),
                                  SizedBox(width: 14),
                                  // Title, Message, Time
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.title,
                                                style: TextStyle(
                                                  color: AppColors.primaryText,
                                                  fontSize: 15,
                                                  fontWeight: item.isRead
                                                      ? FontWeight.w600
                                                      : FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            if (!item.isRead)
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: color,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          item.message,
                                          style: TextStyle(
                                            color: item.isRead
                                                ? AppColors.secondaryText
                                                : AppColors.primaryText.withValues(alpha: 0.85),
                                            fontSize: 13,
                                            height: 1.35,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          timeStr,
                                          style: TextStyle(
                                            color: AppColors.secondaryText.withValues(alpha: 0.6),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
