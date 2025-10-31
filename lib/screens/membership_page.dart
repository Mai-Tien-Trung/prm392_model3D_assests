import 'package:day12_login/data/models/current_subscription.dart';
import 'package:day12_login/data/models/subscription_history.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/services/membership_service.dart';

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> {
  final MembershipService _service = MembershipService();

  late Future<CurrentSubscription?> _currentSub;
  late Future<List<SubscriptionHistory>> _history;

  @override
  void initState() {
    super.initState();
    _currentSub = _service.getCurrentSubscription();
    _history = _service.getMySubscriptionHistory();
  }

  String formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Membership"),
          backgroundColor: const Color(0xFF6C5CE7),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Current Plan", icon: Icon(Icons.workspace_premium)),
              Tab(text: "History", icon: Icon(Icons.history)),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: TabBarView(
            children: [
              _buildCurrentPlanTab(),
              _buildHistoryTab(),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------
  // TAB 1: GÓI HIỆN DÙNG
  // --------------------------
  Widget _buildCurrentPlanTab() {
    return FutureBuilder<CurrentSubscription?>(
      future: _currentSub,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        } else if (snapshot.hasError) {
          return Center(
            child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(
            child: Text(
              "You have no active subscription.",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          );
        }

        final sub = snapshot.data!;
        Color statusColor = sub.status == "Active"
            ? Colors.green
            : (sub.status == "Cancelled" ? Colors.red : Colors.grey);

        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxWidth: 350),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  sub.packageName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  sub.packageDescription,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                Text("Price: ${sub.packagePrice} VND"),
                Text("Duration: ${sub.packageDurationDays} days"),
                Text("Remaining: ${sub.daysRemaining} days"),
                const SizedBox(height: 4),
                Text("Start: ${formatDate(sub.startDate)}"),
                Text("End: ${formatDate(sub.endDate)}"),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      "Status: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      sub.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --------------------------
  // TAB 2: LỊCH SỬ GÓI
  // --------------------------
  Widget _buildHistoryTab() {
    return FutureBuilder<List<SubscriptionHistory>>(
      future: _history,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        } else if (snapshot.hasError) {
          return Center(
            child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text("No subscription history found.",
                style: TextStyle(color: Colors.white70, fontSize: 16)),
          );
        }

        final history = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final item = history[index];
            Color statusColor = item.status == "Active"
                ? Colors.green
                : (item.status == "Cancelled" ? Colors.red : Colors.grey);

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.only(bottom: 15),
              child: ListTile(
                leading: const Icon(Icons.card_membership, color: Colors.deepPurple),
                title: Text(item.packageName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  "${item.packageDescription}\n"
                      "Price: ${item.packagePrice} VND • ${item.packageDurationDays} days\n"
                      "Created: ${formatDate(item.createdAt)}",
                ),
                trailing: Text(
                  item.status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
