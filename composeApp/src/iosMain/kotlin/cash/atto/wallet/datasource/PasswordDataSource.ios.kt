package cash.atto.wallet.datasource

import kotlinx.cinterop.*
import platform.Foundation.NSData
import platform.Foundation.create
import platform.Security.*

actual class PasswordDataSource {
    private val serviceName = "Atto Wallet"

    actual suspend fun getPassword(seed: String): String? {
        val accountName = "password-${seed.hashCode()}"
        return retrievePassword(accountName)
    }

    actual suspend fun setPassword(seed: String, password: String) {
        val accountName = "password-${seed.hashCode()}"
        storePassword(accountName, password)
    }

    @OptIn(ExperimentalForeignApi::class)
    private fun storePassword(accountName: String, password: String) {
        // First, try to delete existing item if it exists
        try {
            deletePassword(accountName)
        } catch (e: Exception) {
            // Item doesn't exist, that's fine
        }

        val passwordData = password.encodeToByteArray()
        val query = mapOf<Any?, Any?>(
            kSecClass to kSecClassGenericPassword,
            kSecAttrService to serviceName,
            kSecAttrAccount to accountName,
            kSecValueData to NSData.create(bytes = passwordData.refTo(0), length = passwordData.size.toULong()),
            kSecAttrAccessible to kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        )

        memScoped {
            val result = SecItemAdd(query.toCFDictionary(), null)
            if (result != errSecSuccess) {
                throw IllegalStateException("Failed to store password in Keychain. Error code: $result")
            }
        }
    }

    @OptIn(ExperimentalForeignApi::class)
    private fun retrievePassword(accountName: String): String? {
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
    private fun deletePassword(accountName: String) {
        val query = mapOf<Any?, Any?>(
            kSecClass to kSecClassGenericPassword,
            kSecAttrService to serviceName,
            kSecAttrAccount to accountName
        )

        memScoped {
            val result = SecItemDelete(query.toCFDictionary())
            if (result != errSecSuccess && result != errSecItemNotFound) {
                throw IllegalStateException("Failed to delete password from Keychain. Error code: $result")
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
