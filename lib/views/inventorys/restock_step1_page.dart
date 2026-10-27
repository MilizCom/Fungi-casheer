import 'package:admin_fungi/views/inventorys/add_mixed_ingredient_sheet.dart';
import 'package:admin_fungi/views/inventorys/restock_step2_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/ingredient_controller.dart';
import '../../controllers/restock_wizard_controller.dart';

class RestockStep1Page extends StatefulWidget {
  const RestockStep1Page({super.key});

  @override
  State<RestockStep1Page> createState() => _RestockStep1PageState();
}

class _RestockStep1PageState extends State<RestockStep1Page> {
  final IngredientController ingController =
      Get.isRegistered<IngredientController>()
      ? Get.find<IngredientController>()
      : Get.put(IngredientController());

  final RestockWizardController wizardController = Get.put(
    RestockWizardController(),
  );

  final TextEditingController searchC = TextEditingController();
  // 👇 METHOD YANG DIPERBARUI
  void _showAddMixedIngredientForm(BuildContext context) {
    AddMixedIngredientSheet.show(); // Memanggil file baru yang kita buat!
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pilih Bahan (Langkah 1/2)",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            Text(
              "Centang bahan yang baru dibeli",
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          // ==========================================
          // 1. HEADER (SEARCH & TOMBOL BAHAN BARU)
          // ==========================================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                // 👇 PERBAIKAN: Dua Tombol Bersebelahan
                Row(
                  children: [
                    // Tombol 1: Bahan Baku Biasa (Biru)
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.blue.shade600,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.blue.shade50,
                          ),
                          icon: Icon(
                            Icons.add_box_rounded,
                            color: Colors.blue[700],
                            size: 18,
                          ),
                          label: Text(
                            "Bahan Baku",
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          onPressed: () => _showAddIngredientForm(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Tombol 2: Bahan Campuran (Ungu)
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.purple.shade600,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.purple.shade50,
                          ),
                          icon: Icon(
                            Icons.blender_rounded,
                            color: Colors.purple[700],
                            size: 18,
                          ),
                          label: Text(
                            "Campuran",
                            style: TextStyle(
                              color: Colors.purple[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          onPressed: () => _showAddMixedIngredientForm(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Search Bar
                TextField(
                  controller: searchC,
                  onChanged: (val) => wizardController.searchQuery.value = val,
                  decoration: InputDecoration(
                    hintText: "Cari bahan untuk dicentang...",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.blueGrey[300],
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ==========================================
          // 2. LIST BAHAN BAKU DENGAN CHECKBOX
          // ==========================================
          // ==========================================
          // 2. LIST BAHAN BAKU DENGAN CHECKBOX
          // ==========================================
          Expanded(
            child: Obx(() {
              if (ingController.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: Colors.green[700]),
                );
              }

              // 👇 PERBAIKAN LOGIKA:
              // Sembunyikan bahan campuran dari daftar kulakan/restock
              var list = ingController.ingredients.where((ing) {
                bool matchName = ing.name.toLowerCase().contains(
                  wizardController.searchQuery.value.toLowerCase(),
                );
                bool isNotMixed =
                    ing.isMixed == false; // <--- HANYA BAHAN MENTAH

                return matchName && isNotMixed;
              }).toList();

              if (list.isEmpty) {
                return Center(
                  child: Text(
                    wizardController.searchQuery.value.isEmpty
                        ? "Belum ada bahan baku mentah."
                        : "Bahan tidak ditemukan.",
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                );
              }

              return ListView.separated(
                // ... (lanjutan kode ListView Anda tetap sama) ...
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                itemCount: list.length,
                separatorBuilder: (c, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  var ing = list[index];

                  return Obx(() {
                    bool isChecked = wizardController.isSelected(ing);

                    return InkWell(
                      onTap: () => wizardController.toggleSelection(ing),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isChecked
                              ? Colors.green.shade50
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isChecked
                                ? Colors.green.shade500
                                : Colors.grey.shade200,
                            width: isChecked ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isChecked,
                              activeColor: Colors.green[700],
                              checkColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (val) =>
                                  wizardController.toggleSelection(ing),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          ing.name,
                                          style: TextStyle(
                                            fontWeight: isChecked
                                                ? FontWeight.w800
                                                : FontWeight.w600,
                                            fontSize: 15,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      // Menampilkan label kecil jika bahan tersebut adalah bahan campuran
                                      if (ing.isMixed == true)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.purple.shade100,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            "Campuran",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.purple.shade800,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  Text(
                                    "Sisa di gudang: ${ing.stock} ${ing.unit}",
                                    style: TextStyle(
                                      color: Colors.blueGrey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              );
            }),
          ),
        ],
      ),

      // ==========================================
      // 3. BOTTOM BAR (TOMBOL LANJUT)
      // ==========================================
      bottomNavigationBar: Obx(() {
        int selectedCount = wizardController.selectedIngredients.length;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SizedBox(
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedCount > 0
                    ? Colors.green[700]
                    : Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              onPressed: selectedCount > 0
                  ? () {
                      Get.to(() => RestockStep2Page());
                    }
                  : null,
              child: Text(
                selectedCount > 0
                    ? "LANJUT ISI STOK ($selectedCount BAHAN)"
                    : "PILIH MINIMAL 1 BAHAN",
                style: TextStyle(
                  color: selectedCount > 0 ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _showAddIngredientForm(BuildContext context) {
    final nameC = TextEditingController();
    final minStockC = TextEditingController(text: '10');
    final minBarStockC = TextEditingController(text: '5'); // Controller Baru
    String selectedUnit = 'gr';
    bool isOptional = false; // State untuk checkbox/switch baru

    final List<String> unitOptions = [
      'gr',
      'ml',
      'pcs',
      'pack',
      'kg',
      'liter',
      'butir',
      'siung',
    ];

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
        child: StatefulBuilder(
          // Menggunakan StatefulBuilder agar switch bisa di-klik
          builder: (context, setModalState) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "BAHAN BAKU BARU",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.blueGrey[800],
                          letterSpacing: 1.0,
                        ),
                      ),
                      InkWell(
                        onTap: () => Get.back(),
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
                      labelText: "Nama Bahan",
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: selectedUnit,
                    items: unitOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) =>
                        setModalState(() => selectedUnit = val!),
                    decoration: InputDecoration(
                      labelText: "Satuan (Unit)",
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minStockC,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Min. Gudang",
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: minBarStockC,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Min. Stok Bar",
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Fitur Opsional Stok
                  Container(
                    decoration: BoxDecoration(
                      color: isOptional
                          ? Colors.green.shade50
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isOptional
                            ? Colors.green.shade200
                            : Colors.transparent,
                      ),
                    ),
                    child: SwitchListTile(
                      title: Text(
                        "Bahan Opsional",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isOptional
                              ? Colors.green[800]
                              : Colors.black87,
                        ),
                      ),
                      subtitle: const Text(
                        "Pilih jika bahan ini tidak diwajibkan selalu ada di Bar.",
                        style: TextStyle(fontSize: 11),
                      ),
                      activeColor: Colors.green[700],
                      value: isOptional,
                      onChanged: (val) {
                        setModalState(() {
                          isOptional = val;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (nameC.text.isEmpty) return;
                        ingController.saveIngredient(
                          id: null,
                          name: nameC.text,
                          unit: selectedUnit,
                          stock: 0,
                          minStock: int.tryParse(minStockC.text) ?? 10,
                          minBarStock: int.tryParse(minBarStockC.text) ?? 5,
                          optionalStock: isOptional,
                        );
                        Get.back();
                        Get.snackbar(
                          "Sukses",
                          "${nameC.text} berhasil dibuat. Silakan centang bahan tersebut untuk mengisi stoknya.",
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      },
                      child: const Text(
                        "SIMPAN BAHAN",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      isScrollControlled: true,
    );
  }
}
