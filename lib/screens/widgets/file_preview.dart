import 'dart:io';

import 'package:flutter/material.dart';
import 'package:question_1_file_upload_project_iliyas_flutter/common/empty_state.dart';
import 'package:video_player/video_player.dart';

/// FilePreview class to show image or video
class FilePreview extends StatelessWidget {
  final File? file;
  final VideoPlayerController? videoPlayerController;
  final bool isVideo;
  final bool isImage;
  final VoidCallback addFileCallBack;

  const FilePreview({
    super.key,
    required this.file,
    required this.videoPlayerController,
    required this.isVideo,
    required this.isImage,
    required this.addFileCallBack,
  });

  @override
  Widget build(BuildContext context) {
    if (file != null || isImage || isVideo) {
      if (isVideo) {
        return AspectRatio(
          aspectRatio: videoPlayerController!.value.aspectRatio,
          child: VideoPlayer(videoPlayerController!),
        );
      } else if (isImage) {
        return Image.file(
          file!,
          fit: BoxFit.contain,
        );
      } else {
        return InkWell(
          onTap: addFileCallBack,
          child: const EmptyStatePreview(),
        );
      }
    } else {
      return InkWell(
        onTap: addFileCallBack,
        child: const EmptyStatePreview(),
      );
    }
  }
}
