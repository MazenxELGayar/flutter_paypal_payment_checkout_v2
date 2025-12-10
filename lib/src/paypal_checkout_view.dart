/// Flutter PayPal Payment Checkout (V1 & V2).
///
/// This library exposes a single high-level widget:
/// [PaypalCheckoutView]
///
/// It handles:
/// - Creating a PayPal payment/order (via V1 or V2 APIs)
/// - Rendering the approval page in an in-app webview
/// - Listening to return/cancel URLs
/// - Executing/capturing the payment (if needed)
/// - Returning the result via callbacks
library flutter_paypal_payment_checkout_v2;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/models/paypal_services_base.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/models/paypal_shared_models.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/v1/paypal_service_v1.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/v2/paypal_service_v2.dart';

import 'models/paypal_payment_model.dart'
    show PayPalGetApprovalUrl, PaypalPaymentModel;

/// Supported PayPal API versions.
///
/// - [PayPalApiVersion.v1] → Legacy Payments API V1.
/// - [PayPalApiVersion.v2] → Modern Orders API V2 (recommended).
enum PayPalApiVersion { v1, v2 }

/// Main checkout widget that handles the entire PayPal flow.
///
/// This widget:
/// - Initializes the selected PayPal API service (V1 or V2).
/// - Either:
///   - Uses a backend-provided [approvalUrl], **or**
///   - Creates the payment/order directly from the client.
/// - Opens an in-app webview to show the PayPal approval page.
/// - Listens for success/cancel redirects using return/cancel URLs.
/// - Executes/captures the payment for client-side flows.
/// - Returns the result to [onUserPayment], [onCancel], or [onError].
class PaypalCheckoutView extends StatefulWidget {
  /// Which PayPal API version to use.
  ///
  /// - [PayPalApiVersion.v1] → uses [PaypalServicesV1] and V1 models.
  /// - [PayPalApiVersion.v2] → uses [PaypalServicesV2] and V2 models.
  final PayPalApiVersion version;

  /// Called when the user completes the payment flow.
  ///
  /// - `response` may be `null` when using the **backend-driven** flow
  ///   (where the server executes/captures and the client only receives
  ///   the `PaypalPaymentModel`).
  /// - `payment` is always the [PaypalPaymentModel] created at the start.
  final PayPalOnSuccess onUserPayment;

  /// Called when the user cancels the PayPal checkout flow.
  final Function onCancel;

  /// Called when any error occurs during:
  /// - Initialization
  /// - Network calls
  /// - Version mismatch
  /// - Unknown exceptions
  final PayPalOnError onError;

  /// App bar title displayed at the top of the checkout screen.
  final String appBarTitle;

  /// Optional note or description (not currently used in logic, but available
  /// for future enhancements or custom UIs).
  final String? note;

  /// Most secure workflow:
  ///
  /// Your backend:
  /// - Creates the PayPal order/payment.
  /// - Returns a [PaypalPaymentModel] with `approvalUrl`.
  ///
  /// The client:
  /// - Only loads that URL and listens for return/cancel.
  ///
  /// Use this when you do **not** want to expose credentials or perform
  /// PayPal API calls in the client.
  final PayPalGetApprovalUrl? approvalUrl;

  /// Less secure and generally not recommended for production.
  ///
  /// Used when:
  /// - The client must request an access token directly.
  /// - The backend cannot (or does not) create the order itself.
  ///
  /// This function should return a **server-generated** access token,
  /// not client credentials.
  final PayPalGetAccessToken? getAccessToken;

  /// Should NEVER be used in production.
  ///
  /// Only for testing or demo apps where you cannot set up a backend yet.
  /// Passing [clientId] and [secretKey] into the app is insecure because
  /// they can be extracted from the binary.
  final String? clientId, secretKey;

  /// Optional custom loading widget shown while:
  /// - Initializing the payment/order, or
  /// - Waiting for callbacks.
  final Widget? loadingIndicator;

  /// The PayPal order model used to build the request.
  ///
  /// - For V1: [PayPalOrderRequestV1]
  /// - For V2: [PayPalOrderRequestV2]
  ///
  /// When using [approvalUrl], this may be `null` if your backend
  /// handles all order creation and execution logic.
  final PayPalOrderRequestBase? payPalOrder;

  /// When `true` → uses PayPal sandbox endpoints.
  ///
  /// When `false` → uses live production endpoints.
  final bool sandboxMode;

  /// By default this is `false`.
  ///
  /// If set to `true`, it bypasses the safety check that normally prevents
  /// using [clientId]/[secretKey] in non-sandbox mode.
  ///
  /// ⚠️ Only set this to `true` if you **fully understand the security risk**.
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
  /// Holds the created PayPal payment/order info (approvalUrl, orderId, etc.).
  PaypalPaymentModel? paymentModel;

  /// Underlying service implementation:
  /// - [PaypalServicesV1] or [PaypalServicesV2].
  late PaypalServicesBase services;

  /// Web loading progress (0.0–1.0).
  double progress = 0;

  /// Controller for the embedded InAppWebView.
  late InAppWebViewController webView;

  /// Convenience getter to check if the widget is configured for V1.
  bool get _isV1 => widget.version == PayPalApiVersion.v1;

  /// Initializes the PayPal flow:
  ///
  /// 1. Chooses the correct service (V1 or V2).
  /// 2. Validates order/service version compatibility.
  /// 3. Calls [PaypalServicesBase.initialize] to:
  ///    - Either use [approvalUrl] (backend flow)
  ///    - Or create the order/payment directly (client flow).
  /// 4. Stores the resulting [PaypalPaymentModel] in state.
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

    // Optional safety: ensure order type matches selected service version.
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
    // While payment/order is initializing → show a loading screen.
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

    // Once we have a paymentModel with approvalUrl → render the webview.
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

  /// Handles the PayPal return URL after approval.
  ///
  /// Delegates to:
  /// - [_executePaymentV1] for V1 flows.
  /// - [_captureOrderV2] for V2 flows.
  Future<void> _handleReturnUrl(Uri? url, BuildContext context) async {
    // Don't try to be smart here — just delegate.
    if (_isV1) {
      await _executePaymentV1(url);
    } else {
      await _captureOrderV2();
    }
  }

  /// Completes the V1 payment using the `execute` URL and `PayerID`.
  ///
  /// Behavior:
  /// - If [paymentModel.accessToken] or [paymentModel.executeUrl] is `null`,
  ///   this indicates a backend-driven execution/capture flow → we simply call
  ///   [onUserPayment] with `response = null` and return.
  /// - Otherwise:
  ///   - Extracts `PayerID` from the return URL query.
  ///   - Calls [PaypalServicesV1.executePayment].
  ///   - Returns the result via [onUserPayment] or [onError].
  Future<void> _executePaymentV1(Uri? url) async {
    final model = paymentModel;
    if (model == null) return;

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

  /// Captures a V2 order after the user returns from PayPal.
  ///
  /// Behavior:
  /// - If [paymentModel.accessToken] or [paymentModel.orderId] is `null`,
  ///   this indicates a backend-driven capture flow → we simply call
  ///   [onUserPayment] with `response = null` and return.
  /// - Otherwise:
  ///   - Calls [PaypalServicesV2.captureOrder].
  ///   - Returns the result via [onUserPayment] or [onError].
  Future<void> _captureOrderV2() async {
    final model = paymentModel;
    if (model == null) return;

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
