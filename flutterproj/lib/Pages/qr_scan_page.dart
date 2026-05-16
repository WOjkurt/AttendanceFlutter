import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/qr_scan_bloc.dart';
import '../controllers/token_controller.dart';
import '../services/student_service.dart';

class QrScanPage extends StatelessWidget {
  const QrScanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QrScanBloc(
        studentService: StudentService(),
        tokenController: TokenController(),
      )..add(const LoadQrCode()),
      child: const _QrScanPageContent(),
    );
  }
}

class _QrScanPageContent extends StatelessWidget {
  const _QrScanPageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: BlocBuilder<QrScanBloc, QrScanState>(
                builder: (context, state) {
                  if (state is QrScanLoading || state is QrScanInitial) {
                    return _buildLoading();
                  }
                  if (state is QrScanError) {
                    return _buildError(context, state);
                  }
                  if (state is QrScanLoaded) {
                    return _buildQrDisplay(context, state);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Center(
        child: Text(
          'My QR Code',
          style: GoogleFonts.sourceSans3(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1F36),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF2E3192)),
    );
  }

  Widget _buildError(BuildContext context, QrScanError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              state.isColdStart
                  ? Icons.cloud_off_rounded
                  : Icons.error_outline_rounded,
              size: 64,
              color: const Color(0xFF2E3192).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              state.isColdStart
                  ? 'Server is waking up...'
                  : 'Failed to load QR Code',
              style: GoogleFonts.sourceSans3(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1F36),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.isColdStart
                  ? 'The server takes 30–60 seconds to wake up. Please try again.'
                  : state.message,
              textAlign: TextAlign.center,
              style: GoogleFonts.sourceSans3(
                fontSize: 14,
                color: const Color(0xFF4A5568),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<QrScanBloc>().add(const RefreshQrCode()),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'Try Again',
                style: GoogleFonts.sourceSans3(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E3192),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrDisplay(BuildContext context, QrScanLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Show this QR to your teacher\nto mark your attendance',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sourceSans3(
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4A5568),
                  ),
                ),
                const SizedBox(height: 32),

                // QR Image
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF2E3192).withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.memory(state.imageBytes, fit: BoxFit.contain),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Your QR code is unique to you.\nDo not share it with others.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sourceSans3(
                    fontSize: 13,
                    color: const Color(0xFF4A5568).withOpacity(0.7),
                  ),
                ),

                const SizedBox(height: 24),

                // Refresh button
                TextButton.icon(
                  onPressed: () =>
                      context.read<QrScanBloc>().add(const RefreshQrCode()),
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Color(0xFF2E3192),
                    size: 18,
                  ),
                  label: Text(
                    'Refresh QR Code',
                    style: GoogleFonts.sourceSans3(
                      color: const Color(0xFF2E3192),
                      fontWeight: FontWeight.w600,
                    ),
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
