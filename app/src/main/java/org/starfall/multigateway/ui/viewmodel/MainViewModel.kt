package org.starfall.multigateway.ui.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import org.starfall.multigateway.data.local.db.AppDatabase
import org.starfall.multigateway.data.local.preferences.AppPreferences
import org.starfall.multigateway.data.local.preferences.AppPreferencesRepository
import org.starfall.multigateway.data.model.*
import org.starfall.multigateway.data.repository.*
import org.starfall.multigateway.data.service.LlmService
import org.starfall.multigateway.data.service.McpService
import java.util.UUID

class MainViewModel(application: Application) : AndroidViewModel(application) {

    private val db = AppDatabase.getInstance(application)
    val conversationRepo = ConversationRepository(db)
    val profileRepo = ProfileRepository(db)
    val llmRepo = LlmRepository(db)
    val mcpRepo = McpRepository(db)
    val prefsRepo = AppPreferencesRepository(application)
    val llmService = LlmService()
    val mcpService = McpService()

    val conversations: StateFlow<List<Conversation>> = conversationRepo.allConversations
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val profiles: StateFlow<List<ChatProfile>> = profileRepo.allProfiles
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val providers: StateFlow<List<LlmProviderInfo>> = llmRepo.allProviders
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val mcpServers: StateFlow<List<McpInfo>> = mcpRepo.allServers
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val appPreferences: StateFlow<AppPreferences> = prefsRepo.appPreferencesFlow
        .stateIn(viewModelScope, SharingStarted.Lazily, AppPreferences())

    private val _currentConversation = MutableStateFlow<Conversation?>(null)
    val currentConversation: StateFlow<Conversation?> = _currentConversation.asStateFlow()

    private val _isGenerating = MutableStateFlow(false)
    val isGenerating: StateFlow<Boolean> = _isGenerating.asStateFlow()

    private var streamJob: Job? = null

    init {
        viewModelScope.launch {
            llmRepo.allProviders.first().let { currentProviders ->
                if (currentProviders.isEmpty()) {
                    initDefaultProviders()
                }
            }
        }
    }

    private suspend fun initDefaultProviders() {
        val openAi = LlmProviderInfo(
            id = "openai",
            name = "OpenAI",
            type = ProviderType.OPENAI,
            baseUrl = "https://api.openai.com/v1",
            auth = Authorization(method = AuthMethod.BEARER_TOKEN, key = "")
        )
        val google = LlmProviderInfo(
            id = "google",
            name = "Google Gemini",
            type = ProviderType.GOOGLE,
            baseUrl = "https://generativelanguage.googleapis.com/v1beta",
            auth = Authorization(method = AuthMethod.QUERY_PARAM, key = "")
        )
        val anthropic = LlmProviderInfo(
            id = "anthropic",
            name = "Anthropic",
            type = ProviderType.ANTHROPIC,
            baseUrl = "https://api.anthropic.com/v1",
            auth = Authorization(method = AuthMethod.CUSTOM_HEADER, key = "")
        )
        val ollama = LlmProviderInfo(
            id = "ollama",
            name = "Ollama (Local)",
            type = ProviderType.OLLAMA,
            baseUrl = "http://10.0.2.2:11434/api",
            auth = Authorization(method = AuthMethod.OTHER, key = "")
        )

        llmRepo.saveProvider(openAi)
        llmRepo.saveProvider(google)
        llmRepo.saveProvider(anthropic)
        llmRepo.saveProvider(ollama)

        prefsRepo.setSelectedModel("openai", "gpt-4o")
    }

    fun selectConversation(conversation: Conversation) {
        _currentConversation.value = conversation
    }

    fun startNewChat() {
        _currentConversation.value = null
    }

    fun deleteConversation(id: String) {
        viewModelScope.launch {
            conversationRepo.deleteConversation(id)
            if (_currentConversation.value?.id == id) {
                _currentConversation.value = null
            }
        }
    }

    fun selectProfile(profileId: String?) {
        viewModelScope.launch {
            prefsRepo.setSelectedProfileId(profileId)
        }
    }

    fun selectModel(providerId: String, modelId: String) {
        viewModelScope.launch {
            prefsRepo.setSelectedModel(providerId, modelId)
        }
    }

    fun sendMessage(userText: String, fileAttachments: List<String> = emptyList()) {
        if (userText.isBlank()) return

        viewModelScope.launch {
            val prefs = appPreferences.value
            val providerList = providers.value
            val activeProvider = providerList.find { it.id == prefs.selectedProviderId }
                ?: providerList.firstOrNull() ?: return@launch
            val modelId = prefs.selectedModelId.ifBlank { "gpt-4o" }

            val activeProfile = prefs.selectedProfileId?.let { profileRepo.getById(it) }

            var conv = _currentConversation.value
            val isNew = conv == null
            val now = System.currentTimeMillis()

            val userMessage = StoredMessage(
                id = UUID.randomUUID().toString(),
                role = ChatRole.USER,
                versions = listOf(MessageVersion(content = userText, timestamp = now.toString(), files = fileAttachments)),
                activeVersionIndex = 0
            )

            val assistantMessageId = UUID.randomUUID().toString()
            val assistantPlaceholder = StoredMessage(
                id = assistantMessageId,
                role = ChatRole.MODEL,
                versions = listOf(MessageVersion(content = "", timestamp = now.toString())),
                activeVersionIndex = 0
            )

            if (isNew) {
                val autoTitle = if (userText.length > 30) userText.take(30) + "..." else userText
                conv = Conversation(
                    id = UUID.randomUUID().toString(),
                    title = autoTitle,
                    createdAt = now,
                    updatedAt = now,
                    messages = listOf(userMessage, assistantPlaceholder),
                    providerId = activeProvider.id,
                    modelId = modelId,
                    profileId = activeProfile?.id
                )
            } else {
                val updatedMessages = conv!!.messages.toMutableList().apply {
                    add(userMessage)
                    add(assistantPlaceholder)
                }
                conv = conv!!.copy(
                    messages = updatedMessages,
                    updatedAt = now,
                    providerId = activeProvider.id,
                    modelId = modelId,
                    profileId = activeProfile?.id
                )
            }

            _currentConversation.value = conv
            conversationRepo.saveConversation(conv!!)

            _isGenerating.value = true
            var accumulatedText = ""

            streamJob?.cancel()
            streamJob = viewModelScope.launch {
                val systemPrompt = activeProfile?.config?.systemPrompt ?: prefs.defaultSystemPrompt
                val temperature = activeProfile?.config?.temperature
                val topP = activeProfile?.config?.topP
                val maxTokens = activeProfile?.config?.maxTokens ?: 4000

                try {
                    llmService.generateStream(
                        provider = activeProvider,
                        modelName = modelId,
                        messages = conv!!.messages.dropLast(1),
                        systemPrompt = systemPrompt,
                        temperature = temperature,
                        topP = topP,
                        maxTokens = maxTokens
                    ).collect { chunk ->
                        accumulatedText += chunk
                        val currentMsgs = _currentConversation.value?.messages?.toMutableList() ?: return@collect
                        val idx = currentMsgs.indexOfFirst { it.id == assistantMessageId }
                        if (idx != -1) {
                            currentMsgs[idx] = currentMsgs[idx].copy(
                                versions = listOf(MessageVersion(content = accumulatedText, timestamp = System.currentTimeMillis().toString()))
                            )
                            val updatedConv = _currentConversation.value!!.copy(
                                messages = currentMsgs,
                                updatedAt = System.currentTimeMillis()
                            )
                            _currentConversation.value = updatedConv
                            conversationRepo.saveConversation(updatedConv)
                        }
                    }
                } catch (e: Exception) {
                    accumulatedText += "\n[Error: ${e.localizedMessage ?: "Generation failed"}]"
                    val currentMsgs = _currentConversation.value?.messages?.toMutableList()
                    val idx = currentMsgs?.indexOfFirst { it.id == assistantMessageId } ?: -1
                    if (idx != -1) {
                        currentMsgs!![idx] = currentMsgs[idx].copy(
                            versions = listOf(MessageVersion(content = accumulatedText, timestamp = System.currentTimeMillis().toString()))
                        )
                        val updatedConv = _currentConversation.value!!.copy(
                            messages = currentMsgs,
                            updatedAt = System.currentTimeMillis()
                        )
                        _currentConversation.value = updatedConv
                        conversationRepo.saveConversation(updatedConv)
                    }
                } finally {
                    _isGenerating.value = false
                }
            }
        }
    }

    fun stopGeneration() {
        streamJob?.cancel()
        _isGenerating.value = false
    }

    fun saveProfile(profile: ChatProfile) {
        viewModelScope.launch {
            profileRepo.saveProfile(profile)
        }
    }

    fun deleteProfile(profileId: String) {
        viewModelScope.launch {
            profileRepo.deleteProfile(profileId)
            if (appPreferences.value.selectedProfileId == profileId) {
                selectProfile(null)
            }
        }
    }

    fun saveProvider(provider: LlmProviderInfo) {
        viewModelScope.launch {
            llmRepo.saveProvider(provider)
        }
    }

    fun deleteProvider(providerId: String) {
        viewModelScope.launch {
            llmRepo.deleteProvider(providerId)
        }
    }

    fun saveMcpServer(server: McpInfo) {
        viewModelScope.launch {
            mcpRepo.saveServer(server)
        }
    }

    fun deleteMcpServer(serverId: String) {
        viewModelScope.launch {
            mcpRepo.deleteServer(serverId)
        }
    }
}
