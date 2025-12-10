/// PayPal Orders V2 user action setting.
///
/// Controls the text displayed on the PayPal button.
///
/// Maps to:
/// `application_context.user_action`
///
/// - **PAY_NOW**
///   Shows “Pay Now” on approval (recommended for one-shot payments).
///
/// - **CONTINUE**
///   Shows “Continue” (multi-step checkout or review flows).
enum PayPalUserActionV2 {
  payNow,
  continueAction;

  /// Converts enum → PayPal API string.
  String get value {
    switch (this) {
      case PayPalUserActionV2.payNow:
        return "PAY_NOW";
      case PayPalUserActionV2.continueAction:
        return "CONTINUE";
    }
  }
}
