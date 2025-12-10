part of '../pay_pal_service_v2.dart';

/// payment_source.paypal
class PayPalPaymentSourceV2 {
  final PayPalPaymentMethodPreferenceV2 paymentMethodPreference;
  final PayPalShippingPreferenceV2 shippingPreference;
  final String returnUrl;
  final String cancelUrl;

  /// Optional tweaks
  final PayPalLandingPageV2? landingPage;
  final PayPalUserActionV2? userAction;

  PayPalPaymentSourceV2({
    required this.paymentMethodPreference,
    required this.shippingPreference,
    this.returnUrl = defaultReturnURL,
    this.cancelUrl = defaultCancelURL,
    this.landingPage,
    this.userAction,
  });

  Map<String, dynamic> toJson() => {
        "paypal": {
          "experience_context": {
            "payment_method_preference": paymentMethodPreference.value,
            if (landingPage != null) "landing_page": landingPage!.value,
            "shipping_preference": shippingPreference.value,
            if (userAction != null) "user_action": userAction!.value,
            "return_url": returnUrl,
            "cancel_url": cancelUrl,
          },
        }
      };
}
