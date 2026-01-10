import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/models/shop_item.dart';
import 'package:brightbound_adventures/core/services/shop_service.dart';

/// Modern shop item card with animations and hover effects
class ModernShopItemCard extends StatefulWidget {
  final ShopItem item;
  final ShopService shopService;
  final VoidCallback? onTap;

  const ModernShopItemCard({
    super.key,
    required this.item,
    required this.shopService,
    this.onTap,
  });

  @override
  State<ModernShopItemCard> createState() => _ModernShopItemCardState();
}

class _ModernShopItemCardState extends State<ModernShopItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getCategoryColor() {
    switch (widget.item.category) {
      case ShopCategory.avatarAccessories:
        return Colors.pink;
      case ShopCategory.backgrounds:
        return Colors.teal;
      case ShopCategory.effects:
        return Colors.orange;
      case ShopCategory.outfits:
        return Colors.purple;
      case ShopCategory.specialItems:
        return Colors.amber;
    }
  }

  IconData _getCategoryIcon() {
    switch (widget.item.category) {
      case ShopCategory.avatarAccessories:
        return Icons.checkroom;
      case ShopCategory.backgrounds:
        return Icons.wallpaper;
      case ShopCategory.effects:
        return Icons.auto_awesome;
      case ShopCategory.outfits:
        return Icons.style;
      case ShopCategory.specialItems:
        return Icons.stars;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPurchased = widget.item.isPurchased;
    final canAfford = widget.shopService.canAfford(widget.item);
    final categoryColor = _getCategoryColor();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final pulse = isPurchased ? 0.0 : _pulseController.value * 0.05;

          return GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.diagonal3Values(
                _isHovered ? 1.05 : 1.0 + pulse,
                _isHovered ? 1.05 : 1.0 + pulse,
                1.0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: isPurchased
                      ? [
                          Colors.green.shade400,
                          Colors.green.shade600,
                        ]
                      : [
                          categoryColor.withValues(
                              alpha: _isHovered ? 0.9 : 0.8),
                          categoryColor.withValues(
                              alpha: _isHovered ? 0.7 : 0.6),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isPurchased ? Colors.green : categoryColor)
                        .withValues(alpha: _isHovered ? 0.5 : 0.3),
                    blurRadius: _isHovered ? 16 : 10,
                    offset: const Offset(0, 4),
                    spreadRadius: _isHovered ? 2 : 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: CustomPaint(
                          painter: _ShopCardPatternPainter(
                            icon: _getCategoryIcon(),
                          ),
                        ),
                      ),
                    ),

                    // Main content
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top: Category badge and owned check
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Category icon
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getCategoryIcon(),
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),

                              // Owned badge
                              if (isPurchased)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.green.shade600,
                                    size: 14,
                                  ),
                                ),
                            ],
                          ),

                          // Center: Item emoji
                          Expanded(
                            child: Center(
                              child: Transform.scale(
                                scale: _isHovered ? 1.1 : 1.0,
                                child: Text(
                                  widget.item.emoji,
                                  style: TextStyle(
                                    fontSize: 50,
                                    shadows: [
                                      Shadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Bottom: Name and price
                          Column(
                            children: [
                              // Item name
                              Text(
                                widget.item.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),

                              // Price or owned button
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isPurchased
                                      ? Colors.white.withValues(alpha: 0.9)
                                      : (canAfford
                                          ? Colors.amber
                                          : Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: isPurchased
                                      ? [
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.green.shade600,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Owned',
                                            style: TextStyle(
                                              color: Colors.green.shade600,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ]
                                      : [
                                          const Text(
                                            '⭐',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${widget.item.starCost}',
                                            style: TextStyle(
                                              color: canAfford
                                                  ? Colors.brown.shade800
                                                  : Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Locked overlay if can't afford
                    if (!canAfford && !isPurchased)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.black.withValues(alpha: 0.2),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ShopCardPatternPainter extends CustomPainter {
  final IconData icon;

  _ShopCardPatternPainter({required this.icon});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw decorative circles
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 5; j++) {
        canvas.drawCircle(
          Offset(
            size.width * (i + 0.5) / 5,
            size.height * (j + 0.5) / 5,
          ),
          4,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
