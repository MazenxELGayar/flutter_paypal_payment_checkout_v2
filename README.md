# Flutter PayPal Payment

A powerful, easy-to-use Flutter package that enables **seamless PayPal checkout flows** using:

* **PayPal Payments / Orders API V2 (recommended)**
* **Legacy Payments API V1 (deprecated by PayPal, but still supported)**

This package supports:

* Secure backend-driven order creation
* Client-side sandbox testing
* In-app WebView checkout experience
* Custom transaction models
* Full capture flow for PayPal V2

---

## ✨ Features

* 🔒 **Production-ready PayPal V2 flow** (backend creates + captures order)
* 🧪 **Sandbox testing mode**
* ⚙️ **Full PayPal Orders API V2 request/response models**
* 💳 **Line items, shipping, taxes, preferences & more**
* 🌐 **Custom return & cancel URL schemes** (e.g., `paypal-sdk://success`)
* 🎯 **Callbacks for success, error, cancellation**
* 🚀 **Supports PayPal API V1 for backward compatibility**

---

## 📦 Installation

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter_paypal_payment: ^2.0.0
```

Install:

```bash
flutter pub get
```

---

# 🚀 Usage

You can choose between:

---

# ✅ **Using PayPal API V2 (Recommended)**

V2 supports **modern PayPal features**, is more secure, and is PayPal’s officially recommended API.

### **Secure Backend Flow**

🔐 **In production, you MUST create and capture orders on your backend.**
Your backend returns only the approval URL.

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PaypalCheckoutViewV2(
      sandboxMode: true,

      /// Recommended: backend returns approval URL
      approvalUrl: () async {
        // Your backend should return a full checkout URL
        return await myBackend.createPaypalOrder();
      },

      /// Called when user finishes checkout and redirects back to app
      onSuccess: (result) {
        print("Payment success: $result");
        Navigator.pop(context);
      },

      onError: (error) {
        print("Error: $error");
        Navigator.pop(context);
      },

      onCancel: () {
        print("Payment cancelled");
        Navigator.pop(context);
      },
    ),
  ),
);
```

---

### **Client-Side Flow (Sandbox Only)**

⚠️ **Never use this in production.
It exposes your PayPal clientId + secretKey.**

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PaypalCheckoutViewV2(
      sandboxMode: true,
      clientId: "SANDBOX_CLIENT_ID",
      secretKey: "SANDBOX_SECRET_KEY",
      overrideInsecureClientCredentials: true, // allow local tokens

      getAccessToken: () async => null,

      transactions: PayPalOrderRequestV2(
        intent: PayPalOrderIntent.capture,
        // amount, items, shipping, etc...
      ),

      onSuccess: (PayPalCaptureOrderResponse res) {
        print("Captured: ${res.status}");
      },

      onError: (error) => print(error),
      onCancel: () => print("Cancelled"),
    ),
  ),
);
```

---

# 🟡 **Legacy PayPal V1 Checkout (Optional)**

PayPal V1 is older and deprecated, but supported for compatibility.

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PaypalCheckoutViewV1(
      sandboxMode: true,
      clientId: "ONLY FOR SANDBOX",
      secretKey: "ONLY FOR SANDBOX",
      getAccessToken: null,   // MUST be handled by your backend in live mode

      transactions: PaypalTransactionV1(
        amount: PaypalTransactionV1Amount(
          subTotal: 100.0,
          tax: 0.0,
          shipping: 0.0,
          handlingFee: 0.0,
          shippingDiscount: 0.0,
          insurance: 0.0,
          total: 100.0,
          currency: 'USD',
        ),
        description: "Order description",
        items: [
          PaypalTransactionV1Item(
            name: "Apple",
            quantity: 4,
            price: 10.0,
            tax: 0.0,
            currency: "USD",
            sku: "SKU_APPLE",
            description: "Fresh apples",
          ),
        ],
      ),

      onSuccess: (params) {
        print("Success: $params");
      },
      onError: (error) => print("Error: $error"),
      onCancel: () => print("Cancelled"),
    ),
  ),
);
```

---

# 🔐 Security Notes (Important)

### **DO NOT PUT YOUR PAYPAL SECRET KEY IN A MOBILE APP FOR PRODUCTION.**

Flutter code can be extracted even from release builds.

✔ Use backend mode (`approvalUrl`) for all real payments
✔ Limit local credentials to **sandbox only**
✔ Set `overrideInsecureClientCredentials` **only for testing**

---

# ❤️ Donate

If you would like to support this package:

**PayPal:**
[https://paypal.me/mazenelgayar](https://paypal.me/mazenelgayar)

Thank you for your support!