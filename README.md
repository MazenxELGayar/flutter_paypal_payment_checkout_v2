# 🌟 Flutter PayPal Payment Checkout V2

[![pub package](https://img.shields.io/pub/v/flutter_paypal_payment_checkout_v2.svg)](https://pub.dev/packages/flutter_paypal_payment_checkout_v2)
![License](https://img.shields.io/badge/License-MIT-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-%E2%9D%A4-blue)

A modern, safe, and powerful Flutter package for integrating **PayPal Checkout** using:

* **PayPal Orders API V2 (Recommended for all new apps)**
* **Legacy PayPal Payments API V1 (For compatibility only)**

Includes a full in-app WebView checkout, typed models, sandbox tools, and secure backend flows.

---

# ❤️ Support the Project

If this package saved you development time, please consider supporting the work behind it:

### **PayPal Donation**

👉 [https://paypal.me/mazenelgayar](https://paypal.me/mazenelgayar)

### **InstaPay**

👉 [https://ipn.eg/S/mazenel-gayarcib/instapay/0ecfXw](https://ipn.eg/S/mazenel-gayarcib/instapay/0ecfXw)
**Tag:** `mazenel-gayarcib@instapay`

Your support directly motivates further updates, improvements, and new features.
Thank you! ❤️🙏

---

# 🚀 Features

* 🔒 **Production-safe PayPal Orders V2 support** (create + capture)
* 🧾 Fully typed request/response models for V1 & V2 APIs
* 🌐 Custom return/cancel URL schemes (`paypal-sdk://success`)
* 🧪 Sandbox-friendly client-side payments
* 🎯 Easy success / error / cancellation callbacks
* 🧰 Integrated WebView + progress indicator
* 🛠 Backward compatible with PayPal Payments API V1
* 🔐 Strong security protections against exposing client secrets

---

# ⚠️ Security Warning

### **DO NOT PUT YOUR PAYPAL SECRET KEY IN A MOBILE APP IN PRODUCTION.**

Flutter code can always be decompiled.

✔ In production → always use **backend-created orders**
✔ In sandbox → it's safe to use local clientId + secretKey
✔ Never enable `overrideInsecureClientCredentials` in live mode

---

# 📦 Installation

```yaml
dependencies:
  flutter_paypal_payment_checkout_v2: ^2.0.3
```

```bash
flutter pub get
```

---

# 🧭 Choosing an API Version

| API                   | Recommended?  | Notes                                            |
| --------------------- | ------------- | ------------------------------------------------ |
| **V2 (Orders API)**   | ✅ Yes         | Modern, secure, officially recommended by PayPal |
| **V1 (Payments API)** | ⚠️ Deprecated | Older, but still supported for legacy apps       |

---

# 🟦 Example: PayPal Orders API V2 (Recommended)

```dart
void _startV2Flow(BuildContext context) {
  final order = PayPalOrderRequestV2(
    intent: PayPalOrderIntentV2.capture,
    paymentSource: PayPalPaymentSourceV2(
      paymentMethodPreference:
          PayPalPaymentMethodPreferenceV2.immediatePaymentRequired,
      shippingPreference: PayPalShippingPreferenceV2.noShipping,
    ),
    purchaseUnits: [
      PayPalPurchaseUnitV2(
        amount: PayPalAmountV2(
          currency: 'USD',
          value: 100.0,
          itemTotal: 100.0,
          taxTotal: 0.0,
        ),
        items: [
          PaypalTransactionV2Item(
            name: 'Apple',
            description: 'Fresh apples',
            quantity: 2,
            unitAmount: 50.0,
            currency: 'USD',
            category: PayPalItemCategoryV2.physicalGoods,
          ),
        ],
      ),
    ],
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PaypalCheckoutView(
        version: PayPalApiVersion.v2,
        sandboxMode: true,
        clientId: "SANDBOX_CLIENT_ID",
        secretKey: "SANDBOX_SECRET_KEY",
        getAccessToken: null,
        approvalUrl: null,
        payPalOrder: order,
        onUserPayment: (success, payment) {
          print("Order Captured: ${success?.data}");
        },
        onError: (err) => print("Error: ${err.message}"),
        onCancel: () => print("Cancelled"),
      ),
    ),
  );
}
```

---

# 🟡 Example: PayPal Payments API V1 (Legacy)

```dart
void _startV1Flow(BuildContext context) {
  final tx = PaypalTransactionV1(
    amount: PaypalTransactionV1Amount(
      subTotal: 100,
      tax: 0,
      shipping: 0,
      handlingFee: 0,
      shippingDiscount: 0,
      insurance: 0,
      total: 100,
      currency: 'USD',
    ),
    description: "Payment for apples",
    items: [
      PaypalTransactionV1Item(
        name: "Apple",
        quantity: 4,
        price: 10,
        tax: 0,
        currency: "USD",
      ),
    ],
  );

  final order = PayPalOrderRequestV1(
    intent: PayPalOrderIntentV1.sale,
    transactions: [tx],
    noteToPayer: "Thank you for your purchase!",
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PaypalCheckoutView(
        version: PayPalApiVersion.v1,
        sandboxMode: true,
        clientId: "SANDBOX_CLIENT_ID",
        secretKey: "SANDBOX_SECRET_KEY",
        getAccessToken: null,
        approvalUrl: null,
        payPalOrder: order,
        onUserPayment: (success, payment) {
          print("V1 execute response: ${success?.data}");
        },
        onError: (err) => print("Error: ${err.message}"),
        onCancel: () => print("Cancelled"),
      ),
    ),
  );
}
```

---

# 🧪 Sandbox-only Client-side Flow

⚠️ **Never use this in production.**

```dart
PaypalCheckoutView(
  version: PayPalApiVersion.v2,
  sandboxMode: true,
  clientId: "SANDBOX_CLIENT_ID",
  secretKey: "SANDBOX_SECRET_KEY",
  overrideInsecureClientCredentials: true,
  payPalOrder: simpleV2Order,
  getAccessToken: null,
  approvalUrl: null,
  onUserPayment: (success, payment) => print(success?.data),
  onError: print,
  onCancel: () => print("Cancelled"),
);
```

---

# 📚 Documentation

This package includes strongly-typed models for:

### ✔ PayPal Orders API V2

* `PayPalOrderRequestV2`
* `PayPalPurchaseUnitV2`
* `PayPalAmountV2`
* `PayPalPaymentSourceV2`
* `PayPalItemCategoryV2`
* `PayPalCaptureOrderResponse`

### ✔ PayPal Payments API V1

* `PayPalOrderRequestV1`
* `PaypalTransactionV1`
* `PaypalTransactionV1Item`
* `PayPalAllowedPaymentMethodV1`

### ✔ Core Models

* `PaypalPaymentModel`
* `PayPalErrorModel`
* `PayPalSuccessPaymentModel`

---

# 🔐 Security Best Practices

| Task                                     | Production | Sandbox            |
| ---------------------------------------- | ---------- | ------------------ |
| Create Orders                            | Backend    | Client or backend  |
| Capture Orders                           | Backend    | Client or backend  |
| Use clientId / secretKey in app          | ❌ NEVER    | ✔ Allowed          |
| Use return/cancel URLs                   | Required   | Optional           |
| Enable overrideInsecureClientCredentials | ❌ NEVER    | ✔ Only for testing |

---

# 🔧 Advanced Tips

### Custom URL schemes

You may safely use:

```
paypal-sdk://success
paypal-sdk://cancel
```

Useful for mobile deep linking.

---

# 📄 License

MIT © 2025 [Mazen El-Gayar](https://github.com/MazenxELGayar)
MIT © 2023 [Tharwat](https://github.com/tharwatsamy)