import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/v1/paypal_checkout_view_v1.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/v1/paypal_service_v1.dart';

void main() {
  runApp(const PaypalPaymentDemo());
}

class PaypalPaymentDemo extends StatelessWidget {
  const PaypalPaymentDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PaypalPaymentDemp',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () {
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
            },
            child: const Text('Pay with paypal'),
          ),
        ),
      ),
    );
  }
}
