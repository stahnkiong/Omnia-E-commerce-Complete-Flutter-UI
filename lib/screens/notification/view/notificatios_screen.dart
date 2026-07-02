import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pasar_now/constants.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _formatDateTime(String isoString) {
    final dateTime = DateTime.tryParse(isoString);
    if (dateTime == null) return '';
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          PopupMenuButton<String>(
            icon: SvgPicture.asset(
              "assets/icons/DotsV.svg",
              colorFilter: ColorFilter.mode(
                Theme.of(context).iconTheme.color!,
                BlendMode.srcIn,
              ),
            ),
            onSelected: (value) async {
              if (value == 'clear') {
                try {
                  final box = Hive.box('notifications');
                  await box.clear();
                } catch (e) {
                  // Fallback in case box is not opened yet in main memory
                  final box = await Hive.openBox('notifications');
                  await box.clear();
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Text('Clear All'),
              ),
            ],
          )
        ],
      ),
      body: FutureBuilder<Box>(
        future: Hive.openBox('notifications').then((box) async {
          for (var key in box.keys) {
            final notification = box.get(key);
            if (notification is Map && notification['is_read'] != true) {
              final updated = Map<String, dynamic>.from(notification);
              updated['is_read'] = true;
              await box.put(key, updated);
            }
          }
          return box;
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final box = snapshot.data!;
          return ValueListenableBuilder<Box>(
            valueListenable: box.listenable(),
            builder: (context, box, _) {
              if (box.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.notifications_none,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: defaultPadding),
                      Text(
                        "No Notifications Yet",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              final notifications = box.values.toList().reversed.toList();
              return ListView.separated(
                padding: const EdgeInsets.all(defaultPadding),
                itemCount: notifications.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final notification =
                      Map<String, dynamic>.from(notifications[index] as Map);
                  final title = notification['title'] ?? '';
                  final body = notification['body'] ?? '';
                  final deliveredAt = notification['delivered_at'] ?? '';

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: defaultPadding / 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(defaultPadding / 2),
                          decoration: BoxDecoration(
                            color: primaryColor.withAlpha(26),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_active,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: defaultPadding),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    _formatDateTime(deliveredAt),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: defaultPadding / 4),
                              Text(
                                body,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
