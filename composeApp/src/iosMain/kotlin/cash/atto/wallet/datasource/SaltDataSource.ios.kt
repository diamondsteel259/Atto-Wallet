package cash.atto.wallet.datasource

import kotlinx.cinterop.*
import platform.Foundation.NSData
import platform.Foundation.create
import platform.Security.*

actual class SaltDataSource {
    private val serviceName = "Atto Wallet"
    private val accountName = "salt"

    actual suspend fun get(): String {
        // Try to retrieve existing salt
        val existingSalt = retrieveSalt()
        if (existingSalt != null) {
            return existingSalt
        }

        // Generate new salt if doesn't exist
        val newSalt = generateSalt()
        storeSalt(newSalt)
        return newSalt
    }

    @OptIn(ExperimentalForeignApi::class)
    private fun generateSalt(): String {
        val saltBytes = ByteArray(32)
        memScoped {
            val result = SecRandomCopyBytes(kSecRandomDefault, 32.toULong(), saltBytes.refTo(0))
            if (result != errSecSuccess) {
                throw IllegalStateException("Failed to generate random salt. Error code: $result")
            }
        }
        // Convert to hex string
        return saltBytes.joinToString("") { "%02x".format(it) }
    }

    @OptIn(ExperimentalForeignApi::class)
    private fun storeSalt(salt: String) {
        // First, try to delete existing item if it exists
        try {
            deleteSalt()
        } catch (e: Exception) {
            // Item doesn't exist, that's fine
        }

        val saltData = salt.encodeToByteArray()
        val query = mapOf<Any?, Any?>(
            kSecClass to kSecClassGenericPassword,
            kSecAttrService to serviceName,
            kSecAttrAccount to accountName,
            kSecValueData to NSData.create(bytes = saltData.refTo(0), length = saltData.size.toULong()),
            kSecAttrAccessible to kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        )

        memScoped {
            val result = SecItemAdd(query.toCFDictionary(), null)
            if (result != errSecSuccess) {
                throw IllegalStateException("Failed to store salt in Keychain. Error code: $result")
            }
        }
    }

    @OptIn(ExperimentalForeignApi::class)
    private fun retrieveSalt(): String? {
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
    private fun deleteSalt() {
        val query = mapOf<Any?, Any?>(
            kSecClass to kSecClassGenericPassword,
            kSecAttrService to serviceName,
            kSecAttrAccount to accountName
        )

        memScoped {
            val result = SecItemDelete(query.toCFDictionary())
            if (result != errSecSuccess && result != errSecItemNotFound) {
                throw IllegalStateException("Failed to delete salt from Keychain. Error code: $result")
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
