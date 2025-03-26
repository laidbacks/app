# Profile API Endpoints

This document outlines the API endpoints for managing user profiles.

## Authentication

All endpoints require authentication. Authentication is handled through session cookies.
If the user is not authenticated, the API will return a `401 Unauthorized` response.

## GET /api/v1/profile

Retrieves the profile information for the currently authenticated user.

### Response

**Status: 200 OK**

```json
{
  "id": 1,
  "username": "johndoe",
  "full_name": "John Doe",
  "email": "john@example.com",
  "bio": "A short bio about me",
  "timezone": "America/New_York",
  "avatar": "https://example.com/avatar.jpg",
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-01-02T00:00:00Z"
}
```

## PATCH /api/v1/profile

Updates the profile information for the currently authenticated user.

### Request

```json
{
  "profile": {
    "full_name": "John Doe",
    "email": "john@example.com",
    "bio": "Updated bio information",
    "timezone": "America/New_York",
    "avatar": "https://example.com/new-avatar.jpg"
  }
}
```

### Response

**Status: 200 OK**

```json
{
  "id": 1,
  "username": "johndoe",
  "full_name": "John Doe",
  "email": "john@example.com",
  "bio": "Updated bio information",
  "timezone": "America/New_York",
  "avatar": "https://example.com/new-avatar.jpg",
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-01-02T00:00:00Z"
}
```

### Error Response

**Status: 422 Unprocessable Entity**

```json
{
  "errors": [
    "Email is invalid",
    "Timezone is not included in the list"
  ]
}
```

## POST /api/v1/profile/avatar

Uploads a new avatar image for the user profile.

### Request

This endpoint expects a multipart form-data request with an `avatar` field containing the image file.

### Response

**Status: 200 OK**

```json
{
  "message": "Avatar uploaded successfully",
  "avatar_url": "https://example.com/avatars/user_1.jpg"
}
```

### Error Response

**Status: 422 Unprocessable Entity**

```json
{
  "error": "File size exceeds maximum limit (5MB)"
}
```

## DELETE /api/v1/profile/avatar

Removes the current avatar image from the user profile.

### Response

**Status: 200 OK**

```json
{
  "message": "Avatar removed successfully"
}
```

### Error Response

**Status: 422 Unprocessable Entity**

```json
{
  "error": "No avatar to remove"
}
```

## Data Validation Rules

- **username**: Required, must be unique
- **email**: Optional, must be a valid email format and unique if provided
- **timezone**: Optional, must be a valid timezone from Rails' `ActiveSupport::TimeZone.all.map(&:name)`
- **full_name**: Optional
- **bio**: Optional
- **avatar**: Optional
  - Supported formats: JPEG, PNG, GIF
  - Maximum file size: 5MB

## Integration Notes

1. Always handle potential error responses by checking the HTTP status code.
2. For form submissions, display validation errors to the user.
3. The profile endpoint returns all profile fields, even if they are null/empty.
4. When updating a profile, you only need to include the fields you want to update.
5. Avatar uploads require a multipart form-data request. 