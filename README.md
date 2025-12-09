
# Flutter PayPal Payment Package

The **Flutter PayPal Payment Package** provides an easy-to-integrate solution for enabling PayPal payments in your Flutter mobile application. This package allows for a seamless checkout experience with both sandbox and production environments.

## Features

- **Seamless PayPal Integration**: Easily integrate PayPal payments into your Flutter app.
- **Sandbox Mode Support**: Test payments in a safe sandbox environment before going live.
- **Customizable Transactions**: Define custom transaction details for each payment.
- **Payment Outcome Callbacks**: Handle success, error, and cancellation events for payments.

## Installation

To install the Flutter PayPal Payment Package, follow these steps

1. Add the package to your project's dependencies in the `pubspec.yaml` file:
   ```yaml
   dependencies:
     flutter_paypal_payment: ^2.0.0
    ``` 
2. Run the following command to fetch the package:

    ``` 
    flutter pub get
    ``` 

## Usage
1. Import the package into your Dart file:

    ``` 
    import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
    ```
2. Navigate to the PayPal checkout view with the desired configuration:
```dart
Navigator.of(context).push(MaterialPageRoute(
builder: (BuildContext context) => PaypalCheckoutViewV1(
/// A MUST FOR PRODUCTION
getAccessToken: null,

/// SANDBOX IS TESTING MODE
sandboxMode: true,
clientId: "ONLY FOR SANDBOX (TESTING PURPOSES ONLY)",
secretKey: "ONLY FOR SANDBOX (TESTING PURPOSES ONLY)",

/// API VERSION 1
transactions: PaypalTransactionV1(
amount: PaypalTransactionV1Amount(
subTotal: 100.0,
tax: 0.0,
total: 100.0,
// total = subtotal + tax + shipping + handlingFee - shippingDiscount + insurance
shipping: 0.0,
handlingFee: 0.0,
shippingDiscount: 0.0,
insurance: 0.0,
currency: 'USD',
),
description: "The payment transaction description.",
custom: null,
// dynamic, you can put user ID or anything
items: [
PaypalTransactionV1Item(
name: "Apple",
description: "Fresh apples",
quantity: 4,
price: 10.0,
tax: 0.0,
sku: "SKU_APPLE",
currency: "USD",
),
PaypalTransactionV1Item(
name: "Pineapple",
description: "Fresh pineapples",
quantity: 5,
price: 12.0,
tax: 0.0,
sku: "SKU_PINEAPPLE",
currency: "USD",
),
],
shippingAddress: null,
// optional, can add PayPalShippingAddressV1 if needed
invoiceNumber: null,
paymentOptions: null,
softDescriptor: null,
),
note: "Contact us for any questions on your order.",
onSuccess: (Map params) async {
log("onSuccess: $params");
Navigator.pop(context);
},
onError: (error) {
log("onError: $error");
Navigator.pop(context);
},
onCancel: () {
log('cancelled:');
Navigator.pop(context);
},
),
));
``` 
## ⚡ Donate 

If you would like to support me, please consider making a donation through one of the following links:

* [PayPal](https://paypal.me/mazenelgayar)

Thank you for your support!
