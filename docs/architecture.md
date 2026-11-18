# BoomVerse MVP architecture

The first release is a web catalog and session launcher. It should discover games, show session readiness, and hand off to a streaming provider without coupling the UI to one vendor.

## Next layers
1. Identity — login, profiles, parental controls, device sessions.
2. Catalog API — games, artwork, genres, regional availability, entitlements, search.
3. Session service — capacity reservation, queue, latency probe, provider token.
4. Streaming adapter — WebRTC/browser streaming, controller input, reconnect.
5. Payments — plans, entitlements, trials, receipts.
6. Observability — first-frame latency, disconnects, regional capacity.

## Initial contracts
- GET /api/catalog?genre=...&q=...
- POST /api/sessions with { gameId, device, region }
- GET /api/sessions/:id for queue and connection state
- POST /api/sessions/:id/terminate

The static MVP uses local data and simulated launch feedback; production integration belongs behind these boundaries.
