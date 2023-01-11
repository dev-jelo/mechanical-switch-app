import 'package:auto_size_text/auto_size_text.dart';
import 'package:drag_and_drop_gridview/devdrag.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:mechanical_switch_app/routes.dart';
import 'package:mechanical_switch_app/settings_drawer.dart';
import 'package:mechanical_switch_app/sql_database.dart';
import 'package:mechanical_switch_app/theme_choose.dart';
import 'package:mechanical_switch_app/attribute_chips.dart';

void main() async {
  // Set up Hive
  await Hive.initFlutter();
  await Hive.openBox('saved');

  // Initialise SQflite database
  await SqlDatabase().initDatabase();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeChoose>(
      create: (_) => ThemeChoose(),
      child: Consumer<ThemeChoose>(
        builder: (_, themeChoose, __) {
          return MaterialApp(
            // ************** remember to remove this later *************//
            debugShowCheckedModeBanner: false,
            // ************** remember to remove this later *************//
            title: 'Mechanical Keyboard Switches',
            theme: themeChoose.getThemeData(),
            initialRoute: '/',
            onGenerateRoute: RouteGenerator.generateRoute,
          );
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var box = Hive.box('saved');
  final ValueNotifier<bool> _filterPressed = ValueNotifier<bool>(false);

  void _update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FilterSwitchesListNotifier>(
      create: (_) => FilterSwitchesListNotifier(),
      child: Consumer<FilterSwitchesListNotifier>(
        builder: (_, filterSwitchesListNotifier, __) {
          return WillPopScope(
            onWillPop: () async {
              if (_filterPressed.value = true) {
                _filterPressed.value = !_filterPressed.value;
                return false;
              } else {
                return true;
              }
            },
            child: Scaffold(
              appBar: AppBar(
                leading: ValueListenableBuilder<bool>(
                  valueListenable: _filterPressed,
                  builder: (BuildContext context, value, _) {
                    return value
                        ? IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
                              _filterPressed.value = !_filterPressed.value;
                            },
                          )
                        : IconButton(
                            icon: const Icon(Icons.settings_outlined),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          );
                  },
                ),
                title: ValueListenableBuilder<bool>(
                    valueListenable: _filterPressed,
                    builder: (context, value, _) {
                      return value
                          ? TextFormField(
                              // autofocus: true,
                              initialValue:
                                  box.get('filterTerms', defaultValue: ''),
                              cursorColor: Colors.white,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Filter...',
                                hintStyle: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white60,
                                ),
                              ),
                              onFieldSubmitted: (String value) {
                                box.put('filterTerms', value);
                                filterSwitchesListNotifier.doFilter();
                              },
                            )
                          : AutoSizeText(
                              filterSwitchesListNotifier.checkIfFiltering()
                                  ? 'Saved Switches (filtered)'
                                  : 'Saved Switches',
                              maxLines: 1,
                              style: const TextStyle(fontSize: 23),
                            );
                    }),
                centerTitle: true,
                actions: [
                  ValueListenableBuilder<bool>(
                      valueListenable: _filterPressed,
                      builder: (context, value, _) {
                        return IconButton(
                          icon: filterSwitchesListNotifier.checkIfFiltering()
                              ? const Icon(Icons.filter_alt)
                              : const Icon(Icons.filter_alt_outlined),
                          onPressed: () {
                            _filterPressed.value = !_filterPressed.value;
                          },
                        );
                      }),
                ],
              ),
              body: Column(
                children: [
                  ValueListenableBuilder<bool>(
                      valueListenable: _filterPressed,
                      builder: (context, value, _) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: value ? 80 : 0,
                          child: Container(
                              decoration: const BoxDecoration(boxShadow: [
                                BoxShadow(
                                  color: Colors.black38,
                                  spreadRadius: 0.4,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ]),
                              child: AttributeChips(
                                searchOrFilterNotifier:
                                    filterSwitchesListNotifier,
                                searchOrFilter: "filter",
                              )),
                        );
                      }),
                  ValueListenableBuilder<bool>(
                      valueListenable: _filterPressed,
                      builder: (context, value, _) {
                        return Divider(
                          thickness: 2,
                          height: value ? 2 : 0,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black26
                              : Colors.grey,
                        );
                      }),
                  Expanded(
                      child: filterSwitchesListNotifier.checkIfFiltering()
                          ? FilteredList()
                          : SwitchesList()),
                ],
              ),
              drawer: SettingsDrawer(_update),
              floatingActionButton: ValueListenableBuilder<bool>(
                valueListenable: _filterPressed,
                builder: (context, value, _) {
                  return value
                      ? const SizedBox.shrink()
                      : FloatingActionButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context)
                                .removeCurrentSnackBar();
                            Navigator.of(context)
                                .pushNamed('/addSwitch')
                                .whenComplete(() => setState(() {}));
                          },
                          child: const Icon(Icons.add_outlined),
                        );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class SwitchesList extends StatelessWidget {
  final box = Hive.box('saved');

  SwitchesList({super.key});

  bool _checkIfEmpty() {
    return box.get('savedSwitches', defaultValue: []).isEmpty;
  }

  String _checkViewChoice() {
    return box.get('viewChoice', defaultValue: 'list');
  }

  @override
  Widget build(BuildContext context) {
    return _checkIfEmpty()
        ? const NoSavedSwitchesScreen()
        : FutureBuilder<List<dynamic>>(
            future: SqlDatabase().getSavedList(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // Copy snapshot data into hive box
                box.put('tempSwitchList', [...?snapshot.data]);
                return ChangeNotifierProvider<SwitchesListTempData>(
                  create: (_) => SwitchesListTempData(),
                  child: Consumer<SwitchesListTempData>(
                    builder: (context, switchesListTempData, __) {
                      switchesListTempData._copyTempData();
                      return switchesListTempData._tempSwitchList!.isEmpty
                          ? const NoSavedSwitchesScreen()
                          : _checkViewChoice() == 'list'
                              ? SwitchesListView(switchesListTempData)
                              : SwitchesGridView(
                                  UniqueKey(), switchesListTempData);
                    },
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          );
  }
}

class SwitchesListView extends StatelessWidget {
  final SwitchesListTempData switchesListTempData;
  const SwitchesListView(this.switchesListTempData, {super.key});

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      onReorder: (int oldIndex, int newIndex) {
        if (newIndex > switchesListTempData._tempSwitchList!.length) {
          newIndex = switchesListTempData._tempSwitchList!.length;
        }
        if (oldIndex < newIndex) newIndex--;

        Map switchMap = switchesListTempData._tempSwitchList![oldIndex];

        switchesListTempData._removeAtIndex(oldIndex);
        switchesListTempData._insertAtIndex(newIndex, switchMap);
        switchesListTempData._reloadWidgets();
      },
      children: <Widget>[
        for (Map i in switchesListTempData._tempSwitchList!)
          Dismissible(
            key: ValueKey(i['id']),
            background: Container(
              color: Colors.red.shade400,
              alignment: AlignmentDirectional.centerStart,
              padding: const EdgeInsets.only(left: 12),
              child: const Icon(Icons.delete),
            ),
            secondaryBackground: Container(
              color: Colors.red.shade400,
              alignment: AlignmentDirectional.centerEnd,
              padding: const EdgeInsets.only(right: 12),
              child: const Icon(Icons.delete),
            ),
            onDismissed: (_) {
              int tempIndex = switchesListTempData._tempSwitchList!
                  .indexWhere((item) => item['id'] == i['id']);
              Map tempSwitch = switchesListTempData._tempSwitchList![tempIndex];
              switchesListTempData._removeWhere(i['id']);
              switchesListTempData._reloadWidgets();

              final snackBar = SnackBar(
                backgroundColor: Colors.grey.shade900,
                content: Text(
                  "Removed ${i['name']}",
                  style: const TextStyle(color: Colors.white),
                ),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () {
                    switchesListTempData._insertAtIndex(tempIndex, tempSwitch);
                    switchesListTempData._reloadWidgets();
                  },
                ),
              );
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white10
                        : Colors.grey.shade300,
                  ),
                ),
              ),
              child: ListTile(
                onTap: () {
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  Navigator.of(context).pushNamed('/switchInfo', arguments: i);
                },
                title: Container(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    i['name'],
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ),
                contentPadding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
                subtitle: const AttributeChips().getAttributeChips(i),
                trailing: ReorderableDragStartListener(
                  index: switchesListTempData._tempSwitchList!
                      .indexWhere((item) => item['id'] == i['id']),
                  child: const Icon(Icons.drag_handle),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class SwitchesGridView extends StatefulWidget {
  final SwitchesListTempData switchesListTempData;
  const SwitchesGridView(Key key, this.switchesListTempData) : super(key: key);

  @override
  State<SwitchesGridView> createState() => _SwitchesGridViewState();
}

class _SwitchesGridViewState extends State<SwitchesGridView> {
  List<dynamic>? _tempSwitchList1;
  List<dynamic>? _tempSwitchList2;

  String? _switchID;
  int? _pos;
  int _variableSet = 0;
  ScrollController? _scrollController;
  double? _width;
  double? _height;

  @override
  void initState() {
    super.initState();
    _tempSwitchList1 = [...widget.switchesListTempData._tempSwitchList!];
    _tempSwitchList2 = [..._tempSwitchList1!];
  }

  void _deleteSwitch(index) async {
    await Future.delayed(const Duration(milliseconds: 350), () {
      _tempSwitchList1!
          .removeWhere((item) => item['id'] == _tempSwitchList1![index]['id']);
      _tempSwitchList2 = [..._tempSwitchList1!];
      widget.switchesListTempData._saveSwitchesList(_tempSwitchList1!);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_tempSwitchList1!.isNotEmpty) {
      return DragAndDropGridView(
        controller: _scrollController,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        padding: const EdgeInsets.all(8),
        itemCount: _tempSwitchList1!.length,
        itemBuilder: (context, index) {
          return AnimatedOpacity(
            duration: _switchID == _tempSwitchList1![index]['id']
                ? const Duration(milliseconds: 200)
                : const Duration(seconds: 0),
            opacity: _switchID == _tempSwitchList1![index]['id']
                ? 0
                : _pos != null
                    ? _pos == index
                        ? 0.6
                        : 1
                    : 1,
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (_variableSet == 0) {
                  _height = constraints.maxHeight + 10;
                  _width = constraints.maxWidth + 10;
                  _variableSet++;
                }
                return Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(6),
                  child: Ink(
                    height: _height,
                    width: _width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF424242)
                          : Colors.white,
                    ),
                    child: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        Navigator.of(context).pushNamed('/switchInfo',
                            arguments: _tempSwitchList1![index]);
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Column(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  child: const Icon(
                                    Icons.remove,
                                    color: Colors.grey,
                                    size: 22,
                                  ),
                                  onTap: () {
                                    int tempIndex = _tempSwitchList1!
                                        .indexWhere((item) =>
                                            item['id'] ==
                                            _tempSwitchList1![index]['id']);
                                    Map tempSwitch =
                                        _tempSwitchList1![tempIndex];

                                    setState(() {
                                      _switchID =
                                          _tempSwitchList1![index]['id'];
                                      _deleteSwitch(index);
                                    });

                                    final snackBar = SnackBar(
                                      backgroundColor: Colors.grey.shade900,
                                      content: Text(
                                        "Removed ${_tempSwitchList1![index]['name']}",
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      action: SnackBarAction(
                                        label: 'UNDO',
                                        onPressed: () {
                                          _tempSwitchList1!
                                              .insert(tempIndex, tempSwitch);
                                          _tempSwitchList2 = [
                                            ..._tempSwitchList1!
                                          ];
                                          _switchID = null;
                                          setState(() {});
                                          widget.switchesListTempData
                                              ._saveSwitchesList(
                                                  _tempSwitchList1!);
                                        },
                                      ),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .removeCurrentSnackBar();
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  },
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 6,
                            child: Image.asset(
                                'assets/images/switches/${_tempSwitchList1![index]["id"]}-1.png'),
                          ),
                          Expanded(
                            flex: const AttributeChips()
                                    .greaterThanThreeAttributes(
                                        _tempSwitchList1![index])
                                ? 3
                                : 2,
                            child: const AttributeChips().getAttributeChips(
                                _tempSwitchList1![index], true, true),
                          ),
                          Expanded(
                            flex: const AttributeChips()
                                    .greaterThanThreeAttributes(
                                        _tempSwitchList1![index])
                                ? 2
                                : 3,
                            child: Center(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: AutoSizeText(
                                  '${_tempSwitchList1![index]["name"]}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                  ),
                                  maxLines: const AttributeChips()
                                          .greaterThanThreeAttributes(
                                              _tempSwitchList1![index])
                                      ? 1
                                      : 2,
                                  minFontSize: 8,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        onWillAccept: (oldIndex, newIndex) {
          _tempSwitchList1 = [..._tempSwitchList2!];
          int indexOfFirstItem = _tempSwitchList1!.indexWhere(
              (item) => item['id'] == _tempSwitchList1![oldIndex]['id']);
          int indexOfSecondItem = _tempSwitchList1!.indexWhere(
              (item) => item['id'] == _tempSwitchList1![newIndex]['id']);

          if (indexOfFirstItem > indexOfSecondItem) {
            for (int i = indexOfFirstItem; i > indexOfSecondItem; i--) {
              var tmp = _tempSwitchList1![i - 1];
              _tempSwitchList1![i - 1] = _tempSwitchList1![i];
              _tempSwitchList1![i] = tmp;
            }
          } else {
            for (int i = indexOfFirstItem; i < indexOfSecondItem; i++) {
              var tmp = _tempSwitchList1![i + 1];
              _tempSwitchList1![i + 1] = _tempSwitchList1![i];
              _tempSwitchList1![i] = tmp;
            }
          }

          setState(() {
            _pos = newIndex;
          });

          return true;
        },
        onReorder: (oldIndex, newIndex) {
          _tempSwitchList1 = [..._tempSwitchList2!];
          int indexOfFirstItem = _tempSwitchList1!.indexWhere(
              (item) => item['id'] == _tempSwitchList1![oldIndex]['id']);
          int indexOfSecondItem = _tempSwitchList1!.indexWhere(
              (item) => item['id'] == _tempSwitchList1![newIndex]['id']);

          if (indexOfFirstItem > indexOfSecondItem) {
            for (int i = indexOfFirstItem; i > indexOfSecondItem; i--) {
              var tmp = _tempSwitchList1![i - 1];
              _tempSwitchList1![i - 1] = _tempSwitchList1![i];
              _tempSwitchList1![i] = tmp;
            }
          } else {
            for (int i = indexOfFirstItem; i < indexOfSecondItem; i++) {
              var tmp = _tempSwitchList1![i + 1];
              _tempSwitchList1![i + 1] = _tempSwitchList1![i];
              _tempSwitchList1![i] = tmp;
            }
          }
          _tempSwitchList2 = [..._tempSwitchList1!];
          setState(() {
            _pos = null;
            widget.switchesListTempData._saveSwitchesList(_tempSwitchList1!);
          });
        },
      );
    } else {
      return const NoSavedSwitchesScreen();
    }
  }
}

class FilteredList extends StatelessWidget {
  final box = Hive.box('saved');

  FilteredList({super.key});

  bool _checkIfEmpty() {
    return box.get('savedSwitches', defaultValue: []).isEmpty;
  }

  String _checkViewChoice() {
    return box.get('viewChoice', defaultValue: 'list');
  }

  @override
  Widget build(BuildContext context) {
    return _checkIfEmpty()
        ? const NoSavedSwitchesScreen()
        : FutureBuilder<List<dynamic>>(
            future: SqlDatabase().getFilteredList(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.isNotEmpty) {
                  return _checkViewChoice() == 'list'
                      ? FilteredListView(snapshot.data)
                      : FilteredGridView(snapshot.data);
                } else {
                  return const NoSavedSwitchesScreen(
                    message: "No saved switches with such criteria found",
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

class FilteredListView extends StatelessWidget {
  final List<dynamic>? data;
  const FilteredListView(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: data!.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white10
                      : Colors.grey.shade300),
            ),
          ),
          child: ListTile(
            onTap: () {
              Navigator.of(context)
                  .pushNamed('/switchInfo', arguments: data![index]);
            },
            title: Container(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                data![index]['name'],
                style: const TextStyle(
                  fontSize: 17,
                ),
              ),
            ),
            contentPadding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
            subtitle: const AttributeChips().getAttributeChips(data![index]),
          ),
        );
      },
    );
  }
}

class FilteredGridView extends StatelessWidget {
  final List<dynamic>? data;
  const FilteredGridView(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      padding: const EdgeInsets.all(8),
      itemCount: data!.length,
      itemBuilder: (context, index) {
        return Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(6),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF424242)
                  : Colors.white,
            ),
            child: InkWell(
              onTap: () {
                Navigator.of(context)
                    .pushNamed('/switchInfo', arguments: data![index]);
              },
              borderRadius: BorderRadius.circular(6),
              child: Column(
                children: [
                  const Expanded(
                    flex: 1,
                    child: SizedBox.shrink(),
                  ),
                  Expanded(
                    flex: 6,
                    child: Image.asset(
                        'assets/images/switches/${data![index]["id"]}-1.png'),
                  ),
                  Expanded(
                    flex: const AttributeChips()
                            .greaterThanThreeAttributes(data![index])
                        ? 3
                        : 2,
                    child: const AttributeChips()
                        .getAttributeChips(data![index], true, true),
                  ),
                  Expanded(
                    flex: const AttributeChips()
                            .greaterThanThreeAttributes(data![index])
                        ? 2
                        : 3,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: AutoSizeText(
                          '${data![index]["name"]}',
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                          maxLines: const AttributeChips()
                                  .greaterThanThreeAttributes(data![index])
                              ? 1
                              : 2,
                          minFontSize: 8,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class NoSavedSwitchesScreen extends StatelessWidget {
  final String? message;
  const NoSavedSwitchesScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    SwitchesListTempData()._copyEmptyToTemp();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 50),
            child: Image.asset(
              Theme.of(context).brightness == Brightness.dark
                  ? 'assets/images/icons/switch(white).png'
                  : 'assets/images/icons/switch(black).png',
              width: 200,
              height: 200,
            ),
          ),
          Text(
            message != null ? message! : 'Tap the + button to add switches!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class SwitchesListTempData with ChangeNotifier {
  var box = Hive.box('saved');
  List<dynamic>? _tempSwitchList;

  void _copyEmptyToTemp() {
    box.put('tempSwitchList', []);
  }

  void _copyTempData() {
    _tempSwitchList = box.get('tempSwitchList');
  }

  void _removeWhere(String idRemove) {
    _tempSwitchList?.removeWhere((item) => item['id'] == idRemove);
  }

  void _removeAtIndex(int index) {
    _tempSwitchList?.removeAt(index);
  }

  void _insertAtIndex(int index, Map switchMap) {
    _tempSwitchList?.insert(index, switchMap);
  }

  void _reloadWidgets() {
    box.put('tempSwitchList', _tempSwitchList);

    List tempListId = [];
    for (Map i in _tempSwitchList!) {
      tempListId.add(i['id']);
    }
    box.put('savedSwitches', tempListId);

    notifyListeners();
  }

  void _saveSwitchesList(List<dynamic> switchList) {
    List tempListId = [];
    for (Map i in switchList) {
      tempListId.add(i['id']);
    }

    box.put('savedSwitches', tempListId);
  }
}

class FilterSwitchesListNotifier with ChangeNotifier {
  var box = Hive.box('saved');

  bool checkIfFiltering() {
    return box.get('filteredChips', defaultValue: []).isNotEmpty ||
        box.get('filterTerms', defaultValue: []).isNotEmpty;
  }

  void doFilter() {
    notifyListeners();
  }
}
