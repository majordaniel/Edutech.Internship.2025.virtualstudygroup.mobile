import 'package:flutter/material.dart';
import 'package:edify_app/constants/colors.dart';
import 'package:edify_app/widgets/texts.dart';
import 'package:edify_app/services/group_management_service.dart';

class LeaveGroupConfirmation extends StatefulWidget {
  final int groupId;

  const LeaveGroupConfirmation({super.key, required this.groupId});

  @override
  State<LeaveGroupConfirmation> createState() => _LeaveGroupConfirmationState();
}

class _LeaveGroupConfirmationState extends State<LeaveGroupConfirmation> {
  bool _isLoading = false;

  void _confirmLeaveGroup() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await GroupManagementService.leaveGroup(widget.groupId);

      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You have left the group'),
            backgroundColor: const Color.fromARGB(24, 30, 30, 30),
          ),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to leave group: ${response.message}',
              style: TextStyle(color: AppColors.primaryRejected),
            ),
            backgroundColor: const Color.fromARGB(24, 30, 30, 30),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        children: [
          CustomTexts(
            title:
                'Are you sure you want to leave this group? You will need to be re-invited to join again.',
            textColor: AppColors.primaryBlackLight,
            textSize: 16,
            textWeight: FontWeight.normal,
            textAlignment: Alignment.center,
          ),
          SizedBox(height: 40),
          if (_isLoading)
            CircularProgressIndicator(color: AppColors.primaryOrange)
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppColors.primaryOrange),
                    ),
                    child: CustomTexts(
                      title: 'Cancel',
                      textColor: AppColors.primaryOrange,
                      textSize: 16,
                      textWeight: FontWeight.w600,
                      textAlignment: Alignment.center,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _confirmLeaveGroup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: CustomTexts(
                      title: 'Leave Group',
                      textColor: Colors.white,
                      textSize: 16,
                      textWeight: FontWeight.w600,
                      textAlignment: Alignment.center,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
