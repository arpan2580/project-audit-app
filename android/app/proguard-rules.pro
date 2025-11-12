# Keep all coroutine scheduling classes
-keep class kotlinx.coroutines.scheduling.** { *; }
-dontwarn kotlinx.coroutines.scheduling.**

-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**

# Keep ktor client internals
-keep class io.ktor.** { *; }
-dontwarn io.ktor.**

# Keep Twilio classes
-keep class com.twilio.** { *; }
-dontwarn com.twilio.**

# Keep SLF4J logger implementation
-keep class org.slf4j.impl.** { *; }
-dontwarn org.slf4j.impl.**
