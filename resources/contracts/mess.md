# Mess API Contract

Base path: `/api/v1/mess`

## GET `/api/v1/mess/menu`

Returns full menu entries.

Query params:
- `weekType` (optional, enum: `odd | even`)

Response `200`

```json
{
  "success": true,
  "message": "Mess menu retrieved successfully",
  "data": [
    {
      "id": 10,
      "weekType": "odd",
      "day": "monday",
      "meals": {
        "breakfast": ["Poha", "Tea"],
        "lunch": ["Rice", "Dal"],
        "snacks": ["Samosa"],
        "dinner": ["Roti", "Paneer Masala"]
      }
    }
  ]
}
```

## GET `/api/v1/mess/menu/today`

Returns computed menu for today based on odd/even rotation.

Response `200`

```json
{
  "success": true,
  "message": "Today's menu retrieved",
  "data": {
    "date": "2026-04-10",
    "calculatedWeek": "even",
    "day": "friday",
    "meals": {
      "breakfast": ["Idli", "Sambar"],
      "lunch": ["Rice", "Sambar"],
      "snacks": ["Puff"],
      "dinner": ["Chapati", "Veg Kurma"]
    }
  }
}
```

Response `404`

```json
{
  "success": false,
  "message": "Mess menu for today was not found"
}
```

## GET `/api/v1/mess/metadata`

Returns metadata for cache invalidation.

Response `200`

```json
{
  "success": true,
  "message": "Mess metadata retrieved",
  "data": {
    "updatedAt": "2026-04-10T08:45:12.000Z",
    "version": "mess-14"
  }
}
```

## GET `/api/v1/mess/week-types`

Returns allowed week types for client filters.

Response `200`

```json
{
  "success": true,
  "message": "Available week types retrieved",
  "data": ["odd", "even"]
}
```
