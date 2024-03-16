import 'dart:io';

import 'package:flutter/material.dart';
import 'package:question_1_file_upload_project_iliyas_flutter/common/empty_state.dart';
import 'package:video_player/video_player.dart';

/// FilePreview class to show image or video
class FilePreview extends StatefulWidget {
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
  State<FilePreview> createState() => _FilePreviewState();
}

class _FilePreviewState extends State<FilePreview> {
  @override
  Widget build(BuildContext context) {
    if (widget.file != null || widget.isImage || widget.isVideo) {
      if (widget.isVideo) {
        return InkWell(
          onTap: () {
            setState(() {
              widget.videoPlayerController!.value.isPlaying
                  ? widget.videoPlayerController!.pause()
                  : widget.videoPlayerController!.play();
            });
          },
          child: AspectRatio(
            aspectRatio: widget.videoPlayerController!.value.aspectRatio,
            child: VideoPlayer(widget.videoPlayerController!),
          ),
        );
      } else if (widget.isImage) {
        return Image.file(
          widget.file!,
          fit: BoxFit.contain,
        );
      } else {
        return InkWell(
          onTap: widget.addFileCallBack,
          child: const EmptyStatePreview(),
        );
      }
    } else {
      return InkWell(
        onTap: widget.addFileCallBack,
        child: const EmptyStatePreview(),
      );
    }
  }
}
