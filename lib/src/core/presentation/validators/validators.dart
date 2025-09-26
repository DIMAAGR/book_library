import 'package:intl/intl.dart';

final _dfDate = DateFormat('dd/MM/yyyy');
final _dfTime = DateFormat('HH:mm');

bool _isCompleteDate(String s) => RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(s);
bool _isCompleteTime(String s) => RegExp(r'^\d{2}:\d{2}$').hasMatch(s);

DateTime? _parseDateStrict(String s) {
  try {
    return _dfDate.parseStrict(s);
  } catch (_) {
    return null;
  }
}

DateTime? _parseTimeOnDateStrict(String time, DateTime date) {
  try {
    final t = _dfTime.parseStrict(time);
    return DateTime(date.year, date.month, date.day, t.hour, t.minute);
  } catch (_) {
    return null;
  }
}

DateTime _todayAtMidnight() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

String? validateTitle(String? v) {
  if (v == null || v.trim().isEmpty) return 'error_title_required';
  return null;
}

String? validateDate(String? s) {
  if (s == null || s.trim().isEmpty) return null;

  if (!_isCompleteDate(s)) return 'error_invalid_date_format';

  final d = _parseDateStrict(s);
  if (d == null) return 'error_invalid_date';

  if (d.isBefore(_todayAtMidnight())) return 'error_date_before_today';
  return null;
}

String? validateTime(String? timeStr, {String? dateStr}) {
  if (timeStr == null || timeStr.trim().isEmpty) return null;

  if (!_isCompleteTime(timeStr)) return 'error_invalid_time_format';

  DateTime baseDate;
  if (dateStr != null && dateStr.trim().isNotEmpty && _isCompleteDate(dateStr)) {
    final d = _parseDateStrict(dateStr);
    if (d == null) return 'error_invalid_time';
    baseDate = d;
  } else {
    baseDate = _todayAtMidnight();
  }

  final dt = _parseTimeOnDateStrict(timeStr, baseDate);
  if (dt == null) return 'error_invalid_time';

  final now = DateTime.now();
  if (DateTime(baseDate.year, baseDate.month, baseDate.day).isAtSameMomentAs(_todayAtMidnight())) {
    if (dt.isBefore(now)) return 'error_time_before_now';
  }
  return null;
}
