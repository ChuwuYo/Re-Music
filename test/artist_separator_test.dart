import 'package:flutter_test/flutter_test.dart';
import 'package:remusic/constants.dart';
import 'package:remusic/providers/audio_provider.dart';

void main() {
  group('artist separator selection', () {
    test('clicking an unselected separator makes it the active one', () {
      final provider = AudioProvider();
      expect(provider.artistSeparator, AppConstants.defaultArtistSeparator);

      provider.toggleArtistSeparator(';');

      expect(provider.allowedArtistSeparators, [';', '_']);
      expect(provider.artistSeparator, ';');
    });

    test('clicking a selected non-active separator promotes it to active', () {
      final provider = AudioProvider();
      provider.toggleArtistSeparator(';');
      provider.toggleArtistSeparator(',');

      expect(provider.allowedArtistSeparators, [',', ';', '_']);
      expect(provider.artistSeparator, ',');

      provider.toggleArtistSeparator(';');

      expect(provider.allowedArtistSeparators, [';', ',', '_']);
      expect(provider.artistSeparator, ';');
    });

    test('clicking the active separator removes it and promotes the next', () {
      final provider = AudioProvider();
      provider.toggleArtistSeparator(';');

      provider.toggleArtistSeparator(';');

      expect(provider.allowedArtistSeparators, ['_']);
      expect(provider.artistSeparator, '_');
    });

    test('the last remaining separator cannot be removed', () {
      final provider = AudioProvider();

      provider.toggleArtistSeparator('_');

      expect(provider.allowedArtistSeparators, ['_']);
      expect(provider.artistSeparator, '_');
    });
  });
}
