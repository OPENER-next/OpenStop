# Panoramax photos

Photo UUIDs are assigned before upload so the ordinary tag constructor can set tags immediately and follow-up questions can depend on them. `SELECT` assigns individual photos to tags, while `JOIN` can combine their UUIDs. Photos are uploaded before the OSM changes that reference them, and retain their UUIDs on retries.

## Photo capture

Camera capture uses `image_picker` to open the native camera. Library selection uses `meta_photo_picker` because its Android file picker preserves GPS metadata that the gallery picker can omit.

Original EXIF coordinates are used when available. Camera photos without GPS use a fresh device-location fix after capture. Library photos without GPS are rejected because the current device location cannot establish where an older photo was taken. Coordinates are sent as upload metadata without rewriting the image file.

The app retains the temporary files returned by the pickers and deletes them when removed, discarded or uploaded. Original library photos are preserved.

## Panoramax login

OSM and Panoramax use separate accounts. Logging out of one leaves the other logged in. Users log in to Panoramax from the photo question or from the Services page.

Login follows the token flow of the Panoramax command line tool. OpenStop generates a token and opens its claim page with `flutter_web_auth_2`. After the user logs in on the instance website, the claim page redirects back to the app through `next_url`. On Android and iOS this uses the custom scheme `de.tu-chemnitz.etit.sse.openstop://panoramax` rather than the verified `https://openstop.app/oauth2` link the OSM login uses. If the user is still logged in on the instance website, the claim page redirects without any user interaction, and browsers do not open verified https links in the app for such redirects. The redirect carries no secret, so a custom scheme is safe. On instances without `next_url` support (instances running versions prior to 2.16.0) the user closes the browser after claiming. OpenStop then verifies the token and stores it in secure storage. Logout revokes the token on the instance.

The instance's terms are accepted on its website during login, so OpenStop does not ask for separate consent.

## Upload

Each questionnaire uploads its photos into a new upload set. After completing the set, OpenStop waits until the instance has processed every photo and only then uploads the OSM changes. If uploading or processing fails, the upload set is deleted and the OSM changes are not uploaded.

## Build configuration

`IS_RELEASE=true` uses https://osm-lens.vee.network by default. Development builds use https://osm-lens-sandbox.vee.network, with separate test data. Users can choose another instance on the Services page, which logs them out of the previous one.
