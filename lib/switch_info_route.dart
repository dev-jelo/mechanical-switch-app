import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:mechanical_switch_app/sql_database.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:mechanical_switch_app/attribute_chips.dart';

class SwitchInfo extends StatefulWidget {
  final Map data;
  const SwitchInfo({super.key, required this.data});

  @override
  State<SwitchInfo> createState() => _SwitchInfoState();
}

class _SwitchInfoState extends State<SwitchInfo>
    with SingleTickerProviderStateMixin {
  final CarouselController _controller = CarouselController();
  TabController? _tabController;

  @override
  void initState() {
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: 0,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          '${data["name"]}',
          maxLines: 1,
          style: const TextStyle(fontSize: 23),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Sources',
            icon: const Icon(Icons.info_outlined),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    insetPadding: const EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(bottom: 1),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  width: 1,
                                ),
                              ),
                            ),
                            margin: const EdgeInsets.only(bottom: 10),
                            child: const Text(
                              'Sources:',
                            ),
                          ),
                          FutureBuilder<List<dynamic>>(
                            future: SqlDatabase().getSources(data['id']),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SourcesSubHeading("Images", 0, 7),
                                    SourcesList(snapshot.data![0]['imagesource']
                                        .toString()),
                                    const SourcesSubHeading(
                                        "Description", 7, 7),
                                    SourcesList(snapshot.data![0]['infosource']
                                        .toString()),
                                    const SourcesSubHeading("Review", 7, 7),
                                    SourcesList(snapshot.data![0]
                                            ['reviewsource']
                                        .toString()),
                                    const SourcesSubHeading("Sound", 7, 7),
                                    SourcesList(snapshot.data![0]['soundsource']
                                        .toString()),
                                    const SourcesSubHeading(
                                        "Force Curve", 7, 7),
                                    SourcesList(snapshot.data![0]['curvesource']
                                        .toString()),
                                  ],
                                );
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: data['Variants'] ==
              0 //Check if particular switch has variants, load a different page layout for such switches
          ? Column(
              children: <Widget>[
                ImageCarousel(data: data, controller: _controller),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: const AttributeChips().getAttributeChips(data, true),
                  ),
                ),
                Expanded(
                  flex: 14,
                  child: Column(
                    children: [
                      Expanded(
                          flex: 3,
                          child: SizedBox.expand(
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black38,
                                    spreadRadius: 0.5,
                                    blurRadius: 5,
                                    offset: Offset(1, 2),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(5),
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFF424242)
                                    : Colors.white,
                              ),
                              margin: const EdgeInsets.all(5),
                              padding: const EdgeInsets.fromLTRB(10, 5, 0, 10),
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      padding: const EdgeInsets.only(right: 10),
                                      margin: const EdgeInsets.only(bottom: 0),
                                      child: TabBar(
                                        controller: _tabController,
                                        labelColor:
                                            Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : Colors.black,
                                        indicatorColor: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        tabs: const [
                                          InfoTab("Description"),
                                          InfoTab("Review"),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 7,
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 5),
                                      child: SizedBox.expand(
                                        child: TabBarView(
                                          controller: _tabController,
                                          children: [
                                            InfoTabText(
                                                data['id'], "info", false, ''),
                                            InfoTabText(data['id'], "review",
                                                false, ''),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            CurveSoundButton('curve', false, data: data),
                            FutureBuilder<List<dynamic>>(
                              future: SqlDatabase().getStats(data['id']),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Expanded(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              ExpandedSizedBox(
                                                'Pre Travel',
                                                snapshot.data![0]['ptravel']
                                                    .toString(),
                                                false,
                                              ),
                                              data['Tactile'] == 1 ||
                                                      data['Clicky'] == 1
                                                  ? ExpandedSizedBoxTactile(
                                                      snapshot.data![0]
                                                              ['actuation']
                                                          .toString(),
                                                      snapshot.data![0]
                                                              ['tactileforce']
                                                          .toString())
                                                  : ExpandedSizedBox(
                                                      'Actuation',
                                                      snapshot.data![0]
                                                              ['actuation']
                                                          .toString(),
                                                      true,
                                                    ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              ExpandedSizedBox(
                                                'Total Travel',
                                                snapshot.data![0]['ttravel']
                                                    .toString(),
                                                false,
                                              ),
                                              ExpandedSizedBox(
                                                'Bottom Out',
                                                snapshot.data![0]['bottom']
                                                    .toString(),
                                                true,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              },
                            ),
                            CurveSoundButton('sound', false, data: data)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : FutureBuilder<List<dynamic>>(
              future: SqlDatabase().getVariants(data['id'], data['Variants']),
              builder: (context, snapshot1) {
                if (snapshot1.hasData) {
                  return ChangeNotifierProvider<VariantsInfo>(
                    create: (_) => VariantsInfo(snapshot1.data!, _controller),
                    child: Consumer<VariantsInfo>(
                      builder: (context, variantsInfo, __) {
                        return Stack(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                ImageCarousel(
                                    data: data,
                                    controller: _controller,
                                    variantsInfo: variantsInfo,
                                    snapshot1: snapshot1),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    child: const AttributeChips()
                                        .getAttributeChips(
                                      data,
                                      true,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 14,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: SizedBox.expand(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.black38,
                                                  spreadRadius: 0.5,
                                                  blurRadius: 5,
                                                  offset: Offset(1, 2),
                                                ),
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? const Color(0xFF424242)
                                                  : Colors.white,
                                            ),
                                            margin: const EdgeInsets.all(5),
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 5, 0, 10),
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10),
                                                    margin:
                                                        const EdgeInsets.only(
                                                            bottom: 0),
                                                    child: TabBar(
                                                      controller:
                                                          _tabController,
                                                      labelColor: Theme.of(
                                                                      context)
                                                                  .brightness ==
                                                              Brightness.dark
                                                          ? Colors.white
                                                          : Colors.black,
                                                      indicatorColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .secondary,
                                                      tabs: const [
                                                        InfoTab("Description"),
                                                        InfoTab("Review"),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 7,
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 5),
                                                    child: SizedBox.expand(
                                                      child: TabBarView(
                                                        controller:
                                                            _tabController,
                                                        children: [
                                                          InfoTabText(
                                                              data['id'],
                                                              'info',
                                                              false,
                                                              ''),
                                                          InfoTabText(
                                                              data['id'],
                                                              'review',
                                                              true,
                                                              variantsInfo
                                                                  .getVariantReview()),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          children: [
                                            CurveSoundButton('curve', true,
                                                variantsInfo: variantsInfo),
                                            FutureBuilder<List<dynamic>>(
                                              future: SqlDatabase()
                                                  .getStats(data['id']),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  return Expanded(
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            children: [
                                                              ExpandedSizedBox(
                                                                'Pre Travel',
                                                                variantsInfo
                                                                    .getPtravel(),
                                                                false,
                                                              ),
                                                              data['Tactile'] ==
                                                                          1 ||
                                                                      data['Clicky'] ==
                                                                          1
                                                                  ? ExpandedSizedBoxTactile(
                                                                      variantsInfo
                                                                          .getActuation(),
                                                                      variantsInfo
                                                                          .getTactile(),
                                                                    )
                                                                  : ExpandedSizedBox(
                                                                      'Actuation',
                                                                      variantsInfo
                                                                          .getActuation(),
                                                                      true,
                                                                    ),
                                                            ],
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            children: [
                                                              ExpandedSizedBox(
                                                                'Total Travel',
                                                                variantsInfo
                                                                    .getTtravel(),
                                                                false,
                                                              ),
                                                              ExpandedSizedBox(
                                                                'Bottom Out',
                                                                variantsInfo
                                                                    .getBottom(),
                                                                true,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                } else {
                                                  return const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                }
                                              },
                                            ),
                                            CurveSoundButton("sound", true,
                                                variantsInfo: variantsInfo),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            VariantsDropDown(variantsInfo),
                          ],
                        );
                      },
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
    );
  }
}

class ImageCarousel extends StatefulWidget {
  final Map data;
  final CarouselController controller;
  final VariantsInfo? variantsInfo;
  final AsyncSnapshot<List<dynamic>>? snapshot1;

  const ImageCarousel(
      {super.key,
      required this.data,
      required this.controller,
      this.variantsInfo,
      this.snapshot1});

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _current = 0;

  Future<List<String>> _getImagePathList() async {
    List<String> imagePaths = [];
    int i = 1;
    bool existsCheck = true;
    while (existsCheck) {
      try {
        await rootBundle
            .load('assets/images/switches/${widget.data["id"]}-$i.png');
        imagePaths.add('assets/images/switches/${widget.data["id"]}-$i.png');
      } catch (e) {
        existsCheck = false;
      }
      i++;
    }
    try {
      await rootBundle
          .load('assets/images/switches/${widget.data["id"]}-switch.gif');
      imagePaths.add('assets/images/switches/${widget.data["id"]}-switch.gif');
    } catch (_) {}

    return imagePaths;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 10,
      child: FutureBuilder<List<String>>(
        future: _getImagePathList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                Expanded(
                  child: CarouselSlider(
                    options: CarouselOptions(
                      enableInfiniteScroll: false,
                      onPageChanged: (int index, _) {
                        setState(() {
                          _current = index;
                          widget.variantsInfo
                              ?.updateDropdownValueFromImage(index);
                        });
                      },
                    ),
                    carouselController: widget.controller,
                    items: snapshot.data!
                        .map(
                          (item) => Image.asset(item),
                        )
                        .toList(),
                  ),
                ),
                snapshot.data!.length > 1
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: snapshot.data!.asMap().entries.map((entry) {
                          return GestureDetector(
                            onTap: () =>
                                widget.controller.animateToPage(entry.key),
                            child: Container(
                              width: widget.variantsInfo == null
                                  ? 8.0
                                  : widget.snapshot1!.data![entry.key]['from']
                                          .toString()
                                          .isEmpty
                                      ? 8.0
                                      : 5.0,
                              height: widget.variantsInfo == null
                                  ? 8.0
                                  : widget.snapshot1!.data![entry.key]['from']
                                          .toString()
                                          .isEmpty
                                      ? 8.0
                                      : 5.0,
                              margin: const EdgeInsets.only(
                                  right: 4.0, left: 4.0, bottom: 11.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black)
                                    .withOpacity(
                                        _current == entry.key ? 0.9 : 0.4),
                              ),
                            ),
                          );
                        }).toList())
                    : const SizedBox.shrink(),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class VariantsDropDown extends StatelessWidget {
  final VariantsInfo variantsInfo;
  const VariantsDropDown(this.variantsInfo, {super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 7,
      right: 7,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        height: 40,
        width: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF424242)
              : Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              spreadRadius: 0.5,
              blurRadius: 5,
              offset: Offset(1, 2),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            isExpanded: true,
            icon: const SizedBox.shrink(),
            value: variantsInfo.dropdownValue,
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            onChanged: (String? newValue) {
              variantsInfo.updateDropdownValueFromSelect(newValue!);
              variantsInfo.updateImage(newValue);
            },
            items: variantsInfo.variantsNames(),
          ),
        ),
      ),
    );
  }
}

class ExpandedSizedBox extends StatelessWidget {
  final box = Hive.box('saved');
  final String description;
  final String info;
  final bool _isForce;
  ExpandedSizedBox(this.description, this.info, this._isForce, {super.key});

  Widget _statText(String info) {
    if (info.isEmpty) {
      return const Text(
        '—',
        style: TextStyle(fontSize: 16),
      );
    } else if (info == "?") {
      return const Text(
        "?",
        style: TextStyle(fontSize: 22),
      );
    } else {
      return AutoSizeText(
        _isForce
            ? '$info ${box.get("forceUnits", defaultValue: "cN")}'
            : '$info mm',
        maxLines: 1,
        minFontSize: 8,
        style: const TextStyle(fontSize: 16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                spreadRadius: 0.5,
                blurRadius: 5,
                offset: Offset(1, 2),
              ),
            ],
            borderRadius: BorderRadius.circular(5),
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF424242)
                : Colors.white,
          ),
          margin: const EdgeInsets.only(left: 2.5, right: 2.5, bottom: 5),
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Column(
            children: [
              const Expanded(
                flex: 1,
                child: SizedBox.expand(),
              ),
              Expanded(
                flex: 3,
                child: SizedBox.expand(
                  child: Center(
                    child: _statText(info),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: SizedBox.expand(
                  child: Center(
                    child: AutoSizeText(
                      description,
                      maxLines: 1,
                      minFontSize: 8,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExpandedSizedBoxTactile extends StatefulWidget {
  final String actuation;
  final String tactileForce;

  const ExpandedSizedBoxTactile(this.actuation, this.tactileForce, {super.key});

  @override
  State<ExpandedSizedBoxTactile> createState() =>
      _ExpandedSizedBoxTactileState();
}

class _ExpandedSizedBoxTactileState extends State<ExpandedSizedBoxTactile> {
  final box = Hive.box('saved');
  bool _showTactileForce = true;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox.expand(
        child: Container(
          margin: const EdgeInsets.only(left: 2.5, right: 2.5, bottom: 5),
          child: Ink(
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  spreadRadius: 0.5,
                  blurRadius: 5,
                  offset: Offset(1, 2),
                ),
              ],
              borderRadius: BorderRadius.circular(5),
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF424242)
                  : Colors.white,
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _showTactileForce = !_showTactileForce;
                });
              },
              borderRadius: BorderRadius.circular(5),
              child: Column(
                children: [
                  const Expanded(
                    flex: 1,
                    child: SizedBox.expand(),
                  ),
                  Expanded(
                    flex: 3,
                    child: SizedBox.expand(
                      child: Center(
                        child: _showTactileForce
                            ? Text(
                                widget.tactileForce.isEmpty
                                    ? '—'
                                    : widget.tactileForce == '?'
                                        ? '?'
                                        : '${widget.tactileForce} ${box.get("forceUnits", defaultValue: "cN")}',
                                style: TextStyle(
                                    fontSize:
                                        widget.tactileForce == '?' ? 22 : 16,
                                    fontWeight: FontWeight.bold),
                              )
                            : Text(
                                widget.actuation.isEmpty
                                    ? '—'
                                    : widget.actuation == '?'
                                        ? '?'
                                        : '${widget.actuation} ${box.get("forceUnits", defaultValue: "cN")}',
                                style: TextStyle(
                                    fontSize: widget.actuation == '?' ? 22 : 16,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: SizedBox.expand(
                      child: Center(
                        child: AutoSizeText(
                          _showTactileForce ? 'Tactile' : 'Actuation',
                          maxLines: 1,
                          minFontSize: 8,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CurveSoundButton extends StatelessWidget {
  final bool hasVariants;
  final String curveOrSound;
  final VariantsInfo? variantsInfo;
  final dynamic data;
  const CurveSoundButton(this.curveOrSound, this.hasVariants,
      {super.key, this.variantsInfo, this.data});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox.expand(
        child: Container(
          margin: EdgeInsets.only(
              left: curveOrSound == "curve" ? 5 : 2.5,
              right: curveOrSound == "curve" ? 2.5 : 5,
              bottom: 5),
          child: Ink(
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  spreadRadius: 0.5,
                  blurRadius: 5,
                  offset: Offset(1, 2),
                ),
              ],
              borderRadius: BorderRadius.circular(5),
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF424242)
                  : Colors.white,
            ),
            child: curveOrSound == "curve"
                ? hasVariants
                    ? ForceCurveButton(
                        variantsInfo!.checkCurveAvailable(),
                        variantsInfo!.getIDCurve(),
                      )
                    : ForceCurveButton(
                        data!['curvesource'].toString().isNotEmpty, data!["id"])
                : hasVariants
                    ? SoundButton(
                        variantsInfo!.checkSoundAvailable(),
                        variantsInfo!.getIDSound(),
                      )
                    : SoundButton(
                        data!['soundsource'].toString().isNotEmpty,
                        data!['id'],
                      ),
          ),
        ),
      ),
    );
  }
}

class SourcesSubHeading extends StatelessWidget {
  final String _subHeading;
  final double _topMargin;
  final double _bottomMargin;
  const SourcesSubHeading(this._subHeading, this._topMargin, this._bottomMargin,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: _topMargin,
        bottom: _bottomMargin,
      ),
      child: Text(
        _subHeading,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class SourcesList extends StatelessWidget {
  final String _sourceURLs;
  const SourcesList(this._sourceURLs, {super.key});

  @override
  Widget build(BuildContext context) {
    if (_sourceURLs.isEmpty) {
      return const Text(
        "N/A",
        style: TextStyle(
          fontStyle: FontStyle.italic,
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (String link in _sourceURLs.split("\n"))
            GestureDetector(
              onTap: () async {
                try {
                  await launchUrlString(
                    link,
                    mode: LaunchMode.externalApplication,
                  );
                } catch (e) {
                  throw 'Could not launch $link';
                }
              },
              child: Text(
                link,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
        ],
      );
    }
  }
}

class InfoTab extends StatelessWidget {
  final String _heading;
  const InfoTab(this._heading, {super.key});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Text(
        _heading,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }
}

class InfoTabText extends StatefulWidget {
  final String id;
  final String infoOrReview;
  final bool variantsReviews;
  final String review;
  const InfoTabText(
      this.id, this.infoOrReview, this.variantsReviews, this.review,
      {super.key});

  @override
  State<InfoTabText> createState() => _InfoTabTextState();
}

class _InfoTabTextState extends State<InfoTabText>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.variantsReviews) {
      return widget.review.isEmpty
          ? Center(
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                child: const Text('Unavailable'),
              ),
            )
          : Scrollbar(
              controller: ScrollController(),
              thickness: 2,
              child: ListView(
                padding: const EdgeInsets.only(right: 6),
                children: [
                  SelectableText(
                    widget.review,
                    style: const TextStyle(fontSize: 15),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            );
    } else {
      return FutureBuilder<List<dynamic>>(
        future: widget.infoOrReview == "info"
            ? SqlDatabase().getDescription(widget.id)
            : SqlDatabase().getReview(widget.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data![0][widget.infoOrReview].isEmpty
                ? Center(
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: const Text('Unavailable'),
                    ),
                  )
                : Scrollbar(
                    controller: ScrollController(),
                    thickness: 2,
                    child: ListView(
                      padding: const EdgeInsets.only(right: 6),
                      children: [
                        SelectableText(
                          snapshot.data![0][widget.infoOrReview],
                          style: const TextStyle(fontSize: 15),
                          textAlign: TextAlign.justify,
                        ),
                      ],
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

  @override
  bool get wantKeepAlive => true;
}

class ForceCurveButton extends StatelessWidget {
  final bool available;
  final String id;
  const ForceCurveButton(this.available, this.id, {super.key});

  @override
  Widget build(BuildContext context) {
    if (available) {
      return InkWell(
        onTap: () async {
          await showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                insetPadding: const EdgeInsets.only(left: 10, right: 10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF343434)
                        : Colors.white,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Theme.of(context).brightness == Brightness.dark
                      ? Image.asset(
                          'assets/images/switches/$id-curve(dark).png')
                      : Image.asset('assets/images/switches/$id-curve.png'),
                ),
              );
            },
          );
        },
        borderRadius: BorderRadius.circular(5),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.show_chart_rounded,
                size: 85,
              ),
              Text(
                'Force Curve',
                style: TextStyle(fontSize: 16),
              )
            ],
          ),
        ),
      );
    } else {
      return const UnavailableIcon("force");
    }
  }
}

class SoundButton extends StatelessWidget {
  final bool available;
  final String id;
  const SoundButton(this.available, this.id, {super.key});

  @override
  Widget build(BuildContext context) {
    if (available) {
      return InkWell(
        onLongPress: () async {
          await showDialog(
              context: context,
              builder: (context) {
                return KeyPressAnimation(id);
              });
        },
        onTap: () {
          AudioPlayer audioPlayer = AudioPlayer();
          audioPlayer.play(AssetSource('audio/$id.m4a'));
        },
        borderRadius: BorderRadius.circular(5),
        child: const Center(
          child: Icon(
            Icons.volume_up_rounded,
            size: 85,
          ),
        ),
      );
    } else {
      return const UnavailableIcon("sound");
    }
  }
}

class UnavailableIcon extends StatelessWidget {
  final String _forceOrSound;

  const UnavailableIcon(this._forceOrSound, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _forceOrSound == "force"
                ? Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: const Icon(
                      Icons.block_rounded,
                      size: 65,
                      color: Colors.grey,
                    ),
                  )
                : const Icon(
                    Icons.volume_off_rounded,
                    size: 85,
                    color: Colors.grey,
                  ),
            Text(
              _forceOrSound == "force"
                  ? 'Force Curve Unavailable'
                  : 'Unavailable',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KeyPressAnimation extends StatefulWidget {
  final String id;
  const KeyPressAnimation(this.id, {super.key});

  @override
  State<KeyPressAnimation> createState() => _KeyPressAnimationState();
}

class _KeyPressAnimationState extends State<KeyPressAnimation> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.only(left: 10, right: 10),
      child: GestureDetector(
        onTapDown: (_) {
          AudioPlayer audioPlayer = AudioPlayer();
          audioPlayer.play(AssetSource('audio/${widget.id}-down.m4a'));
          setState(() {
            _pressed = !_pressed;
          });
        },
        onTapUp: (_) {
          AudioPlayer audioPlayer = AudioPlayer();
          audioPlayer.play(AssetSource('audio/${widget.id}-up.m4a'));
          setState(() {
            _pressed = !_pressed;
          });
        },
        onTapCancel: () {
          AudioPlayer audioPlayer = AudioPlayer();
          audioPlayer.play(AssetSource('audio/${widget.id}-up.m4a'));
          setState(() {
            _pressed = false;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF343434)
                : Colors.white,
          ),
          padding: const EdgeInsets.all(6),
          child: _pressed
              ? Image.asset(
                  Theme.of(context).brightness == Brightness.dark
                      ? 'assets/images/icons/keypress_down(white).png'
                      : 'assets/images/icons/keypress_down(black).png',
                  width: MediaQuery.of(context).size.width * 0.85,
                )
              : Image.asset(
                  Theme.of(context).brightness == Brightness.dark
                      ? 'assets/images/icons/keypress_up(white).png'
                      : 'assets/images/icons/keypress_up(black).png',
                  width: MediaQuery.of(context).size.width * 0.85,
                ),
        ),
      ),
    );
  }
}

class VariantsInfo extends ChangeNotifier {
  final List<dynamic> _variantsData;
  String? dropdownValue;
  List<String> variantsNameList = [];
  final CarouselController? _controller;

  VariantsInfo(this._variantsData, this._controller) {
    dropdownValue = _variantsData[0]['name'];

    for (var element in _variantsData) {
      if (element['name'].toString().isNotEmpty) {
        variantsNameList.add(element['name']);
      }
    }
  }

  List<DropdownMenuItem<String>>? variantsNames() {
    return variantsNameList.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Center(
          child: AutoSizeText(
            value,
            maxLines: 2,
            minFontSize: 8,
            wrapWords: false,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }).toList();
  }

  void updateDropdownValueFromSelect(String newValue) {
    dropdownValue = newValue;
    notifyListeners();
  }

  void updateDropdownValueFromImage(int index) {
    if (_variantsData[index]['name'].toString().isNotEmpty) {
      dropdownValue = _variantsData[index]['name'];
    } else {
      dropdownValue = _variantsData[index]['from'];
    }
    notifyListeners();
  }

  void updateImage(String newValue) {
    List<String> tempList = [];

    for (var element in _variantsData) {
      tempList.add(element['name']);
    }

    _controller!.animateToPage(tempList.indexOf(newValue));
  }

  String getVariantReview() {
    for (int i = 0; i < _variantsData.length; i++) {
      if (_variantsData[i]['name'] == dropdownValue) {
        String reviewid = _variantsData[i]['id'].split('-')[0] +
            "-" +
            _variantsData[i]['reviewfrom'].toString();
        for (int j = 0; j < _variantsData.length; j++) {
          if (_variantsData[j]['id'] == reviewid) {
            return _variantsData[j]['review'];
          }
        }
      }
    }
    return '';
  }

  String getPtravel() {
    for (int i = 0; i < _variantsData.length; i++) {
      if (_variantsData[i]['name'] == dropdownValue) {
        return _variantsData[i]['ptravel'];
      }
    }
    return '';
  }

  String getTtravel() {
    for (int i = 0; i < _variantsData.length; i++) {
      if (_variantsData[i]['name'] == dropdownValue) {
        return _variantsData[i]['ttravel'];
      }
    }
    return '';
  }

  String getActuation() {
    for (int i = 0; i < _variantsData.length; i++) {
      if (_variantsData[i]['name'] == dropdownValue) {
        return _variantsData[i]['actuation'];
      }
    }
    return '';
  }

  String getTactile() {
    for (int i = 0; i < _variantsData.length; i++) {
      if (_variantsData[i]['name'] == dropdownValue) {
        return _variantsData[i]['tactileforce'];
      }
    }
    return '';
  }

  String getBottom() {
    for (int i = 0; i < _variantsData.length; i++) {
      if (_variantsData[i]['name'] == dropdownValue) {
        return _variantsData[i]['bottom'];
      }
    }
    return '';
  }

  bool checkCurveAvailable() {
    for (int i = 0; i < _variantsData.length; i++) {
      if (_variantsData[i]['name'] == dropdownValue &&
          _variantsData[i]['curve'].toString().isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  bool checkSoundAvailable() {
    for (int i = 0; i < _variantsData.length; i++) {
      if (_variantsData[i]['name'] == dropdownValue &&
          _variantsData[i]['sound'].toString().isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  String getIDCurve() {
    for (int i = 0; i < _variantsData.length; i++) {
      if (_variantsData[i]['name'] == dropdownValue) {
        return "${_variantsData[i]['id'].toString().split("-")[0]}-${_variantsData[i]['curve']}";
      }
    }
    return '';
  }

  String getIDSound() {
    for (int i = 0; i < _variantsData.length; i++) {
      if (_variantsData[i]['name'] == dropdownValue) {
        return "${_variantsData[i]['id'].toString().split("-")[0]}-${_variantsData[i]['sound']}";
      }
    }
    return '';
  }
}
