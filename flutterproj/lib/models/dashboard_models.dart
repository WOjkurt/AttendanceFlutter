import 'package:flutter/material.dart';

/// Represents the current/active event shown on the dashboard.
class CurrentEvent {
  final String title;
  final String timeRange;
  final String location;

  const CurrentEvent({
    required this.title,
    required this.timeRange,
    required this.location,
  });
}

/// Represents an upcoming reminder item shown on the dashboard.
class UpcomingReminder {
  final String title;
  final String subtitle;
  final IconData icon;

  const UpcomingReminder({
    required this.title,
    required this.subtitle,
    this.icon = Icons.event_note_rounded,
  });
}
