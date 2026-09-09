package org.starfall.multigateway.data.service

import io.ktor.client.*
import io.ktor.client.engine.cio.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.utils.io.*
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.emitAll
import kotlinx.serialization.json.*
import org.starfall.multigateway.data.model.*

class LlmService {

    private val json = Json {
        ignoreUnknownKeys = true
        encodeDefaults = true
        isLenient = true
    }

    private val httpClient = HttpClient(CIO) {
        install(ContentNegotiation) {
            json(json)
        }
    }

    suspend fun generateStream(
        provider: LlmProviderInfo,
        modelName: String,
        messages: List<StoredMessage>,
        systemPrompt: String = "",
        temperature: Double? = null,
        topP: Double? = null,
        maxTokens: Int = 4000
    ): Flow<String> = flow {
        when (provider.type) {
            ProviderType.OPENAI -> {
                emitAll(streamOpenAi(provider, modelName, messages, systemPrompt, temperature, topP, maxTokens))
            }
            ProviderType.ANTHROPIC -> {
                emitAll(streamAnthropic(provider, modelName, messages, systemPrompt, temperature, topP, maxTokens))
            }
            ProviderType.GOOGLE -> {
                emitAll(streamGoogle(provider, modelName, messages, systemPrompt, temperature, topP, maxTokens))
            }
            ProviderType.OLLAMA -> {
                emitAll(streamOllama(provider, modelName, messages, systemPrompt, temperature, topP, maxTokens))
            }
        }
    }

    private fun streamOpenAi(
        provider: LlmProviderInfo,
        modelName: String,
        messages: List<StoredMessage>,
        systemPrompt: String,
        temperature: Double?,
        topP: Double?,
        maxTokens: Int
    ): Flow<String> = flow {
        val baseUrlClean = provider.baseUrl.trimEnd('/')
        val url = if (baseUrlClean.endsWith("/chat/completions")) baseUrlClean else "$baseUrlClean/chat/completions"

        val openAiMessages = mutableListOf<JsonObject>()
        if (systemPrompt.isNotBlank()) {
            openAiMessages.add(buildJsonObject {
                put("role", "system")
                put("content", systemPrompt)
            })
        }
        for (m in messages) {
            openAiMessages.add(buildJsonObject {
                put("role", if (m.role == ChatRole.MODEL) "assistant" else "user")
                put("content", m.content)
            })
        }

        val requestBody = buildJsonObject {
            put("model", modelName)
            put("messages", JsonArray(openAiMessages))
            put("stream", true)
            put("max_tokens", maxTokens)
            if (temperature != null) put("temperature", temperature)
            if (topP != null) put("top_p", topP)
        }

        try {
            val response = httpClient.post(url) {
                contentType(ContentType.Application.Json)
                applyAuth(provider)
                setBody(requestBody.toString())
            }

            val channel = response.bodyAsChannel()
            while (!channel.isClosedForRead) {
                val line = channel.readUTF8Line() ?: break
                if (line.startsWith("data: ")) {
                    val data = line.removePrefix("data: ").trim()
                    if (data == "[DONE]") break
                    try {
                        val parsed = json.parseToJsonElement(data).jsonObject
                        val delta = parsed["choices"]?.jsonArray?.getOrNull(0)?.jsonObject?.get("delta")?.jsonObject
                        val content = delta?.get("content")?.jsonPrimitive?.contentOrNull
                        if (!content.isNullOrEmpty()) {
                            emit(content)
                        }
                    } catch (_: Exception) {}
                }
            }
        } catch (e: Exception) {
            emit(" [Error: ${e.localizedMessage ?: "Network error"}]")
        }
    }

    private fun streamAnthropic(
        provider: LlmProviderInfo,
        modelName: String,
        messages: List<StoredMessage>,
        systemPrompt: String,
        temperature: Double?,
        topP: Double?,
        maxTokens: Int
    ): Flow<String> = flow {
        val baseUrlClean = provider.baseUrl.trimEnd('/')
        val url = if (baseUrlClean.endsWith("/messages")) baseUrlClean else "$baseUrlClean/messages"

        val anthropicMessages = messages.map { m ->
            buildJsonObject {
                put("role", if (m.role == ChatRole.MODEL) "assistant" else "user")
                put("content", m.content)
            }
        }

        val requestBody = buildJsonObject {
            put("model", modelName)
            put("messages", JsonArray(anthropicMessages))
            put("stream", true)
            put("max_tokens", maxTokens)
            if (systemPrompt.isNotBlank()) put("system", systemPrompt)
            if (temperature != null) put("temperature", temperature)
            if (topP != null) put("top_p", topP)
        }

        try {
            val response = httpClient.post(url) {
                contentType(ContentType.Application.Json)
                header("anthropic-version", "2023-06-01")
                val key = provider.auth.key ?: provider.auth.value
                if (!key.isNullOrEmpty()) {
                    header("x-api-key", key)
                }
                setBody(requestBody.toString())
            }

            val channel = response.bodyAsChannel()
            while (!channel.isClosedForRead) {
                val line = channel.readUTF8Line() ?: break
                if (line.startsWith("data: ")) {
                    val data = line.removePrefix("data: ").trim()
                    try {
                        val parsed = json.parseToJsonElement(data).jsonObject
                        val delta = parsed["delta"]?.jsonObject
                        val text = delta?.get("text")?.jsonPrimitive?.contentOrNull
                        if (!text.isNullOrEmpty()) {
                            emit(text)
                        }
                    } catch (_: Exception) {}
                }
            }
        } catch (e: Exception) {
            emit(" [Error: ${e.localizedMessage ?: "Network error"}]")
        }
    }

    private fun streamGoogle(
        provider: LlmProviderInfo,
        modelName: String,
        messages: List<StoredMessage>,
        systemPrompt: String,
        temperature: Double?,
        topP: Double?,
        maxTokens: Int
    ): Flow<String> = flow {
        val apiKey = provider.auth.key ?: provider.auth.value ?: ""
        val baseUrlClean = provider.baseUrl.trimEnd('/')
        val url = "$baseUrlClean/models/$modelName:streamGenerateContent?key=$apiKey&alt=sse"

        val contents = messages.map { m ->
            buildJsonObject {
                put("role", if (m.role == ChatRole.MODEL) "model" else "user")
                put("parts", JsonArray(listOf(buildJsonObject { put("text", m.content) })))
            }
        }

        val requestBody = buildJsonObject {
            put("contents", JsonArray(contents))
            if (systemPrompt.isNotBlank()) {
                put("system_instruction", buildJsonObject {
                    put("parts", JsonArray(listOf(buildJsonObject { put("text", systemPrompt) })))
                })
            }
            put("generationConfig", buildJsonObject {
                put("maxOutputTokens", maxTokens)
                if (temperature != null) put("temperature", temperature)
                if (topP != null) put("topP", topP)
            })
        }

        try {
            val response = httpClient.post(url) {
                contentType(ContentType.Application.Json)
                setBody(requestBody.toString())
            }

            val channel = response.bodyAsChannel()
            while (!channel.isClosedForRead) {
                val line = channel.readUTF8Line() ?: break
                if (line.startsWith("data: ")) {
                    val data = line.removePrefix("data: ").trim()
                    try {
                        val parsed = json.parseToJsonElement(data).jsonObject
                        val candidates = parsed["candidates"]?.jsonArray
                        val parts = candidates?.getOrNull(0)?.jsonObject?.get("content")?.jsonObject?.get("parts")?.jsonArray
                        val text = parts?.getOrNull(0)?.jsonObject?.get("text")?.jsonPrimitive?.contentOrNull
                        if (!text.isNullOrEmpty()) {
                            emit(text)
                        }
                    } catch (_: Exception) {}
                }
            }
        } catch (e: Exception) {
            emit(" [Error: ${e.localizedMessage ?: "Network error"}]")
        }
    }

    private fun streamOllama(
        provider: LlmProviderInfo,
        modelName: String,
        messages: List<StoredMessage>,
        systemPrompt: String,
        temperature: Double?,
        topP: Double?,
        maxTokens: Int
    ): Flow<String> = flow {
        val baseUrlClean = provider.baseUrl.trimEnd('/')
        val url = "$baseUrlClean/chat"

        val ollamaMessages = mutableListOf<JsonObject>()
        if (systemPrompt.isNotBlank()) {
            ollamaMessages.add(buildJsonObject {
                put("role", "system")
                put("content", systemPrompt)
            })
        }
        for (m in messages) {
            ollamaMessages.add(buildJsonObject {
                put("role", if (m.role == ChatRole.MODEL) "assistant" else "user")
                put("content", m.content)
            })
        }

        val requestBody = buildJsonObject {
            put("model", modelName)
            put("messages", JsonArray(ollamaMessages))
            put("stream", true)
        }

        try {
            val response = httpClient.post(url) {
                contentType(ContentType.Application.Json)
                applyAuth(provider)
                setBody(requestBody.toString())
            }

            val channel = response.bodyAsChannel()
            while (!channel.isClosedForRead) {
                val line = channel.readUTF8Line() ?: break
                if (line.isNotBlank()) {
                    try {
                        val parsed = json.parseToJsonElement(line).jsonObject
                        val content = parsed["message"]?.jsonObject?.get("content")?.jsonPrimitive?.contentOrNull
                        if (!content.isNullOrEmpty()) {
                            emit(content)
                        }
                    } catch (_: Exception) {}
                }
            }
        } catch (e: Exception) {
            emit(" [Error: ${e.localizedMessage ?: "Network error"}]")
        }
    }

    private fun HttpRequestBuilder.applyAuth(provider: LlmProviderInfo) {
        val key = provider.auth.key ?: provider.auth.value
        if (!key.isNullOrEmpty()) {
            when (provider.auth.method) {
                AuthMethod.BEARER_TOKEN -> bearerAuth(key)
                AuthMethod.CUSTOM_HEADER -> {
                    val headerName = provider.auth.key ?: "Authorization"
                    val headerVal = provider.auth.value ?: key
                    header(headerName, headerVal)
                }
                AuthMethod.QUERY_PARAM -> {
                    parameter(provider.auth.key ?: "key", provider.auth.value ?: key)
                }
                AuthMethod.OTHER -> {
                    bearerAuth(key)
                }
            }
        }
        provider.config.headers.forEach { (k, v) ->
            header(k, v)
        }
    }
}
