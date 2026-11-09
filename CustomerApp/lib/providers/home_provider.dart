import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// RIVERPOD 3.x NOTIFIER PROVIDERS (BEGINNER-FRIENDLY)
// ============================================================================

/// Selected tab in BottomNavigationBar (0: Home, 1: Browse, 2: Reorder, 3: Orders, 4: Account)
class BottomNavNotifier extends Notifier<int> {
  @override
  int build() => 0;

  set state(int value) => super.state = value;
  void setIndex(int index) => state = index;
}

final bottomNavIndexProvider = NotifierProvider<BottomNavNotifier, int>(
  BottomNavNotifier.new,
);

/// Current Delivery Location and Slot
class DeliverySlotNotifier extends Notifier<String> {
  @override
  String build() => 'Salt Lake - Tomorrow 6-8 AM';

  set state(String value) => super.state = value;
  void setSlot(String slot) => state = slot;
}

final deliverySlotProvider = NotifierProvider<DeliverySlotNotifier, String>(
  DeliverySlotNotifier.new,
);

/// Active promo banner carousel index
class ActivePromoNotifier extends Notifier<int> {
  @override
  int build() => 0;

  set state(int value) => super.state = value;
  void setIndex(int index) => state = index;
}

final activePromoIndexProvider = NotifierProvider<ActivePromoNotifier, int>(
  ActivePromoNotifier.new,
);

/// Number of items in the floating cart pill
class CartItemCountNotifier extends Notifier<int> {
  @override
  int build() => 3;

  set state(int value) => super.state = value;
  void setCount(int count) => state = count;
}

final cartItemCountProvider = NotifierProvider<CartItemCountNotifier, int>(
  CartItemCountNotifier.new,
);

/// Total price in the floating cart pill
class CartTotalNotifier extends Notifier<int> {
  @override
  int build() => 412;

  set state(int value) => super.state = value;
  void setTotal(int total) => state = total;
}

final cartTotalProvider = NotifierProvider<CartTotalNotifier, int>(
  CartTotalNotifier.new,
);

/// Search query string
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  set state(String value) => super.state = value;
  void setQuery(String query) => state = query;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

// ============================================================================
// DATA MODELS & PROVIDERS
// ============================================================================

/// Category item model
class CategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final String emoji;
  final Color? accentColor;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.emoji,
    this.accentColor,
  });
}

/// Provider supplying the 12 categories shown on the Home screen
final categoriesProvider = Provider<List<CategoryItem>>((ref) {
  return const [
    CategoryItem(
      id: 'veg',
      name: 'Veg',
      icon: Icons.eco_rounded,
      emoji: '🥬',
      accentColor: Color(0xFF2E7D32),
    ),
    CategoryItem(
      id: 'oils',
      name: 'Edible Oils',
      icon: Icons.opacity_rounded,
      emoji: '🛢️',
      accentColor: Color(0xFFE65100),
    ),
    CategoryItem(
      id: 'pulses',
      name: 'Pulses',
      icon: Icons.grain_rounded,
      emoji: '🥣',
      accentColor: Color(0xFFF57F17),
    ),
    CategoryItem(
      id: 'flours',
      name: 'Flours',
      icon: Icons.bakery_dining_rounded,
      emoji: '🌾',
      accentColor: Color(0xFF8D6E63),
    ),
    CategoryItem(
      id: 'dairy',
      name: 'Fresh Dairy',
      icon: Icons.local_drink_rounded,
      emoji: '🥛',
      accentColor: Color(0xFF1976D2),
    ),
    CategoryItem(
      id: 'rice',
      name: 'Rice & Rice\nProducts',
      icon: Icons.rice_bowl_rounded,
      emoji: '🍚',
      accentColor: Color(0xFF5D4037),
    ),
    CategoryItem(
      id: 'butter',
      name: 'Butter\n& Cheese',
      icon: Icons.breakfast_dining_rounded,
      emoji: '🧀',
      accentColor: Color(0xFFFBC02D),
    ),
    CategoryItem(
      id: 'non_veg',
      name: 'Chicken\n& Eggs',
      icon: Icons.egg_rounded,
      emoji: '🍗',
      accentColor: Color(0xFFD84315),
    ),
    CategoryItem(
      id: 'masala',
      name: 'Masala,\nSalt & Sugar',
      icon: Icons.soup_kitchen_rounded,
      emoji: '🧂',
      accentColor: Color(0xFFC2185B),
    ),
    CategoryItem(
      id: 'sauces',
      name: 'Sauces &\nSeasoning',
      icon: Icons.liquor_rounded,
      emoji: '🥫',
      accentColor: Color(0xFFE53935),
    ),
    CategoryItem(
      id: 'instant',
      name: 'Frozen &\nInstant Food',
      icon: Icons.ramen_dining_rounded,
      emoji: '🍜',
      accentColor: Color(0xFF00897B),
    ),
    CategoryItem(
      id: 'cleaning',
      name: 'Cleaning &\nConsumab..',
      icon: Icons.cleaning_services_rounded,
      emoji: '🧴',
      accentColor: Color(0xFF0288D1),
    ),
  ];
});
