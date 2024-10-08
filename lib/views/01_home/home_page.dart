import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formula/bloc/subject/subject_bloc.dart';
import 'package:formula/bloc/theme/theme_bloc.dart';
import 'package:formula/res/app_urls.dart';
import 'package:formula/res/resources.dart';
import 'package:formula/routes/routes_path.dart';
import 'package:formula/views/menu/drawer_menu.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> subjectList = [
    {"image": Resources.images.mathIcon, "title": 'Math Formula'},
    {"image": Resources.images.mathIcon, "title": 'Physics'},
    {"image": Resources.images.mathIcon, "title": 'Chemistry'},
    {"image": Resources.images.mathIcon, "title": 'Biology'},
    {"image": Resources.images.mathIcon, "title": 'Unit Converter'},
    {"image": Resources.images.mathIcon, "title": 'Quiz'},
  ];
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  // TODO: replace this test ad unit with your own ad unit.
  final adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  /// Loads a banner ad.
  void loadAd() {
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.largeBanner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            _isLoaded = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          // Dispose the ad here to free resources.
          ad.dispose();
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) {},
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) {},
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) {},
      ),
    )..load();
  }

  @override
  void initState() {
    context.read<SubjectBloc>().add(SubjectGetEvent());
    loadAd();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerPage(),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.tertiaryFixed,
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: Resources.dimens.height(context) * 0.08,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: IconButton(
                onPressed: () {
                  Theme.of(context).brightness == Brightness.dark
                      ? context
                          .read<ThemeBloc>()
                          .add(ThemeChangeEvent(isDark: false))
                      : context
                          .read<ThemeBloc>()
                          .add(ThemeChangeEvent(isDark: true));
                },
                icon: Icon(Theme.of(context).brightness == Brightness.dark
                    ? Icons.light_mode
                    : Icons.dark_mode)),
          )
        ],
        centerTitle: true,
        title: Text(
          Resources.strings.appName,
          textAlign: TextAlign.center,
          style: Resources.styles
              .kTextStyle18(Theme.of(context).colorScheme.tertiaryFixed),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              SizedBox(
                height: Resources.dimens.height(context) * 0.02,
              ),
              SizedBox(
                height: Resources.dimens.height(context) * 0.7,
                child: BlocConsumer<SubjectBloc, SubjectState>(
                  listener: (context, state) {
                    if (kDebugMode) {
                      print("State : $state");
                    }
                  },
                  builder: (context, state) {
                    if (kDebugMode) {
                      print("State : $state");
                    }
                    if (state is SubjectGetState) {
                      var data = state;
                      if (kDebugMode) {
                        print("Data : ${data.subjects}");
                      }
                      return GridView.builder(
                          itemCount: data.subjects.length + 1,
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 15,
                                  childAspectRatio: 1,
                                  crossAxisSpacing: 15),
                          itemBuilder: (BuildContext context, int index) {
                            if (index < data.subjects.length) {
                              return GestureDetector(
                                onTap: () {
                                  /// navigate based on the index
                                  print(
                                      "data.subjects : ${data.subjects[index]}");

                                  if (data.subjects[index].title
                                          .toString()
                                          .toUpperCase() ==
                                      "QUIZ") {
                                    GoRouter.of(context).pushNamed(
                                      RoutesName.quizListRoute,
                                      extra: data.subjects[index],
                                    );
                                  } else if (data.subjects[index].title
                                      .toString()
                                      .toLowerCase()
                                      .contains("unit converter")) {
                                    GoRouter.of(context).pushNamed(
                                      RoutesName.htmlViewRoute,
                                      extra: {
                                        "url":
                                            "https://examtest.in/formula/public/unit-converter/",
                                        "title": "Unit Converter",
                                      },
                                    );
                                  } else {
                                    GoRouter.of(context).pushNamed(
                                      RoutesName.topicsRoute,
                                      extra: data.subjects[index],
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                      color: index == 1
                                          ? const Color(0xffF0FFC3)
                                          : index == 2
                                              ? const Color(0xffE09DFF)
                                              : Color(0xff9EFFFA),
                                      borderRadius: BorderRadius.circular(11),
                                      border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary,width: 2)),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(15),
                                        child: Image.network(
                                            height: 70,
                                            width: 100,
                                            "${AppUrls.baseUrl}/${data.subjects[index].icon}"),
                                      ),
                                      SizedBox(
                                        height:
                                            Resources.dimens.height(context) *
                                                0.01,
                                      ),
                                      Text(
                                          data.subjects[index].title.toString(),
                                          style: Resources.styles
                                              .kTextStyle16B6(Theme.of(context)
                                                  .colorScheme
                                                  .scrim))
                                    ],
                                  ),
                                ),
                              );
                            }
                            return GestureDetector(
                              onTap: () {
                                GoRouter.of(context).pushNamed(
                                  RoutesName.qBookmarkListRoute,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(11),
                                decoration: BoxDecoration(
                                    color: Color(0xffffee8b),
                                    borderRadius: BorderRadius.circular(11),
                                    border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary,width: 2)),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(11),
                                      child: Image.asset(
                                          filterQuality: FilterQuality.high,
                                          height: 75,
                                          Resources.images.bookmarkIcon),
                                    ),
                                    SizedBox(
                                      height: Resources.dimens.height(context) *
                                          0.01,
                                    ),
                                    Text("Bookmarks",
                                        style: Resources.styles.kTextStyle16B6(
                                            Theme.of(context)
                                                .colorScheme
                                                .scrim))
                                  ],
                                ),
                              ),
                            );
                          });
                    }
                    return const SizedBox();
                  },
                ),
              ),
              Container(
                child: _bannerAd == null
                    ? Align(
                        alignment: Alignment.bottomCenter,
                        child: SafeArea(
                          child: SizedBox(
                            width: _bannerAd!.size.width.toDouble(),
                            height: _bannerAd!.size.height.toDouble(),
                            child: AdWidget(ad: _bannerAd!),
                          ),
                        ),
                      )
                    : const SizedBox(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
