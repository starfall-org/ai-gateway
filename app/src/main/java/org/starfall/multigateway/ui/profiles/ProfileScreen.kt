package org.starfall.multigateway.ui.profiles

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.outlined.PersonOff
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import org.starfall.multigateway.data.model.ChatProfile
import org.starfall.multigateway.data.model.LlmChatConfig
import java.util.UUID

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProfileScreen(
    profiles: List<ChatProfile>,
    selectedProfileId: String?,
    onSelectProfile: (String?) -> Unit,
    onSaveProfile: (ChatProfile) -> Unit,
    onDeleteProfile: (String) -> Unit,
    onBack: () -> Unit
) {
    var showDialog by remember { mutableStateOf(false) }
    var editingProfile by remember { mutableStateOf<ChatProfile?>(null) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Chat Profiles") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        },
        floatingActionButton = {
            FloatingActionButton(
                onClick = {
                    editingProfile = null
                    showDialog = true
                }
            ) {
                Icon(Icons.Default.Add, contentDescription = "New Profile")
            }
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            item {
                val isNoProfileSelected = selectedProfileId == null
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable { onSelectProfile(null) },
                    colors = CardDefaults.cardColors(
                        containerColor = if (isNoProfileSelected) MaterialTheme.colorScheme.primaryContainer else MaterialTheme.colorScheme.surfaceVariant
                    ),
                    shape = RoundedCornerShape(16.dp)
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            Icons.Outlined.PersonOff,
                            contentDescription = null,
                            tint = if (isNoProfileSelected) MaterialTheme.colorScheme.onPrimaryContainer else MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        Spacer(modifier = Modifier.width(16.dp))
                        Column(modifier = Modifier.weight(1f)) {
                            Text(
                                text = "No Profile",
                                style = MaterialTheme.typography.titleMedium,
                                color = if (isNoProfileSelected) MaterialTheme.colorScheme.onPrimaryContainer else MaterialTheme.colorScheme.onSurfaceVariant
                            )
                            Text(
                                text = "Use default system parameters without active profile",
                                style = MaterialTheme.typography.bodySmall,
                                color = if (isNoProfileSelected) MaterialTheme.colorScheme.onPrimaryContainer else MaterialTheme.colorScheme.outline
                            )
                        }
                        if (isNoProfileSelected) {
                            Icon(
                                Icons.Default.Check,
                                contentDescription = "Selected",
                                tint = MaterialTheme.colorScheme.primary
                            )
                        }
                    }
                }
            }

            items(profiles, key = { it.id }) { profile ->
                val isSelected = profile.id == selectedProfileId
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable { onSelectProfile(profile.id) },
                    colors = CardDefaults.cardColors(
                        containerColor = if (isSelected) MaterialTheme.colorScheme.primaryContainer else MaterialTheme.colorScheme.surfaceVariant
                    ),
                    shape = RoundedCornerShape(16.dp)
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text(
                                text = profile.name,
                                style = MaterialTheme.typography.titleMedium,
                                color = if (isSelected) MaterialTheme.colorScheme.onPrimaryContainer else MaterialTheme.colorScheme.onSurfaceVariant
                            )
                            if (profile.config.systemPrompt.isNotBlank()) {
                                Text(
                                    text = profile.config.systemPrompt,
                                    style = MaterialTheme.typography.bodySmall,
                                    maxLines = 2,
                                    color = if (isSelected) MaterialTheme.colorScheme.onPrimaryContainer else MaterialTheme.colorScheme.outline
                                )
                            }
                        }

                        IconButton(onClick = {
                            editingProfile = profile
                            showDialog = true
                        }) {
                            Icon(Icons.Default.Edit, contentDescription = "Edit")
                        }

                        IconButton(onClick = { onDeleteProfile(profile.id) }) {
                            Icon(Icons.Default.Delete, contentDescription = "Delete")
                        }

                        if (isSelected) {
                            Icon(
                                Icons.Default.Check,
                                contentDescription = "Selected",
                                tint = MaterialTheme.colorScheme.primary
                            )
                        }
                    }
                }
            }
        }
    }

    if (showDialog) {
        EditProfileDialog(
            profile = editingProfile,
            onDismiss = { showDialog = false },
            onSave = {
                onSaveProfile(it)
                showDialog = false
            }
        )
    }
}

@Composable
fun EditProfileDialog(
    profile: ChatProfile?,
    onDismiss: () -> Unit,
    onSave: (ChatProfile) -> Unit
) {
    var name by remember { mutableStateOf(profile?.name ?: "") }
    var systemPrompt by remember { mutableStateOf(profile?.config?.systemPrompt ?: "") }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(if (profile == null) "New Profile" else "Edit Profile") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                OutlinedTextField(
                    value = name,
                    onValueChange = { name = it },
                    label = { Text("Profile Name") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )

                OutlinedTextField(
                    value = systemPrompt,
                    onValueChange = { systemPrompt = it },
                    label = { Text("System Prompt") },
                    modifier = Modifier.fillMaxWidth(),
                    minLines = 3,
                    maxLines = 6
                )
            }
        },
        confirmButton = {
            TextButton(
                onClick = {
                    if (name.isNotBlank()) {
                        val newProfile = ChatProfile(
                            id = profile?.id ?: UUID.randomUUID().toString(),
                            name = name,
                            config = LlmChatConfig(systemPrompt = systemPrompt)
                        )
                        onSave(newProfile)
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
