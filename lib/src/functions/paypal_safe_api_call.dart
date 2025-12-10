import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/models/paypal_shared_models.dart';

/// Safely executes a Dio API call and wraps the result in an Either type.
///
/// This helper prevents repetitive try/catch blocks across API services and
/// standardizes error handling for both known (Dio) and unknown exceptions.
///
/// Returns:
/// - `Right(Response)` when the request succeeds.
/// - `Left(PayPalErrorModel)` when an error occurs.
///
/// Parameters:
/// - [request]: A function that performs the Dio request.
/// - [networkErrorKey]: Error key used when a Dio-related/network error occurs.
/// - [networkErrorMessage]: Message shown for network-related failures.
/// - [unknownErrorKey]: Error key used for unexpected errors.
/// - [unknownErrorMessage]: Message shown for unknown/unhandled errors.
///
/// Error Handling:
/// - **DioException** → Uses response body if available, otherwise e.toString().
/// - **Any other exception** → Treated as an unknown error, returned with code 500.
///
Future<Either<PayPalErrorModel, Response>> payPalSafeApiCall(
  Future<Response> Function() request, {
  required String networkErrorKey,
  required String networkErrorMessage,
  required String unknownErrorKey,
  required String unknownErrorMessage,
}) async {
  try {
    final response = await request();
    return Right(response);
  } on DioException catch (e) {
    return Left(
      PayPalErrorModel(
        error: e.response?.data ?? e.toString(),
        message: networkErrorMessage,
        key: networkErrorKey,
        code: e.response?.statusCode ?? 400,
      ),
    );
  } catch (e) {
    return Left(
      PayPalErrorModel(
        error: e.toString(),
        message: unknownErrorMessage,
        key: unknownErrorKey,
        code: 500,
      ),
    );
  }
}
