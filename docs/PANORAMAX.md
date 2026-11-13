# Panoramax photos

Photo UUIDs are assigned before upload so the ordinary tag constructor can set tags immediately and follow-up questions can depend on them. `SELECT` assigns individual photos to tags, while `JOIN` can combine their UUIDs. Photos are uploaded before the OSM changes that reference them, and retain their UUIDs on retries.

## Photo capture

Camera capture uses `image_picker` to open the native camera. Library selection uses `meta_photo_picker` because its Android file picker preserves GPS metadata that the gallery picker can omit.

Original EXIF coordinates are used when available. Camera photos without GPS use a fresh device-location fix after capture. Library photos without GPS are rejected because the current device location cannot establish where an older photo was taken. Coordinates are sent as upload metadata without rewriting the image file.

The app retains the temporary files returned by the pickers and deletes them when removed, discarded or uploaded. Original library photos are preserved.

## OSM identity and Panoramax login

OSM editing and Panoramax uploads use separate credentials. OpenStop requests the OSM `openid` scope to obtain a short-lived ID token alongside its editing credential. The ID token is sent to the instance's custom `POST /api/auth/osm/exchange` endpoint, which verifies its signature, issuer, audience and expiry before issuing a Panoramax credential.

The Panoramax credential is stored in secure storage. The ID token is not persisted, and the OSM access token stays in the app. Renewing photo authentication obtains a fresh identity proof through OSM login.

Publication and identity-sharing consent is requested before the exchange and remembered for the current OSM account. Logout or switching accounts clears it. Cancelling leaves the questionnaire open.

## Build configuration

`IS_RELEASE=true` selects https://osm-lens.vee.network. Development builds use https://osm-lens-sandbox.vee.network, with separate test data.
