package org.starfall.multigateway.ui.speech

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.outlined.Delete
import androidx.compose.material.icons.outlined.Edit
import androidx.compose.material.icons.outlined.RecordVoiceOver
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.starfall.multigateway.data.model.SpeechService
import java.util.UUID

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SpeechScreen(
    speechServices: List<SpeechService>,
    onSaveService: (SpeechService) -> Unit,
    onDeleteService: (String) -> Unit,
    onTestVoice: (text: String, speed: Float, pitch: Float) -> Unit,
    onBack: () -> Unit
) {
    var editingService by remember { mutableStateOf<SpeechService?>(null) }
    var isCreatingNew by remember { mutableStateOf(false) }
    var deletingServiceId by remember { mutableStateOf<String?>(null) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text(
                            text = "Speech Services",
                            style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.SemiBold)
                        )
                        Text(
                            text = "Manage text-to-speech services",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.outline
                        )
                    }
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    IconButton(onClick = { isCreatingNew = true }) {
                        Icon(Icons.Default.Add, contentDescription = "Add Voice")
                    }
                }
            )
        }
    ) { padding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(horizontal = 16.dp, vertical = 8.dp)
        ) {
            LazyColumn(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                items(speechServices, key = { it.id }) { service ->
                    SpeechServiceCard(
                        service = service,
                        onTest = {
                            onTestVoice("Hello! This is a preview of the ${service.name} voice.", service.speed, service.pitch)
                        },
                        onEdit = { editingService = service },
                        onDelete = { deletingServiceId = service.id }
                    )
                }
            }
        }
    }

    if (editingService != null || isCreatingNew) {
        val target = editingService ?: SpeechService(
            id = UUID.randomUUID().toString(),
            name = "Custom TTS",
            provider = "System",
            voice = "default",
            speed = 1.0f,
            pitch = 1.0f
        )

        AddOrEditSpeechDialog(
            initialService = target,
            isNew = isCreatingNew,
            onTest = onTestVoice,
            onDismiss = {
                editingService = null
                isCreatingNew = false
            },
            onSave = { saved ->
                onSaveService(saved)
                editingService = null
                isCreatingNew = false
            }
        )
    }

    if (deletingServiceId != null) {
        AlertDialog(
            onDismissRequest = { deletingServiceId = null },
            title = { Text("Delete Speech Service") },
            text = { Text("Are you sure you want to remove this TTS voice configuration?") },
            confirmButton = {
                Button(
                    onClick = {
                        deletingServiceId?.let { onDeleteService(it) }
                        deletingServiceId = null
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.error)
                ) {
                    Text("Delete")
                }
            },
            dismissButton = {
                TextButton(onClick = { deletingServiceId = null }) {
                    Text("Cancel")
                }
            }
        )
    }
}

@Composable
fun SpeechServiceCard(
    service: SpeechService,
    onTest: () -> Unit,
    onEdit: () -> Unit,
    onDelete: () -> Unit
) {
    Surface(
        shape = RoundedCornerShape(16.dp),
        color = MaterialTheme.colorScheme.surfaceContainerLow,
        border = androidx.compose.foundation.BorderStroke(1.dp, MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.5f)),
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier.padding(14.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .clip(CircleShape)
                    .background(MaterialTheme.colorScheme.primaryContainer),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Outlined.RecordVoiceOver,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.primary,
                    modifier = Modifier.size(22.dp)
                )
            }

            Spacer(modifier = Modifier.width(14.dp))

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = service.name,
                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.SemiBold),
                    color = MaterialTheme.colorScheme.onSurface
                )
                Text(
                    text = "Provider: ${service.provider} • Voice: ${service.voice}",
                    style = MaterialTheme.typography.bodySmall.copy(fontSize = 11.sp),
                    color = MaterialTheme.colorScheme.primary
                )
                Text(
                    text = "Speed: ${service.speed}x • Pitch: ${service.pitch}x",
                    style = MaterialTheme.typography.bodySmall.copy(fontSize = 11.sp),
                    color = MaterialTheme.colorScheme.outline
                )
            }

            Row(verticalAlignment = Alignment.CenterVertically) {
                IconButton(onClick = onTest, modifier = Modifier.size(36.dp)) {
                    Icon(
                        imageVector = Icons.Default.PlayArrow,
                        contentDescription = "Test voice",
                        tint = MaterialTheme.colorScheme.primary,
                        modifier = Modifier.size(22.dp)
                    )
                }
                IconButton(onClick = onEdit, modifier = Modifier.size(36.dp)) {
                    Icon(Icons.Outlined.Edit, contentDescription = "Edit", modifier = Modifier.size(18.dp))
                }
                IconButton(onClick = onDelete, modifier = Modifier.size(36.dp)) {
                    Icon(Icons.Outlined.Delete, contentDescription = "Delete", tint = MaterialTheme.colorScheme.error, modifier = Modifier.size(18.dp))
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddOrEditSpeechDialog(
    initialService: SpeechService,
    isNew: Boolean,
    onTest: (String, Float, Pitch: Float) -> Unit,
    onDismiss: () -> Unit,
    onSave: (SpeechService) -> Unit
) {
    var name by remember { mutableStateOf(initialService.name) }
    var provider by remember { mutableStateOf(initialService.provider) }
    var voice by remember { mutableStateOf(initialService.voice) }
    var speed by remember { mutableFloatStateOf(initialService.speed) }
    var pitch by remember { mutableFloatStateOf(initialService.pitch) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(if (isNew) "Add Speech Service" else "Edit Voice Config") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                OutlinedTextField(
                    value = name,
                    onValueChange = { name = it },
                    label = { Text("Service Name") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )

                OutlinedTextField(
                    value = voice,
                    onValueChange = { voice = it },
                    label = { Text("Voice Identifier (e.g. en-US-default)") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )

                Text(
                    text = "Speed Rate: ${String.format("%.1f", speed)}x",
                    style = MaterialTheme.typography.labelMedium
                )
                Slider(
                    value = speed,
                    onValueChange = { speed = it },
                    valueRange = 0.5f..2.0f
                )

                Text(
                    text = "Pitch: ${String.format("%.1f", pitch)}x",
                    style = MaterialTheme.typography.labelMedium
                )
                Slider(
                    value = pitch,
                    onValueChange = { pitch = it },
                    valueRange = 0.5f..2.0f
                )

                OutlinedButton(
                    onClick = {
                        onTest("Testing speech voice output. Quality is optimal.", speed, pitch)
                    },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Icon(Icons.Default.PlayArrow, contentDescription = null, modifier = Modifier.size(18.dp))
                    Spacer(modifier = Modifier.width(6.dp))
                    Text("Test Voice Preview")
                }
            }
        },
        confirmButton = {
            Button(
                onClick = {
                    if (name.isNotBlank()) {
                        val updated = initialService.copy(
                            name = name.trim(),
                            provider = provider.trim(),
                            voice = voice.trim(),
                            speed = speed,
                            pitch = pitch
                        )
                        onSave(updated)
                    }
                }
            ) {
                Text("Save")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}
