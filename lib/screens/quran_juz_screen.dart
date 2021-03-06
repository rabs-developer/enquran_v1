import 'package:flutter/material.dart';
import 'package:enquran/helpers/settings_helpers.dart';
import 'package:enquran/helpers/shimmer_helpers.dart';
import 'package:enquran/localizations/app_localizations.dart';
import 'package:enquran/models/chapters_models.dart';
import 'package:enquran/models/juz_model.dart';
import 'package:enquran/screens/quran_aya_screen.dart';
import 'package:enquran/services/quran_data_services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:enquran/app_themes.dart';

class QuranJuzScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _QuranJuzScreenState();
  }
}

class _QuranJuzScreenState extends State<QuranJuzScreen> {
  QuranJuzScreenScopedModel quranJuzScreenScopedModel =
      QuranJuzScreenScopedModel();

  @override
  void initState() {

     AppTheme.initilizeTheme();
    (() async {
      await quranJuzScreenScopedModel.getJuzs();
      await quranJuzScreenScopedModel.getChapters();
    })();

    super.initState();
  }

  @override
  void dispose() {
    quranJuzScreenScopedModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          ScopedModel<QuranJuzScreenScopedModel>(
            model: quranJuzScreenScopedModel,
            child: ScopedModelDescendant<QuranJuzScreenScopedModel>(
              builder: (
                BuildContext context,
                Widget child,
                QuranJuzScreenScopedModel model,
              ) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: model.isGettingJuzs
                      ? 5
                      : (model.juzModel?.juzs?.length ?? 0),
                  itemBuilder: (BuildContext context, int index) {
                    if (model.isGettingJuzs) {
                      return chapterDataCellShimmer();
                    }

                    var chapter = model.juzModel?.juzs?.elementAt(index);
                    return chapterDataCell(chapter);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget chapterDataCell(Juz juz) {
    if (juz == null) {
      return Container();
    }

    int firstSura = int.parse(juz.verseMapping.keys.first);
    int firstAya = int.parse(juz.verseMapping.values.first.split("-")[0]);

    var selectedChapter =
        quranJuzScreenScopedModel.chaptersModel.chapters.firstOrDefault(
      (v) => v.chapterNumber == firstSura && firstAya <= v.versesCount,
    );

   
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 10.0, bottom: 15, right: 10),
      decoration: BoxDecoration(
        color: AppTheme.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15.0,
            offset: Offset(0.0, 5.0),
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return QuranAyaScreen(
                  chapter: selectedChapter,
                );
              },
            ),
          );
        },
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
             AppTheme.language == "English" || AppTheme.language == "Both"?
            Text(
              '${AppLocalizations.of(context).juzText} ${juz.juzNumber}',
              style: TextStyle(
                fontSize: 18,
              ),
            ):SizedBox(),

             AppTheme.language == "Arabic" || AppTheme.language == "Both"?
            Text('${selectedChapter?.nameSimple} $firstSura:$firstAya'):SizedBox(),
          ],
        ),
        trailing:
         AppTheme.language == "Arabic" || AppTheme.language == "Both"?
         Container(
          width: 175,
          child: Text(
            juz.aya ?? '',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ):SizedBox(),
      ),
    );
  }

  Widget chapterDataCellShimmer() {
    return ShimmerHelpers.createShimmer(
      child: InkWell(
        onTap: () {},
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(left: 10.0, bottom: 15, right: 10),
          decoration: BoxDecoration(
            color: AppTheme.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black12,
                blurRadius: 15.0,
                offset: Offset(0.0, 5.0),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: 18,
                  height: 18,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      height: 20,
                      color: Colors.white,
                    ),
                    SizedBox.fromSize(size: Size.fromHeight(5)),
                    Container(
                      height: 16,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Container(
                  height: 24,
                  width: 75,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuranJuzScreenScopedModel extends Model {
  QuranDataService _quranDataService = QuranDataService.instance;
  bool isGettingJuzs = true;

  JuzModel juzModel;

  ChaptersModel chaptersModel = ChaptersModel();

  Future getJuzs() async {
    try {
      isGettingJuzs = true;

      juzModel = await _quranDataService.getJuzs();
      notifyListeners();
    } finally {
      isGettingJuzs = false;
      notifyListeners();
    }
  }

  Future getChapters() async {
    var locale = SettingsHelpers.instance.getLocale();
    chaptersModel = await _quranDataService.getChapters(
      locale,
    );
    notifyListeners();
  }

  void dispose() {
    _quranDataService.dispose();
  }
}
