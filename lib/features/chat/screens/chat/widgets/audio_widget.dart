import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_utils/common/widgets/containers/t_container.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/voice_message_controller.dart';

class VoiceMessageRecorder extends StatelessWidget {
  final VoiceMessageController controller = Get.put(VoiceMessageController());

  VoiceMessageRecorder({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return TContainer(
        height: 60,
        backgroundColor: controller.isPause.value ? Colors.red : const Color(0xff1d1c21),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.mic, color: Colors.white),
            const SizedBox(width: TSizes.spaceBtwItems / 2),
            Expanded(
              child: AudioWaveforms(
                size: const Size(double.infinity, 50.0),
                recorderController: controller.recorderController,
                enableGesture: true,
                shouldCalculateScrolledPosition: true,
                waveStyle: const WaveStyle(
                  waveColor: Colors.white,
                  spacing: 8.0,
                  waveThickness: 3.0,
                  extendWaveform: true,
                  showBottom: true,
                  showMiddleLine: false,
                  showTop: true,
                ),
              ),
            ),
            Text(_formatTime(controller.recordingTime.value), style: const TextStyle(color: Colors.white)),
          ],
        ),
      );
    });
  }

  // Format the recording time as MM:SS
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }
}
