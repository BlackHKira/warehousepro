import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../theme/app_theme.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final _controller = MobileScannerController();
  final _manualCtrl = TextEditingController();
  bool _showManual = false;
  bool _detected = false;

  @override
  void dispose() {
    _controller.dispose();
    _manualCtrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_detected) return;
    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode != null && barcode.isNotEmpty) {
      _detected = true;
      Navigator.pop(context, barcode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét mã vạch'),
        actions: [
          IconButton(
            icon: Icon(_showManual ? Icons.qr_code_scanner : Icons.keyboard),
            tooltip: _showManual ? 'Quét camera' : 'Nhập thủ công',
            onPressed: () => setState(() => _showManual = !_showManual),
          ),
        ],
      ),
      body: _showManual ? _buildManual() : _buildScanner(),
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 40,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
              child: const Text('Đưa mã vạch vào khung hình', style: TextStyle(color: Colors.white70, fontSize: 14)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManual() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.qr_code, size: 80, color: AppColors.primary),
          const SizedBox(height: 24),
          TextField(
            controller: _manualCtrl,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Nhập mã vạch',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.qr_code_scanner),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (v) {
              if (v.trim().isNotEmpty) Navigator.pop(context, v.trim());
            },
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              if (_manualCtrl.text.trim().isNotEmpty) Navigator.pop(context, _manualCtrl.text.trim());
            },
            icon: const Icon(Icons.search),
            label: const Text('Tra cứu'),
          ),
        ],
      ),
    );
  }
}
