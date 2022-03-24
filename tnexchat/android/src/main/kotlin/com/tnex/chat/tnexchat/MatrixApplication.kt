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

        tnexMatrix.initialize()
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