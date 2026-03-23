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

  bool get isCourse => id.startsWith('course-');

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
    required this.cartItems,
    required this.enrolledPrograms,
  });

  factory PortalState.initial() {
    return const PortalState(
      wishlist: <ProgramSelection>[],
      cartItems: <ProgramSelection>[],
      enrolledPrograms: <ProgramSelection>[],
    );
  }

  final List<ProgramSelection> wishlist;
  final List<ProgramSelection> cartItems;
  final List<ProgramSelection> enrolledPrograms;

  bool isWishlisted(String id) => wishlist.any((item) => item.id == id);

  bool isInCart(String id, String priceOptionId) {
    return cartItems.any(
      (item) => item.id == id && item.priceOptionId == priceOptionId,
    );
  }

  int get cartCount => cartItems.length;

  ProgramSelection? get latestEnrolledProgram =>
      enrolledPrograms.isEmpty ? null : enrolledPrograms.last;

  PortalState copyWith({
    List<ProgramSelection>? wishlist,
    List<ProgramSelection>? cartItems,
    bool clearCart = false,
    List<ProgramSelection>? enrolledPrograms,
    bool clearEnrolledPrograms = false,
  }) {
    return PortalState(
      wishlist: wishlist ?? this.wishlist,
      cartItems: clearCart ? const <ProgramSelection>[] : cartItems ?? this.cartItems,
      enrolledPrograms: clearEnrolledPrograms
          ? const <ProgramSelection>[]
          : enrolledPrograms ?? this.enrolledPrograms,
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
    if (_initialized) {
      return;
    }

    _preferences = await SharedPreferences.getInstance();
    state.value = PortalState(
      wishlist: _readProgramList(_wishlistKey),
      cartItems: _readProgramList(_cartKey),
      enrolledPrograms: _readProgramList(_enrolledKey),
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

    final updatedCart = [
      ...state.value.cartItems.where((item) => item.id != program.id),
      program,
    ];

    await _save(state.value.copyWith(cartItems: updatedCart));
  }

  Future<void> removeFromCart(String id) async {
    await ensureInitialized();
    await _save(
      state.value.copyWith(
        cartItems: state.value.cartItems.where((item) => item.id != id).toList(),
      ),
    );
  }

  Future<void> clearCart() async {
    await ensureInitialized();
    await _save(state.value.copyWith(clearCart: true));
  }

  Future<void> completePayment(List<ProgramSelection> programs) async {
    await ensureInitialized();
    if (programs.isEmpty) {
      return;
    }

    final purchasedIds = programs.map((program) => program.id).toSet();
    final remainingCart = state.value.cartItems
        .where((item) => !purchasedIds.contains(item.id))
        .toList();

    final mergedEnrolled = [
      ...state.value.enrolledPrograms.where(
        (item) => !purchasedIds.contains(item.id),
      ),
      ...programs,
    ];

    await _save(
      state.value.copyWith(
        cartItems: remainingCart,
        enrolledPrograms: mergedEnrolled,
      ),
    );
  }

  List<ProgramSelection> _readProgramList(String key) {
    final rawValue = _preferences?.getString(key);
    if (rawValue == null || rawValue.isEmpty) {
      return const <ProgramSelection>[];
    }

    final decoded = jsonDecode(rawValue);
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map(
            (item) => ProgramSelection.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    if (decoded is Map) {
      return [
        ProgramSelection.fromJson(Map<String, dynamic>.from(decoded)),
      ];
    }

    return const <ProgramSelection>[];
  }

  Future<void> _save(PortalState newState) async {
    state.value = newState;
    await _preferences!.setString(
      _wishlistKey,
      jsonEncode(newState.wishlist.map((item) => item.toJson()).toList()),
    );
    await _preferences!.setString(
      _cartKey,
      jsonEncode(newState.cartItems.map((item) => item.toJson()).toList()),
    );
    await _preferences!.setString(
      _enrolledKey,
      jsonEncode(
        newState.enrolledPrograms.map((item) => item.toJson()).toList(),
      ),
    );
  }
}
