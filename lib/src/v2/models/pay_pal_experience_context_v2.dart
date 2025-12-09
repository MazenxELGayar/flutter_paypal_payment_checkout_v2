part of '../pay_pal_service_v2.dart';


/// -------------------- EXPERIENCE CONTEXT --------------------

class PayPalExperienceContextV2 {
  final PayPalPaymentMethodPreferenceV2 paymentMethodPreference;
  final PayPalShippingPreferenceV2 shippingPreference;
  final String returnUrl;
  final String cancelUrl;

  /// Optional tweaks
  final PayPalLandingPageV2? landingPage;
  final PayPalUserActionV2? userAction;

  PayPalExperienceContextV2({
    required this.paymentMethodPreference,
    required this.shippingPreference,
    required this.returnUrl,
    required this.cancelUrl,
    this.landingPage,
    this.userAction,
  });

  Map<String, dynamic> toJson() => {
    "payment_method_preference": paymentMethodPreference.value,
    if (landingPage != null) "landing_page": landingPage!.value,
    "shipping_preference": shippingPreference.value,
    if (userAction != null) "user_action": userAction!.value,
    "return_url": returnUrl,
    "cancel_url": cancelUrl,
  };
}

/// payment_source.paypal
class PayPalPaymentSourceV2 {
  final PayPalExperienceContextV2 experienceContext;

  PayPalPaymentSourceV2({
    required this.experienceContext,
  });

  Map<String, dynamic> toJson() => {
    "paypal": {
      "experience_context": experienceContext.toJson(),
    },
  };
}