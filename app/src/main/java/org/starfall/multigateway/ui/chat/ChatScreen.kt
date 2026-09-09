package org.starfall.multigateway.ui.chat

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.widget.Toast
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.launch
import org.starfall.multigateway.data.model.ChatProfile
import org.starfall.multigateway.data.model.ChatRole
import org.starfall.multigateway.data.model.Conversation
import org.starfall.multigateway.data.model.LlmProviderInfo
import org.starfall.multigateway.data.model.StoredMessage

@Composable
fun ChatScreen(
    conversation: Conversation?,
    selectedProfile: ChatProfile?,
    isGenerating: Boolean,
    providers: List<LlmProviderInfo>,
    selectedProviderId: String,
    selectedModelName: String,
    onSendMessage: (String, List<String>) -> Unit,
    onStopGenerating: () -> Unit,
    onOpenDrawer: () -> Unit,
    onOpenEndDrawer: () -> Unit,
    onRegenerate: () -> Unit,
    onEditMessage: (messageId: String, newContent: String) -> Unit,
    onDeleteMessage: (messageId: String) -> Unit,
    onSwitchVersion: (messageId: String, versionIndex: Int) -> Unit,
    onSelectModel: (providerId: String, modelId: String) -> Unit,
    onReadMessage: (String) -> Unit,
    onFetchOllamaModels: (suspend (String) -> List<String>)? = null,
    modifier: Modifier = Modifier
) {
    val listState = rememberLazyListState()
    val coroutineScope = rememberCoroutineScope()
    val context = LocalContext.current

    val messages = conversation?.messages ?: emptyList()

    // Dialog state for editing a message
    var editingMessage by remember { mutableStateOf<StoredMessage?>(null) }
    var editContentText by remember { mutableStateOf("") }

    // Dialog state for deleting a message
    var deletingMessageId by remember { mutableStateOf<String?>(null) }

    LaunchedEffect(messages.size, messages.lastOrNull()?.content?.length) {
        if (messages.isNotEmpty()) {
            coroutineScope.launch {
                listState.animateScrollToItem(messages.size - 1)
            }
        }
    }

    Scaffold(
        topBar = {
            ChatAppBar(
                currentSession = conversation,
                selectedProfile = selectedProfile,
                onOpenDrawer = onOpenDrawer,
                onOpenEndDrawer = onOpenEndDrawer
            )
        },
        bottomBar = {
            UserInputArea(
                isGenerating = isGenerating,
                onSendMessage = onSendMessage,
                onStopGenerating = onStopGenerating,
                selectedModelName = selectedModelName,
                providers = providers,
                selectedProviderId = selectedProviderId,
                onSelectModel = onSelectModel,
                onFetchOllamaModels = onFetchOllamaModels
            )
        },
        modifier = modifier.fillMaxSize()
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
        ) {
            if (messages.isEmpty()) {
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxWidth(),
                    contentAlignment = Alignment.Center
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        modifier = Modifier.padding(24.dp)
                    ) {
                        Text(
                            text = "MultiGateway",
                            style = MaterialTheme.typography.headlineMedium,
                            color = MaterialTheme.colorScheme.primary
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = selectedProfile?.config?.systemPrompt?.take(90)?.plus("...")
                                ?: "Connect to multiple LLM providers and agents seamlessly.",
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.outline,
                            textAlign = androidx.compose.ui.text.style.TextAlign.Center
                        )
                    }
                }
            } else {
                LazyColumn(
                    state = listState,
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxWidth(),
                    contentPadding = PaddingValues(vertical = 8.dp)
                ) {
                    items(messages, key = { it.id }) { msg ->
                        val isLast = msg.id == messages.lastOrNull()?.id

                        if (msg.role == ChatRole.USER) {
                            UserMessageCard(
                                message = msg,
                                onEdit = {
                                    editingMessage = msg
                                    editContentText = msg.content
                                },
                                onDelete = {
                                    deletingMessageId = msg.id
                                },
                                onSwitchVersion = { newIdx ->
                                    onSwitchVersion(msg.id, newIdx)
                                }
                            )
                        } else {
                            AssistantMessageCard(
                                message = msg,
                                isStreaming = isGenerating && isLast,
                                onCopy = {
                                    val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                                    clipboard.setPrimaryClip(ClipData.newPlainText("Copied", msg.content))
                                    Toast.makeText(context, "Copied to clipboard", Toast.LENGTH_SHORT).show()
                                },
                                onRegenerate = onRegenerate,
                                onEdit = {
                                    editingMessage = msg
                                    editContentText = msg.content
                                },
                                onDelete = {
                                    deletingMessageId = msg.id
                                },
                                onRead = {
                                    onReadMessage(msg.content)
                                },
                                onSwitchVersion = { newIdx ->
                                    onSwitchVersion(msg.id, newIdx)
                                }
                            )
                        }
                    }
                }
            }
        }
    }

    // Edit message dialog
    if (editingMessage != null) {
        AlertDialog(
            onDismissRequest = { editingMessage = null },
            title = { Text("Edit Message") },
            text = {
                OutlinedTextField(
                    value = editContentText,
                    onValueChange = { editContentText = it },
                    modifier = Modifier.fillMaxWidth().heightIn(min = 120.dp, max = 240.dp),
                    label = { Text("Message Content") }
                )
            },
            confirmButton = {
                Button(
                    onClick = {
                        val id = editingMessage?.id
                        if (id != null && editContentText.isNotBlank()) {
                            onEditMessage(id, editContentText)
                        }
                        editingMessage = null
                    }
                ) {
                    Text("Save")
                }
            },
            dismissButton = {
                TextButton(onClick = { editingMessage = null }) {
                    Text("Cancel")
                }
            }
        )
    }

    // Delete message confirmation dialog
    if (deletingMessageId != null) {
        AlertDialog(
            onDismissRequest = { deletingMessageId = null },
            title = { Text("Delete Message") },
            text = { Text("Are you sure you want to delete this message?") },
            confirmButton = {
                Button(
                    onClick = {
                        deletingMessageId?.let { onDeleteMessage(it) }
                        deletingMessageId = null
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.error)
                ) {
                    Text("Delete")
                }
            },
            dismissButton = {
                TextButton(onClick = { deletingMessageId = null }) {
                    Text("Cancel")
                }
            }
        )
    }
}
