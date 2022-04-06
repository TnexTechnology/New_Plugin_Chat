package com.tnex.chat.tnexchat

import android.app.Activity
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** TnexchatPlugin */
class TnexchatPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var activity : Activity

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "tnexchat")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      "initMatrixWithToken" -> initMatrixWithToken(call, result)
      "updateUserUploadInfo" -> updateUserUploadInfo(call, result)
      "updateUserUploadToken" -> updateUserUploadToken(call, result)
      "openRoomWithId" -> openRoomWithId(call, result)
      else -> {
        result.notImplemented()
      }
    }

//    var arguments = call.arguments as Map<String, Any>
//    if (call.method == "initMatrixWithToken") {
//      val tokenFake = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI5NGVkM2IwNi1lN2E1LTQ2ODMtOWM0Ni0wZjc2YzEyZDlhYTAifQ.43m-TAjkt8AqHv1JGeAIJMrU-k2kdn-qh1p6FLCcd-Y"
//
//      val roomId = "!YKsBgFhGFwNhpbTxdZ:chat-matrix.tnex.com.vn"
////      MatrixApplication.sInstance.tnexMatrix.showChatDetail(roomId, tokenFake);
//      //result.success("Android ${AppTestInfo.getAndroidVersion()}")
//    } else {
//      result.notImplemented()
//    }
  }

  private fun initMatrixWithToken(@NonNull call: MethodCall, @NonNull result: Result) {
    activity.runOnUiThread {
      var arguments = call.arguments as Map<String, Any>
      var token = arguments["token"] as String
      var homeServerChat = arguments["homeServerChat"] as String
      var urlUploadFiles = arguments["urlUploadFiles"] as String
      MatrixApplication.sInstance.tnexMatrix.initialize(homeServerChat, urlUploadFiles)

      MatrixApplication.sInstance.tnexMatrix.loginMatrix(token, {
        activity.runOnUiThread {
          result.success(it)
        }
      })
    }
  }

  private fun updateUserUploadInfo(@NonNull call: MethodCall, @NonNull result: Result) {
    val arguments = call.arguments as Map<String, Any>
    val userDeviceId = arguments["userDeviceId"] as String
    val userUploadToken = arguments["userUploadToken"] as String
    val userLocation = arguments["userLocation"] as String
    val userLanguage = arguments["userLanguage"] as String
    MatrixApplication.sInstance.tnexMatrix.updateUserUploadInfo(userDeviceId, userUploadToken, userLocation, userLanguage)
  }

  private fun updateUserUploadToken(@NonNull call: MethodCall, @NonNull result: Result) {
    val arguments = call.arguments as Map<String, Any>
    val userUploadToken = arguments["userUploadToken"] as String
    MatrixApplication.sInstance.tnexMatrix.updateToken(userUploadToken)
  }

  private fun openRoomWithId(@NonNull call: MethodCall, @NonNull result: Result) {
    activity.runOnUiThread {
      val arguments = call.arguments as Map<String, Any>
      val roomID = arguments["roomID"] as String
      MatrixApplication.sInstance.tnexMatrix.openRoom(roomID)
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    //TODO("Not yet implemented")
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    //TODO("Not yet implemented")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    //TODO("Not yet implemented")
  }

  override fun onDetachedFromActivity() {
    //TODO("Not yet implemented")
  }

}
