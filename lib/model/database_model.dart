// // ignore_for_file: non_constant_identifier_names
//
// import 'dart:typed_data';
//
// class DatabaseModel {
//   final int? id;
//   final String category_name;
//   final Uint8List? category_image;
//
//   DatabaseModel({
//     this.id,
//     required this.category_name,
//     required this.category_image,
//   });
//
//   factory DatabaseModel.fromMap({required Map<String, dynamic> data}) {
//     return DatabaseModel(
//       id: data['']
//       id: model.id,
//       category_name: model.category_name,
//       category_image: model.category_image,
//     );
//   }
// }
import 'dart:typed_data';

class CategoryModel {
  int? id;
  String name;
  Uint8List? image;

  CategoryModel({required this.name, this.image, this.id});

  factory CategoryModel.fromMap({required Map<String, dynamic> data}) {
    return CategoryModel(
      id: data['category_id'],
      name: data['category_name'],
      image: data['category_image'],
    );
  }
}
