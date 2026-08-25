import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/cauldron_goodie.dart';
import '../models/cauldron_goodies_catalog.dart';
import '../services/goodies_image_service.dart';

/// Full-page gallery of all goodies with rarity, probability, and clickable
/// full-size previews. DEBUG only — accessed from localhost Debug Panel.
class GoodiesCatalogScreen extends StatefulWidget {
  const GoodiesCatalogScreen({super.key});

  @override
  State<GoodiesCatalogScreen> createState() => _GoodiesCatalogScreenState();
}

class _GoodiesCatalogScreenState extends State<GoodiesCatalogScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _preloadAll();
  }

  Future<void> _preloadAll() async {
    // Preload ALL goodies images (not just current level's)
    await GoodiesImageService.preloadImages(CauldronGoodiesCatalog.all);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final allGoodies = CauldronGoodiesCatalog.all;
    final totalWeight = allGoodies.fold<int>(0, (s, g) => s + g.rarity.weight);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏅 Goodies Catalog'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${allGoodies.length} goodies • weight: $totalWeight',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              itemCount: allGoodies.length,
              itemBuilder: (context, index) {
                final goodie = allGoodies[index];
                final img = GoodiesImageService.getImage(goodie.id);
                final pct = (goodie.rarity.weight / totalWeight * 100).toStringAsFixed(1);
                final rarityColor = _rarityColor(goodie.rarity);

                return GestureDetector(
                  onTap: () => _showFullscreen(context, goodie, img),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: rarityColor,
                              width: goodie.isLegendary ? 3 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: rarityColor.withValues(alpha: 0.3),
                                blurRadius: goodie.isLegendary ? 12 : 4,
                                spreadRadius: goodie.isLegendary ? 2 : 0,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: img != null
                                ? RawImage(image: img, fit: BoxFit.cover)
                                : Center(
                                    child: Text(goodie.emoji,
                                        style: const TextStyle(fontSize: 32)),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        goodie.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: rarityColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${goodie.rarity.name.toUpperCase()} $pct%',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: rarityColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Color _rarityColor(GoodieRarity rarity) => switch (rarity) {
        GoodieRarity.common => Colors.grey.shade600,
        GoodieRarity.uncommon => Colors.green.shade700,
        GoodieRarity.rare => Colors.blue.shade700,
        GoodieRarity.legendary => const Color(0xFFFFD700),
      };

  void _showFullscreen(
      BuildContext context, CauldronGoodie goodie, ui.Image? img) {
    final rarityColor = _rarityColor(goodie.rarity);
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => GestureDetector(
        onTap: () => Navigator.of(ctx).pop(),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: rarityColor,
                    width: goodie.isLegendary ? 4 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: rarityColor.withValues(alpha: 0.5),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: img != null
                      ? RawImage(image: img, fit: BoxFit.cover)
                      : Center(
                          child: Text(goodie.emoji,
                              style: const TextStyle(fontSize: 80)),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                goodie.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: rarityColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  goodie.rarity.name.toUpperCase(),
                  style: TextStyle(
                    color: rarityColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tap to close',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
