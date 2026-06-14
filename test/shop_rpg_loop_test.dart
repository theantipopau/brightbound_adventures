import 'package:brightbound_adventures/core/models/cosmetics.dart';
import 'package:brightbound_adventures/core/models/shop_item.dart';
import 'package:brightbound_adventures/core/services/shop_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('shop outfit rewards have matching avatar outfit visuals', () {
    final avatarOutfitIds =
        CosmeticsLibrary.defaultOutfits.map((outfit) => outfit.id).toSet();
    final shopOutfitIds = ShopDatabase.getByCategory(ShopCategory.outfits)
        .map((item) => item.id)
        .toSet();

    expect(avatarOutfitIds.containsAll(shopOutfitIds), isTrue);
  });

  test('shop purchase spends stars and marks item as owned', () async {
    final shop = ShopService();
    await shop.initialize();
    await shop.reset();
    await shop.addStars(50);

    final purchased = await shop.purchaseItem('accessory_glasses');

    expect(purchased, isTrue);
    expect(shop.starBalance, 0);
    expect(shop.isPurchased('accessory_glasses'), isTrue);
  });
}
