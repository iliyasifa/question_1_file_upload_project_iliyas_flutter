import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:question_1_file_upload_project_iliyas_flutter/screens/widgets/file_preview.dart';
import 'package:question_1_file_upload_project_iliyas_flutter/screens/widgets/uploading_overlay.dart';
import 'package:video_player/video_player.dart';

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  FileUploadScreenState createState() => FileUploadScreenState();
}

class FileUploadScreenState extends State<FileUploadScreen> {
  /// to store the file path
  File? _file;

  /// flag for uploading status
  bool _isUploading = false;

  /// controller to the video
  late VideoPlayerController _videoPlayerController;

  /// to show the video content
  bool _isVideo = false;

  /// to show the image content
  bool _isImage = false;

  /// _restrictDuplicateUpload inititated because while
  /// trying to upload we compare with _file to
  /// restrict duplicate upload
  File _restrictDuplicateUpload = File('');

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(''));

    /// to play the if video is selected by listening the [_videoPlayerController]
    _videoPlayerController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    /// to properly dispose
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Upload Demo'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  /// Preview area
                  GestureDetector(
                    /// to delete or select a file in the preview area
                    onLongPress: _file != null
                        ? () => _deleteFile(context)
                        : () => _selectFile(context),

                    ///
                    child: SizedBox(
                      height: 500,
                      child: FilePreview(
                        file: _file,
                        videoPlayerController: _videoPlayerController,
                        isVideo: _isVideo,
                        isImage: _isImage,
                        addFileCallBack: () => _selectFile(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// add or select file button
                  ElevatedButton.icon(
                    onPressed: () => _selectFile(context),
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Select a file'),
                  ),
                  const SizedBox(height: 20),

                  /// to upload file
                  ElevatedButton.icon(
                    onPressed: _isUploading ? null : _checkNetworkAndUpload,
                    icon: const Icon(Icons.cloud_upload),
                    label: Text(
                      !_isUploading ? 'Upload File' : 'Uploading.....',
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          /// Show uploading overlay if uploading is in progress
          if (_isUploading) const UploadingOverlay(),
        ],
      ),
    );
  }

  /// [_showSnackbar] to show snackbar by passing
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  /// [_checkNetworkAndUpload] to check n/w status and upload
  Future<void> _checkNetworkAndUpload() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none && mounted) {
      _showSnackbar('No internet connection');
    } else {
      _uploadFile();
    }
  }

  /// [_uploadFile] to upload a file
  Future<void> _uploadFile() async {
    try {
      // Validate file
      if (_file != null) {
        if (_restrictDuplicateUpload != _file) {
          setState(() {
            _isUploading = true;
          });
          // Upload file to Firebase Storage
          final Reference storageRef =
              FirebaseStorage.instance.ref().child('uploads/${_file!.path}');
          UploadTask uploadTask = storageRef.putFile(_file!);

          // Wait for upload to complete
          await uploadTask.whenComplete(() {
            setState(() {
              _isUploading = false;
            });
          });
          _restrictDuplicateUpload = _file!;
          if (mounted) {
            // Show success message
            _showSnackbar('File uploaded successfully');
          }
        } else {
          // Show success message
          _showSnackbar(
              'Already Uploaded!!!,\nYou can add new file and tap to upload');
        }
      } else {
        // Show success message
        _showSnackbar('Please select a file to upload');
      }
    } catch (e) {
      if (mounted) {
        // Show error message
        _showSnackbar('Error: $e');
      }

      setState(() {
        _isUploading = false;
      });
    }
  }

  /// [_selectFile] to select a file
  Future<void> _selectFile(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Select Image'),
                onTap: () {
                  _pickImageOrVideo(isImagePick: true);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text('Select Video'),
                onTap: () {
                  _pickImageOrVideo(isVideoPick: true);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// [_pickImageOrVideo] to pick image or video
  void _pickImageOrVideo({
    bool isImagePick = false,
    bool isVideoPick = false,
  }) async {
    final picker = ImagePicker();
    XFile? pickedFile;
    if (isImagePick) {
      pickedFile = await picker.pickImage(source: ImageSource.gallery);
    } else if (isVideoPick) {
      pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    }
    if (pickedFile != null) {
      bool isLimit = File(pickedFile.path).lengthSync() < (10 * 1024 * 1024);
      if (isLimit) {
        setState(() {
          _file = File(pickedFile!.path);
          if (isImagePick) {
            _isImage = true;
            _isVideo = false;
          } else if (isVideoPick) {
            _isVideo = true;
            _isImage = false;
            _videoPlayerController = VideoPlayerController.file(_file!)
              ..initialize().then((_) {
                setState(() {});
                _videoPlayerController.play();
              });
          }
        });
      } else {
        if (mounted) {
          _showSnackbar('File size exceeds 10 MB limit');
        }
      }
    }
  }

  /// [_deleteFile] to delete file locally not
  void _deleteFile(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete File'),
          content: const Text(
              'Are you sure you want to delete the file? Please make sure before deleting.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _file = null;
                  _isImage = false;
                  _isVideo = false;
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
