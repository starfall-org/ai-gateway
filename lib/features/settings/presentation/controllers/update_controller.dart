import 'package:multigateway/shared/utils/app_version.dart';
import 'package:signals/signals.dart';

/// Controller quản lý trạng thái kiểm tra/cập nhật ứng dụng
class UpdateController {
  final isChecking = signal<bool>(false);
  final isDownloading = signal<bool>(false);
  final hasUpdate = signal<bool>(false);
  final currentVersion = signal<String>('0.0.0');
  final latestVersion = signal<String>('0.0.0');
  final lastCheckedAt = signal<DateTime?>(null);

  Future<void> initialize() async {
    currentVersion.value = await getAppVersion();
  }

  Future<void> checkForUpdates() async {
    if (isChecking.value) return;
    isChecking.value = true;
    try {
      await Future.delayed(const Duration(seconds: 2));
      lastCheckedAt.value = DateTime.now();

      // Giữ logic giả lập: mặc định không có bản cập nhật mới
      latestVersion.value = currentVersion.value;
      hasUpdate.value = false;
    } finally {
      isChecking.value = false;
    }
  }

  Future<void> downloadUpdate() async {
    if (isDownloading.value) return;
    isDownloading.value = true;
    try {
      // Giả lập quá trình tải xuống
      await Future.delayed(const Duration(seconds: 2));
      hasUpdate.value = false;
    } finally {
      isDownloading.value = false;
    }
  }

  void skipUpdate() {
    hasUpdate.value = false;
  }

  void dispose() {
    isChecking.dispose();
    isDownloading.dispose();
    hasUpdate.dispose();
    currentVersion.dispose();
    latestVersion.dispose();
    lastCheckedAt.dispose();
  }
}
