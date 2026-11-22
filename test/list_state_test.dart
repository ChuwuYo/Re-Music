import 'package:flutter_test/flutter_test.dart';
import 'package:remusic/constants.dart';

void main() {
  test('resolves list state from total and visible counts', () {
    expect(AppConstants.resolveListState(0, 0), ListState.empty);
    expect(AppConstants.resolveListState(3, 0), ListState.noMatch);
    expect(AppConstants.resolveListState(3, 2), ListState.ready);
  });
}
