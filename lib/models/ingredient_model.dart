import 'package:cloud_firestore/cloud_firestore.dart';

class IngredientModel {
  final String id;
  final String name;
  final String unit;
  final int stock;
  final int barStock;
  final int minStock;
  final int unitPrice;

  // --- VARIABEL STOK & OPSIONAL ---
  final int minBarStock;
  final bool optionalStock;

  // 👇 --- VARIABEL BARU UNTUK BAHAN CAMPURAN ---
  final bool isMixed;
  final List<Map<String, dynamic>> composition;

  IngredientModel({
    required this.id,
    required this.name,
    required this.unit,
    required this.stock,
    this.barStock = 0,
    required this.minStock,
    this.unitPrice = 0,
    this.minBarStock = 10,
    this.optionalStock = false,

    // Default untuk bahan baku reguler
    this.isMixed = false,
    this.composition = const [],
  });

  factory IngredientModel.fromFirestore(
    Map<String, dynamic> data,
    String docId,
  ) {
    return IngredientModel(
      id: docId,
      name: data['name'] ?? 'Bahan',
      unit: data['unit'] ?? 'pcs',
      barStock: (data['bar_stock'] as num?)?.toInt() ?? 0,
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      minStock: (data['min_stock'] as num?)?.toInt() ?? 10,
      unitPrice: (data['unit_price'] as num?)?.toInt() ?? 0,

      // --- BACA DARI FIREBASE ---
      minBarStock: (data['min_bar_stock'] as num?)?.toInt() ?? 10,
      optionalStock: data['optional_stock'] ?? false,

      // 👇 --- BACA DATA BAHAN CAMPURAN ---
      isMixed: data['is_mixed'] ?? false,
      composition: data['composition'] != null
          ? List<Map<String, dynamic>>.from(data['composition'])
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'unit': unit,
      'stock': stock,
      'min_stock': minStock,
      'bar_stock': barStock,
      'unit_price': unitPrice,

      // --- SIMPAN KE FIREBASE ---
      'min_bar_stock': minBarStock,
      'optional_stock': optionalStock,

      // 👇 --- SIMPAN DATA BAHAN CAMPURAN ---
      'is_mixed': isMixed,
      'composition': composition,

      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  IngredientModel copyWith({
    String? id,
    String? name,
    String? unit,
    int? stock,
    int? barStock,
    int? minStock,
    int? unitPrice,
    int? minBarStock,
    bool? optionalStock,
    bool? isMixed,
    List<Map<String, dynamic>>? composition,
  }) {
    return IngredientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      stock: stock ?? this.stock,
      barStock: barStock ?? this.barStock,
      minStock: minStock ?? this.minStock,
      unitPrice: unitPrice ?? this.unitPrice,
      minBarStock: minBarStock ?? this.minBarStock,
      optionalStock: optionalStock ?? this.optionalStock,
      isMixed: isMixed ?? this.isMixed,
      composition: composition ?? this.composition,
    );
  }
}
