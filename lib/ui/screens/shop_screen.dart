import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brightbound_adventures/core/services/shop_service.dart';
import 'package:brightbound_adventures/core/services/avatar_provider.dart';
import 'package:brightbound_adventures/core/models/shop_item.dart';
import 'package:brightbound_adventures/ui/widgets/modern_shop_item_card.dart';

/// Shop screen for purchasing cosmetics and power-ups
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ShopCategory _selectedCategory = ShopCategory.avatarAccessories;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: ShopCategory.values.length,
      vsync: this,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedCategory = ShopCategory.values[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade700,
              Colors.deepPurple.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with star balance
              _buildHeader(),

              // Category tabs
              _buildCategoryTabs(),

              // Items grid
              Expanded(
                child: _buildItemsGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🛍️ Star Shop',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Buy cool items with your stars!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Star balance
          Consumer<ShopService>(
            builder: (context, shop, _) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      '${shop.starBalance}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(15),
        ),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
        tabAlignment: TabAlignment.start,
        tabs: ShopCategory.values.map((category) {
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  ShopHelper.getCategoryIcon(category),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(ShopHelper.getCategoryName(category)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildItemsGrid() {
    return Consumer<ShopService>(
      builder: (context, shop, _) {
        final items = shop.getItemsByCategory(_selectedCategory);

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('📦', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text(
                  'Coming soon!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ModernShopItemCard(
              item: items[index],
              shopService: shop,
              onTap: () => _showItemDetails(items[index], shop),
            );
          },
        );
      },
    );
  }

  void _showItemDetails(ShopItem item, ShopService shop) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final avatarProvider = dialogContext.watch<AvatarProvider>();
        final isEquippableOutfit = item.category == ShopCategory.outfits;
        final isEquipped =
            isEquippableOutfit && avatarProvider.avatar?.outfitId == item.id;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.emoji,
                  style: const TextStyle(fontSize: 80),
                ),
                const SizedBox(height: 16),
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _buildRewardPreview(item, isEquipped: isEquipped),
                const SizedBox(height: 24),
                if (!item.isPurchased) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        '${item.starCost} stars',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: shop.canAfford(item)
                              ? () => _purchaseItem(item, shop)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Buy'),
                        ),
                      ),
                    ],
                  ),
                  if (!shop.canAfford(item))
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Not enough stars! Need ${item.starCost - shop.starBalance} more.',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isEquipped ? Colors.indigo : Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isEquipped
                              ? Icons.checkroom_rounded
                              : Icons.check_circle_rounded,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isEquipped ? 'Equipped' : 'Already Owned',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isEquippableOutfit) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isEquipped
                            ? null
                            : () => _equipOutfit(item, dialogContext),
                        icon: const Icon(Icons.checkroom_rounded),
                        label: Text(isEquipped ? 'Wearing Now' : 'Wear Outfit'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Close'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRewardPreview(ShopItem item, {required bool isEquipped}) {
    final color = ShopHelper.getCategoryColor(item.category);
    final icon = isEquipped
        ? Icons.check_circle_rounded
        : ShopHelper.getCategoryIcon(item.category);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _rewardImpactText(item, isEquipped: isEquipped),
              style: TextStyle(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _rewardImpactText(ShopItem item, {required bool isEquipped}) {
    if (isEquipped) {
      return 'Your character is wearing this outfit on the world map.';
    }

    switch (item.category) {
      case ShopCategory.outfits:
        return item.isPurchased
            ? 'Owned outfit. Wear it to update your character on the map.'
            : 'Unlocks a wearable outfit and equips it right away.';
      case ShopCategory.avatarAccessories:
        return 'Unlocks a character accessory for the avatar collection.';
      case ShopCategory.backgrounds:
        return 'Adds a collectible backdrop for future profile and map scenes.';
      case ShopCategory.effects:
        return 'Adds a collectible visual effect for future celebrations.';
      case ShopCategory.specialItems:
        return 'Adds a special boost item for the adventure inventory.';
    }
  }

  void _purchaseItem(ShopItem item, ShopService shop) async {
    final success = await shop.purchaseItem(item.id);

    if (mounted) {
      Navigator.pop(context);

      if (success) {
        await _unlockAvatarReward(item);
        _showPurchaseSuccess(item);
      } else {
        _showPurchaseError();
      }
    }
  }

  Future<void> _unlockAvatarReward(ShopItem item) async {
    final avatarProvider = context.read<AvatarProvider>();
    if (!avatarProvider.hasAvatar) return;

    switch (item.category) {
      case ShopCategory.outfits:
        await avatarProvider.unlockOutfit(item.id);
        await avatarProvider.changeOutfit(item.id);
        break;
      case ShopCategory.avatarAccessories:
        await avatarProvider.unlockAccessory(item.id);
        break;
      case ShopCategory.backgrounds:
      case ShopCategory.effects:
      case ShopCategory.specialItems:
        break;
    }
  }

  Future<void> _equipOutfit(ShopItem item, BuildContext dialogContext) async {
    await context.read<AvatarProvider>().changeOutfit(item.id);
    if (!dialogContext.mounted) return;
    Navigator.pop(dialogContext);
    _showEquippedSuccess(item);
  }

  void _showPurchaseSuccess(ShopItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.category == ShopCategory.outfits
                    ? 'You bought and equipped ${item.name}!'
                    : 'You bought ${item.name}!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showEquippedSuccess(ShopItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${item.name} equipped!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.indigo,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showPurchaseError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Purchase failed! Please try again.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
