package org.starfall.multigateway.ui.providers

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import org.starfall.multigateway.data.model.LlmProviderInfo

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProviderScreen(
    providers: List<LlmProviderInfo>,
    onSaveProvider: (LlmProviderInfo) -> Unit,
    onBack: () -> Unit
) {
    var editingProvider by remember { mutableStateOf<LlmProviderInfo?>(null) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Providers & API Keys") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            items(providers, key = { it.id }) { provider ->
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text(provider.name, style = MaterialTheme.typography.titleMedium)
                            Text(
                                text = provider.baseUrl,
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.outline
                            )
                            val key = provider.auth.key ?: provider.auth.value
                            Text(
                                text = if (!key.isNullOrEmpty()) "API Key: ••••••••" else "API Key: Not configured",
                                style = MaterialTheme.typography.bodySmall,
                                color = if (!key.isNullOrEmpty()) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.error
                            )
                        }

                        IconButton(onClick = { editingProvider = provider }) {
                            Icon(Icons.Default.Edit, contentDescription = "Edit Key")
                        }
                    }
                }
            }
        }
    }

    editingProvider?.let { provider ->
        EditProviderDialog(
            provider = provider,
            onDismiss = { editingProvider = null },
            onSave = {
                onSaveProvider(it)
                editingProvider = null
            }
        )
    }
}

@Composable
fun EditProviderDialog(
    provider: LlmProviderInfo,
    onDismiss: () -> Unit,
    onSave: (LlmProviderInfo) -> Unit
) {
    var apiKey by remember { mutableStateOf(provider.auth.key ?: provider.auth.value ?: "") }
    var baseUrl by remember { mutableStateOf(provider.baseUrl) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Configure ${provider.name}") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                OutlinedTextField(
                    value = baseUrl,
                    onValueChange = { baseUrl = it },
                    label = { Text("Base URL") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )

                OutlinedTextField(
                    value = apiKey,
                    onValueChange = { apiKey = it },
                    label = { Text("API Key") },
                    singleLine = true,
                    visualTransformation = PasswordVisualTransformation(),
                    modifier = Modifier.fillMaxWidth()
                )
            }
        },
        confirmButton = {
            TextButton(
                onClick = {
                    val updated = provider.copy(
                        baseUrl = baseUrl,
                        auth = provider.auth.copy(key = apiKey, value = apiKey)
                    )
                    onSave(updated)
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
