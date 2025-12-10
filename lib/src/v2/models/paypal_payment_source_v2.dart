import 'package:flutter_paypal_payment_checkout_v2/flutter_paypal_payment_checkout_v2.dart';

/// Represents the **payment_source.paypal** object for the
/// PayPal **Orders API V2**.
///
/// This structure controls how the PayPal checkout experience behaves,
/// including:
/// - Allowed payment methods
/// - Shipping behavior
/// - Landing page style
/// - Post-approval deep links
/// - Button behavior (“Pay Now” vs “Continue”)
///
/// It maps to the PayPal JSON structure:
/// ```json
/// "payment_source": {
///   "paypal": {
///     "experience_context": {
///       "payment_method_preference": "...",
///       "landing_page": "...",
///       "shipping_preference": "...",
///       "user_action": "...",
///       "return_url": "...",
///       "cancel_url": "..."
///     }
///   }
/// }
/// ```
class PayPalPaymentSourceV2 {
  /// Determines whether PayPal requires immediate payment
  /// or allows unrestricted funding sources.
  ///
  /// Maps to:
  /// `experience_context.payment_method_preference`
  final PayPalPaymentMethodPreferenceV2 paymentMethodPreference;

  /// Controls how PayPal handles or displays shipping addresses.
  ///
  /// Maps to:
  /// `experience_context.shipping_preference`
  final PayPalShippingPreferenceV2 shippingPreference;

  /// The URL PayPal redirects to after successful approval.
  ///
  /// Defaults to the SDK's internal deep link.
  final String returnUrl;

  /// The URL PayPal redirects to if the buyer cancels the checkout.
  ///
  /// Defaults to the SDK's internal deep link.
  final String cancelUrl;

  /// Optional override for the initial landing experience:
  /// - `LOGIN`
  /// - `NO_PREFERENCE`
  final PayPalLandingPageV2? landingPage;

  /// Optional UI behavior for PayPal's approval button:
  /// - `PAY_NOW`
  /// - `CONTINUE`
  final PayPalUserActionV2? userAction;

  PayPalPaymentSourceV2({
    required this.paymentMethodPreference,
    required this.shippingPreference,
    this.returnUrl = defaultReturnURL,
    this.cancelUrl = defaultCancelURL,
    this.landingPage,
    this.userAction,
  });

  /// Converts the object into the JSON structure expected by
  /// PayPal Orders V2 API.
  ///
  /// Output example:
  /// ```json
  /// {
  ///   "paypal": {
  ///     "experience_context": {
  ///       "payment_method_preference": "IMMEDIATE_PAYMENT_REQUIRED",
  ///       "landing_page": "LOGIN",
  ///       "shipping_preference": "NO_SHIPPING",
  ///       "user_action": "PAY_NOW",
  ///       "return_url": "paypal-sdk://success",
  ///       "cancel_url": "paypal-sdk://cancel"
  ///     }
  ///   }
  /// }
  /// ```
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
