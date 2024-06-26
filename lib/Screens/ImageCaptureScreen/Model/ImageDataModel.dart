import 'package:hive/hive.dart';

import '../../../global.dart';

@HiveType(typeId: image_model_type_id)
class ImageDataModel{

  @HiveField(0)
  String imagePath;
  @HiveField(1)
  String doctorName;
  @HiveField(2)
  int employeeId;

  ImageDataModel({
    required this.imagePath,
    required this.doctorName,
    required this.employeeId
  });

  @override
  String toString() {
    return 'ImageDataModel('
        'imagePath: $imagePath,'
        'doctorName: $doctorName'
        'employeeId: $employeeId'
        ')';
  }
}