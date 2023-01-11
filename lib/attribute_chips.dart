import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';

class AttributeChips extends StatelessWidget {
  static const _attributeChips = <String, Color>{
    'Linear': Color(0xFFB50B00),
    'Tactile': Color(0xFF8C4C00),
    'Clicky': Color(0xFF1973C6),
    'Collar': Color(0xFF5F5F5F),
    'Bar': Color(0xFF5F5F5F),
    'Silent': Color(0xFF2EA4B5),
    'Low': Color(0xFF2D9224),
    'Optical': Color(0xFFB0A21C),
    'Mod': Color(0xFF763AC1),
  };

  final dynamic searchOrFilterNotifier;
  final String? searchOrFilter;
  const AttributeChips(
      {super.key, this.searchOrFilterNotifier, this.searchOrFilter});

  bool greaterThanThreeAttributes(Map chips) {
    int count = 0;
    chips.forEach((key, value) {
      if (value == 1 && key != 'variants') count++;
    });

    if (count > 3) {
      return true;
    } else {
      return false;
    }
  }

  Widget getAttributeChips(Map chips, [bool? infoChips, bool? smallSize]) {
    List<String> chipList = [];
    chips.forEach((key, value) {
      if (value == 1 && key != 'Variants') chipList.add(key);
    });

    return Wrap(
      alignment: infoChips == null ? WrapAlignment.start : WrapAlignment.center,
      children: <Widget>[
        for (String i in chipList)
          Container(
            width: smallSize == null ? 60 : 55,
            margin: infoChips == null
                ? const EdgeInsets.only(top: 8, right: 6)
                : smallSize == null
                    ? const EdgeInsets.only(
                        right: 3,
                        left: 3,
                      )
                    : chipList.length > 3
                        ? const EdgeInsets.only(top: 4, right: 2, left: 2)
                        : const EdgeInsets.only(top: 10, right: 2, left: 2),
            padding: const EdgeInsets.only(top: 3, bottom: 3),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: _attributeChips[i],
            ),
            child: AutoSizeText(
              i,
              style: TextStyle(
                fontSize: smallSize == null ? 13 : 12,
                color: Colors.white,
              ),
              maxLines: 1,
              minFontSize: 9,
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SelectAttributeChips>(
      create: (context) => SelectAttributeChips(context),
      child: Container(
        alignment: Alignment.center,
        constraints:
            BoxConstraints(minWidth: MediaQuery.of(context).size.width),
        color: Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.only(
          top: 6,
          bottom: 8,
        ),
        child: Consumer<SelectAttributeChips>(
          builder: (_, selectAttributeChips, ___) {
            return Wrap(
              clipBehavior: Clip.hardEdge,
              children: <Widget>[
                for (MapEntry<String, Color> i in _attributeChips.entries)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (searchOrFilter == "search") {
                        selectAttributeChips.toggleSelected(i.key);
                        searchOrFilterNotifier.doSearch();
                      } else {
                        selectAttributeChips.toggleFiltered(i.key);
                        searchOrFilterNotifier.doFilter();
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 6,
                      margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                      padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        color: i.value,
                        boxShadow: searchOrFilter == "search"
                            ? selectAttributeChips.checkIfSelected(i.key)
                            : selectAttributeChips.checkIfFiltered(i.key),
                      ),
                      child: Text(
                        i.key,
                        style: const TextStyle(
                          fontSize: 14.5,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class SelectAttributeChips with ChangeNotifier {
  var box = Hive.box('saved');
  List _selectedChips = [];
  List _filteredChips = [];

  final BuildContext context;

  SelectAttributeChips(this.context) {
    box.put('selectedChips', []);
  }

  List<BoxShadow>? checkIfSelected(String attributeName) {
    if (_selectedChips.contains(attributeName)) {
      return [
        BoxShadow(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
          spreadRadius: 3,
          blurRadius: 0,
        ),
      ];
    } else {
      return [];
    }
  }

  List<BoxShadow>? checkIfFiltered(String attributeName) {
    if (_filteredChips.contains(attributeName)) {
      return [
        BoxShadow(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
          spreadRadius: 3,
          blurRadius: 0,
        ),
      ];
    } else {
      return [];
    }
  }

  Future<void> toggleSelected(String attributeName) async {
    _selectedChips = box.get('selectedChips', defaultValue: []);
    if (_selectedChips.contains(attributeName)) {
      List tempSearchList = box.get('selectedChips', defaultValue: []);
      tempSearchList.remove(attributeName);
      box.put('selectedChips', tempSearchList);
    } else {
      List tempSearchList = box.get('selectedChips', defaultValue: []);
      tempSearchList.add(attributeName);
      box.put('selectedChips', tempSearchList);
    }
    notifyListeners();
  }

  Future<void> toggleFiltered(String attributeName) async {
    _filteredChips = box.get('filteredChips', defaultValue: []);
    if (_filteredChips.contains(attributeName)) {
      List tempFilterList = box.get('filteredChips', defaultValue: []);
      tempFilterList.remove(attributeName);
      box.put('filteredChips', tempFilterList);
    } else {
      List tempFilterList = box.get('filteredChips', defaultValue: []);
      tempFilterList.add(attributeName);
      box.put('filteredChips', tempFilterList);
    }
    notifyListeners();
  }
}
