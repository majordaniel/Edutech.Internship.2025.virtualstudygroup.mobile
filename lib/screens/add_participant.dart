import 'package:edify_app/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:edify_app/widgets/texts.dart';
import 'package:edify_app/constants/colors.dart';
import 'package:edify_app/widgets/buttons.dart';

class AddParticipantPage extends StatelessWidget {
  const AddParticipantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [Icon(null)], title: CustomAppbar()),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Wrap(
                spacing: 7,
                runSpacing: 17.1,
                alignment: WrapAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primaryBlack,
                        width: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomTexts(
                          title: 'Garry Jones',
                          textColor: AppColors.primaryBlack,
                          textSize: 16,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.center,
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.all(-10),
                          ),
                          onPressed: () {},
                          child: CustomTexts(
                            title: 'X',
                            textColor: AppColors.primaryBlack,
                            textSize: 16,
                            textWeight: FontWeight.w500,
                            textAlignment: AlignmentGeometry.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primaryBlack,
                        width: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomTexts(
                          title: 'George Uwah',
                          textColor: AppColors.primaryBlack,
                          textSize: 16,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.center,
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.all(-10),
                          ),
                          onPressed: () {},
                          child: CustomTexts(
                            title: 'X',
                            textColor: AppColors.primaryBlack,
                            textSize: 16,
                            textWeight: FontWeight.w500,
                            textAlignment: AlignmentGeometry.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primaryBlack,
                        width: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomTexts(
                          title: 'Gbolahan Daniel',
                          textColor: AppColors.primaryBlack,
                          textSize: 16,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.center,
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.all(-10),
                          ),
                          onPressed: () {},
                          child: CustomTexts(
                            title: 'X',
                            textColor: AppColors.primaryBlack,
                            textSize: 16,
                            textWeight: FontWeight.w500,
                            textAlignment: AlignmentGeometry.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primaryBlack,
                        width: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomTexts(
                          title: 'Gilbert Jane',
                          textColor: AppColors.primaryBlack,
                          textSize: 16,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.center,
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.all(-10),
                          ),
                          onPressed: () {},
                          child: CustomTexts(
                            title: 'X',
                            textColor: AppColors.primaryBlack,
                            textSize: 16,
                            textWeight: FontWeight.w500,
                            textAlignment: AlignmentGeometry.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primaryBlack,
                        width: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomTexts(
                          title: 'Garry Jones',
                          textColor: AppColors.primaryBlack,
                          textSize: 16,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.center,
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.all(-10),
                          ),
                          onPressed: () {},
                          child: CustomTexts(
                            title: 'X',
                            textColor: AppColors.primaryBlack,
                            textSize: 16,
                            textWeight: FontWeight.w500,
                            textAlignment: AlignmentGeometry.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Searchbar
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  // hint: Icon(Icons.search_outlined, ),
                  prefixIcon: Icon(Icons.search_outlined),
                ),
              ),

              SizedBox(height: 28),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: AppColors.primaryOrangeLight,
                        ),
                        child: CustomTexts(
                          title: 'GU',
                          textColor: AppColors.primaryBlack,
                          textSize: 14,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerRight,
                        ),
                      ),
                      SizedBox(width: 13),
                      Column(
                        children: [
                          CustomTexts(
                            title: 'George Uwah',
                            textColor: AppColors.primaryAppbarBlack,
                            textSize: 16,
                            textWeight: FontWeight.w500,
                            textAlignment: AlignmentGeometry.centerLeft,
                          ),
                          CustomTexts(
                            title: 'George_wayne',
                            textColor: AppColors.primaryBlack,
                            textSize: 12,
                            textWeight: FontWeight.w500,
                            textAlignment: AlignmentGeometry.centerLeft,
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(width: 209),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primaryOrange,
                      size: 40,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Divider(height: 1, color: AppColors.primaryProgressBlack),
              SizedBox(height: 37),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: AppColors.primaryOrangeLight,
                        ),
                        child: CustomTexts(
                          title: 'GU',
                          textColor: AppColors.primaryBlack,
                          textSize: 14,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerRight,
                        ),
                      ),
                      SizedBox(width: 13),
                      Column(
                        children: [
                          CustomTexts(
                            title: 'George Uwah',
                            textColor: AppColors.primaryAppbarBlack,
                            textSize: 16,
                            textWeight: FontWeight.w500,
                            textAlignment: AlignmentGeometry.centerLeft,
                          ),
                          CustomTexts(
                            title: 'George_wayne',
                            textColor: AppColors.primaryBlack,
                            textSize: 12,
                            textWeight: FontWeight.w500,
                            textAlignment: AlignmentGeometry.centerLeft,
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(width: 209),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primaryOrange,
                      size: 40,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Divider(height: 1, color: AppColors.primaryProgressBlack),
              SizedBox(height: 37),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: AppColors.primaryOrangeLight,
                        ),
                        child: CustomTexts(
                          title: 'GU',
                          textColor: AppColors.primaryBlack,
                          textSize: 14,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerRight,
                        ),
                      ),
                      SizedBox(width: 13),
                      Column(
                        children: [
                          CustomTexts(
                            title: 'George Uwah',
                            textColor: AppColors.primaryAppbarBlack,
                            textSize: 16,
                            textWeight: FontWeight.w500,
                            textAlignment: AlignmentGeometry.centerLeft,
                          ),
                          CustomTexts(
                            title: 'George_wayne',
                            textColor: AppColors.primaryBlack,
                            textSize: 12,
                            textWeight: FontWeight.w500,
                            textAlignment: AlignmentGeometry.centerLeft,
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(width: 209),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primaryOrange,
                      size: 40,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Divider(height: 1, color: AppColors.primaryProgressBlack),
              SizedBox(height: 37),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: AppColors.primaryOrangeLight,
                        ),
                        child: CustomTexts(
                          title: 'GU',
                          textColor: AppColors.primaryBlack,
                          textSize: 14,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerRight,
                        ),
                      ),
                      SizedBox(width: 13),
                      Column(
                        children: [
                          CustomTexts(
                            title: 'George Uwah',
                            textColor: AppColors.primaryAppbarBlack,
                            textSize: 16,
                            textWeight: FontWeight.w500,
                            textAlignment: AlignmentGeometry.centerLeft,
                          ),
                          CustomTexts(
                            title: 'George_wayne',
                            textColor: AppColors.primaryBlack,
                            textSize: 12,
                            textWeight: FontWeight.w500,
                            textAlignment: AlignmentGeometry.centerLeft,
                          ),
                        ],
                      ),
                    ],
                  ),

                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primaryOrange,
                      size: 40,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Divider(height: 1, color: AppColors.primaryProgressBlack),
              SizedBox(height: 37),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: AppColors.primaryOrangeLight,
                        ),
                        child: CustomTexts(
                          title: 'GU',
                          textColor: AppColors.primaryBlack,
                          textSize: 14,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerRight,
                        ),
                      ),
                      SizedBox(width: 13),
                      Column(
                        children: [
                          CustomTexts(
                            title: 'George Uwah',
                            textColor: AppColors.primaryAppbarBlack,
                            textSize: 16,
                            textWeight: FontWeight.w500,
                            textAlignment: AlignmentGeometry.centerLeft,
                          ),
                          CustomTexts(
                            title: 'George_wayne',
                            textColor: AppColors.primaryBlack,
                            textSize: 12,
                            textWeight: FontWeight.w500,
                            textAlignment: AlignmentGeometry.centerLeft,
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(width: 209),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primaryOrange,
                      size: 40,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Divider(height: 1, color: AppColors.primaryProgressBlack),
              SizedBox(height: 37),
              SizedBox(height: 30),
              CustomButtons(
                buttonColor: AppColors.primaryOrange,
                buttonHeight: 48,
                buttonTitle: 'Add Participant',
                buttonWidth: 395,
                textColor: AppColors.primaryWhiteIcon,
                textSize: 16,
                textWeight: FontWeight.w500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
