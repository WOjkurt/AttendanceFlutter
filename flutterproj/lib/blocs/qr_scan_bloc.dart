import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:typed_data';
import '../services/student_service.dart';
import '../controllers/token_controller.dart';

// ─── Events ──────────────────────────────────────────────────────────────────

abstract class QrScanEvent extends Equatable {
  const QrScanEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when the QR page is opened — loads the student's QR image.
class LoadQrCode extends QrScanEvent {
  const LoadQrCode();
}

/// Triggered by the refresh button to re-fetch the QR image.
class RefreshQrCode extends QrScanEvent {
  const RefreshQrCode();
}

// ─── States ──────────────────────────────────────────────────────────────────

abstract class QrScanState extends Equatable {
  const QrScanState();

  @override
  List<Object?> get props => [];
}

class QrScanInitial extends QrScanState {
  const QrScanInitial();
}

class QrScanLoading extends QrScanState {
  const QrScanLoading();
}

/// QR image loaded successfully. [imageBytes] is the raw PNG from the backend.
class QrScanLoaded extends QrScanState {
  final Uint8List imageBytes;

  const QrScanLoaded(this.imageBytes);

  @override
  List<Object?> get props => [imageBytes];
}

class QrScanError extends QrScanState {
  final String message;
  final bool isColdStart;

  const QrScanError(this.message, {this.isColdStart = false});

  @override
  List<Object?> get props => [message, isColdStart];
}

// ─── BLoC ────────────────────────────────────────────────────────────────────

/// Fetches and displays the student's personal QR code.
///
/// Flow:
///   1. Call GET /api/Student/Qr_In_Student_By_Login with JWT auth token.
///   2. The backend infers the student from the logged-in user.
///   3. Emit [QrScanLoaded] with the raw PNG bytes for display.
///
/// The teacher's app (separate project) handles scanning and posting attendance
/// via POST /AttendanceStudentManagement/AttendanceStudent.
class QrScanBloc extends Bloc<QrScanEvent, QrScanState> {
  final StudentService _studentService;
  final TokenController _tokenController;

  QrScanBloc({StudentService? studentService, TokenController? tokenController})
    : _studentService = studentService ?? StudentService(),
      _tokenController = tokenController ?? TokenController(),
      super(const QrScanInitial()) {
    on<LoadQrCode>(_onLoadQrCode);
    on<RefreshQrCode>(_onRefreshQrCode);
  }

  Future<void> _onLoadQrCode(
    LoadQrCode event,
    Emitter<QrScanState> emit,
  ) async {
    emit(const QrScanLoading());
    await _fetchQr(emit);
  }

  Future<void> _onRefreshQrCode(
    RefreshQrCode event,
    Emitter<QrScanState> emit,
  ) async {
    emit(const QrScanLoading());
    await _fetchQr(emit);
  }

  Future<void> _fetchQr(Emitter<QrScanState> emit) async {
    try {
      final imageBytes = await _studentService.getStudentQrCode();
      emit(QrScanLoaded(imageBytes));
    } catch (e) {
      final message = e
          .toString()
          .replaceAll('ApiException: ', '')
          .replaceAll('Exception: ', '');

      final isColdStart =
          message.contains('503') ||
          message.contains('cold') ||
          message.contains('waking');

      emit(QrScanError(message, isColdStart: isColdStart));
    }
  }
}
