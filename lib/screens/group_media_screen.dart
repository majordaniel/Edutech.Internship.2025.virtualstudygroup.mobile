import 'package:edify_app/providers/user_provider.dart';
import 'package:edify_app/widgets/icon_button.dart';
import 'package:edify_app/widgets/notification_icon.dart';
import 'package:edify_app/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:edify_app/constants/colors.dart';
import 'package:edify_app/widgets/appbar.dart';
import 'package:edify_app/widgets/texts.dart';
import 'package:edify_app/services/file_manager_service.dart';
import 'package:edify_app/services/file_download_service.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:io';

import 'package:provider/provider.dart';

class GroupMediaScreen extends StatefulWidget {
  final int groupId;
  final String groupName;

  const GroupMediaScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupMediaScreen> createState() => _GroupMediaScreenState();
}

class _GroupMediaScreenState extends State<GroupMediaScreen> {
  List<File> _mediaFiles = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMediaFiles();
  }

  Future<void> _loadMediaFiles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final mediaFiles = await FileManagerService().getGroupMedia(
        widget.groupId,
      );
      setState(() {
        _mediaFiles = mediaFiles;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load media: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openMediaFile(File file) async {
    try {
      await FileDownloadService().openFileWithExternalApp(file.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open file: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImagePreview(File imageFile) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.all(0),
        child: Stack(
          children: [
            PhotoView(
              imageProvider: FileImage(imageFile),
              backgroundDecoration: BoxDecoration(color: Colors.black),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaGrid() {
    if (_mediaFiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: AppColors.primaryBlackLight,
            ),
            SizedBox(height: 16),
            CustomTexts(
              title: 'No media files',
              textColor: AppColors.primaryBlack,
              textSize: 16,
              textWeight: FontWeight.w500,
              textAlignment: Alignment.center,
            ),
            SizedBox(height: 8),
            CustomTexts(
              title: 'Media files from this group will appear here',
              textColor: AppColors.primaryBlackLight,
              textSize: 14,
              textWeight: FontWeight.w400,
              textAlignment: Alignment.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _mediaFiles.length,
      itemBuilder: (context, index) {
        final file = _mediaFiles[index];
        final fileName = file.path.split('/').last;
        final isImage = FileManagerService().getFileType(fileName) == 'image';

        return GestureDetector(
          onTap: () {
            if (isImage) {
              _showImagePreview(file);
            } else {
              _openMediaFile(file);
            }
          },
          onLongPress: () => _showMediaOptions(file),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.primaryGreyLight,
            ),
            child: isImage
                ? _buildImageThumbnail(file)
                : _buildVideoThumbnail(file),
          ),
        );
      },
    );
  }

  Widget _buildImageThumbnail(File file) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.primaryGreyLight,
            child: Icon(
              Icons.photo_outlined,
              color: AppColors.primaryBlackLight,
              size: 24,
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoThumbnail(File file) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: AppColors.primaryBlack.withOpacity(0.7),
          child: Icon(Icons.videocam_outlined, color: Colors.white, size: 24),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.play_arrow, color: Colors.white, size: 12),
          ),
        ),
      ],
    );
  }

  void _showMediaOptions(File file) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.open_in_new, color: AppColors.primaryOrange),
              title: Text('Open'),
              onTap: () {
                Navigator.pop(context);
                _openMediaFile(file);
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: AppColors.primaryOrange),
              title: Text('Share'),
              onTap: () {
                Navigator.pop(context);
                _shareMediaFile(file);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _deleteMediaFile(file);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareMediaFile(File file) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share functionality coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _deleteMediaFile(File file) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Media'),
        content: Text('Are you sure you want to delete this media file?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await FileManagerService().deleteFile(file);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Media file deleted'),
            backgroundColor: Colors.green,
          ),
        );
        _loadMediaFiles(); // Refresh the list
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryWhiteIcon,
      appBar: AppBar(
        backgroundColor: AppColors.primaryWhiteIcon,
        elevation: 0,
        title: const CustomAppbar(),
        actions: [
          NotificationIcon(),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 0,
                ),
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return SimpleUserAvatar(
                      imageUrl: userProvider.user?.avatarUrl,
                      userName: userProvider.user?.fullName,
                      size: 40,
                      // onLogout: () => LogoutHandler.logout(context),
                    );
                  },
                ),
              ),
              CustomIconButton(),
              SizedBox(width: 17.81),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  CustomTexts(
                    title: _error!,
                    textColor: AppColors.primaryBlack,
                    textSize: 16,
                    textWeight: FontWeight.w500,
                    textAlignment: Alignment.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadMediaFiles,
                    child: Text('Retry'),
                  ),
                ],
              ),
            )
          : _buildMediaGrid(),
    );
  }
}
