package cash.atto.wallet.ui

import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.datetime.Instant
import platform.Foundation.NSDate
import platform.Foundation.NSDateFormatter
import platform.Foundation.NSLocale
import platform.Foundation.NSTimeZone
import platform.Foundation.currentLocale
import platform.Foundation.dateWithTimeIntervalSince1970
import platform.Foundation.systemTimeZone

actual object AttoDateFormatter {
    @OptIn(ExperimentalForeignApi::class)
    actual fun format(value: Instant): String {
        val nsDate = NSDate.dateWithTimeIntervalSince1970(value.epochSeconds.toDouble())
        val formatter = NSDateFormatter().apply {
            locale = NSLocale.currentLocale
            dateFormat = "dd MMM yyyy, HH:mm"
            timeZone = NSTimeZone.systemTimeZone
        }
        return formatter.stringFromDate(nsDate)
    }
}
