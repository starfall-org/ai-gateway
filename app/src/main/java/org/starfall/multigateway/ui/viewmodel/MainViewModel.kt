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
import org.starfall.multigateway.data.service.TtsHelper
import java.util.UUID

class MainViewModel(application: Application) : AndroidViewModel(application) {

    private val db = AppDatabase.getInstance(application)
    val conversationRepo = ConversationRepository(db)
    val profileRepo = ProfileRepository(db)
    val llmRepo = LlmRepository(db)
    val mcpRepo = McpRepository(db)
    val speechRepo = SpeechRepository(db)
    val prefsRepo = AppPreferencesRepository(application)
    val llmService = LlmService()
    val mcpService = McpService()
    val ttsHelper = TtsHelper(application)

    val conversations: StateFlow<List<Conversation>> = conversationRepo.allConversations
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val profiles: StateFlow<List<ChatProfile>> = profileRepo.allProfiles
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val providers: StateFlow<List<LlmProviderInfo>> = llmRepo.allProviders
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val mcpServers: StateFlow<List<McpInfo>> = mcpRepo.allServers
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val speechServices: StateFlow<List<SpeechService>> = speechRepo.allServices
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
                } else {
                    val existingOllama = currentProviders.find { it.type == ProviderType.OLLAMA }
                    if (existingOllama != null && (
                            existingOllama.baseUrl.contains("108.181.196.208") ||
                            existingOllama.baseUrl.contains("10.0.2.2") ||
                            existingOllama.baseUrl.contains("localhost")
                        )) {
                        llmRepo.saveProvider(
                            existingOllama.copy(
                                name = "Ollama",
                                baseUrl = "https://ollama.com/api"
                            )
                        )
                    }
                }
            }

            profileRepo.allProfiles.first().let { currentProfiles ->
                if (currentProfiles.isEmpty()) {
                    initDefaultProfiles()
                }
            }

            speechRepo.allServices.first().let { currentServices ->
                if (currentServices.isEmpty()) {
                    initDefaultSpeechServices()
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
            name = "Ollama",
            type = ProviderType.OLLAMA,
            baseUrl = "https://ollama.com/api",
            auth = Authorization(method = AuthMethod.OTHER, key = "")
        )

        llmRepo.saveProvider(openAi)
        llmRepo.saveProvider(google)
        llmRepo.saveProvider(anthropic)
        llmRepo.saveProvider(ollama)

        prefsRepo.setSelectedModel("ollama", "llama3.2:latest")
    }

    private suspend fun initDefaultProfiles() {
        val general = ChatProfile(
            id = "profile_general",
            name = "General Assistant",
            config = LlmChatConfig(
                systemPrompt = "You are a helpful, capable, and thoughtful AI assistant. Respond clearly and accurately.",
                temperature = 0.7,
                topP = 0.95
            )
        )
        val coding = ChatProfile(
            id = "profile_coding",
            name = "Code Architect",
            config = LlmChatConfig(
                systemPrompt = "You are an expert software engineer and system architect. Provide clean, modular, and idiomatic code with explanations.",
                temperature = 0.2,
                topP = 0.9
            )
        )
        val writer = ChatProfile(
            id = "profile_creative",
            name = "Creative Writer",
            config = LlmChatConfig(
                systemPrompt = "You are an imaginative creative writer, editor, and storyteller. Help users craft engaging stories, prose, and content.",
                temperature = 0.9,
                topP = 1.0
            )
        )

        profileRepo.saveProfile(general)
        profileRepo.saveProfile(coding)
        profileRepo.saveProfile(writer)

        prefsRepo.setSelectedProfileId("profile_general")
    }

    private suspend fun initDefaultSpeechServices() {
        val systemTts = SpeechService(
            id = "system_tts",
            name = "Android System TTS",
            provider = "system",
            voice = "Default",
            speed = 1.0f,
            pitch = 1.0f
        )
        speechRepo.saveService(systemTts)
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

    fun renameConversation(id: String, newTitle: String) {
        viewModelScope.launch {
            val conv = conversationRepo.getById(id) ?: return@launch
            val updated = conv.copy(title = newTitle, updatedAt = System.currentTimeMillis())
            conversationRepo.saveConversation(updated)
            if (_currentConversation.value?.id == id) {
                _currentConversation.value = updated
            }
        }
    }

    fun clearAllConversations() {
        viewModelScope.launch {
            conversationRepo.deleteAll()
            _currentConversation.value = null
        }
    }

    fun deleteAllUserData() {
        viewModelScope.launch {
            conversationRepo.deleteAll()
            _currentConversation.value = null
            // Also reset active profile to default
            prefsRepo.setSelectedProfileId(null)
        }
    }

    fun cleanCache() {
        // Clear cached responses and stopped streams
        stopGeneration()
        stopSpeaking()
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

    fun speakText(text: String) {
        ttsHelper.speak(text)
    }

    fun stopSpeaking() {
        ttsHelper.stop()
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
            var reasoningText = ""

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

                        // Check if the output has <think>...</think> reasoning tags
                        val parsedReasoning: String?
                        val parsedContent: String
                        if (accumulatedText.contains("<think>")) {
                            if (accumulatedText.contains("</think>")) {
                                val parts = accumulatedText.split("</think>", limit = 2)
                                parsedReasoning = parts[0].replace("<think>", "").trim()
                                parsedContent = parts[1].trimStart()
                            } else {
                                parsedReasoning = accumulatedText.replace("<think>", "").trim()
                                parsedContent = ""
                            }
                        } else {
                            parsedReasoning = null
                            parsedContent = accumulatedText
                        }

                        val currentMsgs = _currentConversation.value?.messages?.toMutableList() ?: return@collect
                        val idx = currentMsgs.indexOfFirst { it.id == assistantMessageId }
                        if (idx != -1) {
                            currentMsgs[idx] = currentMsgs[idx].copy(
                                versions = listOf(
                                    MessageVersion(
                                        content = parsedContent,
                                        reasoningContent = parsedReasoning,
                                        timestamp = System.currentTimeMillis().toString()
                                    )
                                )
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

    fun editMessage(messageId: String, newContent: String) {
        val conv = _currentConversation.value ?: return
        val currentMsgs = conv.messages.toMutableList()
        val idx = currentMsgs.indexOfFirst { it.id == messageId }
        if (idx != -1) {
            val oldMsg = currentMsgs[idx]
            val newVersions = oldMsg.versions.toMutableList()
            newVersions.add(MessageVersion(content = newContent, timestamp = System.currentTimeMillis().toString()))
            currentMsgs[idx] = oldMsg.copy(
                versions = newVersions,
                activeVersionIndex = newVersions.size - 1
            )
            val updated = conv.copy(messages = currentMsgs, updatedAt = System.currentTimeMillis())
            _currentConversation.value = updated
            viewModelScope.launch { conversationRepo.saveConversation(updated) }
        }
    }

    fun deleteMessage(messageId: String) {
        val conv = _currentConversation.value ?: return
        val currentMsgs = conv.messages.filter { it.id != messageId }
        val updated = conv.copy(messages = currentMsgs, updatedAt = System.currentTimeMillis())
        _currentConversation.value = updated
        viewModelScope.launch { conversationRepo.saveConversation(updated) }
    }

    fun switchMessageVersion(messageId: String, versionIndex: Int) {
        val conv = _currentConversation.value ?: return
        val currentMsgs = conv.messages.toMutableList()
        val idx = currentMsgs.indexOfFirst { it.id == messageId }
        if (idx != -1) {
            val oldMsg = currentMsgs[idx]
            if (versionIndex in oldMsg.versions.indices) {
                currentMsgs[idx] = oldMsg.copy(activeVersionIndex = versionIndex)
                val updated = conv.copy(messages = currentMsgs)
                _currentConversation.value = updated
                viewModelScope.launch { conversationRepo.saveConversation(updated) }
            }
        }
    }

    fun regenerateLastMessage() {
        val conv = _currentConversation.value ?: return
        if (conv.messages.isEmpty()) return
        val lastUserMessage = conv.messages.lastOrNull { it.role == ChatRole.USER } ?: return
        // Remove trailing model messages if any
        val trimmedMessages = conv.messages.takeWhile { it.id != lastUserMessage.id }.toMutableList()
        val updated = conv.copy(messages = trimmedMessages)
        _currentConversation.value = updated
        sendMessage(lastUserMessage.content, lastUserMessage.files)
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

    suspend fun testConnection(provider: LlmProviderInfo): Result<String> {
        return llmService.testConnection(provider)
    }

    suspend fun fetchOllamaModels(baseUrl: String): List<String> {
        return llmService.fetchOllamaModels(baseUrl)
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

    fun saveSpeechService(service: SpeechService) {
        viewModelScope.launch {
            speechRepo.saveService(service)
        }
    }

    fun deleteSpeechService(serviceId: String) {
        viewModelScope.launch {
            speechRepo.deleteService(serviceId)
        }
    }

    override fun onCleared() {
        super.onCleared()
        ttsHelper.shutdown()
    }
}
