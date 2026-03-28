# Shuttle API Contract

Base path: `/api/v1/shuttles`

## GET `/api/v1/shuttles`

Returns shuttle schedule entries.

Query params:
- `day` (optional, string, lowercase expected)
- `from` (optional, string)
- `to` (optional, string)

Response `200`

```json
{
  "success": true,
  "message": "Shuttles retrieved successfully",
  "data": [
    {
      "id": 101,
      "from": "Nila Campus",
      "to": "Sahyadri",
      "time": "09:00",
      "via": ["Main Gate"],
      "days": ["monday", "tuesday", "wednesday", "thursday", "friday"],
      "isOutsideTrip": false,
      "isMultipleBuses": true
    }
  ]
}
```

Note: `isMultipleBuses` is enforced from backend schema and is part of the official response.

## GET `/api/v1/shuttles/metadata`

Returns metadata for cache invalidation.

Response `200`

```json
{
  "success": true,
  "message": "Shuttle metadata retrieved",
  "data": {
    "updatedAt": "2026-04-10T08:45:12.000Z",
    "version": "shuttle-42"
  }
}
```
