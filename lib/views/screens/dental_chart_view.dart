import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../../controllers/dental_chart_controller.dart';
import '../../models/tooth_mode.dart';

class DentalChartView extends StatelessWidget {
  final DentalChartController controller = Get.find<DentalChartController>();
  final int currentPatientId;

  DentalChartView({super.key, required this.currentPatientId});

  String _formatNumbers(String input) {
    if (Get.locale?.languageCode == 'ar') {
      const englishToArabic = {
        '0': '٠', '1': '١', '2': '٢', '3': '٣', '4': '٤',
        '5': '٥', '6': '٦', '7': '٧', '8': '٨', '9': '٩'
      };
      return input.split('').map((char) => englishToArabic[char] ?? char).join();
    }
    return input;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: CircularProgressIndicator(color: Color(0xFF58A6FF)),
          ),
        );
      }

      final upperTeethList = controller.teeth.length >= 16 ? controller.teeth.sublist(0, 16) : <Tooth>[];
      final lowerTeethList = controller.teeth.length >= 32 ? controller.teeth.sublist(16, 32) : <Tooth>[];

      int decayedCount = controller.teeth.where((t) => t.status == ToothStatus.decayed).length;
      int rootCanalCount = controller.teeth.where((t) => t.status == ToothStatus.rootCanal).length;
      int rootAndFillCount = controller.teeth.where((t) => t.status == ToothStatus.rootAndFill).length;
      int missingCount = controller.teeth.where((t) => t.status == ToothStatus.missing).length;

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1B263B),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text('dental_chart_interactive_title'.tr,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text('dental_chart_instruction'.tr,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
            const SizedBox(height: 15),

            LayoutBuilder(
              builder: (context, constraints) {
                final double maxWidth = constraints.maxWidth;
                return SizedBox(
                  height: 480,
                  width: maxWidth,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      ..._buildUpperArc(upperTeethList, maxWidth),
                      ..._buildLowerArc(lowerTeethList, maxWidth),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1B2A),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.analytics_rounded, color: Color(0xFF58A6FF), size: 18),
                      const SizedBox(width: 8),
                      Text('dental_summary_title'.tr,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 10,
                    children: [
                      _buildSummaryItem('decayed_label'.tr, decayedCount, Colors.redAccent),
                      _buildSummaryItem('root_canal_label'.tr, rootCanalCount, Colors.purpleAccent),
                      _buildSummaryItem('root_fill_label'.tr, rootAndFillCount, const Color(0xFFFFB703)),
                      _buildSummaryItem('missing_label'.tr, missingCount, Colors.red),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => controller.savePatientChart(currentPatientId),
                icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 20),
                label: Text('save_chart_btn'.tr, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF58A6FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            )
          ],
        ),
      );
    });
  }

  Widget _buildSummaryItem(String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text('$label: ', style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(_formatNumbers('$count'), style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  List<Widget> _buildUpperArc(List<Tooth> teethList, double maxWidth) {
    List<Widget> children = [];
    final List<_LayoutPos> upperLayout = [
      _LayoutPos(dx: 0.14, dy: 160, angle: -0.65), _LayoutPos(dx: 0.17, dy: 125, angle: -0.55),
      _LayoutPos(dx: 0.21, dy: 95,  angle: -0.45), _LayoutPos(dx: 0.26, dy: 70,  angle: -0.35),
      _LayoutPos(dx: 0.31, dy: 52,  angle: -0.22), _LayoutPos(dx: 0.36, dy: 40,  angle: -0.12),
      _LayoutPos(dx: 0.42, dy: 34,  angle: -0.05), _LayoutPos(dx: 0.47, dy: 32,  angle: 0.0),
      _LayoutPos(dx: 0.53, dy: 32,  angle: 0.0),  _LayoutPos(dx: 0.58, dy: 34,  angle: 0.05),
      _LayoutPos(dx: 0.64, dy: 40,  angle: 0.12), _LayoutPos(dx: 0.69, dy: 52,  angle: 0.22),
      _LayoutPos(dx: 0.74, dy: 70,  angle: 0.35), _LayoutPos(dx: 0.79, dy: 95,  angle: 0.45),
      _LayoutPos(dx: 0.83, dy: 125, angle: 0.55), _LayoutPos(dx: 0.86, dy: 160, angle: 0.65),
    ];
    for (int i = 0; i < teethList.length && i < upperLayout.length; i++) {
      children.add(Positioned(left: maxWidth * upperLayout[i].dx - 16, top: upperLayout[i].dy, child: _buildInteractiveTooth(teethList[i], upperLayout[i].angle, true)));
    }
    return children;
  }

  List<Widget> _buildLowerArc(List<Tooth> teethList, double maxWidth) {
    List<Widget> children = [];
    final List<_LayoutPos> lowerLayout = [
      _LayoutPos(dx: 0.86, dy: 250, angle: -0.65), _LayoutPos(dx: 0.83, dy: 285, angle: -0.55),
      _LayoutPos(dx: 0.79, dy: 315, angle: -0.45), _LayoutPos(dx: 0.74, dy: 340, angle: -0.35),
      _LayoutPos(dx: 0.69, dy: 358, angle: -0.22), _LayoutPos(dx: 0.64, dy: 370, angle: -0.12),
      _LayoutPos(dx: 0.58, dy: 376, angle: -0.05), _LayoutPos(dx: 0.53, dy: 378, angle: 0.0),
      _LayoutPos(dx: 0.47, dy: 378, angle: 0.0),  _LayoutPos(dx: 0.42, dy: 376, angle: 0.05),
      _LayoutPos(dx: 0.36, dy: 370, angle: 0.12), _LayoutPos(dx: 0.31, dy: 358, angle: 0.22),
      _LayoutPos(dx: 0.26, dy: 340, angle: 0.35), _LayoutPos(dx: 0.21, dy: 315, angle: 0.45),
      _LayoutPos(dx: 0.17, dy: 285, angle: 0.55), _LayoutPos(dx: 0.14, dy: 250, angle: 0.65),
    ];
    for (int i = 0; i < teethList.length && i < lowerLayout.length; i++) {
      children.add(Positioned(left: maxWidth * lowerLayout[i].dx - 16, top: lowerLayout[i].dy, child: _buildInteractiveTooth(teethList[i], lowerLayout[i].angle, false)));
    }
    return children;
  }

  String _getBaseToothIcon(int toothNumber) {
    if ((toothNumber >= 1 && toothNumber <= 3) || (toothNumber >= 14 && toothNumber <= 16) || (toothNumber >= 17 && toothNumber <= 19) || (toothNumber >= 30 && toothNumber <= 32)) {
      return 'assets/30 4.png';
    } else if (toothNumber == 4 || toothNumber == 5 || toothNumber == 12 || toothNumber == 13 || toothNumber == 20 || toothNumber == 21 || toothNumber == 28 || toothNumber == 29) {
      return 'assets/4 4.png';
    } else if (toothNumber == 6 || toothNumber == 11 || toothNumber == 22 || toothNumber == 27) {
      return 'assets/6 4.png';
    } else {
      return 'assets/2 4.png';
    }
  }

  String? _getMedicalStatusOverlay(ToothStatus status) {
    switch (status) {
      case ToothStatus.decayed: return 'assets/decay.png';
      case ToothStatus.rootCanal: return 'assets/root.png';
      case ToothStatus.rootAndFill: return 'assets/root&fill.png';
      default: return null;
    }
  }

  Widget _buildInteractiveTooth(Tooth tooth, double angle, bool isUpper) {
    final statusOverlay = _getMedicalStatusOverlay(tooth.status);
    bool shouldFlipHorizontal = (tooth.number >= 9 && tooth.number <= 16) || (tooth.number >= 17 && tooth.number <= 24);
    final Matrix4 transformMatrix = Matrix4.identity();
    if (!isUpper) transformMatrix.multiply(Matrix4.rotationX(math.pi));
    if (shouldFlipHorizontal) transformMatrix.multiply(Matrix4.identity()..setEntry(0, 0, -1));

    return GestureDetector(
      onTap: () => _showDialog(tooth),
      behavior: HitTestBehavior.opaque,
      child: Transform.rotate(
        angle: angle,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isUpper) const SizedBox(height: 1),
            if (!isUpper) _buildToothNumber(tooth.number, tooth.status),
            Transform(
              alignment: Alignment.center,
              transform: transformMatrix,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: tooth.status == ToothStatus.missing ? 0.3 : 1.0,
                    child: SizedBox(width: 32, height: 32, child: Image.asset(_getBaseToothIcon(tooth.number), fit: BoxFit.contain, filterQuality: FilterQuality.high)),
                  ),
                  if (statusOverlay != null && tooth.status != ToothStatus.missing)
                    SizedBox(width: 32, height: 32, child: Image.asset(statusOverlay, fit: BoxFit.contain, color: tooth.status == ToothStatus.decayed ? Colors.red.withValues(alpha: 0.7) : tooth.status == ToothStatus.rootCanal ? Colors.purple.withValues(alpha: 0.7) : Colors.orange.withValues(alpha: 0.7), colorBlendMode: BlendMode.srcATop)),
                  if (tooth.status == ToothStatus.missing) const Icon(Icons.close_rounded, color: Colors.redAccent, size: 28, shadows: [Shadow(color: Colors.black87, blurRadius: 4)]),
                ],
              ),
            ),
            if (isUpper) const SizedBox(height: 1),
            if (isUpper) _buildToothNumber(tooth.number, tooth.status),
          ],
        ),
      ),
    );
  }

  Widget _buildToothNumber(int number, ToothStatus status) {
    Color textColor = Colors.white54;
    if (status == ToothStatus.decayed) textColor = Colors.redAccent;
    if (status == ToothStatus.rootCanal) textColor = Colors.purpleAccent;
    if (status == ToothStatus.rootAndFill) textColor = Colors.orangeAccent;
    if (status == ToothStatus.missing) textColor = Colors.red;
    return Text(_formatNumbers('$number'), style: TextStyle(color: textColor, fontSize: 9, fontWeight: FontWeight.bold));
  }

  void _showDialog(Tooth tooth) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Color(0xFF1B263B), borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("${"tooth_number".tr} ${_formatNumbers(tooth.number.toString())}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(color: Colors.white24, height: 30),
              _buildOptionTile('healthy_label'.tr, ToothStatus.healthy, tooth.number),
              _buildOptionTile('decayed_label'.tr, ToothStatus.decayed, tooth.number),
              _buildOptionTile('root_canal_label'.tr, ToothStatus.rootCanal, tooth.number),
              _buildOptionTile('root_fill_label'.tr, ToothStatus.rootAndFill, tooth.number),
              _buildOptionTile('missing_label'.tr, ToothStatus.missing, tooth.number),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile(String title, ToothStatus status, int toothNumber) {
    final statusOverlay = _getMedicalStatusOverlay(status);
    return ListTile(
      horizontalTitleGap: 20,
      leading: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(width: 36, height: 36, child: Opacity(opacity: status == ToothStatus.missing ? 0.4 : 1.0, child: Image.asset(_getBaseToothIcon(toothNumber), fit: BoxFit.contain))),
          if (statusOverlay != null && status != ToothStatus.missing) SizedBox(width: 36, height: 36, child: Image.asset(statusOverlay, fit: BoxFit.contain)),
          if (status == ToothStatus.missing) const Icon(Icons.close_rounded, color: Colors.redAccent, size: 24),
        ],
      ),
      title: Text(title, style: TextStyle(color: status == ToothStatus.missing ? Colors.redAccent : Colors.white, fontSize: 16, fontWeight: status == ToothStatus.missing ? FontWeight.bold : FontWeight.normal)),
      onTap: () {
        controller.updateStatus(toothNumber, status);
        Get.back();
      },
    );
  }
}

class _LayoutPos {
  final double dx;
  final double dy;
  final double angle;
  _LayoutPos({required this.dx, required this.dy, required this.angle});
}