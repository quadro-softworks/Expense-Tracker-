import 'package:flutter/material.dart';

    class StatisticsScreen extends StatelessWidget {
      const StatisticsScreen({super.key});

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Statistics'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: const Center(
            child: Text('Statistics will be shown here.'),
          ),
        );
      }
    }