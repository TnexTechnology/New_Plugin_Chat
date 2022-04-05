package com.tnex.chat.tnexchat

import android.app.Application
import android.content.Context
import android.os.StrictMode
import androidx.multidex.MultiDex
import com.tnex.matrix.BuildConfig.FLAVOR_DESCRIPTION
import com.tnex.matrix.app.*
import com.tnex.matrix.app.features.room.VectorRoomDisplayNameFallbackProvider
import dagger.hilt.android.EntryPointAccessors
import dagger.hilt.android.HiltAndroidApp
import org.matrix.android.sdk.api.MatrixConfiguration
import javax.inject.Inject

@HiltAndroidApp
class MatrixApplication : Application(), MatrixConfiguration.Provider {

    companion object {
        lateinit var sInstance: MatrixApplication
    }

    @Inject
    lateinit var tnexMatrix: MatrixTnexApplication
    override fun onCreate() {
        sInstance = this
        initAppData()
        super.onCreate()
        tnexMatrix.initialize("https://chat-matrix.tnex.com.vn", "https://graviteeioapigw-preprod.tnex.vn/api/v1/customer-gw/services/uploadFiles")
//        val token = "Bearer eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiIyNjMwY2I5Yy01NzcxLTRkZWUtOTVjZC1hZDkyYWNjNTg4ZGMiLC" +
//                "JmaXJzdG5hbWUiOiJOR1VZ4buETiBUSOG7iiBCScOKTiIsInJvbGUiOlsiVDEiXSwiaXNzIjoiaHR0cDovL2dyYXZp" +
//                "dGVlaW9hbWd5LXVhdC50bmRtYXJrZXRwbGFjZS5jb20vbXNiL29pZGMiLCJtb2JpbGUiOiIwOTY4OTY1NjU4IiwicG" +
//                "VybWlzc2lvbiI6ImZ1bGwtYWNjZXNzIiwiZGV2aWNlLWlkIjoiNjc2NjczZDAxOTIxMzA2YiIsImxhc3RuYW1lIjoi" +
//                "IiwiYXVkIjoibXNiX2NsaWVudCIsImN1c3RvbWVyLWlkIjoiY2Q4N2I1YjEtNjgzYS00ZmU4LThmOWQtNGRiZGJlZW" +
//                "Y2NTBiIiwiY2lmLW51bWJlciI6IjE2MzI0NzU4MDMxMzY0IiwiZG9tYWluIjoibXNiIiwibWVyY2hhbnQtaWQiOiIi" +
//                "LCJleHAiOjE2NDg2OTY4NjksImlhdCI6MTY0ODY5NTk2OSwianRpIjoiMjIwMzMxMTAwNjA5MDk2MDI5In0.NX8Q5I" +
//                "nQ8fdxgCmTStPT08UA6h3NdcnbW0qkO_MqT3IDRV8y2C22qPgxfPNrZ0tcvQZ_O1hWx0BaO1qOXu8Vpw4QqY6u7Tov" +
//                "naNtFBOjMYvJM_Go2IZthO4b4FYBRYZXl5v-Zk9Zb6vK6yKtUqCHRFmAqJKjnk2zkjegXXn9liaGe8_-BUr_qz1Qy9" +
//                "Iz6idi2uGYdr2moWSP6th6gKJ0ioWTFdvHwgagG03XoK0cDdeMVBeozzO-o9GwuiI_ljBr38wOKULlrpqAi-WAPwEh" +
//                "RBfWi79UHi48_u3rI-MMiFZ2skiYJjwdjz56YHNtQs-aCrOJwBn15naQxr6aggLAUg"
//        val deviceId = "676673d01921306b"
//        val langguage = "vi"
//        val local = "21.0233792,105.8096129"
//        tnexMatrix.updateUserUploadInfo(deviceId, token, local, langguage);
    }

    private fun initAppData() {
        DaggerMatrixAppComponent.builder()
            .application(this)
            .appDependencies(
                EntryPointAccessors.fromApplication(
                    applicationContext,
                    MatrixApplicationModuleDependencies::class.java
                )
            )
            .build()
            .inject(this)
    }

    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        MultiDex.install(this)
    }

    override fun providesMatrixConfiguration(): MatrixConfiguration {
        return MatrixConfiguration(
            applicationFlavor = FLAVOR_DESCRIPTION,
            roomDisplayNameFallbackProvider = VectorRoomDisplayNameFallbackProvider(this)
        )
    }
}