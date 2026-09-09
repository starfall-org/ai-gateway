package org.starfall.multigateway.ui.drawer

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import org.starfall.multigateway.data.model.Conversation

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ConversationsDrawer(
    conversations: List<Conversation>,
    currentConversationId: String?,
    onSelectConversation: (Conversation) -> Unit,
    onNewChat: () -> Unit,
    onDeleteConversation: (String) -> Unit,
    onNavigateToProfiles: () -> Unit,
    onNavigateToProviders: () -> Unit,
    onNavigateToMcp: () -> Unit,
    onNavigateToSettings: () -> Unit,
    onCloseDrawer: () -> Unit
) {
    ModalDrawerSheet(
        modifier = Modifier.width(320.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(16.dp)
        ) {
            FilledTonalButton(
                onClick = {
                    onNewChat()
                    onCloseDrawer()
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 8.dp),
                shape = ShapeDefaults.Large
            ) {
                Icon(Icons.Default.Add, contentDescription = "New Chat")
                Spacer(modifier = Modifier.width(8.dp))
                Text("New Chat", style = MaterialTheme.typography.titleMedium)
            }

            HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp))

            Text(
                text = "Recent Chats",
                style = MaterialTheme.typography.labelLarge,
                color = MaterialTheme.colorScheme.primary,
                modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
            )

            LazyColumn(
                modifier = Modifier.weight(1f)
            ) {
                items(conversations, key = { it.id }) { conv ->
                    val isSelected = conv.id == currentConversationId
                    NavigationDrawerItem(
                        icon = { Icon(Icons.Outlined.ChatBubbleOutline, contentDescription = null) },
                        label = {
                            Text(
                                text = conv.title.ifBlank { "New Chat" },
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis
                            )
                        },
                        selected = isSelected,
                        onClick = {
                            onSelectConversation(conv)
                            onCloseDrawer()
                        },
                        badge = {
                            IconButton(
                                onClick = { onDeleteConversation(conv.id) },
                                modifier = Modifier.size(24.dp)
                            ) {
                                Icon(
                                    Icons.Default.Delete,
                                    contentDescription = "Delete",
                                    tint = MaterialTheme.colorScheme.outline
                                )
                            }
                        },
                        modifier = Modifier.padding(vertical = 2.dp)
                    )
                }
            }

            HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp))

            NavigationDrawerItem(
                icon = { Icon(Icons.Outlined.Person, contentDescription = null) },
                label = { Text("Profiles") },
                selected = false,
                onClick = {
                    onNavigateToProfiles()
                    onCloseDrawer()
                }
            )

            NavigationDrawerItem(
                icon = { Icon(Icons.Outlined.Tune, contentDescription = null) },
                label = { Text("Providers & Models") },
                selected = false,
                onClick = {
                    onNavigateToProviders()
                    onCloseDrawer()
                }
            )

            NavigationDrawerItem(
                icon = { Icon(Icons.Outlined.Extension, contentDescription = null) },
                label = { Text("MCP Servers") },
                selected = false,
                onClick = {
                    onNavigateToMcp()
                    onCloseDrawer()
                }
            )

            NavigationDrawerItem(
                icon = { Icon(Icons.Outlined.Settings, contentDescription = null) },
                label = { Text("Settings") },
                selected = false,
                onClick = {
                    onNavigateToSettings()
                    onCloseDrawer()
                }
            )
        }
    }
}
