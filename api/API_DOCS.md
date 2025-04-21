# WhatsApp Business API Integration Documentation

This document describes the endpoints and usage for the WhatsApp Business API integration.

## Authentication

All API endpoints (except webhooks) require authentication. Use the JWT token obtained during login.

```
Authorization: Bearer YOUR_JWT_TOKEN
```

## WhatsApp Business Configuration

### Show Configuration

Get the current WhatsApp Business configuration for the authenticated recruiter.

**Request:**
```
GET /api/v1/whatsapp_business_config
```

**Response:**
```json
{
  "id": 1,
  "phone_number_id": "1234567890",
  "business_account_id": "98765432109876",
  "created_at": "2023-05-01T12:00:00.000Z",
  "updated_at": "2023-05-01T12:00:00.000Z",
  "recruiter": {
    "id": 1
  }
}
```

### Create Configuration

Create a new WhatsApp Business configuration for the authenticated recruiter.

**Request:**
```
POST /api/v1/whatsapp_business_config
Content-Type: application/json

{
  "whats_app_business_config": {
    "access_token": "EAAbcXYZ123...",
    "phone_number_id": "1234567890",
    "business_account_id": "98765432109876",
    "webhook_secret": "your_webhook_secret"
  }
}
```

**Response:**
```json
{
  "id": 1,
  "phone_number_id": "1234567890",
  "business_account_id": "98765432109876",
  "created_at": "2023-05-01T12:00:00.000Z",
  "updated_at": "2023-05-01T12:00:00.000Z",
  "recruiter": {
    "id": 1
  }
}
```

### Update Configuration

Update an existing WhatsApp Business configuration.

**Request:**
```
PUT /api/v1/whatsapp_business_config
Content-Type: application/json

{
  "whats_app_business_config": {
    "access_token": "EAAbcXYZ123...",
    "phone_number_id": "1234567890",
    "business_account_id": "98765432109876",
    "webhook_secret": "your_webhook_secret"
  }
}
```

**Response:**
```json
{
  "id": 1,
  "phone_number_id": "1234567890",
  "business_account_id": "98765432109876",
  "created_at": "2023-05-01T12:00:00.000Z",
  "updated_at": "2023-05-01T12:00:00.000Z",
  "recruiter": {
    "id": 1
  }
}
```

### Delete Configuration

Delete the WhatsApp Business configuration.

**Request:**
```
DELETE /api/v1/whatsapp_business_config
```

**Response:**
```
204 No Content
```

### Send Test Message

Send a test message to verify WhatsApp integration is working.

**Request:**
```
POST /api/v1/whatsapp_business_config/test_message
Content-Type: application/json

{
  "phone_number": "+1234567890",
  "message": "This is a test message from RecruitMate!"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Test message sent successfully",
  "message_id": "wamid.abcdef123456789"
}
```

## Webhook Setup

To receive messages and events from WhatsApp, you need to configure a webhook.

### Configure Webhook in WhatsApp Business Portal

1. Go to your WhatsApp Business Dashboard
2. Navigate to API Setup > Webhooks
3. Click "Add Webhook"
4. Enter your webhook URL: `https://your-domain.com/api/v1/whatsapp_webhooks`
5. Set the Verify Token to match your `WHATSAPP_WEBHOOK_VERIFY_TOKEN` environment variable
6. Subscribe to the events you need (messages, message_status, etc.)

### Environment Variables

For production use, set the following environment variables:

```
ENCRYPTION_PRIMARY_KEY=your_primary_key
ENCRYPTION_DETERMINISTIC_KEY=your_deterministic_key
ENCRYPTION_KEY_DERIVATION_SALT=your_key_derivation_salt
WHATSAPP_WEBHOOK_VERIFY_TOKEN=your_webhook_verify_token
```

## Security Considerations

1. Always use HTTPS for all API endpoints
2. Keep your encryption keys secure and rotate them periodically
3. Store access tokens and secrets properly using environment variables
4. Verify webhook signatures for all incoming requests
5. The API only returns necessary fields, not sensitive credentials 