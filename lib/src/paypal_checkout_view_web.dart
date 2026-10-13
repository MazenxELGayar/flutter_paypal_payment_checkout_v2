import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/models/paypal_services_base.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/models/paypal_shared_models.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/v1/paypal_service_v1.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/v2/paypal_service_v2.dart';
import 'package:web/web.dart' as web;

import 'models/paypal_payment_model.dart'
    show PaypalPaymentModel, PaypalCheckoutConfig, PayPalApiVersion;

/// Web checkout widget that redirects the browser to PayPal's approval page.
///
/// After approval or cancellation PayPal redirects back to the configured
/// [returnURL] / [cancelURL]. State is restored from [sessionStorage] so the
/// widget can complete the flow via [onUserPayment], [onCancel], or [onError].
///
/// **Recommended web setup**
/// - Provide [PaypalCheckoutConfig.approvalUrl] from your backend.
/// - Set HTTPS return/cancel URLs (see [webDefaultReturnUrl] /
///   [webDefaultCancelUrl]) when creating the PayPal order server-side.
/// - Omit client [accessToken] / [orderId] on [PaypalPaymentModel] so capture
///   runs on your backend after redirect.
class PaypalCheckoutView extends StatefulWidget {
  final PaypalCheckoutConfig config;

  const PaypalCheckoutView({Key? key, required this.config}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PaypalCheckoutViewState();
}

class _PaypalCheckoutViewState extends State<PaypalCheckoutView> {
  PaypalPaymentModel? paymentModel;
  late PaypalServicesBase services;

  bool get _isV1 => widget.config.version == PayPalApiVersion.v1;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  /// Restores state after a PayPal redirect or starts a new checkout.
  Future<void> _bootstrap() async {
    final stored = web.window.sessionStorage.getItem(paypalWebSessionStorageKey);
    if (stored != null) {
      try {
        final state = jsonDecode(stored) as Map<String, dynamic>;
        final model = _paymentModelFromJson(
          state['paymentModel'] as Map<String, dynamic>,
        );
        final versionName = state['version'] as String?;
        final currentUrl = Uri.base.toString();

        if (currentUrl.contains(model.cancelURL)) {
          _clearStoredCheckout();
          widget.config.onCancel();
          return;
        }

        if (currentUrl.contains(model.returnURL)) {
          _setupServices(
            versionName == PayPalApiVersion.v1.name
                ? PayPalApiVersion.v1
                : PayPalApiVersion.v2,
          );
          setState(() => paymentModel = model);
          await _handleReturnUrl(Uri.base);
          _clearStoredCheckout();
          return;
        }

        // Stale session from an abandoned checkout — start fresh.
        _clearStoredCheckout();
      } catch (e) {
        _clearStoredCheckout();
        widget.config.onError(
          PayPalErrorModel(
            error: e.toString(),
            message: "Failed to restore PayPal checkout state after redirect.",
            key: "WEB_CHECKOUT_STATE_RESTORE_FAILED",
            code: 500,
          ),
        );
        return;
      }
    }

    await _initializePayment();
  }

  void _setupServices(PayPalApiVersion version) {
    if (version == PayPalApiVersion.v1) {
      services = PaypalServicesV1(
        getAccessTokenFunction: widget.config.getAccessToken,
        sandboxMode: widget.config.sandboxMode,
        clientId: widget.config.clientId,
        secretKey: widget.config.secretKey,
        overrideInsecureClientCredentials:
            widget.config.overrideInsecureClientCredentials,
      );
    } else {
      services = PaypalServicesV2(
        getAccessTokenFunction: widget.config.getAccessToken,
        sandboxMode: widget.config.sandboxMode,
        clientId: widget.config.clientId,
        secretKey: widget.config.secretKey,
        overrideInsecureClientCredentials:
            widget.config.overrideInsecureClientCredentials,
      );
    }
  }

  Future<void> _initializePayment() async {
    _setupServices(widget.config.version);

    if (widget.config.payPalOrder != null) {
      final isOrderV1 = widget.config.payPalOrder!.isV1;
      final isServiceV1 = services is PaypalServicesV1;

      if (isOrderV1 != isServiceV1) {
        widget.config.onError(
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
        return;
      }
    }

    try {
      final result = await services.initialize(
        getApprovalUrl: widget.config.approvalUrl,
        payPalOrder: widget.config.payPalOrder,
      );

      await result.fold((error) async => widget.config.onError(error), (
        paymentModel,
      ) async {
        setState(() => this.paymentModel = paymentModel);
        await _redirectToPayPal(paymentModel);
      });
    } catch (e) {
      widget.config.onError(
        PayPalErrorModel(
          error: e.toString(),
          message: "Unknown error",
          key: "UNKNOWN_ERROR",
          code: 500,
        ),
      );
    }
  }

  Future<void> _redirectToPayPal(PaypalPaymentModel model) async {
    final state = jsonEncode({
      'paymentModel': model.toJson(),
      'version': widget.config.version.name,
    });
    web.window.sessionStorage.setItem(paypalWebSessionStorageKey, state);
    web.window.location.assign(model.approvalUrl);
  }

  void _clearStoredCheckout() {
    web.window.sessionStorage.removeItem(paypalWebSessionStorageKey);
  }

  PaypalPaymentModel _paymentModelFromJson(Map<String, dynamic> json) {
    return PaypalPaymentModel(
      orderId: json['orderId'] as String?,
      approvalUrl: json['approvalUrl'] as String,
      executeUrl: json['executeUrl'] as String?,
      accessToken: json['accessToken'] as String?,
      returnURL: json['returnURL'] as String? ?? defaultReturnURL,
      cancelURL: json['cancelURL'] as String? ?? defaultCancelURL,
      status: json['status'] as String?,
      message: json['message'] as String? ?? '',
      key: json['key'] as String? ?? '',
      code: json['code'] as int? ?? 200,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(widget.config.appBarTitle),
      ),
      body: Center(
        child:
            widget.config.loadingIndicator ?? const CircularProgressIndicator(),
      ),
    );
  }

  Future<void> _handleReturnUrl(Uri url) async {
    if (_isV1) {
      await _executePaymentV1(url);
    } else {
      await _captureOrderV2();
    }
  }

  Future<void> _executePaymentV1(Uri url) async {
    final model = paymentModel;
    if (model == null) return;

    if (model.accessToken == null || model.executeUrl == null) {
      widget.config.onUserPayment(null, model);
      return;
    }

    final webApiError = validateWebDirectApiCall();
    if (webApiError != null) {
      widget.config.onError(webApiError);
      return;
    }

    final payerId = url.queryParameters['PayerID'];

    if (payerId == null) {
      widget.config.onError(
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

    result.fold((error) => widget.config.onError(error), (success) {
      widget.config.onUserPayment(success, model);
    });
  }

  Future<void> _captureOrderV2() async {
    final model = paymentModel;
    if (model == null) return;

    if (model.accessToken == null || model.orderId == null) {
      final result = await widget.config.onUserPayment(null, model);
      return result.fold(
        (PayPalErrorModel error) {
          if (kDebugMode) {
            print("Backend flow => error: $error");
          }
          widget.config.onError(error);
        },
        (success) {
          if (kDebugMode) {
            print("Backend flow => Payment Captured: $success");
          }
        },
      );
    }

    final webApiError = validateWebDirectApiCall();
    if (webApiError != null) {
      widget.config.onError(webApiError);
      return;
    }

    final v2 = services as PaypalServicesV2;

    final result = await v2.captureOrder(model.orderId!, model.accessToken!);

    result.fold((error) => widget.config.onError(error), (success) {
      widget.config.onUserPayment(success, model);
    });
  }
}
