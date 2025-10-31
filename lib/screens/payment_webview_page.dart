import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'payment_result_page.dart';

class PaymentWebViewPage extends StatefulWidget {
  final String paymentUrl;

  const PaymentWebViewPage({super.key, required this.paymentUrl});

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onNavigationRequest: (navReq) {
            // Kiểm tra URL callback khi thanh toán xong
            if (navReq.url.contains("vnpay-return")) {
              // Parse query để lấy thông tin cơ bản
              final uri = Uri.parse(navReq.url);
              final bankCode = uri.queryParameters["vnp_BankCode"] ?? "";
              final amount = uri.queryParameters["vnp_Amount"] ?? "";
              final responseCode = uri.queryParameters["vnp_ResponseCode"] ?? "";
              final packageName = uri.queryParameters["vnp_OrderInfo"] ?? "";

              // Nếu thành công (ResponseCode = 00)
              if (responseCode == "00") {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentResultPage(
                      packageName: packageName,
                      bankCode: bankCode,
                      amount: (int.tryParse(amount) ?? 0) ~/ 100, // convert về VND
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Payment failed!")),
                );
                Navigator.pop(context, false);
              }

              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("VNPAY Payment"),
        backgroundColor: const Color(0xFF6C5CE7),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.deepPurple)),
        ],
      ),
    );
  }
}
