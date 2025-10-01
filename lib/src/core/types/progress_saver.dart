import 'package:book_library/src/core/failures/failures.dart';
import 'package:dartz/dartz.dart';

typedef ProgressSaver = Future<Either<Failure, Unit>> Function(String bookId, int percent);
