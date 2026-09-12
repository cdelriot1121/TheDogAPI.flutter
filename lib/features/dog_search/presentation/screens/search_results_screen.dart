import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/breed_model.dart';
import '../../data/services/dog_api_service.dart';
import '../widgets/dog_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_state_widget.dart';
import 'dog_detail_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String initialQuery;

  const SearchResultsScreen({
    super.key,
    required this.initialQuery,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final DogApiService _apiService = DogApiService();
  late String _currentQuery;
  late Future<List<BreedModel>> _breedsFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentQuery = widget.initialQuery;
    _searchController.text = _currentQuery;
    _fetchResults();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchResults() {
    setState(() {
      _breedsFuture = _apiService.searchBreeds(_currentQuery);
    });
  }

  void _onNewSearch(String query) {
    final clean = query.trim();
    if (clean.isEmpty) return;
    setState(() {
      _currentQuery = clean;
    });
    _fetchResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantalla 2: Resultados'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Search Control Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.amber.shade50.withValues(alpha: 0.4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: _onNewSearch,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Buscar otra raza...',
                        prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.primaryColor),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _onNewSearch(_searchController.text),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Icon(Icons.search, size: 20),
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: FutureBuilder<List<BreedModel>>(
                future: _breedsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: AppTheme.primaryColor),
                          const SizedBox(height: 16),
                          Text(
                            'Consultando TheDogAPI para "$_currentQuery"...',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return ErrorStateWidget(
                      errorMessage: snapshot.error.toString(),
                      onRetry: _fetchResults,
                    );
                  }

                  final breeds = snapshot.data ?? [];

                  if (breeds.isEmpty) {
                    return EmptyStateWidget(
                      query: _currentQuery,
                      onReset: () {
                        Navigator.pop(context);
                      },
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header showing results count
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            const Text(
                              'Se encontraron ',
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                            ),
                            Text(
                              '${breeds.length} razas',
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              ' para "$_currentQuery"',
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                            ),
                          ],
                        ),
                      ),

                      // ListView with Dog Cards
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: breeds.length,
                          itemBuilder: (context, index) {
                            final breed = breeds[index];
                            return DogCard(
                              breed: breed,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DogDetailScreen(breed: breed),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
