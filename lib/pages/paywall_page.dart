import 'package:flutter/material.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/revenue_cat_service.dart';

class PaywallPage extends StatefulWidget {
  final String? offeringIdentifier;
  final VoidCallback? onPurchaseCompleted;
  final VoidCallback? onRestoreCompleted;

  const PaywallPage({
    super.key,
    this.offeringIdentifier,
    this.onPurchaseCompleted,
    this.onRestoreCompleted,
  });

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  bool _isLoading = false;

  Future<void> _presentPaywall() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final paywallResult = await RevenueCatUI.presentPaywall();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (paywallResult == PaywallResult.purchased ||
          paywallResult == PaywallResult.restored) {
        widget.onPurchaseCompleted?.call();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Welcome to 1X2-AI Pro! 🎉'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else if (paywallResult == PaywallResult.cancelled) {
        if (mounted) {
          Navigator.of(context).pop(false);
        }
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _presentPaywallIfNeeded() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final paywallResult = await RevenueCatUI.presentPaywallIfNeeded(
        RevenueCatService.entitlementId,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (paywallResult == PaywallResult.purchased ||
          paywallResult == PaywallResult.restored) {
        widget.onPurchaseCompleted?.call();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Welcome to 1X2-AI Pro! 🎉'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else if (paywallResult == PaywallResult.notPresented) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You already have Pro access!'),
              backgroundColor: Colors.blue,
            ),
          );
          Navigator.of(context).pop(false);
        }
      } else if (paywallResult == PaywallResult.cancelled) {
        if (mounted) {
          Navigator.of(context).pop(false);
        }
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _presentPaywallIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class PaywallButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPurchaseCompleted;

  const PaywallButton({
    super.key,
    this.text = 'Upgrade to Pro',
    this.onPurchaseCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => PaywallPage(
              onPurchaseCompleted: onPurchaseCompleted,
            ),
            fullscreenDialog: true,
          ),
        );

        if (result == true && onPurchaseCompleted != null) {
          onPurchaseCompleted!();
        }
      },
      icon: const Icon(Icons.star, color: Colors.amber),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
