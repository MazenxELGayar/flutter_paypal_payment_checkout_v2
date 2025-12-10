/// Controls which PayPal login/checkout experience the user initially sees.
///
/// Maps to:
/// `application_context.landing_page`
///
/// - **LOGIN**          → Shows the PayPal login page.
/// - **NO_PREFERENCE**  → Lets PayPal decide (default experience).
enum PayPalLandingPageV2 {
  login,
  noPreference;

  /// Converts enum → PayPal API string.
  String get value {
    switch (this) {
      case PayPalLandingPageV2.login:
        return "LOGIN";
      case PayPalLandingPageV2.noPreference:
        return "NO_PREFERENCE";
    }
  }
}
