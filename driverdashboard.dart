import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luggagetracker_app/login.dart'; // Import the login page

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  DriverDashboardState createState() => DriverDashboardState();
}

class DriverDashboardState extends State<DriverDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> acceptedRequests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAcceptedRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadAcceptedRequests() async {
    final snapshot = await FirebaseFirestore.instance.collection('accepted_requests').get();
    setState(() {
      acceptedRequests = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }

  void _acceptRequest(Map<String, dynamic> luggage) async {
    setState(() {
      acceptedRequests.insert(0, luggage); // Add the new request at the top
    });
    FirebaseFirestore.instance.collection('luggage').doc(luggage['id']).delete();
    FirebaseFirestore.instance.collection('accepted_requests').add(luggage);
    _sendNotification("Request Accepted", "Luggage ACCEPTED ID: ${luggage['luggageId']}");
  }

  void _updateStatus(String luggageId, String status) {
    String notificationTitle;
    String notificationMessage;

    // Determine the title and message based on status
    switch (status) {
      case "Start":
        notificationTitle = "Trip Started";
        notificationMessage = "Trip STARTED for luggage ID: $luggageId";
        break;
      case "In-Transit":
        notificationTitle = "In Transit";
        notificationMessage = "Luggage ID: $luggageId is now IN-TRANSIT.";
        break;
      case "Arrived":
        notificationTitle = "Arrived";
        notificationMessage = "Luggage ID: $luggageId has ARRIVED at the destination.";
        // Send notification for "Arrived"
        _sendNotification(notificationTitle, notificationMessage);
        // Follow-up notification 5 seconds later
        Future.delayed(const Duration(seconds: 5), () {
          _sendNotification("Ready for Pickup", "Luggage ID: $luggageId is ready for pickup.");
        });
        break;
      default:
        notificationTitle = "Status Updated";
        notificationMessage = "Status updated for luggage ID: $luggageId";
    }

    // Send notification for all other statuses
    if (status != "Arrived") {
      _sendNotification(notificationTitle, notificationMessage);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Status updated to '$status' for luggage ID: $luggageId")),
    );
  }

  void _sendNotification(String title, String message) {
    FirebaseFirestore.instance.collection('notifications').add({
      'title': title,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Dashboard"),
        backgroundColor: Colors.purpleAccent,
        actions: [
          Container(
            decoration: BoxDecoration(
              color: Colors.redAccent, // Background color for the logout button
              borderRadius: BorderRadius.circular(5), // Rounded corners
            ),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'Logout',
              onPressed: _logout,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Incoming Requests"),
            Tab(text: "Accepted Requests"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('luggage').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No incoming luggage requests"));
              }
              final luggageRequests = snapshot.data!.docs.map((doc) {
                return {
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                };
              }).toList();

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      "Incoming Luggage Requests",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: luggageRequests.length,
                        itemBuilder: (context, index) {
                          final luggage = luggageRequests[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text("Request #${index + 1}"),
                              subtitle: Text(
                                "Luggage ID: ${luggage['luggageId']}\n"
                                    "Description: ${luggage['description']}\n"
                                    "Fragile: ${luggage['isFragile'] ?? false ? 'Yes' : 'No'}\n"
                                    "Drop-Off Point: ${luggage['dropOffCounty']}, ${luggage['dropOffSubCounty']}\n"
                                    "Recipient Name: ${luggage['recipientName']}\n"
                                    "Recipient Phone: ${luggage['recipientPhone']}",
                              ),
                              trailing: ElevatedButton(
                                onPressed: () => _acceptRequest(luggage),
                                child: const Text("Accept"),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  "Accepted Luggage Requests",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: acceptedRequests.length,
                    itemBuilder: (context, index) {
                      final accepted = acceptedRequests[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text("Luggage ID: ${accepted['luggageId']}"),
                          subtitle: Text(
                            "Fragile: ${accepted['isFragile'] ?? false ? 'Yes' : 'No'}\n"
                                "Drop-Off Point: ${accepted['dropOffCounty']}, ${accepted['dropOffSubCounty']}\n"
                                "Recipient Name: ${accepted['recipientName']}\n"
                                "Recipient Phone: ${accepted['recipientPhone']}",
                          ),
                          trailing: DropdownButton<String>(
                            items: ["Start", "In-Transit", "Arrived"].map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              );
                            }).toList(),
                            onChanged: (newStatus) {
                              if (newStatus != null) {
                                _updateStatus(accepted['luggageId'], newStatus);
                              }
                            },
                            hint: const Text("Update Status"),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
