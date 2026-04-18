import 'package:flutter_bloc/flutter_bloc.dart';

// --- Events ---
abstract class QrScanEvent {}

class ScanQrCode extends QrScanEvent {
  final String rawValue;

  ScanQrCode(this.rawValue);
}

class ResetScanner extends QrScanEvent {}

// --- States ---
abstract class QrScanState {}

class QrScanInitial extends QrScanState {}

class QrScanProcessing extends QrScanState {}

class QrScanSuccess extends QrScanState {
  final String scannedData;

  QrScanSuccess(this.scannedData);
}

class QrScanError extends QrScanState {
  final String message;

  QrScanError(this.message);
}

// --- BLoC ---
class QrScanBloc extends Bloc<QrScanEvent, QrScanState> {
  QrScanBloc() : super(QrScanInitial()) {
    on<ScanQrCode>((event, emit) async {
      emit(QrScanProcessing());

      try {
        // Simulate a network delay for processing attendance
        await Future.delayed(const Duration(seconds: 1));

        // Typically, this is where you'd validate the QR code with your backend.
        // If successful:
        emit(QrScanSuccess(event.rawValue));
        
        // If failed you would throw an exception or emit QrScanError
      } catch (e) {
        emit(QrScanError("Failed to process QR Code."));
      }
    });

    on<ResetScanner>((event, emit) {
      emit(QrScanInitial());
    });
  }
}
