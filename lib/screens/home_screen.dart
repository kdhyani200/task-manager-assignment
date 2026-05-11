import 'package:assign_task_manager/models/quote.dart';
import 'package:assign_task_manager/services/quote_service.dart';
import 'package:assign_task_manager/widgets/drawer.dart';
import 'package:assign_task_manager/widgets/filter_item.dart';
import 'package:assign_task_manager/widgets/quote_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../providers/filter_provider.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late Future<Quote> _quoteFuture;

  @override
  void initState() {
    super.initState();
    _quoteFuture = QuoteService().fetchRandomQuote();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(filteredTasksProvider);

    void _refreshQuote() {
      setState(() {
        _quoteFuture = QuoteService().fetchRandomQuote();
      });
    }

    return Scaffold(
      drawer: const MainDrawer(),
      appBar: AppBar(
        title: const Text(
          "Task Manager",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: _refreshQuote, icon: const Icon(Icons.refresh)),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const NewTask()),
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // QUOTE CARD
              FutureBuilder<Quote>(
                future: _quoteFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const QuotePlaceholder();
                  }

                  if (snapshot.hasError || !snapshot.hasData) {
                    return const QuoteCard(
                      author: "Steve Jobs",
                      quoteText: "Keep Moving.",
                    );
                  }

                  final q = snapshot.data!;

                  return QuoteCard(author: q.author, quoteText: q.quoteText);
                },
              ),

              const SizedBox(height: 20),

              // FILTER ROW
              Row(
                children: const [
                  FilterItem(itemName: 'All', filter: TaskFilter.all),
                  SizedBox(width: 8),
                  FilterItem(itemName: 'Done', filter: TaskFilter.completed),
                  SizedBox(width: 8),
                  FilterItem(itemName: 'To-do', filter: TaskFilter.pending),
                ],
              ),

              const SizedBox(height: 20),

              // TASK LIST
              tasksAsync.when(
                data: (tasks) => tasks.isEmpty
                    ? const EmptyTaskPlaceholder()
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: tasks.length,
                        separatorBuilder: (c, i) => const SizedBox(height: 12),
                        itemBuilder: (c, i) =>
                            TaskItemCard(task: tasks[i], index: i),
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text("Error: $e")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// LOADING QUOTE CARD
class QuotePlaceholder extends StatelessWidget {
  const QuotePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[900]!,
        highlightColor: Colors.grey[800]!,
        period: const Duration(milliseconds: 1500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 10,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 16,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: 16,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: 70,
                height: 12,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// EMPTY TASK PLACEHOLDER
class EmptyTaskPlaceholder extends StatelessWidget {
  const EmptyTaskPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(
            Icons.assignment_turned_in_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            "No tasks here yet!",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
