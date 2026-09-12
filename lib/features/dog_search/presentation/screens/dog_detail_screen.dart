import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/breed_model.dart';
import '../../data/models/dog_image_model.dart';
import '../../data/services/dog_api_service.dart';

class DogDetailScreen extends StatefulWidget {
  final BreedModel breed;

  const DogDetailScreen({
    super.key,
    required this.breed,
  });

  @override
  State<DogDetailScreen> createState() => _DogDetailScreenState();
}

class _DogDetailScreenState extends State<DogDetailScreen> {
  final DogApiService _apiService = DogApiService();
  DogImageModel? _imageDetail;

  @override
  void initState() {
    super.initState();
    _loadImageDetails();
  }

  Future<void> _loadImageDetails() async {
    if (widget.breed.referenceImageId != null &&
        widget.breed.referenceImageId!.isNotEmpty) {
      final detail = await _apiService.getImageDetails(widget.breed.referenceImageId!);
      if (mounted) {
        setState(() {
          _imageDetail = detail;
        });
      }
    }
  }

  void _openFullImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image_rounded,
                    color: Colors.white54,
                    size: 80,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Text(
                'Pellizca o arrastra para hacer zoom',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine best image URL (prefer response from GET /images/{id} if retrieved, else breed.imageUrl)
    final imageUrl = _imageDetail?.url ?? widget.breed.imageUrl;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsible Image Header
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.breed.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: Colors.black87, blurRadius: 8),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl != null)
                    GestureDetector(
                      onTap: () => _openFullImageDialog(imageUrl),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: Colors.amber.shade50,
                            child: const Center(
                              child: CircularProgressIndicator(color: AppTheme.primaryColor),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.amber.shade50,
                          child: const Icon(Icons.pets_rounded, size: 80, color: AppTheme.primaryColor),
                        ),
                      ),
                    )
                  else
                    Container(
                      color: Colors.amber.shade50,
                      child: const Icon(Icons.pets_rounded, size: 80, color: AppTheme.primaryColor),
                    ),
                  
                  // Gradient Overlay for readability
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.6),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Floating Zoom Badge
                  if (imageUrl != null)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton.small(
                        heroTag: 'zoomBtn',
                        backgroundColor: AppTheme.primaryColor,
                        onPressed: () => _openFullImageDialog(imageUrl),
                        child: const Icon(Icons.fullscreen_rounded, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Breed Details Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pantalla 3 indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded, size: 16, color: AppTheme.primaryColor),
                        SizedBox(width: 6),
                        Text(
                          'Pantalla 3: Perfil Canino',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Stats Grid Cards (Weight, Height, Life Span)
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.scale_rounded,
                          title: 'Peso (Métrico)',
                          value: widget.breed.metricWeight != null
                              ? '${widget.breed.metricWeight} kg'
                              : 'No especificado',
                          subtitle: widget.breed.imperialWeight != null
                              ? '${widget.breed.imperialWeight} lbs'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.straighten_rounded,
                          title: 'Altura (Métrica)',
                          value: widget.breed.metricHeight != null
                              ? '${widget.breed.metricHeight} cm'
                              : 'No especificado',
                          subtitle: widget.breed.imperialHeight != null
                              ? '${widget.breed.imperialHeight} in'
                              : null,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.favorite_rounded,
                          title: 'Esperanza de Vida',
                          value: widget.breed.lifeSpan != null && widget.breed.lifeSpan!.isNotEmpty
                              ? widget.breed.lifeSpan!
                              : 'No especificado',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.category_rounded,
                          title: 'Grupo de Raza',
                          value: widget.breed.breedGroup != null && widget.breed.breedGroup!.isNotEmpty
                              ? widget.breed.breedGroup!
                              : 'General',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Temperament Section
                  if (widget.breed.temperamentTags.isNotEmpty) ...[
                    const Text(
                      'Temperamento y Personalidad',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.breed.temperamentTags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.amber.shade300),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Origin & History
                  if (widget.breed.origin != null && widget.breed.origin!.isNotEmpty) ...[
                    _buildSectionTitle('Origen de la Raza'),
                    const SizedBox(height: 8),
                    _buildInfoCard(
                      icon: Icons.flag_rounded,
                      content: '${widget.breed.origin}${widget.breed.countryCode != null ? " (${widget.breed.countryCode})" : ""}',
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (widget.breed.bredFor != null && widget.breed.bredFor!.isNotEmpty) ...[
                    _buildSectionTitle('Criado Para'),
                    const SizedBox(height: 8),
                    _buildInfoCard(
                      icon: Icons.work_outline_rounded,
                      content: widget.breed.bredFor!,
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (widget.breed.description != null && widget.breed.description!.isNotEmpty) ...[
                    _buildSectionTitle('Descripción General'),
                    const SizedBox(height: 8),
                    _buildInfoCard(
                      icon: Icons.description_outlined,
                      content: widget.breed.description!,
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (widget.breed.history != null && widget.breed.history!.isNotEmpty) ...[
                    _buildSectionTitle('Historia de la Raza'),
                    const SizedBox(height: 8),
                    _buildInfoCard(
                      icon: Icons.history_edu_rounded,
                      content: widget.breed.history!,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Extra API technical info for team video explanation
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detalles de la API:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '• ID Raza: ${widget.breed.id}\n'
                          '• Reference Image ID: ${widget.breed.referenceImageId ?? "N/A"}\n'
                          '• Endpoint Detalle: GET /images/${widget.breed.referenceImageId ?? "{id}"}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primaryColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
