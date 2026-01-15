import 'dart:math';

class DistanceCalculator {
  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in kilometers
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Input validation
    if (lat1.isNaN || lon1.isNaN || lat2.isNaN || lon2.isNaN) {
      return 0.0;
    }

    // Check if coordinates are valid (latitude: -90 to 90, longitude: -180 to 180)
    if (lat1 < -90 ||
        lat1 > 90 ||
        lat2 < -90 ||
        lat2 > 90 ||
        lon1 < -180 ||
        lon1 > 180 ||
        lon2 < -180 ||
        lon2 > 180) {
      return 0.0;
    }

    const double earthRadius = 6371; // Earth's radius in kilometers

    // Convert latitude and longitude from degrees to radians
    final double lat1Rad = _degreesToRadians(lat1);
    final double lon1Rad = _degreesToRadians(lon1);
    final double lat2Rad = _degreesToRadians(lat2);
    final double lon2Rad = _degreesToRadians(lon2);

    // Differences in coordinates
    final double deltaLat = lat2Rad - lat1Rad;
    final double deltaLon = lon2Rad - lon1Rad;

    // Haversine formula
    final double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLon / 2) * sin(deltaLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    // Calculate distance
    final double distance = earthRadius * c;

    return distance;
  }

  /// Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Format distance for display
  /// Returns formatted string with appropriate unit
  static String formatDistance(double distanceInKm) {
    if (distanceInKm.isNaN || distanceInKm < 0) {
      return 'N/A';
    }

    if (distanceInKm < 1) {
      // Convert to meters for distances less than 1 km
      final int meters = (distanceInKm * 1000).round();
      return '$meters m';
    } else if (distanceInKm < 10) {
      // Show one decimal place for distances between 1-10 km
      return '${distanceInKm.toStringAsFixed(1)} km';
    } else {
      // Show as integer for distances greater than 10 km
      return '${distanceInKm.round()} km';
    }
  }
}
