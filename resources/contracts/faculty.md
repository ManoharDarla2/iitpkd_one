# Faculty API Contract

Base path: `/api/v1/faculty`

## GET `/api/v1/faculty`

Returns lightweight faculty cards.

Query params:
- `department` (optional, string)

Response `200`

```json
{
  "success": true,
  "message": "Faculty list retrieved successfully",
  "data": [
    {
      "id": 1,
      "slug": "dr-smith-kumar",
      "name": "Dr. Smith Kumar",
      "designation": "Associate Professor",
      "department": "Computer Science and Engineering",
      "imageUrl": "https://example.com/images/smith.jpg"
    }
  ]
}
```

## GET `/api/v1/faculty/:slug`

Returns full faculty profile.

Path params:
- `slug` (required, string)

Response `200`

```json
{
  "success": true,
  "message": "Faculty profile retrieved successfully",
  "data": {
    "id": 1,
    "slug": "dr-smith-kumar",
    "name": "Dr. Smith Kumar",
    "imageUrl": "https://example.com/images/smith.jpg",
    "department": "Computer Science and Engineering",
    "designation": "Associate Professor",
    "email": "smith@college.edu",
    "biosketch": "...",
    "teaching": "...",
    "office": "...",
    "publications": "...",
    "additionalInformation": "..."
  }
}
```

Response `404`

```json
{
  "success": false,
  "message": "Faculty profile not found"
}
```

## GET `/api/v1/faculty/metadata`

Returns metadata for cache invalidation.

Response `200`

```json
{
  "success": true,
  "message": "Faculty metadata retrieved",
  "data": {
    "updatedAt": "2026-04-10T08:45:12.000Z",
    "version": "2026-04-10"
  }
}
```
