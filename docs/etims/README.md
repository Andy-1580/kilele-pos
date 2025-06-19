# eTIMS Integration Guide

## Overview
This document outlines the integration of Kilele POS with the Kenya Revenue Authority's (KRA) Electronic Tax Invoice Management System (eTIMS).

## Prerequisites
1. Valid KRA PIN
2. eTIMS API credentials
3. Valid SSL certificate
4. Registered business details

## Integration Steps

### 1. Configuration
```dart
// Example configuration in .env
ETIMS_API_URL=https://api.etims.kra.go.ke
ETIMS_CLIENT_ID=your_client_id
ETIMS_CLIENT_SECRET=your_client_secret
ETIMS_PIN=your_kra_pin
```

### 2. API Endpoints
- Invoice Submission: `/api/v1/invoices`
- Invoice Status: `/api/v1/invoices/{invoiceId}`
- Token Generation: `/api/v1/token`

### 3. Implementation
The integration is implemented in the following files:
- `lib/services/etims_service.dart`
- `lib/models/etims_invoice.dart`
- `lib/providers/etims_provider.dart`

### 4. Error Handling
Common error codes and their meanings:
- 400: Invalid request
- 401: Authentication failed
- 403: Authorization failed
- 404: Resource not found
- 500: Server error

### 5. Testing
1. Use test credentials in development
2. Test with sample invoices
3. Verify error handling
4. Test offline scenarios

## Security Considerations
1. Secure storage of credentials
2. SSL/TLS encryption
3. Token management
4. Data validation

## Troubleshooting
Common issues and solutions:
1. Token expiration
2. Network connectivity
3. Invalid invoice format
4. Rate limiting

## Support
For technical support:
1. KRA eTIMS Support: support@etims.kra.go.ke
2. Kilele POS Support: support@kilelepos.com 