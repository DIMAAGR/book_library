import 'package:book_library/src/core/storage/schema/storage_schema.dart';
import 'package:book_library/src/core/storage/wrapper/shared_preferences_wrapper.dart';
import 'package:book_library/src/features/onboard/data/datasources/local_data_source.dart';

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  const OnboardingLocalDataSourceImpl(this.store);
  final KeyValueWrapper store;

  @override
  Future<bool> isDone() async {
    final value = store.getString(StorageSchema.onboardingDoneKey);
    return value == 'true';
  }

  @override
  Future<void> setDone(bool value) async {
    await store.setString(StorageSchema.onboardingDoneKey, value.toString());
  }
}
