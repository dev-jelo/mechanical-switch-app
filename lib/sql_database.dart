import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SqlDatabase {
  static Database? _db;
  var box = Hive.box('saved');

  Future<void> initDatabase() async {
    //// Set up sqflite and check if database exists or if there is an updated version of the database
    String path = join(await getDatabasesPath(), "switches.db");

    /* For testing purposes, remove later */
    await deleteDatabase(path);

    // Check if database exists
    bool exists = await databaseExists(path);
    if (!exists) {
      // Check if parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy database from assets folder
      ByteData data =
          await rootBundle.load(join("assets", "db", "switches.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);

      // Save version number of database
      await box.put('dbVersion', '1');
    } else {
      // Check version number of current database
      //** Update this section later for updates to database **
      await box.get('dbVersion');
    }

    // Open the database
    _db = await openReadOnlyDatabase(path);
  }

  Future<List> getSwitchList(String? searchTerms) async {
    List selectedChips = await box.get('selectedChips', defaultValue: []);
    String searchText = '';
    String searchAttribute = '';

    if (selectedChips.isNotEmpty) {
      searchAttribute = 'WHERE ';
      for (String i in selectedChips) {
        searchAttribute += "$i IS 1 AND ";
      }
      if (searchTerms!.isNotEmpty) {
        searchText = " name LIKE '%$searchTerms%'";
      } else {
        searchAttribute =
            searchAttribute.substring(0, (searchAttribute.length - 5));
      }
    } else if (searchTerms!.isNotEmpty) {
      searchText = "WHERE name LIKE '%$searchTerms%'";
    }

    return await _db!.rawQuery(
        'SELECT name, id, linear, tactile, clicky, collar, bar, silent, low, optical, mod FROM switches $searchAttribute $searchText');
  }

  Future<List> getFilteredList() async {
    List savedList = await box.get('savedSwitches', defaultValue: []);
    List filteredChips = await box.get('filteredChips', defaultValue: []);
    String filterTerms = await box.get('filterTerms', defaultValue: '');
    String filter = 'WHERE (';
    filter += savedList.map((i) => " id = '$i'").toList().join(' OR ');

    String filterOrder = ' ORDER BY CASE id ';
    int i = 1;
    for (String id in savedList) {
      filterOrder += "WHEN '$id' THEN $i ";
      i++;
    }
    filterOrder += 'END';

    if (filteredChips.isNotEmpty) {
      filter += ') AND ';
      for (String i in filteredChips) {
        filter += "$i IS 1 AND ";
      }

      if (filterTerms.isNotEmpty) {
        filter += "name LIKE '%$filterTerms%'";
      } else {
        filter = filter.substring(0, (filter.length - 5));
      }
    } else if (filterTerms.isNotEmpty) {
      filter += ") AND name LIKE '%$filterTerms%'";
    } else {
      return [];
    }

    return await _db!.rawQuery(
        'SELECT name, id, linear, tactile, clicky, collar, bar, silent, low, optical, mod, variants, soundsource, curvesource FROM switches $filter $filterOrder');
  }

  Future<List> getSavedList() async {
    List savedList = await box.get('savedSwitches', defaultValue: []);

    if (savedList.isNotEmpty) {
      String savedListOrder = 'ORDER BY (CASE id ';
      String savedListString = 'WHERE';
      savedListString +=
          savedList.map((i) => " id = '$i'").toList().join(' OR ');

      int i = 1;
      for (String id in savedList) {
        savedListOrder += "WHEN '$id' THEN $i ";
        i++;
      }
      savedListOrder += 'END)';

      return await _db!.rawQuery(
          'SELECT name, id, linear, tactile, clicky, collar, bar, silent, low, optical, mod, variants, soundsource, curvesource FROM switches $savedListString $savedListOrder');
    } else {
      return [];
    }
  }

  Future<List> getVariants(String id, int variantsCount) async {
    String variantIDs = "WHERE ";
    int count = 1;
    while (count != variantsCount + 1) {
      count != variantsCount
          ? variantIDs += "id = '$id-$count' OR "
          : variantIDs += "id = '$id-$count'";
      count++;
    }

    return await _db!.rawQuery("SELECT * FROM variants $variantIDs");
  }

  Future<List> getDescription(String id) async {
    return await _db!.rawQuery("SELECT info FROM switches WHERE id = '$id'");
  }

  Future<List> getReview(String id) async {
    return await _db!.rawQuery("SELECT review FROM switches WHERE id = '$id'");
  }

  Future<List> getStats(String id) async {
    return await _db!.rawQuery(
        "SELECT ptravel, actuation, tactileforce, ttravel, bottom FROM switches WHERE id = '$id'");
  }

  Future<List> getSources(String id) async {
    return await _db!.rawQuery(
        "SELECT imagesource, infosource, reviewsource, soundsource, curvesource FROM switches WHERE id = '$id'");
  }
}
