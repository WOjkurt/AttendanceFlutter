import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_page.dart';
import 'attendance_status_page.dart';
import '../blocs/qr_scan_bloc.dart';
import 'reminders_page.dart';

class QrScanPage extends StatelessWidget {
  const QrScanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QrScanBloc(),
      child: const _QrScanPageContent(),
    );
  }
}

class _QrScanPageContent extends StatefulWidget {
  const _QrScanPageContent({Key? key}) : super(key: key);

  @override
  State<_QrScanPageContent> createState() => _QrScanPageContentState();
}

class _QrScanPageContentState extends State<_QrScanPageContent> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  void _onDetect(BarcodeCapture capture) {
    // If we're already processing or succeeded, don't trigger again
    final state = context.read<QrScanBloc>().state;
    if (state is QrScanProcessing || state is QrScanSuccess) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      if (barcode.rawValue != null) {
        context.read<QrScanBloc>().add(ScanQrCode(barcode.rawValue!));
      }
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QrScanBloc, QrScanState>(
      listener: (context, state) {
        if (state is QrScanSuccess) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AttendanceStatusPage(),
            ),
          ).then((_) {
            // Reset scanner state when coming back to the scanner
            if (mounted) {
              context.read<QrScanBloc>().add(ResetScanner());
            }
          });
        } else if (state is QrScanError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
          context.read<QrScanBloc>().add(ResetScanner());
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: BlocBuilder<QrScanBloc, QrScanState>(
                  builder: (context, state) {
                    return _buildScannerContainer(state);
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40), // Balance the avatar width
          
          const Text(
            'Scan the QR Code',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerContainer(QrScanState state) {
    bool isProcessingOrSuccess = state is QrScanProcessing || state is QrScanSuccess;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
      padding: const EdgeInsets.all(30.0),
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade50,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Place the QR Code\nwithin this box to scan\nyour attendance',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A5568),
            ),
          ),
          const SizedBox(height: 50),
          
          Stack(
            alignment: Alignment.center,
            children: [
              DottedBorder(
                color: Colors.blue.shade700,
                strokeWidth: 3,
                dashPattern: const [12, 10],
                borderType: BorderType.RRect,
                radius: const Radius.circular(24),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(24)),
                  child: Container(
                    width: 250,
                    height: 250,
                    color: Colors.white,
                    child: isProcessingOrSuccess 
                        ? const Center(child: CircularProgressIndicator())
                        : MobileScanner(
                            controller: _scannerController,
                            onDetect: _onDetect,
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Home
            InkWell(
              onTap: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Icon(
                Icons.home_rounded,
                color: Colors.grey.shade400,
                size: 28,
              ),
            ),
            // Reminders
            InkWell(
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RemindersPage()));
              },
              child: Icon(
                Icons.folder_outlined,
                color: Colors.grey.shade400,
                size: 28,
              ),
            ),
            // QR Scan / Attendance — active
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time_outlined, color: Colors.blue.shade700, size: 28),
                ],
              ),
            ),
            // Profile
            InkWell(
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
              },
              child: Icon(
                Icons.person_outline,
                color: Colors.grey.shade400,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
} // End of file
