import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:signals/signals.dart';

/// Optimized Hive-backed base repository using TypeAdapters for better performance.
/// This replaces JSON serialization with direct binary serialization through TypeAdapters.
///
/// Storage model:
/// - Box name: typeadapter_{prefix}
/// - Record key: itemId (from getItemId)
/// - Record value: Direct object stored using registered TypeAdapter
///
/// Benefits over HiveBaseStorage:
/// - Faster serialization/deserialization through binary format
/// - Smaller storage footprint
/// - Type-safe operations
/// - Better performance for complex nested objects
abstract class HiveTypeAdapterStorage<T> {
  HiveTypeAdapterStorage() {
    // Eagerly initialize Hive box (non-blocking)
    _initBox();
  }

  // Required by repositories
  String get prefix;
  String getItemId(T item);

  // Reactive signal for change notifications
  final changeSignal = signal<int>(0);

  // Internal
  static bool _hiveInitialized = false;

  String get _boxName => 'typeadapter_$prefix';
  String get _metaBoxName => '${_boxName}__meta';

  Future<void> _ensureHive() async {
    if (!_hiveInitialized) {
      // Hive is initialized in main.dart with TypeAdapters registered
      _hiveInitialized = true;
    }
  }

  Future<Box> _openMetaBox() async {
    await _ensureHive();
    if (Hive.isBoxOpen(_metaBoxName)) {
      return Hive.box(_metaBoxName);
    }
    return await Hive.openBox(_metaBoxName);
  }

  Future<Box<T>> _openBox() async {
    await _ensureHive();
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<T>(_boxName);
    }
    return await Hive.openBox<T>(_boxName);
  }

  void _initBox() {
    // Fire-and-forget open to minimize latency for first sync reads
    unawaited(_openBox());
    unawaited(_openMetaBox());
  }

  @protected
  Future<Box> openMetaBox() => _openMetaBox();

  @protected
  String get metaBoxName => _metaBoxName;

  @protected
  List<String> getItemIds() {
    if (!Hive.isBoxOpen(_boxName)) return <String>[];
    final box = Hive.box<T>(_boxName);
    return box.keys
        .map((k) => k.toString())
        .where((k) => !k.startsWith('__'))
        .toList();
  }

  // CRUD Operations

  /// Save an item using TypeAdapter for optimal performance
  Future<void> saveItem(T item) async {
    final id = getItemId(item);
    final box = await _openBox();
    await box.put(id, item);

    // Notify listeners
    changeSignal.value++;
  }

  /// Get an item by ID - direct deserialization through TypeAdapter
  T? getItem(String id) {
    if (!Hive.isBoxOpen(_boxName)) {
      return null;
    }
    final box = Hive.box<T>(_boxName);
    return box.get(id);
  }

  /// Get items synchronously. Returns empty list if box not ready.
  /// For reactive UI, use getItemsAsync() or itemsStream instead.
  List<T> getItems() {
    if (!Hive.isBoxOpen(_boxName)) {
      return <T>[];
    }
    final box = Hive.box<T>(_boxName);
    return _getItemsFromBox(box);
  }

  /// Get items asynchronously, ensuring box is opened first
  Future<List<T>> getItemsAsync() async {
    final box = await _openBox();
    return _getItemsFromBox(box);
  }

  List<T> _getItemsFromBox(Box<T> box) {
    final items = <T>[];

    for (final key in box.keys) {
      final id = key.toString();
      if (id.startsWith('__')) continue;
      
      final item = box.get(id);
      if (item != null) {
        items.add(item);
      }
    }

    // Apply persistent order if available
    final order = getOrder();
    if (order.isNotEmpty) {
      final itemMap = {for (var item in items) getItemId(item): item};
      final sortedItems = <T>[];
      for (var id in order) {
        if (itemMap.containsKey(id)) {
          sortedItems.add(itemMap[id] as T);
          itemMap.remove(id);
        }
      }
      // append remaining items (if any new ones were added but not yet in order list)
      sortedItems.addAll(itemMap.values);
      return sortedItems;
    }

    return items;
  }

  Future<void> saveOrder(List<String> ids) async {
    final metaBox = await _openMetaBox();
    await metaBox.put('__order__', ids);
    changeSignal.value++;
  }

  List<String> getOrder() {
    if (!Hive.isBoxOpen(_metaBoxName)) {
      try {
        final metaBox = Hive.box(_metaBoxName);
        final raw = metaBox.get('__order__');
        if (raw is List) {
          return raw.cast<String>();
        }
      } catch (_) {
        // ignore
      }
      return <String>[];
    }
    final metaBox = Hive.box(_metaBoxName);
    final raw = metaBox.get('__order__');
    if (raw is List) {
      return raw.cast<String>();
    }
    return <String>[];
  }

  Future<void> deleteItem(String id) async {
    final box = await _openBox();
    await box.delete(id);
    changeSignal.value++;
  }

  Future<void> clear() async {
    final box = await _openBox();
    await box.clear();
    final metaBox = await _openMetaBox();
    await metaBox.clear();
    changeSignal.value++;
  }

  // Reactive streams

  /// Stream that emits on every change. Starts by emitting once on subscribe.
  Stream<void> get changes {
    final controller = StreamController<void>.broadcast();
    EffectCleanup? cleanup;

    controller.onListen = () {
      controller.add(null); // initial tick

      // Watch signal changes
      cleanup = effect(() {
        changeSignal.value; // Track signal
        controller.add(null);
      });

      // Also attach to Hive watch (async)
      () async {
        final box = await _openBox();
        box.watch().listen((_) {
          controller.add(null);
        });
      }();
    };

    controller.onCancel = () {
      cleanup?.call();
    };

    return controller.stream;
  }

  /// Emits current items immediately and re-emits on each change.
  Stream<List<T>> get itemsStream {
    final controller = StreamController<List<T>>.broadcast();
    StreamSubscription? hiveSub;
    EffectCleanup? cleanup;

    Future<void> emit() async {
      // Ensure box is open before enumerating
      await _openBox();
      controller.add(getItems());
    }

    controller.onListen = () {
      // initial emit
      unawaited(emit());

      // listen to signal changes
      cleanup = effect(() {
        changeSignal.value; // Track signal
        unawaited(emit());
      });

      // listen to hive events
      () async {
        final box = await _openBox();
        hiveSub = box.watch().listen((_) {
          unawaited(emit());
        });
      }();
    };

    controller.onCancel = () async {
      cleanup?.call();
      await hiveSub?.cancel();
      hiveSub = null;
    };

    return controller.stream;
  }

  // Aliases for compatibility with previous base
  Future<void> addItem(T item) => saveItem(item);
  Future<void> updateItem(T item) => saveItem(item);

  /// Ensures the box is fully opened and ready for operations.
  /// This method should be called in the storage's init() method.
  Future<void> ensureBoxReady() async {
    await _openBox();
    await _openMetaBox();
  }
}
