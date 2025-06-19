# M-Pesa Integration Guide

## Overview
This document outlines the integration of Kilele POS with Safaricom's M-Pesa payment system.

## Prerequisites
1. Safaricom Business Account
2. M-Pesa API credentials
3. Valid SSL certificate
4. Registered business details

## Integration Steps

### 1. Configuration
```dart
// Example configuration in .env
MPESA_CONSUMER_KEY=your_consumer_key
MPESA_CONSUMER_SECRET=your_consumer_secret
MPESA_PASSKEY=your_passkey
MPESA_SHORTCODE=your_shortcode
MPESA_ENV=sandbox  // or production
```

### 2. API Endpoints
- STK Push: `/mpesa/stkpush/v1/processrequest`
- Query Status: `/mpesa/stkpushquery/v1/query`
- Transaction Status: `/mpesa/transactionstatus/v1/query`

### 3. Implementation
The integration is implemented in the following files:
- `lib/services/mpesa_service.dart`
- `lib/models/mpesa_transaction.dart`
- `lib/providers/mpesa_provider.dart`

### 4. Payment Flow
1. Initiate STK Push
2. Customer receives prompt
3. Customer enters PIN
4. Receive callback
5. Update transaction status

### 5. Error Handling
Common error codes and their meanings:
- 400: Invalid request
- 401: Authentication failed
- 403: Authorization failed
- 404: Resource not found
- 500: Server error

## Security Considerations
1. Secure storage of credentials
2. SSL/TLS encryption
3. Callback validation
4. Transaction verification

## Testing
1. Use sandbox environment
2. Test with test phone numbers
3. Verify callbacks
4. Test error scenarios

## Troubleshooting
Common issues and solutions:
1. STK Push timeout
2. Invalid phone numbers
3. Network connectivity
4. Callback handling

## Support
For technical support:
1. Safaricom Developer Support: developer@safaricom.co.ke
2. Kilele POS Support: support@kilelepos.com

## Best Practices
1. Always verify transaction status
2. Implement proper error handling
3. Log all transactions
4. Implement retry mechanism
5. Handle timeouts gracefully 