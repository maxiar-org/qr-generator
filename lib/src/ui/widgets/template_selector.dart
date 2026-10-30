import 'package:flutter/material.dart';

import '../../domain/poster_template.dart';
import '../theme/app_theme.dart';

/// Fila de miniaturas para elegir entre los [templates] que aplican al tipo
/// de QR actual.
class TemplateSelector extends StatelessWidget {
  const TemplateSelector({
    super.key,
    required this.templates,
    required this.selected,
    required this.onSelected,
  });

  final List<PosterTemplate> templates;
  final PosterTemplate selected;
  final ValueChanged<PosterTemplate> onSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 136,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: templates.length,
      separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
      itemBuilder: (context, index) {
        final template = templates[index];
        final isSelected = template.id == selected.id;
        return _TemplateThumbnail(
          template: template,
          isSelected: isSelected,
          onTap: () => onSelected(template),
        );
      },
    ),
  );
}

class _TemplateThumbnail extends StatelessWidget {
  const _TemplateThumbnail({
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  final PosterTemplate template;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 64,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Semantics(
        button: true,
        selected: isSelected,
        label: template.name,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: isSelected ? AppColors.sello : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: Image.asset(template.image, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              template.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    ),
  );
}
