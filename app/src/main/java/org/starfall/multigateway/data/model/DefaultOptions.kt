package org.starfall.multigateway.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class DefaultModelRef(
    @SerialName("model_id") val modelId: String,
    @SerialName("provider_id") val providerId: String
)

@Serializable
data class DefaultOptions(
    @SerialName("chat_model") val chatModel: DefaultModelRef? = null,
    @SerialName("title_generation_model") val titleGenerationModel: DefaultModelRef? = null,
    @SerialName("default_profile_id") val defaultProfileId: String? = null
)
