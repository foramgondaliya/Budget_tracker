import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../Helper/db_helper.dart';
import '../model/database_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    DbHelper.dbHelper.initializeDatabase();
  }

  final TextEditingController categoryNameController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  ImagePicker imagePicker = ImagePicker();
  Uint8List? image;
  Future<List<CategoryModel>> fatchData = DbHelper.dbHelper.fetchData();

  fetchNewData() {
    fatchData = DbHelper.dbHelper.fetchData();
    setState(() {});
  }

  int indexStack = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text("HomePage2"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('SpendingPage');
            },
            icon: Icon(
              Icons.money,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: IndexedStack(
                index: indexStack,
                children: [
                  Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        height: MediaQuery.of(context).size.height / 4,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.deepPurple),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  (image == null) ? null : MemoryImage(image!),
                              child: IconButton(
                                onPressed: () async {
                                  XFile? file = await imagePicker.pickImage(
                                      source: ImageSource.camera);
                                  image = await file!.readAsBytes();
                                  setState(() {});
                                },
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Add Image",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Enter category name",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: categoryNameController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter category name';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 10),
                                border: OutlineInputBorder(),
                                labelText: "Enter Category Name..",
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    if (formKey.currentState!.validate()) {
                                      CategoryModel model = CategoryModel(
                                        name: categoryNameController.text,
                                        image: image,
                                      );
                                      int id = await DbHelper.dbHelper
                                          .insertData(model: model);

                                      if (id >= 1) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Category Inserted Successfully...",
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Category Insertion failed...",
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                      fetchNewData();
                                      categoryNameController.clear();
                                      image = null;
                                      setState(() {});
                                    }
                                  },
                                  label: const Text("Save"),
                                  icon: const Icon(Icons.save),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    categoryNameController.clear();
                                    image = null;
                                    setState(() {});
                                  },
                                  label: const Text("Cancel"),
                                  icon: const Icon(Icons.cancel),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height / 1.24,
                      child: Column(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (val) {
                                setState(() {
                                  fatchData = DbHelper.dbHelper
                                      .searchCategory(data: val);
                                });
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 8,
                            child: FutureBuilder(
                              future: fatchData,
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text("ERROR: ${snapshot.error}"),
                                  );
                                } else if (snapshot.hasData) {
                                  var data = snapshot.data;
                                  return (data!.isEmpty)
                                      ? const Center(
                                          child: Text("No Data available..."),
                                        )
                                      : ListView.builder(
                                          itemCount: data.length,
                                          itemBuilder: (context, index) {
                                            return Card(
                                              elevation: 4,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              child: ListTile(
                                                leading: CircleAvatar(
                                                  backgroundImage: (data[index]
                                                              .image !=
                                                          null)
                                                      ? MemoryImage(
                                                          data[index].image!,
                                                        )
                                                      : null,
                                                ),
                                                title: Text(
                                                  data[index].name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                trailing: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        TextEditingController
                                                            controller =
                                                            TextEditingController();
                                                        controller.text =
                                                            data[index].name;

                                                        Uint8List?
                                                            updatedImage =
                                                            data[index].image;

                                                        showModalBottomSheet(
                                                          context: context,
                                                          builder: (context) {
                                                            return Container(
                                                              alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(12),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  const Text(
                                                                    "Enter Category name",
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          12),
                                                                  TextField(
                                                                    controller:
                                                                        controller,
                                                                    decoration:
                                                                        const InputDecoration(
                                                                      border:
                                                                          OutlineInputBorder(),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          12),
                                                                  GestureDetector(
                                                                    onTap:
                                                                        () async {
                                                                      XFile?
                                                                          file =
                                                                          await imagePicker.pickImage(
                                                                              source: ImageSource.camera);
                                                                      updatedImage =
                                                                          await file!
                                                                              .readAsBytes();
                                                                      setState(
                                                                          () {});
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          150,
                                                                      width:
                                                                          150,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              Colors.grey,
                                                                        ),
                                                                      ),
                                                                      child: (updatedImage ==
                                                                              null)
                                                                          ? Center(
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: const [
                                                                                  Icon(Icons.add_a_photo),
                                                                                  Text("Add Image"),
                                                                                ],
                                                                              ),
                                                                            )
                                                                          : Image
                                                                              .memory(
                                                                              fit: BoxFit.cover,
                                                                              updatedImage!,
                                                                            ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          12),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      ElevatedButton
                                                                          .icon(
                                                                        label: const Text(
                                                                            "Save"),
                                                                        onPressed:
                                                                            () {
                                                                          DbHelper
                                                                              .dbHelper
                                                                              .updateData(
                                                                            model:
                                                                                CategoryModel(
                                                                              name: controller.text,
                                                                              image: updatedImage ?? data[index].image,
                                                                              id: data[index].id,
                                                                            ),
                                                                          );
                                                                          fetchNewData();
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        icon: const Icon(
                                                                            Icons.save),
                                                                      ),
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                      icon: const Icon(
                                                        Icons.edit,
                                                        size: 18,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                "Are You Sure you want to delete category",
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    "No",
                                                                  ),
                                                                ),
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    DbHelper
                                                                        .dbHelper
                                                                        .deleteData(
                                                                            id: data[index].id!);
                                                                    fetchNewData();
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    "Yes",
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        size: 18,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                }
                                return const Center(
                                  child: CircularProgressIndicator.adaptive(),
                                );
                              },
                            ),
                          )
                        ],
                      )),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 100,
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    indexStack = 0;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: indexStack == 0 ? Colors.black : Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Insert Page",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    indexStack = 1;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: indexStack == 1 ? Colors.black : Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Detail screen",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
