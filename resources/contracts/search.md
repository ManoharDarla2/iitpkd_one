# Search API Contract

Base path: `/api/v1/search`

## GET `/api/v1/search`

Unified search across backend-supported categories.

Query params:
- `q` (optional, string)
- `category` (optional, enum: `equipment | faculty | schedule`)
- `limit` (optional, number, min 1, max 100, default 20)

Response `200`

```json
{
  "success": true,
  "message": "Search results for \"drill\"",
  "data": {
    "query": "drill",
    "category": null,
    "totalCount": 1,
    "results": [
      {
        "id": "equipment-4",
        "category": "equipment",
        "title": "Electric Drill",
        "subtitle": "Bosch GSB 10RE",
        "description": "Professional-grade impact drill",
        "imageUrl": "https://example.com/images/drill.jpg",
        "metadata": {
          "make": "Bosch",
          "model": "GSB 10RE",
          "toolType": "Power Tools"
        }
      }
    ]
  }
}
```

For empty `q`, backend returns:

```json
{
  "success": true,
  "message": "Empty query",
  "data": {
    "query": "",
    "category": null,
    "totalCount": 0,
    "results": []
  }
}
```

## GET `/api/v1/search/suggestions`

Autocomplete suggestions.

Query params:
- `q` (optional, string)
- `limit` (optional, number, min 1, max 20, default 8)

Response `200`

```json
{
  "success": true,
  "message": "Suggestions for \"3d\"",
  "data": ["3D Printer", "3D Scanner", "3D Printing Pen"]
}
```

When `q` is empty, response message is `Popular suggestions`.
