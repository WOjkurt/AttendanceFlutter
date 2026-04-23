/// Barrel file — one import gives access to the full external API layer.
///
/// Usage anywhere in the app:
///   import 'package:flutterproj/services/api/api.dart';
library;

// ─── Core ─────────────────────────────────────────────────────────────────────
export 'core/api_config.dart';
export 'core/api_exception.dart';
export 'core/api_client.dart';

// ─── Controllers ──────────────────────────────────────────────────────────────
export 'controllers/school_system_controller.dart';
export 'controllers/ai_controller.dart';

// ─── Models › School ──────────────────────────────────────────────────────────
export 'models/school/student_profile.dart';
export 'models/school/attendance_record.dart';
export 'models/school/schedule_entry.dart';

// ─── Models › AI ──────────────────────────────────────────────────────────────
export 'models/ai/analysis_result.dart';
export 'models/ai/summary_report.dart';
export 'models/ai/risk_prediction.dart';
