package cash.atto.wallet.ui

import kotlinx.cinterop.ExperimentalForeignApi
import platform.Foundation.NSLocale
import platform.Foundation.NSNumber
import platform.Foundation.NSNumberFormatter
import platform.Foundation.NSNumberFormatterDecimalStyle
import platform.Foundation.currentLocale

actual object AttoLocalizedFormatter {
    @OptIn(ExperimentalForeignApi::class)
    actual fun format(value: String): String = try {
        val doubleValue = value.toDouble()
        val formatter = NSNumberFormatter().apply {
            locale = NSLocale.currentLocale
            numberStyle = NSNumberFormatterDecimalStyle
            maximumFractionDigits = 2u
            minimumFractionDigits = 0u
        }
        formatter.stringFromNumber(NSNumber(doubleValue)) ?: "…"
    } catch (_: Exception) {
        "…"
    }
}
