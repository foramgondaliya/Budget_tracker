import 'dart:typed_data';
import 'package:animation/Helper/db_helper.dart';
import 'package:animation/model/database_model.dart';
import 'package:animation/model/spending_Model.dart';
import 'package:flutter/material.dart';

class SpendingPage extends StatefulWidget {
  const SpendingPage({super.key});

  @override
  State<SpendingPage> createState() => _SpendingPageState();
}

class _SpendingPageState extends State<SpendingPage> {
  final TextEditingController amountController = TextEditingController();

  String initialType = "expense";
  int? initialIndex;
  int? pk;
  int indexStack = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Spending Component"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IndexedStack(
          index: indexStack,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter Amount",
                  ),
                ),
                const SizedBox(height: 12),
                const Text("Choose Expense/income"),
                RadioListTile(
                  title: const Text("Expense"),
                  value: "expense",
                  groupValue: initialType,
                  onChanged: (val) {
                    setState(() {
                      initialType = val!;
                    });
                  },
                ),
                RadioListTile(
                  title: const Text("Income"),
                  value: "income",
                  groupValue: initialType,
                  onChanged: (val) {
                    setState(() {
                      initialType = val!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                FutureBuilder<List<CategoryModel>>(
                  future: DbHelper.dbHelper.fetchData(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text("ERROR: ${snapshot.error}"),
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasData) {
                      List<CategoryModel>? data = snapshot.data;

                      return (data == null || data.isEmpty)
                          ? const Text("No Data Available...")
                          : Container(
                              height: 400,
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                ),
                                itemCount: data.length,
                                itemBuilder: (context, i) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        initialIndex =
                                            (initialIndex == null) ? i : null;
                                        pk = data[i]
                                            .id; // Set the primary key here
                                      });
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 250,
                                      child: Text(
                                        data[i].name,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: MemoryImage(
                                            data[i].image as Uint8List,
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                        border: (initialIndex == i)
                                            ? Border.all(
                                                color: Colors.red,
                                                width: 5,
                                              )
                                            : Border.all(
                                                color: Colors.transparent),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                    } else {
                      return const Text("No Data Available...");
                    }
                  },
                ),
                const SizedBox(
                  height: 3,
                ),
                OutlinedButton.icon(
                  label: const Text("Add Amount"),
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    double amount = double.parse(amountController.text);

                    if (pk == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select a category first"),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      SpendingModel spendingModel = SpendingModel(
                        spending_amount: amount,
                        spending_type: initialType,
                        spending_category: pk!,
                      );
                      int res = await DbHelper.dbHelper
                          .insertSpending(spending: spendingModel);

                      if (res >= 1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Spending added successfully..."),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        amountController.clear();
                        initialIndex = null;
                        pk = null;
                        initialType = "expense";
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Spending insertion failed..."),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
            FutureBuilder(
              future: DbHelper.dbHelper.fetchAllSpending(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("ERROR : ${snapshot.error}"),
                  );
                } else if (snapshot.hasData) {
                  List<SpendingModel>? data = snapshot.data;

                  return (data == null || data.isEmpty)
                      ? const Center(child: Text("No data added yet..."))
                      : ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, i) {
                            return ListTile(
                              leading: FutureBuilder<CategoryModel?>(
                                future: DbHelper.dbHelper.findCategory(
                                    id: data[i].spending_category),
                                builder: (context, ss) {
                                  if (ss.hasError) {
                                    return Center(
                                      child: Text("ERROR: ${ss.error}"),
                                    );
                                  } else if (ss.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (ss.hasData) {
                                    CategoryModel? category = ss.data;
                                    return (category == null)
                                        ? CircleAvatar(
                                            radius: 30,
                                            child: Text("N/A"),
                                          )
                                        : CircleAvatar(
                                            radius: 30,
                                            backgroundImage: MemoryImage(
                                                category.image as Uint8List),
                                          );
                                  }
                                  return CircleAvatar(
                                    radius: 30,
                                    child: Text("N/A"),
                                  );
                                },
                              ),
                              title: Text(
                                "${data[i].spending_amount}",
                              ),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${data[i].spending_type}",
                                    style: TextStyle(
                                      color: (data[i].spending_type == "income")
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                  FutureBuilder<CategoryModel?>(
                                    future: DbHelper.dbHelper.findCategory(
                                        id: data[i].spending_category),
                                    builder: (context, ss) {
                                      if (ss.hasError) {
                                        return Center(
                                          child: Text("ERROR: ${ss.error}"),
                                        );
                                      } else if (ss.connectionState ==
                                          ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      } else if (ss.hasData) {
                                        CategoryModel? category = ss.data;
                                        return (category == null)
                                            ? Chip(
                                                label: Text("Unknown"),
                                              )
                                            : Chip(
                                                label: Text(category.name),
                                              );
                                      }
                                      return Chip(
                                        label: Text("Unknown"),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      await UpdatedBottomSheet(
                                          context, data[i]);
                                    },
                                    icon: const Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: Colors.green,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      bool? confirmDelete = await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title:
                                                const Text("Delete Spending"),
                                            content: const Text(
                                                "Are you sure you want to delete this spending?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(false);
                                                },
                                                child: const Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(true);
                                                },
                                                child: const Text("Delete"),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (confirmDelete == true) {
                                        int res = await DbHelper.dbHelper
                                            .deleteSpending(
                                                spending_id:
                                                    data[i].spending_id!);
                                        if (res == 1) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Spending deleted successfully"),
                                              backgroundColor: Colors.green,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                          setState(
                                              () {}); // Refresh the UI after deletion
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Failed to delete spending"),
                                              backgroundColor: Colors.red,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
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
                    "Spending",
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
                    "Spending View",
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

  Future<void> UpdatedBottomSheet(
      BuildContext context, SpendingModel spending) async {
    TextEditingController amountController =
        TextEditingController(text: spending.spending_amount.toString());
    String selectedType = spending.spending_type!;
    int selectedCategory = spending.spending_category;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Wrap(
                children: [
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: "Amount"),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text("Type: "),
                      SizedBox(height: 20),
                      Radio<String>(
                        value: "income",
                        groupValue: selectedType,
                        onChanged: (value) {
                          setState(() {
                            selectedType = value!;
                          });
                        },
                      ),
                      const Text("Income"),
                      Radio<String>(
                        value: "expense",
                        groupValue: selectedType,
                        onChanged: (value) {
                          setState(() {
                            selectedType = value!;
                          });
                        },
                      ),
                      const Text("Expense"),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FutureBuilder<List<CategoryModel>>(
                    future: DbHelper.dbHelper.fetchData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text("Error loading categories"),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text("No categories available"),
                        );
                      }

                      List<CategoryModel> categories = snapshot.data!;
                      return DropdownButtonFormField<int>(
                        value: selectedCategory,
                        decoration:
                            const InputDecoration(labelText: "Category"),
                        items: categories.map((category) {
                          return DropdownMenuItem<int>(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      spending.spending_amount =
                          double.tryParse(amountController.text) ??
                              spending.spending_amount;
                      spending.spending_type = selectedType;
                      spending.spending_category = selectedCategory;

                      await DbHelper.dbHelper
                          .updateSpendingData(model: spending);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Spending updated successfully"),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                    child: const Text("Save"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    setState(() {});
  }
}
