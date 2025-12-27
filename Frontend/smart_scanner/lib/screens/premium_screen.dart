import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isMonthly = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade to Premium'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Unlock All Features',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Scan unlimited documents with AI-powered features',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Features
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Premium Features',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...AppConstants.premiumFeatures.map(
                    (feature) => _buildFeatureItem(feature),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Pricing toggle
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildPricingOption(
                      isMonthly: true,
                      isSelected: _isMonthly,
                    ),
                  ),
                  Expanded(
                    child: _buildPricingOption(
                      isMonthly: false,
                      isSelected: !_isMonthly,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Subscribe button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Consumer<SubscriptionProvider>(
                builder: (context, provider, child) {
                  return ElevatedButton(
                    onPressed: provider.isLoading ? null : _handleSubscribe,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: provider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Subscribe for ${_getPriceText()}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Terms
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Cancel anytime. Subscription automatically renews.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 32),

            // Current plan (for free users)
            Consumer<SubscriptionProvider>(
              builder: (context, provider, child) {
                if (provider.isPremium) {
                  return _buildCurrentPlan(provider);
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingOption({
    required bool isMonthly,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isMonthly = isMonthly;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              isMonthly ? 'Monthly' : 'Yearly',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isMonthly
                  ? Helpers.formatCurrency(AppConstants.monthlyPrice)
                  : Helpers.formatCurrency(AppConstants.yearlyPrice),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isMonthly ? '/month' : '/year',
              style: TextStyle(
                color: isSelected ? Colors.white70 : Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            if (!isMonthly) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Save 50%',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlan(SubscriptionProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Premium Active',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          if (provider.subscriptionExpires != null) ...[
            const SizedBox(height: 12),
            Text(
              Helpers.formatSubscriptionExpiry(provider.subscriptionExpires),
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getPriceText() {
    if (_isMonthly) {
      return Helpers.formatCurrency(AppConstants.monthlyPrice);
    } else {
      return '${Helpers.formatCurrency(AppConstants.yearlyPrice)}/year';
    }
  }

  Future<void> _handleSubscribe() async {
    // Show payment dialog
    final confirmed = await Helpers.showConfirmDialog(
      context,
      'Confirm Subscription',
      'You will be charged ${_getPriceText()}. Continue?',
      confirmText: 'Subscribe',
    );

    if (!confirmed) return;

    // In a real app, this would trigger in-app purchase
    Helpers.showLoadingDialog(context, message: 'Processing subscription...');

    // Simulate subscription process
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Helpers.hideLoadingDialog(context);
      Helpers.showSnackBar(
        context,
        'In-app purchase integration required. See RevenueCat docs.',
      );
    }

    // In production, you would:
    // 1. Use in_app_purchase or purchases_flutter
    // 2. Get receipt data
    // 3. Call verifySubscription Cloud Function
    // 4. Update UI based on result
  }
}
