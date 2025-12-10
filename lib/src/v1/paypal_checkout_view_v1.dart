// library flutter_paypal_checkout;
//
// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_paypal_payment_checkout_v2/src/models/paypal_payment_model.dart';
// import 'package:flutter_paypal_payment_checkout_v2/src/models/shared_models.dart';
// import 'package:flutter_paypal_payment_checkout_v2/src/v1/paypal_service_v1.dart';
//
// class PaypalCheckoutViewV1 extends StatefulWidget {
//   final Function onSuccess, onCancel;
//   final PayPalOnError onError;
//   final String appBarTitle;
//   final String? note;
//
//   /// Most secure workflow.
//   /// Your backend is responsible for creating the PayPal order
//   /// and returning only the approval URL for the user to complete checkout.
//   /// Example: subscriptions or payments that must be created server-side first.
//   final PayPalGetApprovalUrl? approvalUrl;
//
//   /// Less secure and generally not recommended for production.
//   /// Used when the client requests an access token directly or when the backend
//   /// cannot generate the approval URL itself.
//   final PayPalGetAccessToken? getAccessToken;
//
//   /// Should NEVER be used in production.
//   /// Only for testing without a backend, as it exposes the PayPal clientId
//   /// and secretKey inside the application, which is insecure.
//   final String? clientId, secretKey;
//
//   final Widget? loadingIndicator;
//
//   final PayPalOrderRequestV1? payPalOrder;
//
//   /// When true → calls PayPal sandbox APIs.
//   /// When false → calls live / production PayPal APIs.
//   final bool sandboxMode;
//
//   /// By default this is false.
//   /// If set to true, it will bypass the safety check that prevents
//   /// using clientId / secretKey directly in a non-sandbox environment.
//   /// Only set this to true if you fully understand the security risk.
//   final bool overrideInsecureClientCredentials;
//
//   const PaypalCheckoutViewV1({
//     Key? key,
//     required this.onSuccess,
//     required this.getAccessToken,
//     required this.onError,
//     required this.onCancel,
//     required this.payPalOrder,
//     required this.clientId,
//     required this.secretKey,
//     required this.sandboxMode,
//     this.overrideInsecureClientCredentials = false,
//     this.appBarTitle = "Paypal Payment",
//     this.note = '',
//     this.loadingIndicator,
//     this.approvalUrl,
//   }) : super(key: key);
//
//   @override
//   State<StatefulWidget> createState() {
//     return PaypalCheckoutViewV1State();
//   }
// }
//
// class PaypalCheckoutViewV1State extends State<PaypalCheckoutViewV1> {
//   PaypalPaymentModel? paymentModel;
//   String navUrl = '';
//   bool loading = true;
//   bool pageloading = true;
//   bool loadingError = false;
//   late PaypalServicesV1 services;
//   int pressed = 0;
//   double progress = 0;
//
//   late InAppWebViewController webView;
//
//   Future<void> initializePayment() async {
//     services = PaypalServicesV1(
//       getAccessTokenFunction: widget.getAccessToken,
//       sandboxMode: widget.sandboxMode,
//       clientId: widget.clientId,
//       secretKey: widget.secretKey,
//       overrideInsecureClientCredentials:
//           widget.overrideInsecureClientCredentials,
//     );
//
//     try {
//       final result = await services.initialize(
//         getApprovalUrl: widget.approvalUrl,
//         payPalOrder: widget.payPalOrder,
//       );
//       result.fold(
//         (error) {
//           widget.onError(error);
//         },
//         (paymentModel) {
//           setState(
//             () {
//               this.paymentModel = paymentModel;
//             },
//           );
//         },
//       );
//     } catch (e) {
//       widget.onError(
//         PayPalErrorModel(
//           error: e.toString(),
//           message: "Unknown error",
//           key: "UNKNOWN_ERROR",
//           code: 500,
//         ),
//       );
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     initializePayment();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (paymentModel != null) {
//       return Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           centerTitle: true,
//           title: Text(
//             widget.appBarTitle,
//           ),
//         ),
//         body: Stack(
//           children: <Widget>[
//             InAppWebView(
//               shouldOverrideUrlLoading: (controller, navigationAction) async {
//                 final url = navigationAction.request.url;
//
//                 if (url.toString().contains(paymentModel!.returnURL)) {
//                   executePayment(url, context);
//                   return NavigationActionPolicy.CANCEL;
//                 }
//                 if (url.toString().contains(paymentModel!.cancelURL)) {
//                   return NavigationActionPolicy.CANCEL;
//                 } else {
//                   return NavigationActionPolicy.ALLOW;
//                 }
//               },
//               initialUrlRequest: URLRequest(
//                 url: WebUri(
//                   paymentModel!.approvalUrl,
//                 ),
//               ),
//               // initialOptions: InAppWebViewGroupOptions(
//               //   crossPlatform: InAppWebViewOptions(
//               //     useShouldOverrideUrlLoading: true,
//               //   ),
//               // ),
//               onWebViewCreated: (InAppWebViewController controller) {
//                 webView = controller;
//               },
//               onCloseWindow: (InAppWebViewController controller) {
//                 widget.onCancel();
//               },
//               onProgressChanged:
//                   (InAppWebViewController controller, int progress) {
//                 setState(() {
//                   this.progress = progress / 100;
//                 });
//               },
//             ),
//             progress < 1
//                 ? SizedBox(
//                     height: 3,
//                     child: LinearProgressIndicator(
//                       value: progress,
//                     ),
//                   )
//                 : const SizedBox(),
//           ],
//         ),
//       );
//     } else {
//       return Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           centerTitle: true,
//           title: Text(
//             widget.appBarTitle,
//           ),
//         ),
//         body: Center(
//             child:
//                 widget.loadingIndicator ?? const CircularProgressIndicator()),
//       );
//     }
//   }
//
//   Future<void> executePayment(Uri? url, BuildContext context) async {
//     // If you're in the new flow where the backend will execute/capture,
//     // you can just exit early when there's no token/executeUrl.
//     if (paymentModel?.accessToken == null || paymentModel?.executeUrl == null) {
//       // backend will call execute/capture – nothing to do on client
//       return;
//     }
//
//     // Extract PayerID from return URL
//     final payerId = url?.queryParameters['PayerID'];
//
//     if (payerId == null) {
//       widget.onError(
//         PayPalErrorModel(
//           error: "PayerID is null",
//           message: "PayerID is null",
//           key: "PAYMENT_EXECUTE_PAYER_ID_NULL",
//           code: 500,
//         ),
//       );
//       return;
//     }
//
//     final result = await services.executePayment(
//       paymentModel!.executeUrl!,
//       payerId,
//       paymentModel!.accessToken!,
//     );
//
//     result.fold(
//       (error) {
//         widget.onError(
//           error,
//         );
//       },
//       (executeSuccess) {
//         widget.onSuccess(
//           executeSuccess.data,
//         );
//       },
//     );
//   }
// }
