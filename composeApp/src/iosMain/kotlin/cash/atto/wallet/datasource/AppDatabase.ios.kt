package cash.atto.wallet.datasource

import androidx.room.Dao
import androidx.room.Database
import androidx.room.Entity
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.PrimaryKey
import androidx.room.Query
import androidx.room.RoomDatabase
import cash.atto.wallet.Config

@Database(
    entities = [AccountEntryIOS::class, WorkIOS::class],
    version = Config.DATABASE_VERSION
)
abstract class AppDatabaseIOS : RoomDatabase(), AppDatabase, DB {
    abstract override fun accountEntryDao(): AccountEntryDaoIOS
    abstract override fun workDao(): WorkDaoIOS

    override fun clearAllTables() {
        super.clearAllTables()
    }
}

interface DB {
    fun clearAllTables() {}
}

@Dao
interface AccountEntryDaoIOS : AccountEntryDao {
    @Query(
        "SELECT entry from accountEntries " +
                "WHERE publicKey = :publicKey " +
                "ORDER BY height DESC LIMIT 1"
    )
    override suspend fun last(publicKey: ByteArray): ByteArray?

    @Query(
        "SELECT entry from accountEntries " +
                "WHERE publicKey = :publicKey " +
                "ORDER BY height DESC"
    )
    override suspend fun list(publicKey: ByteArray): List<String>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun save(entry: AccountEntryIOS)

    override suspend fun save(entry: AccountEntry) = save(entry as AccountEntryIOS)
}

@Dao
interface WorkDaoIOS : WorkDao {
    @Query("SELECT * FROM work ORDER BY value LIMIT 1")
    override suspend fun get(): WorkIOS?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun set(work: WorkIOS)

    override suspend fun set(work: Work) = set(work as WorkIOS)

    @Query("DELETE FROM work")
    override suspend fun clear()
}

@Entity(tableName = "accountEntries")
data class AccountEntryIOS(
    @PrimaryKey
    override val hash: ByteArray,
    override val publicKey: ByteArray,
    override val height: Long,
    override val entry: String
) : AccountEntry

@Entity(tableName = "work")
data class WorkIOS(
    @PrimaryKey
    override val publicKey: ByteArray,
    override val value: ByteArray
) : Work

actual fun createAccountEntry(
    hash: ByteArray,
    publicKey: ByteArray,
    height: Long,
    entry: String
): AccountEntry = AccountEntryIOS(
    hash = hash,
    publicKey = publicKey,
    height = height,
    entry = entry
)

actual fun createWork(
    publicKey: ByteArray,
    value: ByteArray
): Work = WorkIOS(
    publicKey = publicKey,
    value = value
)
