abstract class ConcurrencyLimiter {
  Future<void> acquire();
  void release();
}
