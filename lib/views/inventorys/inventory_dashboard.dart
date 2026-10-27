import 'package:admin_fungi/views/inventorys/restock_history_page.dart';
import 'package:admin_fungi/views/inventorys/restock_step1_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ingredient_page.dart'; // Sesuaikan path ke file list stok (Fitur 1)

class InventoryDashboard extends StatelessWidget {
  const InventoryDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Pusat Kendali Inventaris",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "MENU GUDANG",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.blueGrey,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                // FITUR 1: LIST STOK
                _buildMenuCard(
                  title: "Daftar Stok\nBahan",
                  icon: Icons.inventory_2_rounded,
                  color: Colors.blue,
                  onTap: () => Get.to(() => const IngredientPage()),
                ),
                // FITUR 2: PENGISIAN STOK (Akan dikerjakan nanti)
                _buildMenuCard(
                  title: "Pengisian &\nBahan Baru",
                  icon: Icons.add_shopping_cart_rounded,
                  color: Colors.green,
                  onTap: () => Get.to(() => const RestockStep1Page()), // Arahka
                ),
                // FITUR 3: LOG PENGISIAN (Akan dikerjakan nanti)
                _buildMenuCard(
                  title: "Riwayat\nRestock",
                  icon: Icons.history_rounded,
                  color: Colors.orange,
                  onTap: () {
                    RestockHistoryPage page = const RestockHistoryPage();
                    Get.to(() => page);
                  },
                ),
                // FITUR 4: STATISTIK (Akan dikerjakan nanti)
                _buildMenuCard(
                  title: "Pantau\nStatistik",
                  icon: Icons.analytics_rounded,
                  color: Colors.purple,
                  onTap: () {
                    Get.snackbar(
                      "Info",
                      "Fitur 4 akan segera dibuat",
                      backgroundColor: Colors.blueGrey,
                      colorText: Colors.white,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required MaterialColor color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color.shade700),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
