package com.ticketmaster.mobile.android

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.net.Uri
import android.provider.Settings
import android.provider.MediaStore
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val galleryRequestCode = 4101
    private val cameraRequestCode = 4102
    private val galleryPermissionRequestCode = 4201
    private val cameraPermissionRequestCode = 4202
    private val imagePickerChannelName = "ticketmaster/ticket_image_picker"
    private val deviceIdentityChannelName = "ticketmaster/device_identity"
    private var pendingResult: MethodChannel.Result? = null
    private var pendingCameraFile: File? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            imagePickerChannelName,
        ).setMethodCallHandler { call, result ->
            handleTicketImageCall(call, result)
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            deviceIdentityChannelName,
        ).setMethodCallHandler { call, result ->
            handleDeviceIdentityCall(call, result)
        }
    }

    private fun handleDeviceIdentityCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "getDeviceIdentity") {
            result.notImplemented()
            return
        }

        val androidId =
            Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
                ?: Build.FINGERPRINT
                ?: packageName
        val label = buildList {
            val manufacturer = Build.MANUFACTURER?.trim().orEmpty()
            val model = Build.MODEL?.trim().orEmpty()
            if (manufacturer.isNotEmpty()) add(manufacturer)
            if (model.isNotEmpty() && model != manufacturer) add(model)
        }.joinToString(" ").ifBlank { "Android device" }

        result.success(
            mapOf(
                "deviceKey" to "android:$androidId",
                "deviceLabel" to label,
                "storageDirectoryPath" to filesDir.absolutePath,
            ),
        )
    }

    private fun handleTicketImageCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "pickTicketImage") {
            result.notImplemented()
            return
        }

        if (pendingResult != null) {
            result.error("busy", "Another image selection is already in progress.", null)
            return
        }

        val source = call.argument<String>("source")
        pendingResult = result

        when (source) {
            "gallery" -> ensureGalleryPermissionAndLaunch()
            "camera" -> ensureCameraPermissionAndLaunch()
            else -> {
                pendingResult = null
                result.error("invalid_source", "Unsupported image source.", null)
            }
        }
    }

    private fun ensureGalleryPermissionAndLaunch() {
        val permission = getGalleryPermission()
        if (permission == null ||
            ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED
        ) {
            launchGallery()
            return
        }

        ActivityCompat.requestPermissions(
            this,
            arrayOf(permission),
            galleryPermissionRequestCode,
        )
    }

    private fun ensureCameraPermissionAndLaunch() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) ==
            PackageManager.PERMISSION_GRANTED
        ) {
            launchCamera()
            return
        }

        ActivityCompat.requestPermissions(
            this,
            arrayOf(Manifest.permission.CAMERA),
            cameraPermissionRequestCode,
        )
    }

    private fun getGalleryPermission(): String? {
        return when {
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU -> Manifest.permission.READ_MEDIA_IMAGES
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.M -> Manifest.permission.READ_EXTERNAL_STORAGE
            else -> null
        }
    }

    private fun launchGallery() {
        try {
            val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
                type = "image/*"
                addCategory(Intent.CATEGORY_OPENABLE)
            }
            startActivityForResult(
                Intent.createChooser(intent, "Select Ticket Image"),
                galleryRequestCode,
            )
        } catch (error: Exception) {
            pendingResult?.error("gallery_failed", error.localizedMessage, null)
            pendingResult = null
        }
    }

    private fun launchCamera() {
        try {
            val imageDir = File(cacheDir, "ticket_uploads").apply { mkdirs() }
            val imageFile = File.createTempFile("ticket_image_", ".jpg", imageDir)
            pendingCameraFile = imageFile
            val imageUri = FileProvider.getUriForFile(
                this,
                "${applicationContext.packageName}.fileprovider",
                imageFile,
            )
            val cameraIntent = Intent(MediaStore.ACTION_IMAGE_CAPTURE).apply {
                putExtra(MediaStore.EXTRA_OUTPUT, imageUri)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
            }

            if (cameraIntent.resolveActivity(packageManager) == null) {
                imageFile.delete()
                pendingCameraFile = null
                pendingResult?.error(
                    "camera_unavailable",
                    "Camera is not available on this device.",
                    null,
                )
                pendingResult = null
                return
            }

            startActivityForResult(cameraIntent, cameraRequestCode)
        } catch (error: Exception) {
            pendingCameraFile?.delete()
            pendingCameraFile = null
            pendingResult?.error("camera_failed", error.localizedMessage, null)
            pendingResult = null
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        when (requestCode) {
            galleryRequestCode -> handleGalleryResult(resultCode, data)
            cameraRequestCode -> handleCameraResult(resultCode)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        val granted = grantResults.isNotEmpty() &&
            grantResults.all { it == PackageManager.PERMISSION_GRANTED }

        when (requestCode) {
            galleryPermissionRequestCode -> {
                if (granted) {
                    launchGallery()
                } else {
                    pendingResult?.error(
                        "permission_denied",
                        "Gallery access is required to select an image.",
                        null,
                    )
                    pendingResult = null
                }
            }
            cameraPermissionRequestCode -> {
                if (granted) {
                    launchCamera()
                } else {
                    pendingResult?.error(
                        "permission_denied",
                        "Camera access is required to capture an image.",
                        null,
                    )
                    pendingResult = null
                }
            }
        }
    }

    private fun handleGalleryResult(resultCode: Int, data: Intent?) {
        val result = pendingResult
        pendingResult = null

        if (resultCode != Activity.RESULT_OK) {
            result?.success(null)
            return
        }

        val uri = data?.data
        if (uri == null) {
            result?.error("read_failed", "No image was selected.", null)
            return
        }

        try {
            val bytes = contentResolver.openInputStream(uri)?.use { it.readBytes() }
            if (bytes == null) {
                result?.error("read_failed", "Unable to read the selected image.", null)
            } else {
                result?.success(bytes)
            }
        } catch (error: Exception) {
            result?.error("read_failed", error.localizedMessage, null)
        }
    }

    private fun handleCameraResult(resultCode: Int) {
        val result = pendingResult
        val imageFile = pendingCameraFile
        pendingResult = null
        pendingCameraFile = null

        if (resultCode != Activity.RESULT_OK || imageFile == null || !imageFile.exists()) {
            imageFile?.delete()
            result?.success(null)
            return
        }

        try {
            result?.success(imageFile.readBytes())
        } catch (error: Exception) {
            result?.error("read_failed", error.localizedMessage, null)
        } finally {
            imageFile.delete()
        }
    }
}
