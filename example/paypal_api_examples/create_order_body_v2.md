# PayPal Create Order Example

```bash
curl -v -X POST https://api-m.sandbox.paypal.com/v2/checkout/orders \
-H 'Content-Type: application/json' \
-H 'PayPal-Request-Id: 7b92603e-77ed-4896-8e78-5dea2050476a' \
-H 'Authorization: Bearer <ACCESS_TOKEN>' \
-d '{
  "intent": "CAPTURE",
  "payment_source": {
    "paypal": {
      "experience_context": {
        "payment_method_preference": "IMMEDIATE_PAYMENT_REQUIRED",
        "landing_page": "LOGIN",
        "shipping_preference": "GET_FROM_FILE",
        "user_action": "PAY_NOW",
        "return_url": "https://example.com/returnUrl",
        "cancel_url": "https://example.com/cancelUrl"
      }
    }
  },
  "purchase_units": [
    {
      "invoice_id": "90210",
      "amount": {
        "currency_code": "USD",
        "value": "230.00",
        "breakdown": {
          "item_total": {"currency_code": "USD","value": "220.00"},
          "shipping": {"currency_code": "USD","value": "10.00"}
        }
      },
      "items": [
        {
          "name": "T-Shirt",
          "description": "Super Fresh Shirt",
          "unit_amount": {"currency_code": "USD","value": "20.00"},
          "quantity": "1",
          "category": "PHYSICAL_GOODS",
          "sku": "sku01",
          "image_url": "https://example.com/static/images/items/1/tshirt_green.jpg",
          "url": "https://example.com/url-to-the-item-being-purchased-1",
          "upc": {"type": "UPC-A","code": "123456789012"}
        },
        {
          "name": "Shoes",
          "description": "Running, Size 10.5",
          "sku": "sku02",
          "unit_amount": {"currency_code": "USD","value": "100.00"},
          "quantity": "2",
          "category": "PHYSICAL_GOODS",
          "image_url": "https://example.com/static/images/items/1/shoes_running.jpg",
          "url": "https://example.com/url-to-the-item-being-purchased-2",
          "upc": {"type": "UPC-A","code": "987654321012"}
        }
      ]
    }
  ]
}'
