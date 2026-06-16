import 'package:flutter/material.dart';
import 'database_helper.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  Map<String, dynamic>? userData;
  Map<String, int> inventory = {'STREAK_SHIELD': 0, 'REVIVE_POTION': 0};
  bool isLoading = true;

  static const Color bgBeige = Color(0xFFF5F5DC);
  static const Color sakuraPink = Color(0xFFFFB7C5);
  static const Color warmBrown = Color(0xFF5D4037);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = await DatabaseHelper.instance.getUserProfile();
    final inv = await DatabaseHelper.instance.getInventory();
    setState(() {
      userData = profile;
      inventory = {
        'STREAK_SHIELD': inv['STREAK_SHIELD'] ?? 0,
        'REVIVE_POTION': inv['REVIVE_POTION'] ?? 0,
      };
      isLoading = false;
    });
  }

  Future<void> _buyItem(String itemCode, int price, int maxLimit) async {
    setState(() {
      isLoading = true;
    });
    
    final result = await DatabaseHelper.instance.buyItem(
      itemCode: itemCode,
      price: price,
      maxLimit: maxLimit,
    );

    // Muat ulang data terbaru
    await _loadData();

    if (mounted) {
      final isSuccess = result['status'] == 'SUCCESS';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? '',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: isSuccess ? warmBrown : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBeige,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: sakuraPink))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER: JUDUL TOKO & SALDO EXP ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '🔮 Pasar Gelap',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: warmBrown,
                          ),
                        ),
                        // Saldo EXP
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: sakuraPink.withValues(alpha: 0.5)),
                            boxShadow: [
                              BoxShadow(
                                color: sakuraPink.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Text('🌸 ', style: TextStyle(fontSize: 16)),
                              Text(
                                '${userData!['current_exp']} EXP',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: warmBrown,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // --- NPC KUCING HITAM (MICRO-CONVERSATIONAL UI) ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: sakuraPink.withValues(alpha: 0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar Kucing Hitam Penyihir
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: warmBrown.withValues(alpha: 0.1),
                                child: const Text(
                                  '🐈‍⬛',
                                  style: TextStyle(fontSize: 36),
                                ),
                              ),
                              // Witch Hat emoji indicator
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text('🎩', style: TextStyle(fontSize: 14)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          
                          // Chat Bubble Kucing Hitam
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Kucing Hitam Monokel',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: warmBrown,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: bgBeige.withValues(alpha: 0.6),
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(15),
                                      bottomLeft: Radius.circular(15),
                                      bottomRight: Radius.circular(15),
                                    ),
                                  ),
                                  child: const Text(
                                    '"Ada EXP yang mau ditukar untuk menyelamatkan nyawamu hari ini? Aku punya pelindung streak yang cukup tepercaya..."',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: warmBrown,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      'Katalog Item Misterius',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: warmBrown,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- KATALOG ITEM ---
                    _buildItemCard(
                      itemCode: 'STREAK_SHIELD',
                      name: 'Streak Shield',
                      description: 'Item pasif penyelamat streak. Otomatis aktif pukul 23:59 untuk menjaga streak jika kamu lupa membaca.',
                      price: 150,
                      maxLimit: 2,
                      emoji: '🛡️',
                      ownedQty: inventory['STREAK_SHIELD'] ?? 0,
                    ),

                    const SizedBox(height: 16),

                    _buildItemCard(
                      itemCode: 'REVIVE_POTION',
                      name: 'Revive Potion',
                      description: 'Ramuan aktif berharga tinggi untuk menyambung kembali streak membaca yang telanjur putus kemarin.',
                      price: 500,
                      maxLimit: 99,
                      emoji: '🧪',
                      ownedQty: inventory['REVIVE_POTION'] ?? 0,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // WIDGET: Kartu Item
  Widget _buildItemCard({
    required String itemCode,
    required String name,
    required String description,
    required int price,
    required int maxLimit,
    required String emoji,
    required int ownedQty,
  }) {
    final bool isMax = ownedQty >= maxLimit;
    final int currentExp = userData!['current_exp'] ?? 0;
    final bool canAfford = currentExp >= price;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isMax 
              ? Colors.grey.withValues(alpha: 0.3)
              : sakuraPink.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: sakuraPink.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji Ilustrasi Item
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isMax 
                  ? Colors.grey[100] 
                  : sakuraPink.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
          ),
          const SizedBox(width: 16),

          // Detail Item
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: warmBrown,
                      ),
                    ),
                    // Indikator Milik
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: bgBeige,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        maxLimit == 99 ? 'Milik: $ownedQty' : 'Milik: $ownedQty/$maxLimit',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: warmBrown,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: warmBrown.withValues(alpha: 0.7),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Harga & Tombol Beli
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Badge Harga EXP
                    Row(
                      children: [
                        const Text('🌸 ', style: TextStyle(fontSize: 14)),
                        Text(
                          '$price EXP',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                      ],
                    ),

                    // Tombol Beli
                    ElevatedButton(
                      onPressed: (isMax || !canAfford) 
                          ? null 
                          : () => _buyItem(itemCode, price, maxLimit),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sakuraPink,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[200],
                        disabledForegroundColor: Colors.grey[400],
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: isMax ? 0 : 2,
                      ),
                      child: Text(
                        isMax 
                            ? 'Maksimal' 
                            : !canAfford 
                                ? 'EXP Kurang'
                                : 'Beli',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
