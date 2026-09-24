import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:remusic/l10n/app_localizations.dart';
import 'package:remusic/models/audio_file.dart';
import 'package:remusic/providers/audio_provider.dart';
import 'package:remusic/widgets/metadata/metadata_edit_dialog.dart';
import 'package:remusic/widgets/metadata/overflow_text_field.dart';

void main() {
  testWidgets('MetadataEditDialog renders dual columns with standard fields', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final audioFile = AudioFile(
      path: 'C:/music/test_song.flac',
      extension: '.flac',
      size: 1024,
      modified: DateTime.now(),
      discNumber: 1,
      discTotal: 2,
      bpm: 128.0,
      lyrics: 'La la la song lyrics',
    );

    final audioProvider = AudioProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<AudioProvider>.value(
        value: audioProvider,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('zh'), Locale('en')],
          locale: const Locale('zh'),
          home: Scaffold(body: MetadataEditDialog(file: audioFile)),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify dialog header and filename
    expect(find.text('编辑元数据'), findsOneWidget);
    expect(find.text('test_song.flac'), findsOneWidget);

    // Verify primary and extended section headers
    expect(find.text('主要信息'), findsOneWidget);
    expect(find.text('其他项'), findsOneWidget);
    expect(find.text('光盘编号、节拍与内嵌歌词'), findsOneWidget);

    // Verify pre-populated extended metadata
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('128.0'), findsOneWidget);
    expect(find.text('La la la song lyrics'), findsOneWidget);
  });

  testWidgets('OverflowTextField displays expand button when text is long', (
    WidgetTester tester,
  ) async {
    final controller = TextEditingController(
      text: 'Super Long Symphony Movement Title That Needs Careful Editing',
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('zh'), Locale('en')],
        locale: const Locale('en'),
        home: Scaffold(
          body: OverflowTextField(
            controller: controller,
            label: 'Title',
            enablePopout: true,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Popout icon button should be present
    final popoutIcon = find.byIcon(Icons.open_in_full);
    expect(popoutIcon, findsOneWidget);

    // Tap the popout button to open the editor dialog
    await tester.tap(popoutIcon);
    await tester.pumpAndSettle();

    // An AlertDialog with Title and Confirm button should be visible
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Title'), findsNWidgets(2)); // label and dialog title

    // Cancel the dialog
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('MetadataEditDialog saves changes to AudioProvider on confirm', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final audioFile = AudioFile(
      path: 'C:/music/test_song.flac',
      extension: '.flac',
      size: 1024,
      modified: DateTime.now(),
      discNumber: 1,
      discTotal: 2,
      bpm: 120.0,
      lyrics: 'Old lyrics',
    );

    final testProvider = _TestAudioProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<AudioProvider>.value(
        value: testProvider,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('zh'), Locale('en')],
          locale: const Locale('zh'),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => MetadataEditDialog(file: audioFile),
                  ),
                  child: const Text('Open Dialog'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();
    expect(find.byType(MetadataEditDialog), findsOneWidget);

    // Enter new Title in primary section
    final titleField = find.widgetWithText(TextFormField, '标题');
    await tester.enterText(titleField, 'New Song Title');

    // Enter new Disc Number and BPM in extended section
    final discNumberField = find.widgetWithText(TextFormField, '光盘号');
    await tester.ensureVisible(discNumberField);
    await tester.enterText(discNumberField, '3');

    final bpmField = find.widgetWithText(TextFormField, 'BPM (节拍)');
    await tester.ensureVisible(bpmField);
    await tester.enterText(bpmField, '135');

    final lyricsField = find.widgetWithText(TextFormField, '歌词');
    await tester.ensureVisible(lyricsField);
    await tester.enterText(lyricsField, 'Updated song lyrics line 1\nLine 2');

    // Tap confirm button
    final confirmButton = find.widgetWithText(FilledButton, '确认');
    await tester.ensureVisible(confirmButton);
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    // Dialog should be dismissed
    expect(find.byType(MetadataEditDialog), findsNothing);

    // Provider should have received updated values
    expect(testProvider.updatedFile, equals(audioFile));
    expect(testProvider.updatedArgs, isNotNull);
    expect(testProvider.updatedArgs!['title'], equals('New Song Title'));
    expect(testProvider.updatedArgs!['discNumber'], equals(3));
    expect(testProvider.updatedArgs!['bpm'], equals(135.0));
    expect(
      testProvider.updatedArgs!['lyrics'],
      equals('Updated song lyrics line 1\nLine 2'),
    );
  });
}

class _TestAudioProvider extends AudioProvider {
  AudioFile? updatedFile;
  Map<String, dynamic>? updatedArgs;

  @override
  Future<void> updateMetadata(
    AudioFile file, {
    required String title,
    required String trackArtist,
    required String albumArtist,
    required String album,
    required String trackNumber,
    required String trackTotal,
    required String year,
    required String genre,
    required String language,
    required String comment,
    int? discNumber,
    int? discTotal,
    double? bpm,
    String? lyrics,
    String? composer,
    String? lyricist,
    String? publisher,
    Map<String, String>? customTags,
  }) async {
    updatedFile = file;
    updatedArgs = {
      'title': title,
      'trackArtist': trackArtist,
      'albumArtist': albumArtist,
      'album': album,
      'trackNumber': trackNumber,
      'trackTotal': trackTotal,
      'year': year,
      'genre': genre,
      'language': language,
      'comment': comment,
      'discNumber': discNumber,
      'discTotal': discTotal,
      'bpm': bpm,
      'lyrics': lyrics,
      'composer': composer,
      'lyricist': lyricist,
      'publisher': publisher,
      'customTags': customTags,
    };
  }
}
