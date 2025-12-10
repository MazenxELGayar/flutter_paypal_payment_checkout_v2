# Changelog

All notable changes to this project will be documented in this file.

## 2.0.4 — 2025-12-10
- Forgot to export models, all models and services are now usable.

## 2.0.3 — 2025-12-10
- Added Tharwat to the contributors.

## 2.0.2 — 2025-12-10
- Added a donation link.

**PayPal:**  
[https://paypal.me/mazenelgayar](https://paypal.me/mazenelgayar)

**InstaPay:**  
https://ipn.eg/S/mazenel-gayarcib/instapay/0ecfXw  
**Tag:** `mazenel-gayarcib@instapay`

# **2.0.1** — 2025-12-10

🧩 **Unified V1 + V2 API with shared models and services**

This release builds on top of the V2 Orders support and introduces a **unified, version-aware API** that can handle both **PayPal Payments API V1** and **Orders API V2** from a single, clean interface.

### **✨ New Features**

* Added shared abstract base types:
  * `PaypalServicesBase`
  * `PayPalOrderRequestBase`
* New unified checkout widget:
  * `PaypalCheckoutView`
  * Explicit `version: PayPalApiVersion.v1 | PayPalApiVersion.v2`
* Shared payment result model:
  * `PaypalPaymentModel` (used for both V1 & V2 flows)
* Version-aware order models:
  * `PayPalOrderRequestV1` (Payments API v1)
  * `PayPalOrderRequestV2` (Orders API v2)
* Clear client-side handling of:
  * V1 → `execute` payment using `PayerID`
  * V2 → `capture` order using `orderId`
* Added `PayPalAllowedPaymentMethodV1` enum and `PayPalPaymentOptionsV1` model for:
  * `UNRESTRICTED`
  * `INSTANT_FUNDING_SOURCE`
  * `IMMEDIATE_PAY`

### **🧪 New Example Screen**

* Demo screen with **two buttons**:
  * **“Pay with PayPal (V2 – Orders API)”**
    * Uses `PayPalOrderRequestV2`, purchase units, amount, items, and shipping address.
  * **“Pay with PayPal (V1 – Payments API)”**
    * Uses `PayPalOrderRequestV1` and `PaypalTransactionV1`.
* Includes inline help explaining:
  * When to use **V1** vs **V2**
  * Why **backend-created orders** are recommended in production
  * Why putting `clientId` / `secretKey` in the app is **sandbox-only**

### **🔒 Safety & Validation**

* Runtime check to prevent:
  * Passing a `PayPalOrderRequestV1` into a V2 service
  * Passing a `PayPalOrderRequestV2` into a V1 service  
    → returns a clear `ORDER_VERSION_MISMATCH` error.
* Centralized checks for:
  * Empty transactions (V1)
  * Empty purchase units (V2)
  * Null `payPalOrder` when required

### **⚠️ Breaking / Deprecation Notes**

* `PaypalCheckoutViewV1` and `PaypalCheckoutViewV2` are now **superseded** by the new `PaypalCheckoutView`.
  * They can still work internally, but the **recommended** usage is the unified widget with `version` + `PayPalOrderRequestBase`.
* Developers should migrate:
  * From direct V1/V2 widgets → to `PaypalCheckoutView(version: PayPalApiVersion.v1 | v2, ...)`.
  * From old loosely-typed maps → to strongly-typed `PayPalOrderRequestV1` / `PayPalOrderRequestV2`.

---

# **2.0.0** — 2025-12-9

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

# **1.0.8** - Legacy

This package simplifies integrating PayPal payments into your mobile app.
Key features include:

* Seamless in-app PayPal WebView checkout
* User-friendly payment flow
* Secure transaction handling
* Customizable UI components
* Real-time payment status updates

Future enhancements include more payment options, fraud protection, subscription support, and analytics improvements.
