import 'package:flutter/material.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../services/revenue_cat_service.dart';
import '../utils/text_direction_helper.dart';

class CustomerCenterPage extends StatefulWidget {
  const CustomerCenterPage({super.key});

  @override
  State<CustomerCenterPage> createState() => _CustomerCenterPageState();
}

class _CustomerCenterPageState extends State<CustomerCenterPage> {
  bool _isLoading = false;

  Future<void> _presentCustomerCenter() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await RevenueCatUI.presentCustomerCenter();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening Customer Center: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _presentCustomerCenter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : const SizedBox.shrink(),
    );
  }
}

class ManageSubscriptionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final String? language;

  const ManageSubscriptionButton({
    super.key,
    this.text = 'Manage Subscription',
    this.icon = Icons.settings,
    this.language,
  });

  Future<void> _openCustomerCenter(BuildContext context) async {
    try {
      final isPro = await RevenueCatService.isProUser();

      if (!isPro) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'You need an active subscription to access Customer Center',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CustomerCenterPage(),
            fullscreenDialog: true,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = language != null && TextDirectionHelper.isRTL(language!);
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade700),
      title: Text(text),
      trailing: isRtl
          ? const Icon(Icons.arrow_back_ios, size: 16)
          : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _openCustomerCenter(context),
    );
  }
}

class RestorePurchasesButton extends StatelessWidget {
  final VoidCallback? onRestoreCompleted;
  final String? language;

  const RestorePurchasesButton({
    super.key,
    this.onRestoreCompleted,
    this.language,
  });

  Future<void> _restorePurchases(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final customerInfo = await RevenueCatService.restorePurchases();

      if (!context.mounted) return;

      Navigator.of(context).pop();

      final hasActiveSubscription = customerInfo.entitlements.active.isNotEmpty;

      if (hasActiveSubscription) {
        onRestoreCompleted?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchases restored successfully! 🎉'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No active subscriptions found'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to restore purchases: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.restore, color: Colors.blue.shade700),
      title: const Text('Restore Purchases'),
      trailing: (language != null && TextDirectionHelper.isRTL(language!))
          ? const Icon(Icons.arrow_back_ios, size: 16)
          : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _restorePurchases(context),
    );
  }
}
