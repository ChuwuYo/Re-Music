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
      comment: 'Initial comment',
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
    expect(find.text('光盘编号与节拍 (BPM)'), findsOneWidget);

    // Verify pre-populated metadata
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('128.0'), findsOneWidget);
    expect(find.text('Initial comment'), findsOneWidget);
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
      comment: 'Old comment',
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

    final commentField = find.widgetWithText(TextFormField, '注释');
    await tester.ensureVisible(commentField);
    await tester.enterText(commentField, 'Updated comment text');

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
      testProvider.updatedArgs!['comment'],
      equals('Updated comment text'),
    );
  });

  testWidgets(
    'MetadataEditDialog shows snackbar and stays open when update fails',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final audioFile = AudioFile(
        path: 'C:/music/test_fail.flac',
        extension: '.flac',
        size: 1024,
        modified: DateTime.now(),
        bpm: 120.5,
      );

      final testProvider = _TestAudioProvider();
      testProvider.throwError = Exception('Disk write failed');

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

      // BPM should accept decimal prefilled value 120.5 without validation error
      final bpmField = find.widgetWithText(TextFormField, 'BPM (节拍)');
      expect(bpmField, findsOneWidget);
      expect(find.text('120.5'), findsOneWidget);

      // Tap confirm button
      final confirmButton = find.widgetWithText(FilledButton, '确认');
      await tester.ensureVisible(confirmButton);
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // Dialog should NOT be dismissed because save failed
      expect(find.byType(MetadataEditDialog), findsOneWidget);

      // SnackBar with error message should be displayed
      expect(find.text('Exception: Disk write failed'), findsOneWidget);
    },
  );

  testWidgets(
    'OverflowTextField dynamically displays Tooltip when text exceeds 25 chars',
    (WidgetTester tester) async {
      final controller = TextEditingController(text: 'Short');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          locale: const Locale('en'),
          home: Scaffold(
            body: OverflowTextField(
              controller: controller,
              label: 'Dynamic Label',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially short text should not have Tooltip
      expect(find.byType(Tooltip), findsNothing);

      // Enter long text (> 25 characters)
      controller.text =
          'This is a long text that definitely exceeds twenty five characters';
      await tester.pumpAndSettle();

      // Tooltip should now be present with the updated text
      expect(find.byType(Tooltip), findsOneWidget);
      final tooltipWidget = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltipWidget.message, equals(controller.text));
    },
  );
}

class _TestAudioProvider extends AudioProvider {
  AudioFile? updatedFile;
  Map<String, dynamic>? updatedArgs;
  Object? throwError;

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
    required String comment,
    String? language,
    int? discNumber,
    int? discTotal,
    double? bpm,
    String? lyrics,
    String? composer,
    String? lyricist,
    String? publisher,
    Map<String, String>? customTags,
  }) async {
    if (throwError != null) {
      throw throwError!;
    }
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
      'comment': comment,
      'language': language,
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
