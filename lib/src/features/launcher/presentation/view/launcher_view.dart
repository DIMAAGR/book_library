import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/features/launcher/presentation/view_model/launcher_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LauncherView extends StatefulWidget {
  const LauncherView({super.key, required this.viewModel});
  final LauncherViewModel viewModel;

  @override
  State<LauncherView> createState() => _LauncherViewState();
}

class _LauncherViewState extends State<LauncherView> {
  @override
  void initState() {
    super.initState();

    widget.viewModel.event.addListener(() {
      final e = widget.viewModel.event.value;
      if (e == null || !mounted) return;

      switch (e) {
        case NavigateTo(:final route):
          context.go(route);
          break;
        case ShowErrorSnackBar(:final message):
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
          break;
        default:
          break;
      }

      widget.viewModel.event.value = null;
    });

    widget.viewModel.decide();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
