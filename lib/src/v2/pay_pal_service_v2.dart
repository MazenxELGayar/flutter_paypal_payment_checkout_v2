import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/models/paypal_payment_model.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/models/paypal_services_base.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/models/shared_models.dart';

part 'enums/pay_pal_item_category_v2.dart';
part 'enums/pay_pal_landing_page_v2.dart';
part 'enums/pay_pal_order_intent_v2.dart';
part 'enums/pay_pal_payment_method_preference_v2.dart';
part 'enums/pay_pal_shipping_preference_v2.dart';
part 'enums/pay_pal_user_action_v2.dart';
part 'models/pay_pal_experience_context_v2.dart';
part 'models/pay_pal_order_request_v2.dart';
part 'models/pay_pal_purchase_unit_v2.dart';

class PaypalServicesV2 extends PaypalServicesBase {
  PaypalServicesV2({
    required String? clientId,
    required String? secretKey,
    required bool sandboxMode,
    required PayPalGetAccessToken? getAccessTokenFunction,
    bool overrideInsecureClientCredentials = false,
  }) : super(
          clientId: clientId,
          secretKey: secretKey,
          sandboxMode: sandboxMode,
          getAccessTokenFunction: getAccessTokenFunction,
          overrideInsecureClientCredentials: overrideInsecureClientCredentials,
        );

  @override
  Future<Either<PayPalErrorModel, PaypalPaymentModel>> createPaypalPayment({
    required PayPalOrderRequestBase payPalOrder,
    required String accessToken,
  }) async {
    // Downcast to the concrete V2 type
    payPalOrder as PayPalOrderRequestV2;

    try {
      final response = await Dio().post(
        '$baseUrl/v2/checkout/orders',
        data: jsonEncode(payPalOrder.toJson()),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      final body = response.data;

      // Links is a List<dynamic>, each is Map<String, dynamic>
      final List<dynamic> linksRaw = body['links'] ?? [];
      Map<String, dynamic>? approvalLink;

      for (final raw in linksRaw) {
        final link = raw as Map<String, dynamic>;
        final rel = link['rel'] as String?;
        if (rel == 'approve' || rel == 'payer-action') {
          approvalLink = link;
          break;
        }
      }

      final href = approvalLink?['href'] as String?;

      if (href == null || href.isEmpty) {
        return Left(
          PayPalErrorModel(
            error: body,
            message:
                "Missing approval link (no 'approve' or 'payer-action' link found)",
            key: "ORDER_CREATE_NO_APPROVE_LINK",
            code: response.statusCode ?? 500,
          ),
        );
      }

      final orderId = body['id'] as String?;
      final status = body['status'] as String?;

      return Right(
        PaypalPaymentModel(
          orderId: orderId,
          approvalUrl: href,
          message: "Order created successfully",
          key: "ORDER_CREATE_SUCCESS",
          accessToken: accessToken,
          code: response.statusCode ?? 200,
          status: status,
          executeUrl: null,
          // experienceContext is your V2 source of URLs
          returnURL: payPalOrder.paymentSource.returnUrl,
          cancelURL: payPalOrder.paymentSource.cancelUrl,
        ),
      );
    } catch (e) {
      return Left(
        PayPalErrorModel(
          error: e.toString(),
          message: "Failed to create order",
          key: "ORDER_CREATE_FAILED",
          code: 500,
        ),
      );
    }
  }

  Future<Either<PayPalErrorModel, PayPalSuccessPaymentModel>> captureOrder(
    String orderId,
    String accessToken,
  ) async {
    try {
      final response = await Dio().post(
        '$baseUrl/v2/checkout/orders/$orderId/capture',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      return Right(
        PayPalSuccessPaymentModel(
          code: response.statusCode ?? 200,
          key: "ORDER_CAPTURE_SUCCESS",
          message: "Order captured successfully",
          data: response.data,
        ),
      );
    } catch (e) {
      return Left(
        PayPalErrorModel(
          error: e.toString(),
          message: "Failed to capture order",
          key: "ORDER_CAPTURE_FAILED",
          code: 500,
        ),
      );
    }
  }

}
