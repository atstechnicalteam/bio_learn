import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgramSelection {
  const ProgramSelection({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.level,
    required this.durationLabel,
    required this.priceOptionId,
    required this.price,
    this.originalPrice,
  });

  factory ProgramSelection.fromJson(Map<String, dynamic> json) {
    return ProgramSelection(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      level: json['level'] as String? ?? '',
      durationLabel: json['durationLabel'] as String? ?? '',
      priceOptionId: json['priceOptionId'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
    );
  }

  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String level;
  final String durationLabel;
  final String priceOptionId;
  final double price;
  final double? originalPrice;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'level': level,
      'durationLabel': durationLabel,
      'priceOptionId': priceOptionId,
      'price': price,
      'originalPrice': originalPrice,
    };
  }
}

class PortalState {
  const PortalState({
    required this.wishlist,
    required this.cartItem,
    required this.enrolledProgram,
  });

  factory PortalState.initial() {
    return const PortalState(
      wishlist: <ProgramSelection>[],
      cartItem: null,
      enrolledProgram: null,
    );
  }

  final List<ProgramSelection> wishlist;
  final ProgramSelection? cartItem;
  final ProgramSelection? enrolledProgram;

  bool isWishlisted(String id) => wishlist.any((item) => item.id == id);

  bool isInCart(String id, String priceOptionId) {
    return cartItem?.id == id && cartItem?.priceOptionId == priceOptionId;
  }

  PortalState copyWith({
    List<ProgramSelection>? wishlist,
    ProgramSelection? cartItem,
    bool clearCart = false,
    ProgramSelection? enrolledProgram,
    bool clearEnrolledProgram = false,
  }) {
    return PortalState(
      wishlist: wishlist ?? this.wishlist,
      cartItem: clearCart ? null : cartItem ?? this.cartItem,
      enrolledProgram: clearEnrolledProgram
          ? null
          : enrolledProgram ?? this.enrolledProgram,
    );
  }
}

class PortalStore {
  PortalStore._();

  static final PortalStore instance = PortalStore._();

  static const String _wishlistKey = 'portal_store.wishlist';
  static const String _cartKey = 'portal_store.cart';
  static const String _enrolledKey = 'portal_store.enrolled';

  final ValueNotifier<PortalState> state =
      ValueNotifier(PortalState.initial());

  SharedPreferences? _preferences;
  bool _initialized = false;

  Future<void> ensureInitialized() async {
    if (_initialized) return;

    _preferences = await SharedPreferences.getInstance();
    state.value = PortalState(
      wishlist: _readList(_wishlistKey),
      cartItem: _readItem(_cartKey),
      enrolledProgram: _readItem(_enrolledKey),
    );
    _initialized = true;
  }

  Future<void> toggleWishlist(ProgramSelection program) async {
    await ensureInitialized();
    final exists = state.value.isWishlisted(program.id);
    final updatedWishlist = exists
        ? state.value.wishlist.where((item) => item.id != program.id).toList()
        : [...state.value.wishlist, program];
    await _save(state.value.copyWith(wishlist: updatedWishlist));
  }

  Future<void> removeFromWishlist(String id) async {
    await ensureInitialized();
    await _save(
      state.value.copyWith(
        wishlist: state.value.wishlist.where((item) => item.id != id).toList(),
      ),
    );
  }

  Future<void> addToCart(ProgramSelection program) async {
    await ensureInitialized();
    await _save(state.value.copyWith(cartItem: program));
  }

  Future<void> clearCart() async {
    await ensureInitialized();
    await _save(state.value.copyWith(clearCart: true));
  }

  Future<void> completePayment(ProgramSelection program) async {
    await ensureInitialized();
    await _save(
      state.value.copyWith(
        cartItem: null,
        clearCart: true,
        enrolledProgram: program,
      ),
    );
  }

  List<ProgramSelection> _readList(String key) {
    final rawValue = _preferences?.getString(key);
    if (rawValue == null || rawValue.isEmpty) return const <ProgramSelection>[];

    final decoded = jsonDecode(rawValue);
    if (decoded is! List) return const <ProgramSelection>[];

    return decoded
        .whereType<Map>()
        .map((item) => ProgramSelection.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  ProgramSelection? _readItem(String key) {
    final rawValue = _preferences?.getString(key);
    if (rawValue == null || rawValue.isEmpty) return null;

    final decoded = jsonDecode(rawValue);
    if (decoded is! Map) return null;

    return ProgramSelection.fromJson(Map<String, dynamic>.from(decoded));
  }

  Future<void> _save(PortalState newState) async {
    state.value = newState;
    await _preferences!.setString(
      _wishlistKey,
      jsonEncode(newState.wishlist.map((item) => item.toJson()).toList()),
    );

    if (newState.cartItem == null) {
      await _preferences!.remove(_cartKey);
    } else {
      await _preferences!.setString(
        _cartKey,
        jsonEncode(newState.cartItem!.toJson()),
      );
    }

    if (newState.enrolledProgram == null) {
      await _preferences!.remove(_enrolledKey);
    } else {
      await _preferences!.setString(
        _enrolledKey,
        jsonEncode(newState.enrolledProgram!.toJson()),
      );
    }
  }
}
