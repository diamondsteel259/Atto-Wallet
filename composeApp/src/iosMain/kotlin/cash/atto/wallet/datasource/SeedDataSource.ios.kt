package cash.atto.wallet.datasource

import kotlinx.cinterop.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.consumeAsFlow
import kotlinx.coroutines.launch
import platform.Foundation.NSData
import platform.Foundation.NSString
import platform.Foundation.NSUTF8StringEncoding
import platform.Foundation.create
import platform.Security.*

actual class SeedDataSource {
    private val serviceName = "Atto Wallet"
    private val accountName = "seed"

    private val _seedChannel = Channel<String?>()
    actual val seed = _seedChannel.consumeAsFlow()

    init {
        CoroutineScope(Dispatchers.Default).launch {
            getSeed()
        }
    }

    actual suspend fun setSeed(seed: String) {
        storeSeed(seed)
        getSeed()
    }

    actual suspend fun clearSeed() {
        deleteSeed()
        getSeed()
    }

    private suspend fun getSeed() {
        try {
            _seedChannel.send(retrieveSeed())
        } catch (ex: Exception) {
            _seedChannel.send(null)
        }
    }

    @OptIn(ExperimentalForeignApi::class)
    private fun storeSeed(seed: String) {
        // First, try to delete existing item if it exists
        try {
            deleteSeed()
        } catch (e: Exception) {
            // Item doesn't exist, that's fine
        }

        val seedData = seed.encodeToByteArray()
        val query = mapOf<Any?, Any?>(
            kSecClass to kSecClassGenericPassword,
            kSecAttrService to serviceName,
            kSecAttrAccount to accountName,
            kSecValueData to NSData.create(bytes = seedData.refTo(0), length = seedData.size.toULong()),
            kSecAttrAccessible to kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        )

        memScoped {
            val result = SecItemAdd(query.toCFDictionary(), null)
            if (result != errSecSuccess) {
                throw IllegalStateException("Failed to store seed in Keychain. Error code: $result")
            }
        }
    }

    @OptIn(ExperimentalForeignApi::class)
    private fun retrieveSeed(): String? {
        val query = mapOf<Any?, Any?>(
            kSecClass to kSecClassGenericPassword,
            kSecAttrService to serviceName,
            kSecAttrAccount to accountName,
            kSecReturnData to kCFBooleanTrue,
            kSecMatchLimit to kSecMatchLimitOne
        )

        memScoped {
            val result = alloc<CFTypeRefVar>()
            val status = SecItemCopyMatching(query.toCFDictionary(), result.ptr)

            return when (status) {
                errSecSuccess -> {
                    val data = result.value as NSData
                    val bytes = ByteArray(data.length.toInt())
                    memcpy(bytes.refTo(0), data.bytes, data.length)
                    bytes.decodeToString()
                }
                errSecItemNotFound -> null
                else -> null
            }
        }
    }

    @OptIn(ExperimentalForeignApi::class)
    private fun deleteSeed() {
        val query = mapOf<Any?, Any?>(
            kSecClass to kSecClassGenericPassword,
            kSecAttrService to serviceName,
            kSecAttrAccount to accountName
        )

        memScoped {
            val result = SecItemDelete(query.toCFDictionary())
            if (result != errSecSuccess && result != errSecItemNotFound) {
                throw IllegalStateException("Failed to delete seed from Keychain. Error code: $result")
            }
        }
    }

    @OptIn(ExperimentalForeignApi::class, BetaInteropApi::class)
    private fun Map<Any?, Any?>.toCFDictionary(): CFDictionaryRef? {
        val keys = mutableListOf<COpaquePointer?>()
        val values = mutableListOf<COpaquePointer?>()

        forEach { (key, value) ->
            keys.add(key as? COpaquePointer)
            values.add(value as? COpaquePointer)
        }

        return CFDictionaryCreate(
            null,
            keys.toCValues(),
            values.toCValues(),
            size.toLong(),
            null,
            null
        )
    }
}
