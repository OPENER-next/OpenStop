# Android photo metadata

The photo question requires the original GPS when importing a library image.
Android 10 and later redact EXIF location unless the app requests
`ACCESS_MEDIA_LOCATION` and opens an original MediaStore URI using
`MediaStore.setRequireOriginal`.

The installed `image_picker` implementation copies the selected image into its
cache, but does not request that permission or decorate the URI before copying.
`requestFullMetadata` alone therefore does not preserve Android GPS.

`MainActivity` handles only the next gallery intent explicitly armed by
`PanoramaxPhoto.captureWithLocation`. It requests the permission and asks for an
original MediaStore image before the plugin makes its copy. Other pickers and
camera results are untouched. Photo Picker URIs cannot use `setRequireOriginal`,
so this request uses the document/content chooser instead. Providers that still
omit GPS are rejected; imported images never receive the phone's current location.

This can be removed when `image_picker` supports the original-location flow on
the Android versions supported by OpenStop. Android documents the requirements
under [media location information](https://developer.android.com/training/data-storage/shared/media#media-location-permission).
