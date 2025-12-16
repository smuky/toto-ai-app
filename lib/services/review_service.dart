import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_review/in_app_review.dart';

class ReviewService {
  static const String _reviewCountKey = 'review_result_count';
  static const String _reviewCompletedKey = 'review_completed';
  static const String _lastReviewRequestDateKey = 'last_review_request_date';
  static const int _reviewThreshold = 3;

  static final InAppReview _inAppReview = InAppReview.instance;

  /// Increments the result count and checks if review should be requested
  static Future<void> onResultReceived() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if user has already completed a review
    final reviewCompleted = prefs.getBool(_reviewCompletedKey) ?? false;
    print('ReviewService: Review completed: $reviewCompleted');
    if (reviewCompleted) {
      print('ReviewService: User has already completed review, skipping');
      return;
    }

    // Increment the result count
    final currentCount = prefs.getInt(_reviewCountKey) ?? 0;
    final newCount = currentCount + 1;
    await prefs.setInt(_reviewCountKey, newCount);
    print('ReviewService: Result count incremented from $currentCount to $newCount (threshold: $_reviewThreshold)');

    // Check if we should request a review
    if (newCount >= _reviewThreshold) {
      print('ReviewService: Threshold reached, requesting review...');
      await _requestReview(prefs);
    }
  }

  /// Requests an in-app review
  static Future<void> _requestReview(SharedPreferences prefs) async {
    try {
      // Check if review is available
      final isAvailable = await _inAppReview.isAvailable();
      print('ReviewService: Review available: $isAvailable');
      
      if (isAvailable) {
        // Store the date of the review request
        final now = DateTime.now().toIso8601String();
        await prefs.setString(_lastReviewRequestDateKey, now);
        print('ReviewService: Stored review request date: $now');
        
        // Request the review
        print('ReviewService: Calling requestReview()...');
        await _inAppReview.requestReview();
        print('ReviewService: requestReview() completed');
        
        // Mark review as completed
        await prefs.setBool(_reviewCompletedKey, true);
        
        // Reset the counter
        await prefs.setInt(_reviewCountKey, 0);
        print('ReviewService: Review marked as completed, counter reset');
      } else {
        print('ReviewService: Review not available (common in development/testing)');
      }
    } catch (e) {
      // Silently fail if review is not available or errors occur
      print('ReviewService: Review request failed: $e');
    }
  }

  /// Gets the current result count
  static Future<int> getResultCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_reviewCountKey) ?? 0;
  }

  /// Checks if user has completed a review
  static Future<bool> hasCompletedReview() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_reviewCompletedKey) ?? false;
  }

  /// Gets the last review request date
  static Future<DateTime?> getLastReviewRequestDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_lastReviewRequestDateKey);
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }

  /// Resets review data (for testing purposes)
  static Future<void> resetReviewData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_reviewCountKey);
    await prefs.remove(_reviewCompletedKey);
    await prefs.remove(_lastReviewRequestDateKey);
  }
}
