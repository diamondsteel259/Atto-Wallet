package cash.atto.wallet.interactor

// This is a stub since iOS uses Keychain directly for secure storage
actual class SeedAESInteractor {
    actual suspend fun encryptSeed(seed: String, password: String): String {
        TODO("Not yet implemented")
    }

    actual suspend fun decryptSeed(
        encryptedSeed: String,
        password: String
    ): String {
        TODO("Not yet implemented")
    }
}
