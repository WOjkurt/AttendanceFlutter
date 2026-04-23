import '../core/api_client.dart';
import '../core/api_config.dart';
import '../models/ai/analysis_result.dart';
import '../models/ai/summary_report.dart';
import '../models/ai/risk_prediction.dart';

/// Handles all HTTP communication with the external **AI integration service**.
///
/// This controller is responsible **only** for mapping endpoints to method
/// calls and converting raw JSON into typed model objects.
/// Business logic belongs in the BLoC layer, not here.
///
/// ─── Setup ──────────────────────────────────────────────────────────────────
/// 1. Fill in [ApiConfig.aiServiceBaseUrl] and [ApiConfig.aiServiceApiKey].
/// 2. Add/rename methods below as the real AI endpoints become available.
/// 3. Inject into the relevant BLoC the same way [AuthService] is injected.
/// ────────────────────────────────────────────────────────────────────────────
class AiController {
  late final ApiClient _client;

  AiController()
      : _client = ApiClient(
          baseUrl: ApiConfig.aiServiceBaseUrl,
          apiKey: ApiConfig.aiServiceApiKey,
        );

  /// Visible for testing — allows injecting a mock [ApiClient].
  AiController.withClient(this._client);

  // ─── Analysis ─────────────────────────────────────────────────────────────

  /// Sends an attendance snapshot to the AI service and returns its analysis
  /// (anomalies, risk flags, summaries, etc.).
  ///
  /// [attendanceData] must be JSON-serialisable and match the schema the
  /// AI service expects.
  ///
  /// TODO: Replace '/analyze/attendance' with the real endpoint path.
  Future<AnalysisResult> analyzeAttendance(
    Map<String, dynamic> attendanceData,
  ) async {
    final data = await _client.post('/analyze/attendance', body: attendanceData);
    return AnalysisResult.fromJson(Map<String, dynamic>.from(data as Map));
  }

  // ─── Reports ──────────────────────────────────────────────────────────────

  /// Requests an AI-generated summary report for [classId]
  /// within [startDate]–[endDate] (ISO-8601 date strings).
  ///
  /// TODO: Replace '/reports/summary' with the real endpoint path.
  Future<SummaryReport> getSummaryReport({
    required String classId,
    required String startDate,
    required String endDate,
  }) async {
    final data = await _client.get(
      '/reports/summary',
      queryParams: {
        'classId': classId,
        'startDate': startDate,
        'endDate': endDate,
      },
    );
    return SummaryReport.fromJson(Map<String, dynamic>.from(data as Map));
  }

  // ─── Predictions ──────────────────────────────────────────────────────────

  /// Asks the AI service to predict attendance risk for [studentId].
  /// Returns a typed [RiskPrediction] with a score and reasoning.
  ///
  /// TODO: Replace '/predict/risk' with the real endpoint path.
  Future<RiskPrediction> predictAttendanceRisk(String studentId) async {
    final data = await _client.get('/predict/risk/$studentId');
    return RiskPrediction.fromJson(Map<String, dynamic>.from(data as Map));
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  void dispose() => _client.dispose();
}
