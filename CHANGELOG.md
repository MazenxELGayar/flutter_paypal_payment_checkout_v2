# **2.0.0**

🚀 **Major rewrite with full PayPal Orders API v2 support**

This release introduces a complete overhaul of the payment flow, API models, and service structure.
⚠️ **Breaking changes** included.

### **✨ New Features**

* Added **PayPal Orders API V2** support (create order + capture).
* Strongly-typed request/response models:

    * `PayPalOrderRequestV2`
    * `PaypalPaymentModelV2`
    * `PayPalCaptureOrderResponse`
* Added full enums for:

    * `shipping_preference`
    * `payment_method_preference`
    * `landing_page`
    * `user_action`
    * `item.category`
* Added safer **custom URL scheme** defaults (`paypal-sdk://success`, `paypal-sdk://cancel`) for return/cancel handling.
* Support both secure and insecure flows:

    * **Secure (recommended):** Backend creates order & handles capture.
    * **Client-side (testing only):** App creates order and captures it.
* Improved WebView behavior & progress UI.

### **🔒 Security Improvements**

* Added strict protection against exposing PayPal `clientId` and `secretKey` in production.
* New flag: `overrideInsecureClientCredentials` to bypass security (sandbox/testing only).
* Added checks preventing live-mode token generation without backend.

### **🔧 Enhancements**

* More reliable approval link extraction (`approve` and `payer-action`).
* Better error models and error surface handling.
* Cleaner separation between backend-driven and client-driven flows.
* More descriptive callback models for success, error, and cancel events.

### **⚠️ Breaking Changes**

* Old V1 models and flows removed or renamed.
* `PaypalPaymentModel` replaced with `PaypalPaymentModelV2`.
* `executePayment` replaced with **order capture**.
* Removed reliance on `PayerID` (not used in PayPal V2).
* Package API simplified and reorganized.

---

# **1.0.8**

This package simplifies integrating PayPal payments into your mobile app.
Key features include:

* Seamless in-app PayPal WebView checkout
* User-friendly payment flow
* Secure transaction handling
* Customizable UI components
* Real-time payment status updates

Future enhancements include more payment options, fraud protection, subscription support, and analytics improvements.