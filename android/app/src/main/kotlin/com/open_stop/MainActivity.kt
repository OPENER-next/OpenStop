package de.tu_chemnitz.etit.sse.openstop

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    private var pendingPhotoPicker: Triple<Intent, Int, Bundle?>? = null

    override fun startActivityForResult(intent: Intent, requestCode: Int, options: Bundle?) {
        val pickingPhoto = intent.type == "image/*" &&
            (intent.action == "android.provider.action.PICK_IMAGES" ||
                intent.action == Intent.ACTION_GET_CONTENT)
        if (pickingPhoto) {
            intent.replaceExtras(Bundle())
            intent.action = Intent.ACTION_GET_CONTENT
            intent.component = null
            intent.setPackage(null)
            intent.addCategory(Intent.CATEGORY_OPENABLE)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q &&
                checkSelfPermission(Manifest.permission.ACCESS_MEDIA_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                pendingPhotoPicker = Triple(intent, requestCode, options)
                requestPermissions(arrayOf(Manifest.permission.ACCESS_MEDIA_LOCATION), MEDIA_LOCATION_REQUEST)
                return
            }
        }
        super.startActivityForResult(intent, requestCode, options)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == MEDIA_LOCATION_REQUEST) {
            val pending = pendingPhotoPicker
            pendingPhotoPicker = null
            if (pending != null) super.startActivityForResult(pending.first, pending.second, pending.third)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        val uri = data?.data ?: data?.clipData?.takeIf { it.itemCount == 1 }?.getItemAt(0)?.uri
        if (resultCode == RESULT_OK && data != null && uri != null &&
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q &&
            checkSelfPermission(Manifest.permission.ACCESS_MEDIA_LOCATION) == PackageManager.PERMISSION_GRANTED &&
            uri.scheme == "content" && uri.authority == MediaStore.AUTHORITY &&
            !isPhotoPickerUri(uri) && contentResolver.getType(uri)?.startsWith("image/") == true) {
            data.data = MediaStore.setRequireOriginal(uri)
        }
        super.onActivityResult(requestCode, resultCode, data)
    }

    private fun isPhotoPickerUri(uri: Uri): Boolean =
        uri.pathSegments.contains("picker")

    companion object {
        private const val MEDIA_LOCATION_REQUEST = 4601
    }
}
