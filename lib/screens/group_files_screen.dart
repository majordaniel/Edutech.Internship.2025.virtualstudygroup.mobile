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
import 'dart:io';

import 'package:provider/provider.dart';

class GroupFilesScreen extends StatefulWidget {
  final int groupId;
  final String groupName;

  const GroupFilesScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupFilesScreen> createState() => _GroupFilesScreenState();
}

class _GroupFilesScreenState extends State<GroupFilesScreen> {
  List<File> _documentFiles = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDocumentFiles();
  }

  Future<void> _loadDocumentFiles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final documentFiles = await FileManagerService().getGroupDocuments(
        widget.groupId,
      );
      setState(() {
        _documentFiles = documentFiles;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load files: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openDocumentFile(File file) async {
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

  Widget _buildFilesList() {
    if (_documentFiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 64,
              color: AppColors.primaryBlackLight,
            ),
            SizedBox(height: 16),
            CustomTexts(
              title: 'No document files',
              textColor: AppColors.primaryBlack,
              textSize: 16,
              textWeight: FontWeight.w500,
              textAlignment: Alignment.center,
            ),
            SizedBox(height: 8),
            CustomTexts(
              title: 'Document files from this group will appear here',
              textColor: AppColors.primaryBlackLight,
              textSize: 14,
              textWeight: FontWeight.w400,
              textAlignment: Alignment.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _documentFiles.length,
      itemBuilder: (context, index) {
        final file = _documentFiles[index];
        final fileName = file.path.split('/').last;
        final fileSize = file.lengthSync();
        final fileType = FileManagerService().getFileType(fileName);
        final fileIcon = FileManagerService().getFileIcon(fileName);
        final formattedSize = FileManagerService().formatFileSize(fileSize);

        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(fileIcon, style: TextStyle(fontSize: 16)),
              ),
            ),
            title: Text(
              fileName,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  'Size: $formattedSize • Type: ${fileType.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryBlackLight,
                  ),
                ),
              ],
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.primaryBlackLight,
            ),
            onTap: () => _openDocumentFile(file),
            onLongPress: () => _showFileOptions(file),
          ),
        );
      },
    );
  }

  void _showFileOptions(File file) {
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
                _openDocumentFile(file);
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: AppColors.primaryOrange),
              title: Text('Share'),
              onTap: () {
                Navigator.pop(context);
                _shareDocumentFile(file);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _deleteDocumentFile(file);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareDocumentFile(File file) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share functionality coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _deleteDocumentFile(File file) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete File'),
        content: Text('Are you sure you want to delete this file?'),
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
            content: Text('File deleted'),
            backgroundColor: Colors.green,
          ),
        );
        _loadDocumentFiles(); // Refresh the list
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
                    onPressed: _loadDocumentFiles,
                    child: Text('Retry'),
                  ),
                ],
              ),
            )
          : _buildFilesList(),
    );
  }
}
