import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pasar_now/constants.dart';
import 'package:pasar_now/models/product_model.dart';
import 'package:pasar_now/providers/product_provider.dart';
import 'package:pasar_now/providers/wishlist_provider.dart';
import 'package:pasar_now/providers/inventory_provider.dart';

// Mock inventory products removed; now dynamically resolved from backend stock data and catalog.

// Product Title Parsing Logic
class ProductParsedInfo {
  final String cleanTitle;
  final bool isCase;
  final int caseSize;
  final double unitWeightKg;
  final String weightUnit;
  final String packagingType;
  final bool hasWeight;

  ProductParsedInfo({
    required this.cleanTitle,
    required this.isCase,
    required this.caseSize,
    required this.unitWeightKg,
    required this.weightUnit,
    required this.packagingType,
    this.hasWeight = true,
  });
}

ProductParsedInfo parseProductTitle(String title, {String? productWeight}) {
  String upperTitle = title.toUpperCase();

  // 1. Try to find a case pattern like "x 12" or "12 x" or "x12" or "12x"
  RegExp caseReg = RegExp(r'(?:X\s*(\d+)|(\d+)\s*X)');
  var caseMatch = caseReg.firstMatch(upperTitle);

  int caseSize = 1;
  bool isCase = false;
  if (caseMatch != null) {
    String? sizeStr = caseMatch.group(1) ?? caseMatch.group(2);
    if (sizeStr != null) {
      caseSize = int.tryParse(sizeStr) ?? 1;
      isCase = caseSize > 1;
    }
  }

  // 2. Try to find weights like "1.5KG", "850G"
  RegExp weightReg = RegExp(r'(\d*\.?\d+)\s*(KG|G|KILO|GRAM|L|ML)');
  var weightMatch = weightReg.firstMatch(upperTitle);

  double unitWeightKg = 0.0;
  String weightUnit = "KG";
  bool hasWeight = false;

  if (weightMatch != null) {
    double value = double.tryParse(weightMatch.group(1) ?? '') ?? 1.0;
    String unit = weightMatch.group(2) ?? 'KG';
    weightUnit = unit;
    hasWeight = true;
    if (unit == 'G' || unit == 'ML') {
      unitWeightKg = value / 1000.0;
    } else {
      unitWeightKg = value;
    }
  } else if (productWeight != null && productWeight.trim().isNotEmpty) {
    // Attempt fallback from medusa models' weight field if any
    String upperWeight = productWeight.toUpperCase().trim();
    RegExp weightFallbackReg = RegExp(r'(\d*\.?\d+)\s*(KG|G|KILO|GRAM|L|ML)?');
    var fallbackMatch = weightFallbackReg.firstMatch(upperWeight);
    if (fallbackMatch != null) {
      double value = double.tryParse(fallbackMatch.group(1) ?? '') ?? 0.0;
      String unit = fallbackMatch.group(2) ?? 'G'; // default to grams
      if (value > 0.0) {
        hasWeight = true;
        weightUnit = unit;
        if (unit == 'G' || unit == 'ML') {
          unitWeightKg = value / 1000.0;
        } else {
          unitWeightKg = value;
        }
      }
    }
  }

  // 3. Packaging type
  String packagingType = "Unit";

  // 4. Clean title for display
  String cleanTitle = title;
  cleanTitle = cleanTitle.replaceAll(
      RegExp(r'\s*x\s*\d+\s*x\s*\d+\.?\d*\s*(kg|g|ml|l)', caseSensitive: false),
      '');
  cleanTitle = cleanTitle.replaceAll(
      RegExp(r'\s*\d+\.?\d*\s*(kg|g|ml|l)', caseSensitive: false), '');
  cleanTitle = cleanTitle.replaceAll(RegExp(r'\s+'), ' ').trim();

  // Title capitalization formatting
  if (cleanTitle.isNotEmpty) {
    cleanTitle = cleanTitle.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  } else {
    cleanTitle = title;
  }

  return ProductParsedInfo(
    cleanTitle: cleanTitle,
    isCase: isCase,
    caseSize: caseSize,
    unitWeightKg: unitWeightKg,
    weightUnit: weightUnit,
    packagingType: packagingType,
    hasWeight: hasWeight,
  );
}

double calculateBackendWeight({
  required ProductParsedInfo parsedInfo,
  required int quantity,
  required double loose,
  required String looseType,
}) {
  if (!parsedInfo.hasWeight) {
    return 0.0;
  }
  final double weightOfUnit = parsedInfo.unitWeightKg;
  if (parsedInfo.isCase) {
    if (looseType == 'packs') {
      return (quantity * parsedInfo.caseSize * weightOfUnit) +
          (loose * weightOfUnit);
    } else {
      return (quantity * parsedInfo.caseSize * weightOfUnit) +
          (loose * parsedInfo.caseSize * weightOfUnit);
    }
  } else {
    return (quantity * weightOfUnit) + (loose * weightOfUnit);
  }
}

double calculateTotalUnits({
  required ProductParsedInfo parsedInfo,
  required int quantity,
  required double loose,
  required String looseType,
}) {
  if (parsedInfo.isCase) {
    if (looseType == 'packs') {
      return (quantity * parsedInfo.caseSize) + loose;
    } else {
      return (quantity * parsedInfo.caseSize) + (loose * parsedInfo.caseSize);
    }
  } else {
    return quantity + loose;
  }
}

String getWeightFormula({
  required ProductParsedInfo parsedInfo,
  required int quantity,
  required double loose,
  required String looseType,
}) {
  if (!parsedInfo.hasWeight) {
    final String looseStr = loose == loose.toInt()
        ? loose.toInt().toString()
        : loose.toStringAsFixed(2);
    if (parsedInfo.isCase) {
      if (looseType == 'packs') {
        return "($quantity × ${parsedInfo.caseSize} Units) + (${loose.toInt()} Units)";
      } else {
        return "($quantity × ${parsedInfo.caseSize} Units) + ($looseStr × ${parsedInfo.caseSize} Units)";
      }
    } else {
      return "$quantity Units + $looseStr Loose";
    }
  }

  final double weightOfUnit = parsedInfo.unitWeightKg;
  final String wStr = weightOfUnit
      .toStringAsFixed(weightOfUnit == weightOfUnit.toInt() ? 0 : 2);

  if (parsedInfo.isCase) {
    if (looseType == 'packs') {
      return "($quantity × ${parsedInfo.caseSize} × $wStr) + (${loose.toInt()} × $wStr)";
    } else {
      final String looseStr = loose.toStringAsFixed(2);
      return "($quantity × ${parsedInfo.caseSize} × $wStr) + ($looseStr × ${parsedInfo.caseSize} × $wStr)";
    }
  } else {
    final String looseStr = loose == loose.toInt()
        ? loose.toInt().toString()
        : loose.toStringAsFixed(2);
    return "($quantity × $wStr) + ($looseStr × $wStr)";
  }
}

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  ProductModel? _findProductById(
      String id, ProductProvider productProvider, List<ProductModel> fetchedProducts) {
    // 1. Search products loaded from backend stock database
    for (var p in fetchedProducts) {
      if (p.id == id) return p;
    }
    // 2. Search ProductProvider catalog products
    final allProducts = [
      ...demoPopularProducts,
      ...productProvider.popularProducts,
      ...productProvider.bestSellers,
      ...productProvider.featuredProducts,
      ...productProvider.flashSaleProducts,
    ];
    for (var p in allProducts) {
      if (p.id == id) return p;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Consumer3<InventoryProvider, WishlistProvider, ProductProvider>(
        builder: (context, inventoryProvider, wishlistProvider, productProvider,
            child) {
          // Combine inventory items and wishlisted product IDs
          final wishlistedIds = wishlistProvider.wishlistedIds;
          final Map<String, InventoryItem> displayMap = {};

          // Add items already in stock inventory
          for (var item in inventoryProvider.items) {
            displayMap[item.productId] = item;
          }

          // Add wishlisted items with 0 count if not already in stock inventory
          for (var wishId in wishlistedIds) {
            if (!displayMap.containsKey(wishId)) {
              displayMap[wishId] = InventoryItem(
                productId: wishId,
                quantity: 0,
                loose: 0.0,
                looseType: 'decimal',
                maxLoosePacks: 12,
              );
            }
          }

          final displayItems = displayMap.values.toList();

          // Calculate summary metrics
          double totalWeight = 0.0;
          int totalUniqueItems = displayItems.length;
          int totalInStockItems = 0;

          final List<Map<String, dynamic>> resolvedList = [];

          for (var item in displayItems) {
            final prod = _findProductById(
                item.productId, productProvider, inventoryProvider.fetchedProducts);
            if (prod != null) {
              final parsed =
                  parseProductTitle(prod.title, productWeight: prod.weight);
              final weight = calculateBackendWeight(
                parsedInfo: parsed,
                quantity: item.quantity,
                loose: item.loose,
                looseType: item.looseType,
              );
              totalWeight += weight;
              if (item.quantity > 0 || item.loose > 0) {
                totalInStockItems++;
              }
              resolvedList.add({
                'item': item,
                'product': prod,
                'parsed': parsed,
                'weight': weight,
              });
            }
          }

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () => inventoryProvider.fetchInventory(),
              child: CustomScrollView(
              slivers: [
                // Top Header / Dashboard Metrics Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Container(
                      padding: const EdgeInsets.all(defaultPadding),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF2C2456),
                                  const Color(0xFF1B1638)
                                ]
                              : [
                                  primaryColor.withOpacity(0.08),
                                  primaryColor.withOpacity(0.02)
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius:
                            BorderRadius.circular(defaultBorderRadious),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Stock Dashboard",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : blackColor,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Physical stock count and backend weights",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: isDark
                                              ? Colors.white70
                                              : blackColor60,
                                        ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.inventory_2_outlined,
                                color: primaryColor,
                                size: 28,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 1, color: Colors.black12),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMetric(
                                context,
                                "${totalWeight.toStringAsFixed(2)} KG",
                                "Total Weight",
                                Icons.scale,
                              ),
                              _buildMetric(
                                context,
                                "$totalInStockItems / $totalUniqueItems",
                                "In Stock Items",
                                Icons.done_all,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Table Header Row
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: defaultPadding),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1F1F2C) : blackColor5,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Expanded(
                            flex: 4,
                            child: Text(
                              "Inventory Item",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                "Full",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                "Loose",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "Qty",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Inventory Items List
                SliverPadding(
                  padding: const EdgeInsets.all(defaultPadding),
                  sliver: resolvedList.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Text(
                                "No items in inventory.\nWishlist items to automatically add them here.",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final itemData = resolvedList[index];
                              final InventoryItem item = itemData['item'];
                              final ProductModel product = itemData['product'];
                              final ProductParsedInfo parsed =
                                  itemData['parsed'];
                              final double weight = itemData['weight'];
                              final double totalUnits = calculateTotalUnits(
                                parsedInfo: parsed,
                                quantity: item.quantity,
                                loose: item.loose,
                                looseType: item.looseType,
                              );
                              final String totalUnitsStr = totalUnits ==
                                      totalUnits.toInt()
                                  ? "${totalUnits.toInt()} ${parsed.packagingType}${totalUnits.toInt() == 1 ? '' : 's'}"
                                  : "${totalUnits.toStringAsFixed(2)} ${parsed.packagingType}s";

                              final isWishlisted =
                                  wishlistedIds.contains(product.id);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: InkWell(
                                  onTap: () {
                                    _showEditBottomSheet(context, item, product,
                                        parsed, inventoryProvider);
                                  },
                                  borderRadius: BorderRadius.circular(
                                      defaultBorderRadious),
                                  child: Ink(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: item.quantity <= 1
                                          ? (isDark
                                              ? const Color(0xFF332211)
                                              : const Color(0xFFFFF9E6))
                                          : (isDark
                                              ? const Color(0xFF1C1C25)
                                              : Colors.white),
                                      borderRadius: BorderRadius.circular(
                                          defaultBorderRadious),
                                      border: Border.all(
                                        color: item.quantity <= 1
                                            ? (isDark
                                                ? const Color(0xFF553311)
                                                : const Color(0xFFFFD580))
                                            : (isDark
                                                ? const Color(0xFF2C2C35)
                                                : Colors.black12),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.02),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Product Image and Title Details
                                        Expanded(
                                          flex: 4,
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                child: Image.network(
                                                  product.image,
                                                  width: 40,
                                                  height: 40,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Container(
                                                    color: Colors.grey[300],
                                                    width: 40,
                                                    height: 40,
                                                    child: const Icon(
                                                        Icons.broken_image,
                                                        size: 20,
                                                        color: Colors.grey),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      parsed.cleanTitle,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Row(
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            parsed.hasWeight
                                                                ? (parsed.isCase
                                                                    ? "${parsed.caseSize} × ${parsed.unitWeightKg.toStringAsFixed(parsed.unitWeightKg == parsed.unitWeightKg.toInt() ? 0 : 2)}KG Case"
                                                                    : "${parsed.unitWeightKg.toStringAsFixed(parsed.unitWeightKg == parsed.unitWeightKg.toInt() ? 0 : 2)}KG ${parsed.packagingType}")
                                                                : (parsed.isCase
                                                                    ? "${parsed.caseSize} × Case"
                                                                    : parsed
                                                                        .packagingType),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .grey),
                                                          ),
                                                        ),
                                                        if (isWishlisted &&
                                                            item.quantity ==
                                                                0 &&
                                                            item.loose ==
                                                                0.0) ...[
                                                          const SizedBox(
                                                              width: 4),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        4,
                                                                    vertical:
                                                                        1),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: primaryColor
                                                                  .withOpacity(
                                                                      0.1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                            ),
                                                            child: Text(
                                                              "Wishlist",
                                                              style: TextStyle(
                                                                color:
                                                                    primaryColor,
                                                                fontSize: 8,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Full Count
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16.0),
                                            child: Text(
                                              item.quantity.toString(),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13),
                                            ),
                                          ),
                                        ),

                                        // Open / Loose Count
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16.0),
                                            child: Text(
                                              _formatLooseDisplay(
                                                  item.loose, item.looseType),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13),
                                            ),
                                          ),
                                        ),

                                        // Backend Weight
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                parsed.hasWeight
                                                    ? "${weight.toStringAsFixed(2)} KG"
                                                    : totalUnitsStr,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              // Text(
                                              //   getWeightFormula(
                                              //     parsedInfo: parsed,
                                              //     quantity: item.quantity,
                                              //     loose: item.loose,
                                              //     looseType: item.looseType,
                                              //   ),
                                              //   style: const TextStyle(
                                              //     color: Colors.grey,
                                              //     fontSize: 8,
                                              //   ),
                                              //   textAlign: TextAlign.end,
                                              // ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: resolvedList.length,
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
        },
      ),
    );
  }

  Widget _buildMetric(
      BuildContext context, String value, String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : blackColor,
                    ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white60 : blackColor60,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatLooseDisplay(double loose, String looseType) {
    if (looseType == 'packs') {
      return loose == 1 ? "1 Pack" : "${loose.toInt()} Packs";
    }

    if (loose == 0.0) return "0";
    if (loose == 0.25) return "1/4 Full";
    if (loose == 0.5) return "1/2 Full";
    if (loose == 0.75) return "3/4 Full";
    if (loose == 1.0) return "Full";
    return "${(loose * 100).toInt()}% Full";
  }

  void _showEditBottomSheet(
    BuildContext context,
    InventoryItem item,
    ProductModel product,
    ProductParsedInfo parsed,
    InventoryProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _EditStockBottomSheet(
          initialItem: item,
          product: product,
          parsed: parsed,
          provider: provider,
        );
      },
    );
  }
}

// Stateful Bottom Sheet component for smooth UI updates during editing
class _EditStockBottomSheet extends StatefulWidget {
  final InventoryItem initialItem;
  final ProductModel product;
  final ProductParsedInfo parsed;
  final InventoryProvider provider;

  const _EditStockBottomSheet({
    required this.initialItem,
    required this.product,
    required this.parsed,
    required this.provider,
  });

  @override
  State<_EditStockBottomSheet> createState() => _EditStockBottomSheetState();
}

class _EditStockBottomSheetState extends State<_EditStockBottomSheet> {
  late int _quantity;
  late double _loose;
  late String _looseType;
  late int _maxLoosePacks;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialItem.quantity;
    _loose = widget.initialItem.loose;
    _looseType = widget.initialItem.looseType;
    _maxLoosePacks = widget.initialItem.maxLoosePacks;

    // Smart default looseType selection based on Case title parsing
    if (widget.initialItem.quantity == 0 && widget.initialItem.loose == 0.0) {
      if (widget.parsed.isCase) {
        _looseType = 'packs';
        _maxLoosePacks = widget.parsed.caseSize;
      } else {
        _looseType = 'decimal';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    final double calculatedWeight = calculateBackendWeight(
      parsedInfo: widget.parsed,
      quantity: _quantity,
      loose: _loose,
      looseType: _looseType,
    );

    final String formulaString = getWeightFormula(
      parsedInfo: widget.parsed,
      quantity: _quantity,
      loose: _loose,
      looseType: _looseType,
    );

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: defaultPadding,
        right: defaultPadding,
        bottom: defaultPadding + keyboardPadding,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF191923) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle indicator
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Product Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(defaultBorderRadious),
                child: Image.network(
                  widget.product.image,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    width: 60,
                    height: 60,
                    child: const Icon(Icons.broken_image,
                        size: 30, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.parsed.cleanTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.product.brandName,
                      style: TextStyle(
                          color: primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      widget.product.title,
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),

          // 1. Quantity Controller (Full Count)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Full Count (${widget.parsed.packagingType}s)",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    "Count of completely full, sealed items",
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(defaultBorderRadious),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _quantity > 0
                          ? () {
                              setState(() {
                                _quantity--;
                              });
                            }
                          : null,
                      icon: const Icon(Icons.remove, size: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _quantity.toString(),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _quantity++;
                        });
                      },
                      icon: const Icon(Icons.add, size: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. Loose Type Selection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Loose",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    "Opened items",
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                ],
              ),
              DropdownButton<String>(
                value: _looseType,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(
                    value: 'decimal',
                    child: Text("% (0.0 to 1.0)"),
                  ),
                  DropdownMenuItem(
                    value: 'packs',
                    child: Text("Packs / Units"),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _looseType = val;
                      // Reset loose value safely to zero to prevent out of bound errors
                      _loose = 0.0;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 3. Slider Area (Open/Loose Count)
          if (_looseType == 'decimal') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Loose Fraction:",
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text(
                  _formatLooseDisplayDecimal(_loose),
                  style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ],
            ),
            Slider(
              value: _loose,
              min: 0.0,
              max: 1.0,
              divisions: 20, // 0.05 increments
              activeColor: primaryColor,
              inactiveColor: primaryColor.withOpacity(0.1),
              onChanged: (val) {
                setState(() {
                  _loose = double.parse(val.toStringAsFixed(2));
                });
              },
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Loose Units:",
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text(
                  "${_loose.toInt()} Packs",
                  style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ],
            ),
            Slider(
              value: _loose.clamp(0.0, _maxLoosePacks.toDouble()),
              min: 0.0,
              max: _maxLoosePacks.toDouble(),
              divisions: _maxLoosePacks > 0 ? _maxLoosePacks : 1,
              activeColor: primaryColor,
              inactiveColor: primaryColor.withOpacity(0.1),
              onChanged: (val) {
                setState(() {
                  _loose = val;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Packs per Case / Limit:",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Row(
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: _maxLoosePacks > 1
                          ? () {
                              setState(() {
                                _maxLoosePacks--;
                                if (_loose > _maxLoosePacks) {
                                  _loose = _maxLoosePacks.toDouble();
                                }
                              });
                            }
                          : null,
                      icon: const Icon(Icons.remove_circle_outline, size: 18),
                    ),
                    Text(
                      _maxLoosePacks.toString(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        setState(() {
                          _maxLoosePacks++;
                        });
                      },
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // 4. Live Backend Weight / Quantity preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF23232F) : lightGreyColor,
              borderRadius: BorderRadius.circular(defaultBorderRadious),
              border: Border.all(color: primaryColor.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Text(
                  widget.parsed.hasWeight
                      ? "PREVIEW BACKEND WEIGHT"
                      : "PREVIEW TOTAL QUANTITY",
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.parsed.hasWeight
                      ? "${calculatedWeight.toStringAsFixed(2)} KG"
                      : (() {
                          final double totalUnits = calculateTotalUnits(
                            parsedInfo: widget.parsed,
                            quantity: _quantity,
                            loose: _loose,
                            looseType: _looseType,
                          );
                          return totalUnits == totalUnits.toInt()
                              ? "${totalUnits.toInt()} ${widget.parsed.packagingType}${totalUnits.toInt() == 1 ? '' : 's'}"
                              : "${totalUnits.toStringAsFixed(2)} ${widget.parsed.packagingType}s";
                        })(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  formulaString,
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                      fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 5. Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultBorderRadious),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultBorderRadious),
                    ),
                  ),
                  onPressed: () async {
                    final updated = widget.initialItem.copyWith(
                      quantity: _quantity,
                      loose: _loose,
                      looseType: _looseType,
                      maxLoosePacks: _maxLoosePacks,
                    );
                    await widget.provider.updateItem(updated);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Save Stock"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatLooseDisplayDecimal(double loose) {
    if (loose == 0.0) return "0 (Empty)";
    if (loose == 0.25) return "0.25 (1/4 Full)";
    if (loose == 0.5) return "0.50 (1/2 Full)";
    if (loose == 0.75) return "0.75 (3/4 Full)";
    if (loose == 1.0) return "1.00 (Full)";
    return "${loose.toStringAsFixed(2)} (${(loose * 100).toInt()}% Full)";
  }
}
