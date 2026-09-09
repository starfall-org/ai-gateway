package org.starfall.multigateway.data.local.db

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import org.starfall.multigateway.data.local.db.dao.*
import org.starfall.multigateway.data.local.db.entities.*

@Database(
    entities = [
        ConversationEntity::class,
        ChatProfileEntity::class,
        LlmProviderEntity::class,
        LlmModelsEntity::class,
        McpServerEntity::class,
        SpeechServiceEntity::class
    ],
    version = 2,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun conversationDao(): ConversationDao
    abstract fun chatProfileDao(): ChatProfileDao
    abstract fun llmProviderDao(): LlmProviderDao
    abstract fun llmModelsDao(): LlmModelsDao
    abstract fun mcpServerDao(): McpServerDao
    abstract fun speechServiceDao(): SpeechServiceDao

    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null

        fun getInstance(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "multigateway_db"
                ).fallbackToDestructiveMigration().build()
                INSTANCE = instance
                instance
            }
        }
    }
}
