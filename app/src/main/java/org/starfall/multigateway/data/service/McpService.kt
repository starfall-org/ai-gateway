package org.starfall.multigateway.data.service

import io.ktor.client.*
import io.ktor.client.engine.cio.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.serialization.json.*
import org.starfall.multigateway.data.model.McpInfo

class McpService {

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

    suspend fun listTools(mcpInfo: McpInfo): List<String> {
        val url = mcpInfo.url ?: return emptyList()
        return try {
            val response = httpClient.get(url) {
                mcpInfo.headers?.forEach { (k, v) -> header(k, v) }
            }
            val bodyText = response.bodyAsText()
            val parsed = json.parseToJsonElement(bodyText).jsonObject
            val toolsArray = parsed["tools"]?.jsonArray
            toolsArray?.mapNotNull { it.jsonObject["name"]?.jsonPrimitive?.contentOrNull } ?: emptyList()
        } catch (e: Exception) {
            emptyList()
        }
    }
}
