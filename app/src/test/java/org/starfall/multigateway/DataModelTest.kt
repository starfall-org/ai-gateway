package org.starfall.multigateway

import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.junit.Assert.*
import org.junit.Test
import org.starfall.multigateway.data.model.*

class DataModelTest {

    private val json = Json {
        ignoreUnknownKeys = true
        encodeDefaults = true
    }

    @Test
    fun testConversationSerialization() {
        val conv = Conversation(
            id = "conv-1",
            title = "Test Chat",
            createdAt = 1000L,
            updatedAt = 2000L,
            messages = listOf(
                StoredMessage(
                    id = "msg-1",
                    role = ChatRole.USER,
                    versions = listOf(MessageVersion(content = "Hello MultiGateway"))
                )
            ),
            providerId = "openai",
            modelId = "gpt-4o",
            profileId = null
        )

        val jsonStr = json.encodeToString(conv)
        val decoded = json.decodeFromString<Conversation>(jsonStr)

        assertEquals("conv-1", decoded.id)
        assertEquals("Test Chat", decoded.title)
        assertNull(decoded.profileId)
        assertEquals(1, decoded.messages.size)
        assertEquals("Hello MultiGateway", decoded.messages.first().content)
    }

    @Test
    fun testChatProfileNoPresets() {
        val profile = ChatProfile(
            id = "custom-1",
            name = "Custom Assistant",
            config = LlmChatConfig(systemPrompt = "You are a helpful assistant")
        )

        val jsonStr = json.encodeToString(profile)
        val decoded = json.decodeFromString<ChatProfile>(jsonStr)

        assertEquals("Custom Assistant", decoded.name)
        assertEquals("You are a helpful assistant", decoded.config.systemPrompt)
    }
}
