import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

enum InterpretationMode { shallow, deep }

class InterpretationToggle extends StatelessWidget {
  final InterpretationMode mode;
  final ValueChanged<InterpretationMode> onChanged;

  const InterpretationToggle({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.antiquePaperDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _buildOption(InterpretationMode.shallow, '浅解'),
          _buildOption(InterpretationMode.deep, '深解'),
        ],
      ),
    );
  }

  Widget _buildOption(InterpretationMode option, String label) {
    final isSelected = mode == option;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(option),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.cinnabarRed : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'KaiTi',
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : AppColors.inkGray,
            ),
          ),
        ),
      ),
    );
  }
}
