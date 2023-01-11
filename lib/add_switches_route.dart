import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:mechanical_switch_app/sql_database.dart';
import 'package:mechanical_switch_app/attribute_chips.dart';

class AddSwitch extends StatelessWidget {
  const AddSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    String searchTerms = '';

    return ChangeNotifierProvider<AddSwitchesListNotifier>(
      create: (_) => AddSwitchesListNotifier(),
      child: Consumer<AddSwitchesListNotifier>(
        builder: (_, addSwitchesListNotifier, __) {
          return Scaffold(
            appBar: AppBar(
              title: TextField(
                autofocus: true,
                cursorColor: Colors.white,
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search_outlined, color: Colors.white),
                  hintText: 'Search for switches',
                  hintStyle: TextStyle(
                    fontSize: 20,
                    color: Colors.white60,
                  ),
                ),
                onSubmitted: (String value) {
                  searchTerms = value;
                  addSwitchesListNotifier.doSearch();
                },
              ),
            ),
            body: Column(
              children: <Widget>[
                AttributeChips(
                  searchOrFilterNotifier: addSwitchesListNotifier,
                  searchOrFilter: "search",
                ),
                const Divider(
                  thickness: 2,
                  height: 2,
                ),
                Expanded(
                  child: AddSwitchesList(searchTerms),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AddSwitchesList extends StatelessWidget {
  final String searchTerms;
  const AddSwitchesList(this.searchTerms, {super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: SqlDatabase().getSwitchList(searchTerms),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            return ListView.separated(
              itemCount: snapshot.data!.length,
              itemBuilder: (_, int index) {
                return ChangeNotifierProvider<CheckBoxSaved>(
                  create: (_) => CheckBoxSaved(),
                  child: Consumer<CheckBoxSaved>(
                    builder: (_, checkBoxSaved, __) {
                      return CheckboxListTile(
                        key: ValueKey(snapshot.data![index]['id']),
                        title: AutoSizeText(
                          snapshot.data![index]['name'],
                          style: const TextStyle(fontSize: 17),
                          maxLines: 1,
                        ),
                        subtitle: const AttributeChips()
                            .getAttributeChips(snapshot.data![index]),
                        controlAffinity: ListTileControlAffinity.trailing,
                        contentPadding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
                        value: checkBoxSaved
                            .getCheckboxValue(snapshot.data![index]['id']),
                        onChanged: (bool? value) {
                          if (value == false) {
                            checkBoxSaved
                                .removeSwitchID(snapshot.data![index]['id']);
                          } else {
                            checkBoxSaved
                                .addSwitchID(snapshot.data![index]['id']);
                          }
                        },
                        activeColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                      );
                    },
                  ),
                );
              },
              separatorBuilder: (_, __) {
                return const Divider(
                  height: 1,
                );
              },
            );
          } else {
            return const Center(
              child: Text(
                'No switches found\n\n: (',
                style: TextStyle(
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class AddSwitchesListNotifier with ChangeNotifier {
  void doSearch() {
    notifyListeners();
  }
}

class CheckBoxSaved with ChangeNotifier {
  var box = Hive.box('saved');

  bool getCheckboxValue(String id) {
    List tempList = box.get('savedSwitches', defaultValue: []);
    return tempList.contains(id);
  }

  void addSwitchID(String id) {
    List tempList = box.get('savedSwitches', defaultValue: []);
    tempList.add(id);
    box.put('savedSwitches', tempList);
    notifyListeners();
  }

  void removeSwitchID(String id) {
    List tempList = box.get('savedSwitches', defaultValue: []);
    tempList.remove(id);
    box.put('savedSwitches', tempList);
    notifyListeners();
  }
}
