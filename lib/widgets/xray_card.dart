import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/app_colors.dart';

class XRayCard extends StatelessWidget {
  final Map<String, dynamic> xray;
  final VoidCallback onTap;

  const XRayCard({
    super.key,
    required this.xray,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final aiResult = xray['ai_result'] ?? {};
    final String imageUrl = xray['image_url'] ?? '';
    final String aiFinding = aiResult['finding'] ?? 'no_notes_label'.tr;

    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.black26,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.broken_image, color: AppColors.textHint, size: 28),
                          const SizedBox(height: 4),
                          Text(
                            imageUrl.isNotEmpty ? imageUrl : 'empty_link_warning'.tr,
                            style: const TextStyle(color: AppColors.error, fontSize: 8, fontWeight: FontWeight.bold),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: AppColors.error, size: 14),
                          const SizedBox(width: 5),
                          Text(
                            'ai_analysis_label'.tr,
                            style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        aiResult['confidence'] ?? '0%',
                        style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    aiFinding,
                    style: const TextStyle(color: AppColors.textMain, fontSize: 11, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}