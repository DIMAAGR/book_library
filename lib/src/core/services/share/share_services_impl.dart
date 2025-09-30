import 'package:book_library/src/core/services/share/share_services.dart';
import 'package:share_plus/share_plus.dart';

class ShareServiceImpl implements ShareService {
  @override
  Future<void> shareText(String text, {String? subject}) async {
    if (text.trim().isEmpty) return;
    await SharePlus.instance.share(ShareParams(text: text, subject: subject));
  }
}
