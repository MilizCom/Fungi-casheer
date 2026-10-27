import 'package:admin_fungi/controllers/add_product_wizard_controller.dart';
import 'package:admin_fungi/views/products/manage_category_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'step2_recipe_page.dart';

class Step1BasicInfoPage extends StatelessWidget {
  Step1BasicInfoPage({super.key});

  final AddProductWizardController controller = Get.put(
    AddProductWizardController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Buat Menu (Langkah 1/2)",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("INFORMASI DASAR"),
            _buildCard(
              child: Column(
                children: [
                  _buildTextField(
                    controller.nameC,
                    "Nama Produk",
                    Icons.fastfood_outlined,
                  ),
                  const SizedBox(height: 16),

                  // --- DROPDOWN KATEGORI UTAMA WITH SHORTCUT BUTTON ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Obx(
                          () => DropdownButtonFormField<String>(
                            value: controller.selectedCategory.value,
                            decoration: InputDecoration(
                              labelText: "Kategori Utama",
                              prefixIcon: Icon(
                                Icons.folder_copy_outlined,
                                color: Colors.blueGrey[300],
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: controller.categoryController.categories.map(
                              (cat) {
                                return DropdownMenuItem(
                                  value: cat.name,
                                  child: Text(cat.name),
                                );
                              },
                            ).toList(),
                            onChanged: controller.onCategoryChanged,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 👇 TOMBOL PINTASAN KE HALAMAN MANAGE CATEGORY 👇
                      Container(
                        height: 54,
                        width: 54,
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade100),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.settings_suggest_rounded,
                            color: Colors.orange[800],
                          ),
                          tooltip: "Kelola Kategori",
                          onPressed: () {
                            // Impor file manage_category_page.dart jika diperlukan di atas
                            Get.to(() => ManageCategoryPage());
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- DROPDOWN SUB KATEGORI ---
                  Obx(() {
                    if (controller.selectedCategory.value == null)
                      return const SizedBox.shrink();

                    var selectedCatData = controller
                        .categoryController
                        .categories
                        .firstWhereOrNull(
                          (c) => c.name == controller.selectedCategory.value,
                        );
                    List<String> subs = selectedCatData?.subCategories ?? [];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: DropdownButtonFormField<String>(
                        value: controller.selectedSubCategory.value,
                        decoration: InputDecoration(
                          labelText: "Sub Kategori",
                          prefixIcon: Icon(
                            Icons.subdirectory_arrow_right_rounded,
                            color: Colors.blueGrey[300],
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: subs.map((sub) {
                          return DropdownMenuItem(value: sub, child: Text(sub));
                        }).toList(),
                        onChanged: (val) =>
                            controller.selectedSubCategory.value = val,
                      ),
                    );
                  }),

                  Obx(
                    () => controller.hasVariants.value
                        ? const SizedBox.shrink()
                        : _buildTextField(
                            controller.priceC,
                            "Harga Jual (Rp)",
                            Icons.payments_outlined,
                            isNumber: true,
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle("PENGATURAN VARIAN"),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => SwitchListTile(
                      title: const Text(
                        "Produk ini memiliki varian?",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        "Contoh: Panas, Dingin, Ukuran Besar.",
                        style: TextStyle(fontSize: 12),
                      ),
                      activeColor: Colors.green[700],
                      value: controller.hasVariants.value,
                      onChanged: (val) => controller.hasVariants.value = val,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),

                  Obx(() {
                    if (!controller.hasVariants.value)
                      return const SizedBox.shrink();
                    return Column(
                      children: [
                        const Divider(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller.varNameC,
                                "Nama Varian (H, I, L)",
                                null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(
                                controller.varPriceC,
                                "Harga",
                                null,
                                isNumber: true,
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              onPressed: controller.addVariant,
                              icon: Icon(
                                Icons.add_circle_rounded,
                                color: Colors.green[700],
                                size: 36,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...controller.variantPrices.entries
                            .map(
                              (e) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  "Varian ${e.key}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text("Rp ${e.value}"),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      controller.removeVariant(e.key),
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        color: Colors.white,
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              if (controller.nameC.text.isEmpty ||
                  controller.selectedCategory.value == null ||
                  controller.selectedSubCategory.value == null) {
                Get.snackbar(
                  "Oops",
                  "Nama produk, kategori, dan sub-kategori wajib diisi!",
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
                return;
              }
              controller.prepareRecipeStep();
              Get.to(() => Step2RecipePage());
            },
            child: const Text(
              "LANJUT KE RESEP",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.blueGrey[400],
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData? icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null
            ? Icon(icon, color: Colors.blueGrey[300])
            : null,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade600, width: 1.5),
        ),
      ),
    );
  }
}
