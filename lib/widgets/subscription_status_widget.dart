import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/revenue_cat_service.dart';
import '../pages/paywall_page.dart';
import '../models/translation_response.dart';

class SubscriptionStatusWidget extends StatefulWidget {
  final VoidCallback? onStatusChanged;
  final SettingsTranslation? settingsTranslation;

  const SubscriptionStatusWidget({
    super.key,
    this.onStatusChanged,
    this.settingsTranslation,
  });

  @override
  State<SubscriptionStatusWidget> createState() =>
      _SubscriptionStatusWidgetState();
}

class _SubscriptionStatusWidgetState extends State<SubscriptionStatusWidget> {
  bool _isPro = false;
  bool _isLoading = true;
  CustomerInfo? _customerInfo;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionStatus();
  }

  Future<void> _loadSubscriptionStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final isPro = await RevenueCatService.isProUser();
      final customerInfo = await RevenueCatService.getCustomerInfo();

      if (mounted) {
        setState(() {
          _isPro = isPro;
          _customerInfo = customerInfo;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getSubscriptionStatusText() {
    if (_isPro && _customerInfo != null) {
      final entitlement =
          _customerInfo!.entitlements.active[RevenueCatService.entitlementId];
      if (entitlement != null) {
        final expirationDate = entitlement.expirationDate;
        if (expirationDate != null) {
          final expiration = DateTime.parse(expirationDate);
          final daysUntilExpiration = expiration
              .difference(DateTime.now())
              .inDays;

          if (entitlement.willRenew) {
            return 'Renews in $daysUntilExpiration days';
          } else {
            return 'Expires in $daysUntilExpiration days';
          }
        }
        return 'Active';
      }
    }
    return widget.settingsTranslation?.freePlan ?? 'Free Plan';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isPro ? Icons.star : Icons.star_border,
                  color: _isPro ? Colors.amber : Colors.grey,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isPro
                            ? '1X2-AI Pro'
                            : (widget.settingsTranslation?.freePlan ??
                                  'Free Plan'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_isPro) ...[
                        const SizedBox(height: 4),
                        Text(
                          _getSubscriptionStatusText(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (!_isPro) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                widget.settingsTranslation?.upgradeToProFor ??
                    'Upgrade to Pro for:',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildFeatureItem(
                widget.settingsTranslation?.unlockAllAIModels ??
                    'Unlock All AI Models',
              ),
              _buildFeatureItem(
                widget.settingsTranslation?.exclusiveSmartLists ??
                    'Exclusive Smart Lists',
              ),
              _buildFeatureItem(
                widget.settingsTranslation?.adFreeExperience ??
                    'Ad-free experience',
              ),
              _buildFeatureItem(
                widget.settingsTranslation?.vipPrioritySupport ??
                    'VIP Priority Support',
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: PaywallButton(
                  text:
                      widget.settingsTranslation?.upgradeToPro ??
                      'Upgrade to Pro',
                  onPurchaseCompleted: () {
                    _loadSubscriptionStatus();
                    widget.onStatusChanged?.call();
                  },
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              _buildFeatureItem(
                '✓ ${widget.settingsTranslation?.unlockAllAIModels ?? 'Unlock All AI Models'}',
                isActive: true,
              ),
              _buildFeatureItem(
                '✓ ${widget.settingsTranslation?.exclusiveSmartLists ?? 'Exclusive Smart Lists'}',
                isActive: true,
              ),
              _buildFeatureItem(
                '✓ ${widget.settingsTranslation?.adFreeExperience ?? 'Ad-free experience'}',
                isActive: true,
              ),
              _buildFeatureItem(
                '✓ ${widget.settingsTranslation?.vipPrioritySupport ?? 'VIP Priority Support'}',
                isActive: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isActive ? Colors.green : Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isActive ? Colors.black87 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class ProFeatureGate extends StatelessWidget {
  final Widget child;
  final Widget? fallback;
  final String? message;

  const ProFeatureGate({
    super.key,
    required this.child,
    this.fallback,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: RevenueCatService.isProUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final isPro = snapshot.data ?? false;

        if (isPro) {
          return child;
        }

        if (fallback != null) {
          return fallback!;
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PaywallPage(),
                fullscreenDialog: true,
              ),
            );
          },
          child: Stack(
            children: [
              Opacity(opacity: 0.3, child: IgnorePointer(child: child)),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock, color: Colors.white, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          message ?? 'Pro Feature',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PaywallPage(),
                                fullscreenDialog: true,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Upgrade'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
