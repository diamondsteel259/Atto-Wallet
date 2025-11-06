package cash.atto.wallet.di

import androidx.room.Room
import androidx.sqlite.driver.bundled.BundledSQLiteDriver
import cash.atto.wallet.datasource.AppDatabase
import cash.atto.wallet.datasource.AppDatabaseIOS
import cash.atto.wallet.datasource.PasswordDataSource
import cash.atto.wallet.datasource.SaltDataSource
import cash.atto.wallet.datasource.SeedDataSource
import cash.atto.wallet.interactor.SeedAESInteractor
import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.coroutines.Dispatchers
import org.koin.core.module.dsl.singleOf
import org.koin.dsl.module
import platform.Foundation.NSDocumentDirectory
import platform.Foundation.NSFileManager
import platform.Foundation.NSSearchPathForDirectoriesInDomains
import platform.Foundation.NSUserDomainMask

@OptIn(ExperimentalForeignApi::class)
fun getDatabaseBuilder(): AppDatabase {
    val documentDirectory = NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory,
        NSUserDomainMask,
        true
    ).first() as String

    val dbDirectory = "$documentDirectory/.atto"
    val dbFilePath = "$dbDirectory/wallet.db"

    // Create directory if it doesn't exist
    val fileManager = NSFileManager.defaultManager
    fileManager.createDirectoryAtPath(
        path = dbDirectory,
        withIntermediateDirectories = true,
        attributes = null,
        error = null
    )

    return Room.databaseBuilder<AppDatabaseIOS>(dbFilePath)
        .setDriver(BundledSQLiteDriver())
        .setQueryCoroutineContext(Dispatchers.IO)
        .build()
}

actual val databaseModule = module {
    single<AppDatabase> { getDatabaseBuilder() }
}

actual val dataSourceModule = module {
    includes(databaseModule)
    singleOf(::PasswordDataSource)
    singleOf(::SeedAESInteractor)
    singleOf(::SaltDataSource)
    singleOf(::SeedDataSource)
}
