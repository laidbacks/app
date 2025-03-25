# Habit Logging API Documentation

This document provides details about the RESTful API endpoints for managing habits and habit logs.

## Authentication

All API endpoints require authentication. Users must log in through the web interface to establish a session before making API requests.

## Habits API

### List All Habits

Retrieves all habits for the authenticated user.

- **URL**: `/api/habits`
- **Method**: `GET`
- **URL Parameters**: None
- **Query Parameters**:
  - `active`: Filter to only active habits when set to `true` 
- **Success Response**:
  - **Code**: 200
  - **Content**: Array of habit objects
  ```json
  [
    {
      "id": 1,
      "name": "Daily Meditation",
      "description": "Meditate for 10 minutes every day",
      "frequency": "daily",
      "active": true,
      "user_id": 1,
      "created_at": "2025-03-24T18:26:58.000Z",
      "updated_at": "2025-03-24T18:26:58.000Z"
    }
  ]
  ```

### Get Habit

Retrieves a specific habit.

- **URL**: `/api/habits/:id`
- **Method**: `GET`
- **URL Parameters**:
  - `id`: ID of the habit to retrieve
- **Success Response**:
  - **Code**: 200
  - **Content**: Habit object
  ```json
  {
    "id": 1,
    "name": "Daily Meditation",
    "description": "Meditate for 10 minutes every day",
    "frequency": "daily",
    "active": true,
    "user_id": 1,
    "created_at": "2025-03-24T18:26:58.000Z",
    "updated_at": "2025-03-24T18:26:58.000Z"
  }
  ```
- **Error Response**:
  - **Code**: 404
  - **Content**: `{ "error": "Habit not found" }`

### Create Habit

Creates a new habit.

- **URL**: `/api/habits`
- **Method**: `POST`
- **Data Parameters**:
  ```json
  {
    "habit": {
      "name": "Daily Meditation",
      "description": "Meditate for 10 minutes every day",
      "frequency": "daily",
      "active": true
    }
  }
  ```
- **Success Response**:
  - **Code**: 201
  - **Content**: Created habit object
- **Error Response**:
  - **Code**: 422
  - **Content**: `{ "errors": ["Name can't be blank"] }`

### Update Habit

Updates an existing habit.

- **URL**: `/api/habits/:id`
- **Method**: `PATCH/PUT`
- **URL Parameters**:
  - `id`: ID of the habit to update
- **Data Parameters**:
  ```json
  {
    "habit": {
      "name": "Updated Habit Name",
      "description": "Updated description",
      "frequency": "weekly",
      "active": false
    }
  }
  ```
- **Success Response**:
  - **Code**: 200
  - **Content**: Updated habit object
- **Error Response**:
  - **Code**: 404
  - **Content**: `{ "error": "Habit not found" }`
  - **Code**: 422
  - **Content**: `{ "errors": ["Name can't be blank"] }`

### Delete Habit

Deletes a habit.

- **URL**: `/api/habits/:id`
- **Method**: `DELETE`
- **URL Parameters**:
  - `id`: ID of the habit to delete
- **Success Response**:
  - **Code**: 204
  - **Content**: None
- **Error Response**:
  - **Code**: 404
  - **Content**: `{ "error": "Habit not found" }`

### Get Habit Statistics

Retrieves statistics for a habit, including completion rate.

- **URL**: `/api/habits/:id/stats`
- **Method**: `GET`
- **URL Parameters**:
  - `id`: ID of the habit
- **Query Parameters**:
  - `start_date`: Optional start date for statistics calculation (format: YYYY-MM-DD)
  - `end_date`: Optional end date for statistics calculation (format: YYYY-MM-DD)
- **Success Response**:
  - **Code**: 200
  - **Content**:
  ```json
  {
    "completion_rate": 75.0,
    "habit_id": 1,
    "period": {
      "start_date": "2025-02-24",
      "end_date": "2025-03-24"
    }
  }
  ```
- **Error Response**:
  - **Code**: 404
  - **Content**: `{ "error": "Habit not found" }`

## Habit Logs API

### List All Habit Logs

Retrieves all habit logs for the authenticated user.

- **URL**: `/api/habit_logs`
- **Method**: `GET`
- **Query Parameters**:
  - `start_date`: Filter logs by start date (format: YYYY-MM-DD)
  - `end_date`: Filter logs by end date (format: YYYY-MM-DD)
  - `completed`: Filter by completion status (`true` or `false`)
- **Success Response**:
  - **Code**: 200
  - **Content**: Array of habit log objects
  ```json
  [
    {
      "id": 1,
      "date": "2025-03-24",
      "notes": "Felt great today",
      "completed": true,
      "habit_id": 1,
      "user_id": 1,
      "created_at": "2025-03-24T18:27:38.000Z",
      "updated_at": "2025-03-24T18:27:38.000Z"
    }
  ]
  ```

### List Logs for a Specific Habit

Retrieves all logs for a specific habit.

- **URL**: `/api/habits/:habit_id/habit_logs`
- **Method**: `GET`
- **URL Parameters**:
  - `habit_id`: ID of the habit
- **Query Parameters**:
  - Same as "List All Habit Logs"
- **Success Response**:
  - **Code**: 200
  - **Content**: Array of habit log objects

### Get Habit Log

Retrieves a specific habit log.

- **URL**: `/api/habit_logs/:id`
- **Method**: `GET`
- **URL Parameters**:
  - `id`: ID of the habit log to retrieve
- **Success Response**:
  - **Code**: 200
  - **Content**: Habit log object
- **Error Response**:
  - **Code**: 404
  - **Content**: `{ "error": "Habit log not found" }`

### Create Habit Log

Creates a new habit log.

- **URL**: `/api/habits/:habit_id/habit_logs`
- **Method**: `POST`
- **URL Parameters**:
  - `habit_id`: ID of the habit
- **Data Parameters**:
  ```json
  {
    "habit_log": {
      "date": "2025-03-24",
      "notes": "Meditation session went well",
      "completed": true
    }
  }
  ```
- **Success Response**:
  - **Code**: 201
  - **Content**: Created habit log object
- **Error Response**:
  - **Code**: 422
  - **Content**: `{ "errors": ["Date can't be blank"] }`

### Update Habit Log

Updates an existing habit log.

- **URL**: `/api/habit_logs/:id`
- **Method**: `PATCH/PUT`
- **URL Parameters**:
  - `id`: ID of the habit log to update
- **Data Parameters**:
  ```json
  {
    "habit_log": {
      "notes": "Updated notes",
      "completed": false
    }
  }
  ```
- **Success Response**:
  - **Code**: 200
  - **Content**: Updated habit log object
- **Error Response**:
  - **Code**: 404
  - **Content**: `{ "error": "Habit log not found" }`
  - **Code**: 422
  - **Content**: `{ "errors": ["Date can't be blank"] }`

### Delete Habit Log

Deletes a habit log.

- **URL**: `/api/habit_logs/:id`
- **Method**: `DELETE`
- **URL Parameters**:
  - `id`: ID of the habit log to delete
- **Success Response**:
  - **Code**: 204
  - **Content**: None
- **Error Response**:
  - **Code**: 404
  - **Content**: `{ "error": "Habit log not found" }`

### Toggle Today's Log

Toggles or creates a log entry for today for a specific habit.

- **URL**: `/api/habits/:habit_id/toggle_today`
- **Method**: `PATCH`
- **URL Parameters**:
  - `habit_id`: ID of the habit
- **Success Response**:
  - **Code**: 200
  - **Content**: Updated or created habit log object
- **Error Response**:
  - **Code**: 404
  - **Content**: `{ "error": "Habit not found" }`
  - **Code**: 422
  - **Content**: `{ "errors": ["User must match the habit's user"] }`

## Data Models

### Habit

- `id`: Integer
- `name`: String (required)
- `description`: Text
- `frequency`: String (required)
- `active`: Boolean (default: true)
- `user_id`: Integer (foreign key)
- `created_at`: DateTime
- `updated_at`: DateTime

### Habit Log

- `id`: Integer
- `date`: Date (required)
- `notes`: Text
- `completed`: Boolean (required)
- `habit_id`: Integer (foreign key)
- `user_id`: Integer (foreign key)
- `created_at`: DateTime
- `updated_at`: DateTime

## Error Handling

All API endpoints return appropriate HTTP status codes:

- `200 OK`: Request succeeded
- `201 Created`: Resource successfully created
- `204 No Content`: Request succeeded, no content to return
- `401 Unauthorized`: User is not authenticated
- `404 Not Found`: Requested resource does not exist
- `422 Unprocessable Entity`: Request data failed validation

Error responses include descriptive messages to help with debugging. 