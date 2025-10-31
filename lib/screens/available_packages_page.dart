import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:day12_login/data/models/membership_package.dart';
import 'package:day12_login/data/services/membership_service.dart';

class AvailablePackagesPage extends StatefulWidget {
  const AvailablePackagesPage({super.key});

  @override
  State<AvailablePackagesPage> createState() => _AvailablePackagesPageState();
}

class _AvailablePackagesPageState extends State<AvailablePackagesPage> {
  final MembershipService _service = MembershipService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Membership Packages"),
        backgroundColor: const Color(0xFF6C5CE7),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<MembershipPackage>>(
          future: _service.getAllPackages(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text("No packages available.",
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
              );
            }

            final packages = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: packages.length,
              itemBuilder: (context, index) {
                final pkg = packages[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pkg.packageName,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(pkg.packageDescription),
                        const SizedBox(height: 6),
                        Text("Price: ${pkg.packagePrice} VND"),
                        Text("Duration: ${pkg.packageDurationDays} days"),
                        Text("Generations: ${pkg.modelGenerationLimitDisplay}"),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C5CE7),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () async {
                              try {
                                final result =
                                await _service.purchasePackage(pkg.packageId);

                                if (result['success'] == true) {
                                  final type =
                                  result['packageType']?.toString().toLowerCase();

                                  if (type == 'free') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(result['message'] ??
                                              'Subscribed successfully!')),
                                    );
                                  } else if (type == 'paid' &&
                                      result['paymentUrl'] != null) {
                                    final url = result['paymentUrl'] as String;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                          Text("Redirecting to VNPAY...")),
                                    );
                                    await _openPaymentUrl(url);
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(result['message'] ??
                                            'Failed to subscribe')),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            },
                            icon: const Icon(Icons.check),
                            label: const Text("Subscribe"),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _openPaymentUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
