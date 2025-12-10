library flutter_paypal_payment_checkout_v2;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/models/paypal_services_base.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/models/shared_models.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/v1/paypal_service_v1.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/v2/pay_pal_service_v2.dart';

import 'models/paypal_payment_model.dart'
    show PayPalGetApprovalUrl, PaypalPaymentModel;

enum PayPalApiVersion { v1, v2 }

class PaypalCheckoutView extends StatefulWidget {
  final PayPalApiVersion version;
  final PayPalOnSuccess onUserPayment;
  final Function onCancel;
  final PayPalOnError onError;
  final String appBarTitle;
  final String? note;

  /// Most secure workflow.
  /// Your backend is responsible for creating the PayPal order
  /// and returning only the approval URL for the user to complete checkout.
  final PayPalGetApprovalUrl? approvalUrl;

  /// Less secure and generally not recommended for production.
  /// Used when the client requests an access token directly or when the backend
  /// cannot generate the approval URL itself.
  final PayPalGetAccessToken? getAccessToken;

  /// Should NEVER be used in production.
  /// Only for testing without a backend, as it exposes the PayPal clientId
  /// and secretKey inside the application, which is insecure.
  final String? clientId, secretKey;

  final Widget? loadingIndicator;

  /// Can be PayPalOrderRequestV1 or PayPalOrderRequestV2
  final PayPalOrderRequestBase? payPalOrder;

  /// When true → calls PayPal sandbox APIs.
  /// When false → calls live / production PayPal APIs.
  final bool sandboxMode;

  /// By default this is false.
  /// If set to true, it will bypass the safety check that prevents
  /// using clientId / secretKey directly in a non-sandbox environment.
  /// Only set this to true if you fully understand the security risk.
  final bool overrideInsecureClientCredentials;

  const PaypalCheckoutView({
    Key? key,
    required this.onUserPayment,
    required this.getAccessToken,
    required this.onError,
    required this.onCancel,
    required this.payPalOrder,
    required this.clientId,
    required this.secretKey,
    required this.sandboxMode,
    this.overrideInsecureClientCredentials = false,
    this.appBarTitle = "Paypal Payment",
    this.note = '',
    this.loadingIndicator,
    this.approvalUrl,
    required this.version,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PaypalCheckoutViewState();
}

class _PaypalCheckoutViewState extends State<PaypalCheckoutView> {
  PaypalPaymentModel? paymentModel;
  late PaypalServicesBase services;

  double progress = 0;
  late InAppWebViewController webView;

  bool get _isV1 => widget.version == PayPalApiVersion.v1;

  Future<void> _initializePayment() async {
    // Pick the correct service implementation based on the order type
    if (_isV1) {
      services = PaypalServicesV1(
        getAccessTokenFunction: widget.getAccessToken,
        sandboxMode: widget.sandboxMode,
        clientId: widget.clientId,
        secretKey: widget.secretKey,
        overrideInsecureClientCredentials:
            widget.overrideInsecureClientCredentials,
      );
    } else {
      services = PaypalServicesV2(
        getAccessTokenFunction: widget.getAccessToken,
        sandboxMode: widget.sandboxMode,
        clientId: widget.clientId,
        secretKey: widget.secretKey,
        overrideInsecureClientCredentials:
            widget.overrideInsecureClientCredentials,
      );
    }

    if (widget.payPalOrder != null) {
      final isOrderV1 = widget.payPalOrder!.isV1;
      final isServiceV1 = services is PaypalServicesV1;

      if (isOrderV1 != isServiceV1) {
        widget.onError(
          PayPalErrorModel(
            error: "Order type does not match selected PayPal service version.",
            message:
                "You passed a ${isOrderV1 ? 'V1' : 'V2'} order into a ${isServiceV1 ? 'V1' : 'V2'} service.\n\n"
                "Make sure:\n"
                "- PayPalOrderRequestV1 → PaypalServicesV1\n"
                "- PayPalOrderRequestV2 → PaypalServicesV2",
            key: "ORDER_VERSION_MISMATCH",
            code: 400,
          ),
        );
        return; // Stop here — do NOT continue
      }
    }

    try {
      final result = await services.initialize(
        getApprovalUrl: widget.approvalUrl,
        payPalOrder: widget.payPalOrder,
      );

      result.fold(
        (error) => widget.onError(error),
        (paymentModel) {
          setState(() {
            this.paymentModel = paymentModel;
          });
        },
      );
    } catch (e) {
      widget.onError(
        PayPalErrorModel(
          error: e.toString(),
          message: "Unknown error",
          key: "UNKNOWN_ERROR",
          code: 500,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  @override
  Widget build(BuildContext context) {
    if (paymentModel == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(widget.appBarTitle),
        ),
        body: Center(
          child: widget.loadingIndicator ?? const CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(widget.appBarTitle),
      ),
      body: Stack(
        children: <Widget>[
          InAppWebView(
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url;
              final urlStr = url.toString();

              // Use the URLs coming back from PaypalPaymentModel for both V1 and V2
              final returnURL = paymentModel!.returnURL;
              final cancelURL = paymentModel!.cancelURL;

              if (urlStr.contains(returnURL)) {
                await _handleReturnUrl(url, context);
                return NavigationActionPolicy.CANCEL;
              }

              if (urlStr.contains(cancelURL)) {
                widget.onCancel();
                return NavigationActionPolicy.CANCEL;
              }

              return NavigationActionPolicy.ALLOW;
            },
            initialUrlRequest: URLRequest(
              url: WebUri(paymentModel!.approvalUrl),
            ),
            onWebViewCreated: (controller) {
              webView = controller;
            },
            onCloseWindow: (controller) {
              widget.onCancel();
            },
            onProgressChanged: (controller, progress) {
              setState(() {
                this.progress = progress / 100;
              });
            },
          ),
          progress < 1
              ? SizedBox(
                  height: 3,
                  child: LinearProgressIndicator(value: progress),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  Future<void> _handleReturnUrl(Uri? url, BuildContext context) async {
    // Don't try to be smart here — just delegate.
    if (_isV1) {
      await _executePaymentV1(url);
    } else {
      await _captureOrderV2();
    }
  }

  Future<void> _executePaymentV1(Uri? url) async {
    final model = paymentModel;
    if (model == null) return;

    // ✅ Same as your original:
    // If you're in the new flow where the backend will execute/capture,
    // you can just exit early when there's no token/executeUrl.
    if (model.accessToken == null || model.executeUrl == null) {
      // backend will call execute/capture – nothing to do on client
      widget.onUserPayment(
        null,
        model,
      );
      return;
    }

    // Extract PayerID from return URL
    final payerId = url?.queryParameters['PayerID'];

    if (payerId == null) {
      widget.onError(
        PayPalErrorModel(
          error: "PayerID is null",
          message: "PayerID is null",
          key: "PAYMENT_EXECUTE_PAYER_ID_NULL",
          code: 500,
        ),
      );
      return;
    }

    final v1 = services as PaypalServicesV1;

    final result = await v1.executePayment(
      model.executeUrl!,
      payerId,
      model.accessToken!,
    );

    result.fold(
      (error) => widget.onError(error),
      (success) {
        widget.onUserPayment(
          success,
          model,
        );
      },
    );
  }

  Future<void> _captureOrderV2() async {
    final model = paymentModel;
    if (model == null) return;

    // ✅ Same as your original:
    // If you're in the new flow where the backend will execute/capture,
    // you can just exit early when there's no token/orderId.
    if (model.accessToken == null || model.orderId == null) {
      widget.onUserPayment(
        null,
        model,
      );
      return;
    }

    final v2 = services as PaypalServicesV2;

    final result = await v2.captureOrder(
      model.orderId!,
      model.accessToken!,
    );

    result.fold(
      (error) => widget.onError(error),
      (success) {
        widget.onUserPayment(
          success,
          model,
        );
      },
    );
  }
}
