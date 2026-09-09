package org.starfall.multigateway.ui

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material.icons.outlined.PersonOff
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import kotlinx.coroutines.launch
import org.starfall.multigateway.data.local.preferences.AppPreferences
import org.starfall.multigateway.data.model.ChatProfile
import org.starfall.multigateway.data.model.Conversation
import org.starfall.multigateway.data.model.LlmProviderInfo
import org.starfall.multigateway.data.model.McpInfo
import org.starfall.multigateway.ui.chat.ChatScreen
import org.starfall.multigateway.ui.drawer.ConversationsDrawer
import org.starfall.multigateway.ui.mcp.McpScreen
import org.starfall.multigateway.ui.profiles.ProfileScreen
import org.starfall.multigateway.ui.providers.ProviderScreen
import org.starfall.multigateway.ui.settings.SettingsScreen
import org.starfall.multigateway.ui.viewmodel.MainViewModel

enum class Screen {
    CHAT,
    PROFILES,
    PROVIDERS,
    MCP,
    SETTINGS
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainScreen(viewModel: MainViewModel) {
    val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)
    val coroutineScope = rememberCoroutineScope()

    var currentScreen by remember { mutableStateOf(Screen.CHAT) }
    var showModelPicker by remember { mutableStateOf(false) }

    val conversations: List<Conversation> by viewModel.conversations.collectAsStateWithLifecycle()
    val currentConv: Conversation? by viewModel.currentConversation.collectAsStateWithLifecycle()
    val isGenerating: Boolean by viewModel.isGenerating.collectAsStateWithLifecycle()
    val appPrefs: AppPreferences by viewModel.appPreferences.collectAsStateWithLifecycle()
    val profiles: List<ChatProfile> by viewModel.profiles.collectAsStateWithLifecycle()
    val providers: List<LlmProviderInfo> by viewModel.providers.collectAsStateWithLifecycle()
    val mcpServers: List<McpInfo> by viewModel.mcpServers.collectAsStateWithLifecycle()

    val activeProfile: ChatProfile? = appPrefs.selectedProfileId?.let { id -> profiles.find { it.id == id } }

    ModalNavigationDrawer(
        drawerState = drawerState,
        drawerContent = {
            ConversationsDrawer(
                conversations = conversations,
                currentConversationId = currentConv?.id,
                onSelectConversation = {
                    viewModel.selectConversation(it)
                    currentScreen = Screen.CHAT
                },
                onNewChat = {
                    viewModel.startNewChat()
                    currentScreen = Screen.CHAT
                },
                onDeleteConversation = { viewModel.deleteConversation(it) },
                onNavigateToProfiles = { currentScreen = Screen.PROFILES },
                onNavigateToProviders = { currentScreen = Screen.PROVIDERS },
                onNavigateToMcp = { currentScreen = Screen.MCP },
                onNavigateToSettings = { currentScreen = Screen.SETTINGS },
                onCloseDrawer = { coroutineScope.launch { drawerState.close() } }
            )
        }
    ) {
        Scaffold { innerPadding ->
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(innerPadding)
            ) {
                when (currentScreen) {
                    Screen.CHAT -> {
                        Column(modifier = Modifier.fillMaxSize()) {
                            Surface(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(horizontal = 16.dp, vertical = 8.dp),
                                shape = RoundedCornerShape(28.dp),
                                color = MaterialTheme.colorScheme.surfaceContainerHigh,
                                tonalElevation = 4.dp
                            ) {
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(horizontal = 12.dp, vertical = 6.dp),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    IconButton(
                                        onClick = { coroutineScope.launch { drawerState.open() } }
                                    ) {
                                        Icon(Icons.Default.Menu, contentDescription = "Drawer Menu")
                                    }

                                    Row(
                                        modifier = Modifier
                                            .weight(1f)
                                            .clickable { showModelPicker = true }
                                            .padding(horizontal = 8.dp),
                                        verticalAlignment = Alignment.CenterVertically
                                    ) {
                                        Column {
                                            Text(
                                                text = appPrefs.selectedModelId.ifBlank { "gpt-4o" },
                                                style = MaterialTheme.typography.titleMedium,
                                                color = MaterialTheme.colorScheme.onSurface
                                            )
                                            Text(
                                                text = appPrefs.selectedProviderId.ifBlank { "openai" }.uppercase(),
                                                style = MaterialTheme.typography.labelSmall,
                                                color = MaterialTheme.colorScheme.primary
                                            )
                                        }
                                    }

                                    Surface(
                                        shape = CircleShape,
                                        color = if (activeProfile != null) MaterialTheme.colorScheme.primaryContainer else MaterialTheme.colorScheme.surfaceVariant,
                                        modifier = Modifier
                                            .size(36.dp)
                                            .clickable { currentScreen = Screen.PROFILES }
                                    ) {
                                        Box(contentAlignment = Alignment.Center) {
                                            if (activeProfile != null) {
                                                Icon(
                                                    Icons.Outlined.Person,
                                                    contentDescription = "Active Profile: ${activeProfile.name}",
                                                    tint = MaterialTheme.colorScheme.onPrimaryContainer,
                                                    modifier = Modifier.size(20.dp)
                                                )
                                            } else {
                                                Icon(
                                                    Icons.Outlined.PersonOff,
                                                    contentDescription = "No Profile",
                                                    tint = MaterialTheme.colorScheme.onSurfaceVariant,
                                                    modifier = Modifier.size(18.dp)
                                                )
                                            }
                                        }
                                    }
                                }
                            }

                            ChatScreen(
                                conversation = currentConv,
                                isGenerating = isGenerating,
                                onSendMessage = { text -> viewModel.sendMessage(text) },
                                onStopGenerating = { viewModel.stopGeneration() },
                                modifier = Modifier.weight(1f)
                            )
                        }
                    }

                    Screen.PROFILES -> {
                        ProfileScreen(
                            profiles = profiles,
                            selectedProfileId = appPrefs.selectedProfileId,
                            onSelectProfile = { viewModel.selectProfile(it) },
                            onSaveProfile = { viewModel.saveProfile(it) },
                            onDeleteProfile = { viewModel.deleteProfile(it) },
                            onBack = { currentScreen = Screen.CHAT }
                        )
                    }

                    Screen.PROVIDERS -> {
                        ProviderScreen(
                            providers = providers,
                            onSaveProvider = { viewModel.saveProvider(it) },
                            onBack = { currentScreen = Screen.CHAT }
                        )
                    }

                    Screen.MCP -> {
                        McpScreen(
                            mcpServers = mcpServers,
                            onSaveMcpServer = { viewModel.saveMcpServer(it) },
                            onDeleteMcpServer = { viewModel.deleteMcpServer(it) },
                            onBack = { currentScreen = Screen.CHAT }
                        )
                    }

                    Screen.SETTINGS -> {
                        SettingsScreen(
                            appPreferences = appPrefs,
                            onThemeChange = { mode ->
                                coroutineScope.launch { viewModel.prefsRepo.setThemeMode(mode) }
                            },
                            onDynamicColorChange = { use ->
                                coroutineScope.launch { viewModel.prefsRepo.setUseDynamicColor(use) }
                            },
                            onBack = { currentScreen = Screen.CHAT }
                        )
                    }
                }
            }
        }
    }

    if (showModelPicker) {
        ModelPickerDialog(
            providers = providers,
            currentProviderId = appPrefs.selectedProviderId,
            currentModelId = appPrefs.selectedModelId,
            onDismiss = { showModelPicker = false },
            onSelect = { providerId, modelId ->
                viewModel.selectModel(providerId, modelId)
                showModelPicker = false
            }
        )
    }
}

@Composable
fun ModelPickerDialog(
    providers: List<LlmProviderInfo>,
    currentProviderId: String,
    currentModelId: String,
    onDismiss: () -> Unit,
    onSelect: (providerId: String, modelId: String) -> Unit
) {
    val modelMap = remember {
        mapOf(
            "openai" to listOf("gpt-4o", "gpt-4o-mini", "o1", "o3-mini"),
            "google" to listOf("gemini-1.5-flash", "gemini-1.5-pro", "gemini-2.0-flash"),
            "anthropic" to listOf("claude-3-5-sonnet-20241022", "claude-3-5-haiku-20241022"),
            "ollama" to listOf("llama3.2", "qwen2.5", "mistral")
        )
    }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Select Model") },
        text = {
            Column(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                providers.forEach { provider ->
                    Text(
                        text = provider.name,
                        style = MaterialTheme.typography.titleSmall,
                        color = MaterialTheme.colorScheme.primary
                    )
                    val models = modelMap[provider.id] ?: listOf("default")
                    models.forEach { model ->
                        val isSelected = provider.id == currentProviderId && model == currentModelId
                        FilterChip(
                            selected = isSelected,
                            onClick = { onSelect(provider.id, model) },
                            label = { Text(model) },
                            modifier = Modifier.padding(end = 6.dp)
                        )
                    }
                    HorizontalDivider()
                }
            }
        },
        confirmButton = {
            TextButton(onClick = onDismiss) {
                Text("Close")
            }
        }
    )
}
