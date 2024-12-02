import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  void _markAsRead(String docId) {
    FirebaseFirestore.instance.collection('notifications').doc(docId).update({
      'isRead': true,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notifications available"));
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index].data() as Map<String, dynamic>;
              final isRead = notification['isRead'] ?? false;
              final docId = notifications[index].id;

              // Format the timestamp
              final timestamp = notification['timestamp'] != null
                  ? (notification['timestamp'] as Timestamp).toDate()
                  : null;
              final formattedTime = timestamp != null
                  ? "${timestamp.day}-${timestamp.month}-${timestamp.year} ${timestamp.hour}:${timestamp.minute}"
                  : "Unknown time";

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  onTap: () => _markAsRead(docId),
                  title: Row(
                    children: [
                      Text(notification['title'] ?? 'Notification'),
                      if (!isRead) // Show dot if the notification is unread
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.circle, color: Colors.red, size: 8),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification['message'] ?? 'No details'),
                      const SizedBox(height: 4), // Add some space between the message and timestamp
                      Text(
                        formattedTime,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
