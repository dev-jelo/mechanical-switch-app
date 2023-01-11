import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:mechanical_switch_app/theme_choose.dart';

class SettingsDrawer extends StatelessWidget {
  final dynamic update;
  const SettingsDrawer(this.update, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .8,
      child: SafeArea(
        child: Drawer(
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: const Center(
                    child: Text(
                  'Preferences',
                  style: TextStyle(
                    fontSize: 25,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                )),
              ),
              ListTile(
                title: const Text(
                  'Theme',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                trailing: Consumer<ThemeChoose>(
                  builder: (_, themeChoose, __) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Container(
                              height: 35,
                              margin: const EdgeInsets.only(right: 30),
                              child: Radio(
                                activeColor:
                                    Theme.of(context).colorScheme.secondary,
                                value: 'light',
                                groupValue: themeChoose.getTheme(),
                                onChanged: (_) {
                                  themeChoose.setLight();
                                },
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 30),
                              child: const Text('Light'),
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            SizedBox(
                              height: 35,
                              child: Radio(
                                activeColor:
                                    Theme.of(context).colorScheme.secondary,
                                value: 'dark',
                                groupValue: themeChoose.getTheme(),
                                onChanged: (_) {
                                  themeChoose.setDark();
                                },
                              ),
                            ),
                            const Text('Dark'),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text(
                  'View Style',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                trailing: ChangeNotifierProvider<ViewChoice>(
                  create: (_) => ViewChoice(),
                  child: Consumer<ViewChoice>(
                    builder: (_, viewChoice, __) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Container(
                                height: 35,
                                margin: const EdgeInsets.only(right: 30),
                                child: Radio(
                                  activeColor:
                                      Theme.of(context).colorScheme.secondary,
                                  value: 'list',
                                  groupValue: viewChoice.getViewChoice(),
                                  onChanged: (_) {
                                    viewChoice.setListView();
                                    update();
                                  },
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(right: 30),
                                child: const Text('List'),
                              ),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              SizedBox(
                                height: 35,
                                child: Radio(
                                  activeColor:
                                      Theme.of(context).colorScheme.secondary,
                                  value: 'grid',
                                  groupValue: viewChoice.getViewChoice(),
                                  onChanged: (_) {
                                    viewChoice.setGridView();
                                    update();
                                  },
                                ),
                              ),
                              const Text('Grid'),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text(
                  'Force Units',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                trailing: ChangeNotifierProvider<ForceUnits>(
                  create: (_) => ForceUnits(),
                  child: Consumer<ForceUnits>(
                    builder: (_, forceUnits, __) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Container(
                                height: 35,
                                margin: const EdgeInsets.only(right: 30),
                                child: Radio(
                                  activeColor:
                                      Theme.of(context).colorScheme.secondary,
                                  value: 'cN',
                                  groupValue: forceUnits.getForceUnitsChoice(),
                                  onChanged: (_) =>
                                      forceUnits.setForceUnitsCN(),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(right: 30),
                                child: const Text('cN'),
                              ),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              SizedBox(
                                height: 35,
                                child: Radio(
                                  activeColor:
                                      Theme.of(context).colorScheme.secondary,
                                  value: 'gf',
                                  groupValue: forceUnits.getForceUnitsChoice(),
                                  onChanged: (_) =>
                                      forceUnits.setForceUnitsGF(),
                                ),
                              ),
                              const Text('gf'),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const Divider(),
              const Expanded(
                flex: 16,
                child: SwitchGlowAnimation(),
              ),
              Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: const Text("v 1.0"),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class SwitchGlowAnimation extends StatefulWidget {
  const SwitchGlowAnimation({super.key});

  @override
  State<SwitchGlowAnimation> createState() => _SwitchGlowAnimationState();
}

class _SwitchGlowAnimationState extends State<SwitchGlowAnimation> {
  bool tapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Opacity(
        opacity: tapped ? 1.0 : 0.2,
        child: Image.asset(
          Theme.of(context).brightness == Brightness.dark
              ? 'assets/images/icons/switch(white).png'
              : 'assets/images/icons/switch(black).png',
          width: 170,
          height: 170,
        ),
      ),
      onTapDown: (TapDownDetails tapDownDetails) {
        setState(() {
          tapped = !tapped;
        });
      },
      onTapUp: (TapUpDetails tapUpDetails) {
        setState(() {
          tapped = !tapped;
        });
      },
      onTapCancel: () {
        setState(() {
          tapped = false;
        });
      },
    );
  }
}

class ForceUnits with ChangeNotifier {
  var box = Hive.box('saved');

  String getForceUnitsChoice() {
    return box.get('forceUnits', defaultValue: 'cN');
  }

  void setForceUnitsCN() {
    box.put('forceUnits', 'cN');
    notifyListeners();
  }

  void setForceUnitsGF() {
    box.put('forceUnits', 'gf');
    notifyListeners();
  }
}

class ViewChoice with ChangeNotifier {
  var box = Hive.box('saved');

  String getViewChoice() {
    return box.get('viewChoice', defaultValue: 'list');
  }

  void setListView() {
    box.put('viewChoice', 'list');
    notifyListeners();
  }

  void setGridView() {
    box.put('viewChoice', 'grid');
    notifyListeners();
  }
}
