package org.starfall.multigateway.data.local.preferences

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.*
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "app_preferences")

data class AppPreferences(
    val selectedProfileId: String? = null,
    val selectedProviderId: String = "",
    val selectedModelId: String = "",
    val themeMode: String = "SYSTEM",
    val useDynamicColor: Boolean = true,
    val defaultSystemPrompt: String = ""
)

class AppPreferencesRepository(private val context: Context) {

    private object PreferenceKeys {
        val SELECTED_PROFILE_ID = stringPreferencesKey("selected_profile_id")
        val SELECTED_PROVIDER_ID = stringPreferencesKey("selected_provider_id")
        val SELECTED_MODEL_ID = stringPreferencesKey("selected_model_id")
        val THEME_MODE = stringPreferencesKey("theme_mode")
        val USE_DYNAMIC_COLOR = booleanPreferencesKey("use_dynamic_color")
        val DEFAULT_SYSTEM_PROMPT = stringPreferencesKey("default_system_prompt")
    }

    val appPreferencesFlow: Flow<AppPreferences> = context.dataStore.data
        .map { preferences ->
            val profileId = preferences[PreferenceKeys.SELECTED_PROFILE_ID]
            AppPreferences(
                selectedProfileId = if (profileId.isNullOrEmpty()) null else profileId,
                selectedProviderId = preferences[PreferenceKeys.SELECTED_PROVIDER_ID] ?: "",
                selectedModelId = preferences[PreferenceKeys.SELECTED_MODEL_ID] ?: "",
                themeMode = preferences[PreferenceKeys.THEME_MODE] ?: "SYSTEM",
                useDynamicColor = preferences[PreferenceKeys.USE_DYNAMIC_COLOR] ?: true,
                defaultSystemPrompt = preferences[PreferenceKeys.DEFAULT_SYSTEM_PROMPT] ?: ""
            )
        }

    suspend fun setSelectedProfileId(profileId: String?) {
        context.dataStore.edit { preferences ->
            if (profileId.isNullOrEmpty()) {
                preferences.remove(PreferenceKeys.SELECTED_PROFILE_ID)
            } else {
                preferences[PreferenceKeys.SELECTED_PROFILE_ID] = profileId
            }
        }
    }

    suspend fun setSelectedModel(providerId: String, modelId: String) {
        context.dataStore.edit { preferences ->
            preferences[PreferenceKeys.SELECTED_PROVIDER_ID] = providerId
            preferences[PreferenceKeys.SELECTED_MODEL_ID] = modelId
        }
    }

    suspend fun setThemeMode(mode: String) {
        context.dataStore.edit { preferences ->
            preferences[PreferenceKeys.THEME_MODE] = mode
        }
    }

    suspend fun setUseDynamicColor(useDynamic: Boolean) {
        context.dataStore.edit { preferences ->
            preferences[PreferenceKeys.USE_DYNAMIC_COLOR] = useDynamic
        }
    }
}
