import 'package:animation/Helper/db_helper.dart';
import 'package:animation/model/spending_Model.dart';
import 'package:flutter/material.dart';

class ViewSpendingComponent extends StatefulWidget {
  const ViewSpendingComponent({super.key});

  @override
  State<ViewSpendingComponent> createState() => _ViewSpendingComponentState();
}

class _ViewSpendingComponentState extends State<ViewSpendingComponent> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DbHelper.dbHelper.fetchAllSpending(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("ERROR : ${snapshot.error}"),
          );
        } else if (snapshot.hasData) {
          List<SpendingModel>? data = snapshot.data;

          return (data == null || data.isEmpty)
              ? Center(child: Text("No data added yet..."))
              : ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text("${data[i].spending_category}"),
                      ),
                      title: Text(
                        "${data[i].spending_amount}",
                      ),
                      subtitle: Text(
                        "${data[i].spending_type}",
                      ),
                      trailing: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
