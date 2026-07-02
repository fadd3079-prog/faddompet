import 'package:faddompet/data/repositories/update_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses app versions without prefix and build number', () {
    expect(AppVersion.parse('v1.2.0')?.normalized, '1.2.0');
    expect(AppVersion.parse('1.2.0+2004')?.normalized, '1.2.0');
  });

  test('compares semantic versions correctly', () {
    expect(
      AppVersion.parse('1.2.1')!.compareTo(AppVersion.parse('1.2.0')!),
      greaterThan(0),
    );
    expect(AppVersion.parse('1.2.0')!.compareTo(AppVersion.parse('1.2.0')!), 0);
    expect(
      AppVersion.parse('1.2.0')!.compareTo(AppVersion.parse('1.3.0')!),
      lessThan(0),
    );
    expect(
      AppVersion.parse('1.3.0')!.compareTo(AppVersion.parse('1.2.9')!),
      greaterThan(0),
    );
    expect(
      AppVersion.parse('2.0.0')!.compareTo(AppVersion.parse('1.9.9')!),
      greaterThan(0),
    );
  });

  test('picks arm64 APK asset from release assets', () {
    final asset = UpdateRepository.pickArm64ApkAsset([
      {
        'name': 'FadDompet-v1.2.1-armeabi-v7a.apk',
        'browser_download_url': 'https://example.com/arm.apk',
        'size': 10,
      },
      {
        'name': 'FadDompet-v1.2.1-arm64.apk',
        'browser_download_url': 'https://example.com/arm64.apk',
        'size': 20,
      },
    ]);

    expect(asset?.name, 'FadDompet-v1.2.1-arm64.apk');
    expect(asset?.downloadUrl, 'https://example.com/arm64.apk');
    expect(asset?.sizeBytes, 20);
  });

  test('extracts SHA256 from release body', () {
    final hash = UpdateRepository.extractSha256(
      'SHA256\n`32BC9A85385D836ACAE4A1ECB0990DF3609579727ADDB89C1BA26D567D87A410`',
    );

    expect(
      hash,
      '32bc9a85385d836acae4a1ecb0990df3609579727addb89c1ba26d567d87a410',
    );
  });

  test('treats v1.2.0 release as up to date for 1.2.0+2004 app', () {
    final info = UpdateRepository.parseRelease({
      'tag_name': 'v1.2.0',
      'name': 'FadDompet v1.2.0',
      'body': '',
      'published_at': '2026-07-02T00:00:00Z',
      'assets': [
        {
          'name': 'FadDompet-v1.2.0-arm64.apk',
          'browser_download_url': 'https://example.com/arm64.apk',
          'size': 20,
        },
      ],
    }, '1.2.0+2004');

    expect(info.status, AppUpdateStatus.upToDate);
    expect(info.canDownload, isFalse);
  });
}
