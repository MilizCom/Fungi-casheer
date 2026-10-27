import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_menu_controller.dart';
import '../../models/admin_product_model.dart';
import 'recipe_editor_dialog.dart';
import 'step1_basic_info_page.dart'; // Import halaman Wizard Langkah 1

class ManageMenuPage extends StatefulWidget {
  const ManageMenuPage({super.key});

  @override
  State<ManageMenuPage> createState() => _ManageMenuPageState();
}

class _ManageMenuPageState extends State<ManageMenuPage> {
  final AdminMenuController controller = Get.put(AdminMenuController());

  // State Lokal untuk Pencarian & Filter
  final TextEditingController searchC = TextEditingController();
  String selectedCategory = "Semua";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Kelola Menu & Resep",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black12,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),

      // ==========================================================
      // TOMBOL MENU BARU (MENGARAH KE WIZARD LANGKAH 1)
      // ==========================================================
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green[700],
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          "Menu Baru",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        onPressed: () {
          // Buka alur pembuatan produk baru yang terpisah (Modular)
          Get.to(() => Step1BasicInfoPage());
        },
      ),

      body: Column(
        children: [
          // --- 1. SEARCH & FILTER SECTION ---
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: searchC,
                  onChanged: (val) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: "Cari menu (Nasi, Kopi, dll)...",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.blueGrey[400],
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.green.shade600,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Kategori Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildCategoryChip("Semua"),
                      const SizedBox(width: 8),
                      _buildCategoryChip("Makanan"),
                      const SizedBox(width: 8),
                      _buildCategoryChip("Minuman"),
                      const SizedBox(width: 8),
                      _buildCategoryChip("Snack"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- 2. LIST MENU ---
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: Colors.green[700]),
                );
              }

              // LOGIKA FILTER
              var filteredList = controller.products.where((p) {
                bool matchName = p.name.toLowerCase().contains(
                  searchC.text.toLowerCase(),
                );
                bool matchCat =
                    selectedCategory == "Semua" ||
                    p.category.toLowerCase() == selectedCategory.toLowerCase();
                return matchName && matchCat;
              }).toList();

              if (filteredList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fastfood_outlined,
                        size: 60,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Menu tidak ditemukan.",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: filteredList.length,
                separatorBuilder: (c, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildProductTile(context, filteredList[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    bool isSelected = selectedCategory == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) => setState(() => selectedCategory = label),
      selectedColor: Colors.green.shade50,
      labelStyle: TextStyle(
        color: isSelected ? Colors.green[800] : Colors.blueGrey[600],
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
      ),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? Colors.green.shade600 : Colors.grey.shade300,
        width: isSelected ? 1.5 : 1.0,
      ),
      elevation: 0,
      pressElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildProductTile(BuildContext context, AdminProductModel product) {
    bool hasDefaultRecipe = product.recipe.isNotEmpty;
    bool hasVariantRecipe = product.variantRecipes.values.any(
      (list) => list.isNotEmpty,
    );
    bool hasRecipe = hasDefaultRecipe || hasVariantRecipe;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Produk
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              product.category == 'Minuman'
                  ? Icons.local_cafe_rounded
                  : Icons.restaurant_rounded,
              color: Colors.blueGrey[600],
            ),
          ),
          const SizedBox(width: 16),

          // Info Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Rp ${product.price}",
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),

                // Badge Indikator Resep
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: hasRecipe
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: hasRecipe
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasRecipe
                            ? Icons.check_circle_rounded
                            : Icons.warning_rounded,
                        size: 12,
                        color: hasRecipe ? Colors.green[600] : Colors.red[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hasRecipe ? "Resep Aktif" : "Tanpa Resep",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: hasRecipe
                              ? Colors.green[700]
                              : Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tombol Edit
          IconButton(
            icon: Icon(
              Icons.edit_note_rounded,
              color: Colors.blue[700],
              size: 28,
            ),
            onPressed: () => _showEditProductForm(context, product),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FORM EDIT PRODUK EKSISTING
  // ==========================================================
  void _showEditProductForm(BuildContext context, AdminProductModel product) {
    final nameC = TextEditingController(text: product.name);
    final priceC = TextEditingController(text: product.price.toString());
    final categoryC = TextEditingController(text: product.category);

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Form
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "EDIT PRODUK",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.blueGrey[800],
                      letterSpacing: 1.0,
                    ),
                  ),
                  InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              TextField(
                controller: nameC,
                decoration: InputDecoration(
                  labelText: "Nama Produk",
                  labelStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.green.shade600,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: priceC,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Harga Dasar (Rp)",
                  labelStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.green.shade600,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: categoryC,
                decoration: InputDecoration(
                  labelText: "Kategori (Makanan/Minuman)",
                  labelStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.green.shade600,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // TOMBOL ATUR RESEP
              InkWell(
                onTap: () {
                  Get.back(); // Tutup form edit
                  Get.to(() => RecipeEditorDialog(product: product));
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.science_rounded,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Atur Resep & Komposisi",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.blue[800],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Hubungkan dengan stok bahan baku",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blueGrey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.blue[400],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Tombol Hapus
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Get.defaultDialog(
                      title: "Hapus Menu?",
                      titleStyle: const TextStyle(fontWeight: FontWeight.w800),
                      middleText: "Menu ini akan dihapus permanen.",
                      textConfirm: "Hapus",
                      confirmTextColor: Colors.white,
                      buttonColor: Colors.red[700],
                      cancelTextColor: Colors.grey[600],
                      textCancel: "Batal",
                      onConfirm: () {
                        controller.deleteProduct(product.id);
                        Get.back(); // Dialog
                        Get.back(); // Sheet
                      },
                    );
                  },
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red[700],
                  ),
                  label: Text(
                    "Hapus Menu Ini",
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    controller.updateProduct(
                      product.id,
                      nameC.text,
                      int.tryParse(priceC.text) ?? 0,
                      categoryC.text,
                    );
                  },
                  child: const Text(
                    "SIMPAN PERUBAHAN",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
