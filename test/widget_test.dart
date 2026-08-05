import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Initials Logic Tests', () {
    String getInitials(String? name) {
      if (name == null || name.isEmpty) return 'G';
      return name.length >= 2
          ? name.substring(0, 2).toUpperCase()
          : name.toUpperCase();
    }

    test('should extract 2 characters for long names', () {
      expect(getInitials('John'), 'JO');
    });

    test('should extract 1 character for single-letter names', () {
      expect(getInitials('A'), 'A');
    });

    test('should return placeholder for empty name', () {
      expect(getInitials(''), 'G');
      expect(getInitials(null), 'G');
    });
  });

  group('DonutChartPainter Ratios Tests', () {
    List<double> calculateGaps(double presentRate, double absentRate, double lateRate) {
      final totalPct = presentRate + absentRate + lateRate;
      final normalizedPresent = totalPct > 0 ? presentRate / totalPct : 0.0;
      final normalizedAbsent = totalPct > 0 ? absentRate / totalPct : 0.0;

      return [
        0.0,
        normalizedPresent,
        normalizedPresent + normalizedAbsent,
        1.0,
      ];
    }

    test('should calculate correct gaps when all categories have values', () {
      final gaps = calculateGaps(8.0, 1.0, 1.0); // 80% Present, 10% Absent, 10% Late
      expect(gaps, [0.0, 0.8, 0.9, 1.0]);
    });

    test('should handle zero total cases safely', () {
      final gaps = calculateGaps(0.0, 0.0, 0.0);
      expect(gaps, [0.0, 0.0, 0.0, 1.0]);
    });
  });
}
