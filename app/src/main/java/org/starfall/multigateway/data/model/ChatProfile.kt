package org.starfall.multigateway.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

enum class ThinkingLevel {
    @SerialName("none") NONE,
    @SerialName("low") LOW,
    @SerialName("medium") MEDIUM,
    @SerialName("high") HIGH,
    @SerialName("auto") AUTO,
    @SerialName("custom") CUSTOM
}

@Serializable
data class LlmChatConfig(
    @SerialName("system_prompt") val systemPrompt: String = "",
    @SerialName("enable_stream") val enableStream: Boolean = true,
    @SerialName("top_p") val topP: Double? = null,
    @SerialName("top_k") val topK: Double? = null,
    val temperature: Double? = null,
    @SerialName("context_window") val contextWindow: Int = 60000,
    @SerialName("conversation_length") val conversationLength: Int = 10,
    @SerialName("max_tokens") val maxTokens: Int = 4000,
    @SerialName("custom_thinking_tokens") val customThinkingTokens: Int? = null,
    @SerialName("thinking_level") val thinkingLevel: ThinkingLevel = ThinkingLevel.AUTO
)

@Serializable
data class ActiveMcp(
    val id: String,
    @SerialName("active_tool_names") val activeToolNames: List<String> = emptyList()
)

@Serializable
data class ModelTool(
    @SerialName("model_id") val modelId: String,
    @SerialName("provider_id") val providerId: String,
    @SerialName("tool_name") val toolName: String
)

@Serializable
data class ChatProfile(
    val id: String,
    val name: String,
    val icon: String? = null,
    val config: LlmChatConfig = LlmChatConfig(),
    @SerialName("active_mcp") val activeMcp: List<ActiveMcp> = emptyList(),
    @SerialName("active_model_tools") val activeModelTools: List<ModelTool> = emptyList()
)
