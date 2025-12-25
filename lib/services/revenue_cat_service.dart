import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:toto_ai/services/user_permission_service.dart';

class RevenueCatService {
  static const String _apiKey = 'goog_AkVuvoDljodKjgbYiqBSGNCbhyW';
  static const String _entitlementId = '1X2-AI Pro';
  
  static bool _isInitialized = false;
  
  // DEBUG: Set this to true to simulate premium status in development
  // Set to false to test free plan restrictions
  static const bool _debugSimulatePremium = true;

  static Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.info);
      
      final configuration = PurchasesConfiguration(_apiKey);
      
      await Purchases.configure(configuration);
      
      _isInitialized = true;
      
      if (kDebugMode) {
        print('RevenueCat: SDK initialized successfully');
      }
      
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        if (kDebugMode) {
          print('RevenueCat: Customer info updated');
          print('Active entitlements: ${customerInfo.entitlements.active.keys}');
        }
      });
      
    } catch (e) {
      if (kDebugMode) {
        print('RevenueCat: Failed to initialize - $e');
      }
      rethrow;
    }
  }

  static Future<bool> isProUser() async {
    // First check server permissions
    try {
      if (UserPermissionService.isPro) {
        return true; // User has premium permissions from server
      }
    } catch (e) {
      // If there's an error checking server permissions, continue with local check
      print('Error checking server permissions: $e');
    }

    // Fall back to local premium status
    if (kDebugMode && _debugSimulatePremium) {
      print('RevenueCat: DEBUG MODE - Simulating premium status: true');
      return true;
    }
    
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final hasEntitlement = customerInfo.entitlements.active.containsKey(_entitlementId);
      
      if (kDebugMode) {
        print('RevenueCat: Pro status check - $hasEntitlement');
      }
      
      return hasEntitlement;
    } catch (e) {
      if (kDebugMode) {
        print('RevenueCat: Error checking pro status - $e');
      }
      return false;
    }
  }

  static Future<CustomerInfo> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      if (kDebugMode) {
        print('RevenueCat: Error getting customer info - $e');
      }
      rethrow;
    }
  }

  static Future<Offerings> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      
      if (kDebugMode) {
        print('RevenueCat: Fetched offerings');
        if (offerings.current != null) {
          print('Current offering: ${offerings.current!.identifier}');
          print('Available packages: ${offerings.current!.availablePackages.map((p) => p.identifier).join(", ")}');
        }
      }
      
      return offerings;
    } catch (e) {
      if (kDebugMode) {
        print('RevenueCat: Error getting offerings - $e');
      }
      rethrow;
    }
  }

  static Future<CustomerInfo> purchasePackage(Package package) async {
    try {
      if (kDebugMode) {
        print('RevenueCat: Attempting to purchase ${package.identifier}');
      }
      
      final purchaseResult = await Purchases.purchasePackage(package);
      
      if (kDebugMode) {
        print('RevenueCat: Purchase successful');
        print('Active entitlements: ${purchaseResult.customerInfo.entitlements.active.keys}');
      }
      
      return purchaseResult.customerInfo;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      
      if (kDebugMode) {
        print('RevenueCat: Purchase error - ${errorCode.name}');
      }
      
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        throw Exception('Purchase was cancelled');
      } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
        throw Exception('Purchase not allowed');
      } else if (errorCode == PurchasesErrorCode.paymentPendingError) {
        throw Exception('Payment is pending');
      } else {
        throw Exception('Purchase failed: ${e.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('RevenueCat: Unexpected purchase error - $e');
      }
      rethrow;
    }
  }

  static Future<CustomerInfo> restorePurchases() async {
    try {
      if (kDebugMode) {
        print('RevenueCat: Restoring purchases');
      }
      
      final customerInfo = await Purchases.restorePurchases();
      
      if (kDebugMode) {
        print('RevenueCat: Purchases restored');
        print('Active entitlements: ${customerInfo.entitlements.active.keys}');
      }
      
      return customerInfo;
    } catch (e) {
      if (kDebugMode) {
        print('RevenueCat: Error restoring purchases - $e');
      }
      rethrow;
    }
  }

  static Future<void> logIn(String userId) async {
    try {
      if (kDebugMode) {
        print('RevenueCat: Logging in user $userId');
      }
      
      await Purchases.logIn(userId);
      
      if (kDebugMode) {
        print('RevenueCat: User logged in successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('RevenueCat: Error logging in - $e');
      }
      rethrow;
    }
  }

  static Future<void> logOut() async {
    try {
      if (kDebugMode) {
        print('RevenueCat: Logging out user');
      }
      
      await Purchases.logOut();
      
      if (kDebugMode) {
        print('RevenueCat: User logged out successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('RevenueCat: Error logging out - $e');
      }
      rethrow;
    }
  }

  static String get entitlementId => _entitlementId;
}
