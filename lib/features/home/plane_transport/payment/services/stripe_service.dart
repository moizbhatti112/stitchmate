import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:stitchmate/core/constants/stripe_keys.dart';

class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();

  Future<void> makePayment({
    required int amount,
    required Function onPaymentSuccess,
  }) async {
    try {
      // Changed return type expectation to Map
      String? paymentIntentClientSecret = await _createPaymentIntent(
        amount,
        "pkr",
      );

      if (paymentIntentClientSecret == null) return;
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: "Stitchmate",
        ),
      );
      await _processPayment(onPaymentSuccess);
    } catch (e) {
      debugPrint("Payment error: ${e.toString()}");
    }
  }

  // Changed return type to match what the function actually returns
  Future<String?> _createPaymentIntent(int amount, String currency) async {
    try {
      final Dio dio = Dio();
      Map<String, dynamic> body = {
        "amount": _calculateAmount(amount),
        "currency": currency,
      };

      var response = await dio.post(
        "https://api.stripe.com/v1/payment_intents",
        data: body,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            "Authorization": "Bearer $stripeSecretKey",
            "Content-Type": "application/x-www-form-urlencoded",
          },
        ),
      );

      if (response.data != null) {
        return response.data["client_secret"];
      }
      return null;
    } catch (e) {
      debugPrint("Create payment intent error: ${e.toString()}");
      return null;
    }
  }

  Future<void> _processPayment(Function onPaymentSuccess) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      // await Stripe.instance.confirmPaymentSheetPayment();
      // Handle successful payment here
      onPaymentSuccess();
    } catch (e) {
      debugPrint("Payment processing error: ${e.toString()}");
    }
  }

  String _calculateAmount(int amount) {
    final calculatedAmount = amount * 100;
    return calculatedAmount.toString();
  }
}
