import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../../Components/Components.dart';
import '../../LocalDB/DatabaseHelper.dart';
import '../../global.dart';
import '../ImageCaptureScreen/Model/ImageDataModel.dart';

class ImageArchive extends StatefulWidget {
  const ImageArchive({super.key});

  @override
  State<StatefulWidget> createState() => _ImageArchiveState();
}

class _ImageArchiveState extends State<ImageArchive> {
  Future<List<ImageDataModel>>? imageDataList;
  bool isImageDataListIsNotEmpty = true;
  File? _image;
  final imageHiveBox = HiveBoxHelper<ImageDataModel>('image_db');
  final ValueNotifier<bool> enableUploadButtons = ValueNotifier(true);


  @override
  void initState() {
    setState(() {
      imageDataList = imageHiveBox.getAll();
      imageDataList?.then((value) {
        setState(() {
          isImageDataListIsNotEmpty = value.isNotEmpty;
        });
        print("initState imageDataList : $value");
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: MyTextView("Image Archive", 16, FontWeight.bold, Colors.black, TextAlign.center),
          backgroundColor: themeColor,
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Visibility(
                  visible: true,
                  child: Center(
                    child: MyTextView("", 14, FontWeight.bold, Colors.black, TextAlign.center),
                  ),
                ),

                Visibility(
                  visible: isImageDataListIsNotEmpty,
                  child: Column(
                    children: [
                      FutureBuilder<List<ImageDataModel>>(
                        future: imageDataList,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final dataList = snapshot.data!;
                            return ListView.builder(
                              primary: false,
                              shrinkWrap: true,
                              itemCount: dataList.length,
                              itemBuilder: (context, index) {
                                final data = dataList[index];
                                return Card(
                                  elevation: 1,
                                  child: ListTile(
                                    title: Text(
                                      "Dr. Name : ${data.doctorName}",
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    leading: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(data.imagePath),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        imageHiveBox.delete(index);
                                        setState(() {
                                          imageDataList = imageHiveBox.getAll();
                                          imageDataList?.then((value) {
                                            setState(() {
                                              isImageDataListIsNotEmpty =
                                                  value.isNotEmpty;
                                            });
                                          });
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateColor.resolveWith(
                                        (states) => states.isEmpty
                                        ? primaryButtonColor
                                        : Colors.black26),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ))),
                            onPressed: () async {
                              enableUploadButtons.value =
                              !enableUploadButtons.value;
                              await sendAllPrescribedProducts();
                              enableUploadButtons.value =
                              !enableUploadButtons.value;
                            },
                            child: (enableUploadButtons.value)
                                ? const Text(
                              'Upload All',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                                : const Text(
                              'Uploading...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  sendAllPrescribedProducts() async {
    imageDataList?.then((value) async {
      int count = 0;
      int pos = 0;
      for (var p in value) {
        var uri =
        Uri.parse('${serverPath}/api/ImageCapture/SubmitImageCapture');
        var request = http.Request('POST', uri);
        var authorizationToken = currentLoginUser.token;
        request.headers['accept'] = '*/*';
        request.headers['Authorization'] = 'Bearer $authorizationToken';
        request.headers['Content-Type'] = 'application/json';

        var bytes = await File(p.imagePath).readAsBytes();
        var base64Image = base64Encode(bytes);
        var data = {
          'doctorName': p.doctorName,
          'employeeId': p.employeeId,
          'base64Image': base64Image,
          // 'prescribedProducts': prescribedProducts.toString(),
        };

        var jsonData = jsonEncode(data);
        request.body = jsonData;

        var response = await request.send();
        if (response.statusCode == 200) {
          imageHiveBox.delete(pos);
          setState(() {
            imageDataList = imageHiveBox.getAll();
            imageDataList?.then((value) {
              setState(() {
                pos--;
                isImageDataListIsNotEmpty = value.isNotEmpty;
              });
            });
          });
          count++;
          print('upload pending: $count');
        } else {
          print('error $count');
        }
        pos++;
      }

      print('count : $count');
      print('list size : ${value.length}');

      if (count == value.length) {
        Fluttertoast.showToast(
            msg: "Successfully Upload All Data",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "Error: ",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    });
  }
}
