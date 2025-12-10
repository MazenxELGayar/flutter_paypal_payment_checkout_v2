/// PayPal Orders V1 intent: "sale" or "authorize"
enum PayPalOrderIntentV1 {
  sale,
  authorize;

  String get value {
    switch (this) {
      case PayPalOrderIntentV1.sale:
        return "sale";
      case PayPalOrderIntentV1.authorize:
        return "authorize";
    }
  }
}
