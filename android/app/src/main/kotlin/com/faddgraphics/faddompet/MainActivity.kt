package com.faddgraphics.faddompet

import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.faddgraphics.faddompet/update")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openApk" -> {
                        val path = call.argument<String>("path")
                        if (path.isNullOrBlank()) {
                            result.success(
                                mapOf(
                                    "opened" to false,
                                    "permissionDenied" to false,
                                    "message" to "invalid_path",
                                ),
                            )
                        } else {
                            openApk(path, result)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun openApk(path: String, result: MethodChannel.Result) {
        val file = File(path)
        if (!file.exists()) {
            result.success(
                mapOf(
                    "opened" to false,
                    "permissionDenied" to false,
                    "message" to "file_not_found",
                ),
            )
            return
        }

        try {
            val uri = FileProvider.getUriForFile(
                this,
                "$packageName.updateFileProvider",
                file,
            )
            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, "application/vnd.android.package-archive")
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
            result.success(
                mapOf(
                    "opened" to true,
                    "permissionDenied" to false,
                    "message" to "opened",
                ),
            )
        } catch (_: SecurityException) {
            result.success(
                mapOf(
                    "opened" to false,
                    "permissionDenied" to true,
                    "message" to "permission_denied",
                ),
            )
        } catch (_: Exception) {
            result.success(
                mapOf(
                    "opened" to false,
                    "permissionDenied" to false,
                    "message" to "open_failed",
                ),
            )
        }
    }
}
