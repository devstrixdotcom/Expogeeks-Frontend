// import 'dart:io';
// import 'package:event_pro/data/remote/api_value.dart';
// import 'package:event_pro/data/local/contants.dart';
// import 'package:event_pro/data/remote/get_user_data.dart';
// import 'package:event_pro/utils/helper_functions.dart';
// import 'package:event_pro/view/base_screen.dart';
// import 'package:event_pro/utils/basic_route.dart';
// import 'package:event_pro/utils/color.dart';
// import 'package:event_pro/sharedwidget/circular_image_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';

// import '../../../data/local/shared_pref_helper.dart';

// class MyProfileScreen extends StatefulWidget {
//   const MyProfileScreen({super.key});

//   @override
//   State<MyProfileScreen> createState() => _MyProfileScreenState();
// }

// class _MyProfileScreenState extends State<MyProfileScreen> {
//   // Controllers for text fields
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _officeNoController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _budgetController = TextEditingController();
//   final TextEditingController _weddingDateController = TextEditingController();
//   final TextEditingController _tempDateController = TextEditingController();
//   final TextEditingController _destinationController = TextEditingController();
//   final TextEditingController _venueController = TextEditingController();

//   bool isLoading = true;
//   String? selectedBudget;
//   String fullPhoneNumber = '';
//   String selectedCountryCode = SharedPreferencesHelper.getUserCountryCode();
//   String _rawDate = '';

//   final List<String> budgetList = [
//     '0 - 10,000',
//     '10,000 - 20,000',
//     '20,000 - 30,000',
//     '30,000 - 40,000',
//     '40,000 Plus'
//   ];

//   @override
//   void initState() {
//     super.initState();
//     initializeControllers();
//     initPref();
//   }

//   void initializeControllers() {
//     _nameController.text = constant.nameValue;
//     _phoneController.text = constant.phoneValue;
//     _emailController.text = constant.emailValue;
//     _officeNoController.text = constant.officeNumber;
//     _addressController.text = constant.addressValue;
//     _rawDate = constant.expectedDateValue;
//     _tempDateController.text = DateFormatter.formatDayWithSuffix(_rawDate);
//     _budgetController.text = constant.budgetValue;
//     _destinationController.text = constant.destinationValue;
//     _venueController.text = constant.venueValue;

//     if (budgetList.contains(constant.budgetValue)) {
//       selectedBudget = constant.budgetValue;
//     }
//   }

//   Future<void> initPref() async {
//     await GetUserData().getUserDetails();
//     setState(() {
//       _venueController.text = constant.venueValue;
//       isLoading = false;
//     });
//   }

//   String formatDateWithSuffix(DateTime date) {
//     final String day = DateFormat('d').format(date);
//     final String month = DateFormat('MMM').format(date);
//     final String year = DateFormat('y').format(date);
//     String suffix = 'th';

//     if (day.endsWith('1') && day != '11') {
//       suffix = 'st';
//     } else if (day.endsWith('2') && day != '12') {
//       suffix = 'nd';
//     } else if (day.endsWith('3') && day != '13') {
//       suffix = 'rd';
//     }

//     return '$day$suffix $month $year';
//   }

//   Widget editDialog({
//     required double height,
//     required double width,
//     required String title,
//     required String text1,
//     required String text2,
//     required String text3,
//     required String text4,
//     required TextEditingController controller1,
//     required TextEditingController controller2,
//     required TextEditingController controller3,
//     required TextEditingController controller4,
//     required bool isTwoFields,
//     required bool isMultiLine,
//   }) {
//     return Dialog(
//       insetPadding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Container(
//         width: width,
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: cyangreenLight,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                     height: 1.5,
//                     color: const Color.fromRGBO(85, 85, 85, 1),
//                     fontSize: convertFigmaToUIWidth(14, width),
//                     fontWeight: FontWeight.w600),
//               ),
//               const SizedBox(height: 20),
//               _buildDialogFields(
//                 title: title,
//                 controller1: controller1,
//                 controller2: controller2,
//                 controller3: controller3,
//                 controller4: controller4,
//                 isTwoFields: isTwoFields,
//                 isMultiLine: isMultiLine,
//                 text1: text1,
//                 text2: text2,
//                 text3: text3,
//                 text4: text4,
//               ),
//               const SizedBox(height: 15),
//               _buildSaveButton(title),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDialogFields({
//     required String title,
//     required TextEditingController controller1,
//     required TextEditingController controller2,
//     required TextEditingController controller3,
//     required TextEditingController controller4,
//     required bool isTwoFields,
//     required bool isMultiLine,
//     required String text1,
//     required String text2,
//     required String text3,
//     required String text4,
//   }) {
//     var width = MediaQuery.of(context).size.width;
//     return Column(
//       children: [
//         if (title == 'Budget')
//           _buildBudgetDropdown()
//         else if (title == 'Wedding Date')
//           _buildWeddingDateField(controller1)
//         else
//           _buildTextField(
//             controller: controller1,
//             labelText: title == 'Contact Details' ? text1 : null,
//             isMultiLine: isMultiLine,
//           ),
//         if (isTwoFields) ...[
//           SizedBox(height: convertFigmaToUIWidth(15, width)),
//           _buildPhoneField(controller2, text2),
//           SizedBox(height: convertFigmaToUIWidth(15, width)),
//           _buildEmailField(controller3, text3),
//           if (constant.userType == constant.exhibitorUser)
//             SizedBox(height: convertFigmaToUIWidth(15, width)),
//           if (constant.userType == constant.exhibitorUser)
//             _buildOfficeNumberField(controller4, text4),
//         ],
//       ],
//     );
//   }

//   Widget _buildBudgetDropdown() {
//     var width = MediaQuery.of(context).size.width;
//     return DropdownButtonFormField<String>(
//       value: selectedBudget,
//       isDense: true,
//       isExpanded: true,
//       hint: const Text('Select'),
//       icon: const Icon(Icons.arrow_drop_down_sharp, color: cyangreen, size: 30),
//       style: TextStyle(
//           height: 1.5,
//           color: Color.fromRGBO(85, 85, 85, 1),
//           // fontSize: 15,
//           fontSize: convertFigmaToUIWidth(15, width),
//           fontWeight: FontWeight.w400),
//       onChanged: (value) {
//         setState(() {
//           selectedBudget = value!;
//           _budgetController.text = value;
//         });
//       },
//       items: budgetList.map((type) {
//         return DropdownMenuItem<String>(
//           value: type,
//           child: Text(type),
//         );
//       }).toList(),
//       decoration: InputDecoration(
//         isDense: true,
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//     );
//   }

//   Widget _buildWeddingDateField(TextEditingController controller) {
//     return TextField(
//       controller: controller,
//       maxLines: 1,
//       autofocus: true,
//       decoration: InputDecoration(
//         isDense: true,
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//         suffixIcon: IconButton(
//           icon: const Icon(Icons.calendar_month_outlined, color: cyangreen),
//           onPressed: () async {
//             final DateTime? pickedDate = await showDatePicker(
//               context: context,
//               initialDate: DateTime.now(),
//               firstDate: DateTime.now(),
//               lastDate: DateTime(2100),
//             );
//             if (pickedDate != null) {
//               _rawDate = DateFormat('yyyy-MM-dd').format(pickedDate);
//               final String formattedDate =
//                   DateFormatter.formatDayWithSuffix(_rawDate);
//               _tempDateController.text = formattedDate;
//               _weddingDateController.text = formattedDate;
//             }
//           },
//         ),
//       ),
//       readOnly: true,
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String? labelText,
//     required bool isMultiLine,
//   }) {
//     var width = MediaQuery.of(context).size.width;
//     return TextField(
//       controller: controller,
//       maxLines: isMultiLine ? 3 : 1,
//       autofocus: true,
//       decoration: InputDecoration(
//         labelText: labelText,
//         alignLabelWithHint: labelText != null,
//         labelStyle: TextStyle(
//             height: 1.5,
//             color: const Color.fromRGBO(85, 85, 85, 1),
//             // fontSize: 15,
//             fontSize: convertFigmaToUIWidth(15, width),
//             fontWeight: FontWeight.w600),
//         isDense: true,
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//     );
//   }

//   Widget _buildPhoneField(TextEditingController controller, String labelText) {
//     var data = SharedPreferencesHelper.getUserCountryCode();
//     var width = MediaQuery.of(context).size.width;
//     print("data: $data");

//     return Row(
//       children: [
//         SizedBox(
//           width: convertFigmaToUIWidth(120, width) ?? 120,
//           child: IntlPhoneField(
//             initialCountryCode:
//                 getCountryISOCode(SharedPreferencesHelper.getUserCountryCode()),
//             showCountryFlag: true,
//             showDropdownIcon: true,
//             disableLengthCheck: true,
//             dropdownIconPosition: IconPosition.trailing,
//             textAlign: TextAlign.center,
//             decoration: InputDecoration(
//               border:
//                   OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               contentPadding:
//                   const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
//             ),
//             onChanged: (phone) {
//               setState(() {
//                 selectedCountryCode = phone.countryCode;
//               });
//               print("Updated Country Code: $selectedCountryCode");
//             },
//             onCountryChanged: (country) {
//               setState(() {
//                 selectedCountryCode = "+${country.dialCode}";
//               });
//               print("Updated Country Code: $selectedCountryCode");
//             },
//           ),
//         ),
//          SizedBox(width: convertFigmaToUIWidth(8, width)),
//         Expanded(
//           child: TextField(
//             controller: controller,
//             keyboardType: TextInputType.phone,
//             inputFormatters: [
//               FilteringTextInputFormatter.digitsOnly,
//               LengthLimitingTextInputFormatter(13),
//             ],

//             onChanged: (value) {
//               if (value.length < 8) {
//                 print("Phone number must be at least 8 digits.");
//               }
//             },
//             decoration: InputDecoration(
//               labelText: labelText,
//               border:
//                   OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               contentPadding:
//                   const EdgeInsets.symmetric(horizontal: 15, vertical: 10),

//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildEmailField(TextEditingController controller, String labelText) {
//     var width = MediaQuery.of(context).size.width;
//     return TextField(
//       controller: controller,
//       readOnly: _emailController.text.isNotEmpty,
//       decoration: _emailController.text.isEmpty
//           ? InputDecoration(
//               labelText: labelText,
//               alignLabelWithHint: true,
//               labelStyle: TextStyle(
//                   height: 1.5,
//                   color: const Color.fromRGBO(85, 85, 85, 1),
//                   // fontSize: 15,
//                   fontSize: convertFigmaToUIWidth(15, width),
//                   fontWeight: FontWeight.w600),
//               isDense: true,
//               contentPadding:
//                   const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//               border:
//                   OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             )
//           : InputDecoration(
//               labelText: labelText,
//               labelStyle: TextStyle(
//                   height: 1.5,
//                   color: const Color.fromRGBO(85, 85, 85, 1),
//                   // fontSize: 15,
//                   fontSize: convertFigmaToUIWidth(15, width),
//                   fontWeight: FontWeight.w600),
//               isDense: true,
//               filled: true,
//               fillColor: Colors.grey.shade300,
//               contentPadding:
//                   const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//               border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: BorderSide(color: Colors.grey.shade400)),
//             ),
//     );
//   }

//   Widget _buildOfficeNumberField(
//       TextEditingController controller, String labelText) {
//     var width = MediaQuery.of(context).size.width;
//     return TextField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: labelText,
//         labelStyle: TextStyle(
//             height: 1.5,
//             color: const Color.fromRGBO(85, 85, 85, 1),
//             // fontSize: 15,
//             fontSize: convertFigmaToUIWidth(15, width),
//             fontWeight: FontWeight.w600),
//         isDense: true,
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//       keyboardType: TextInputType.number,
//       inputFormatters: [
//         FilteringTextInputFormatter.digitsOnly,
//         LengthLimitingTextInputFormatter(14)
//       ],
//     );
//   }

//   Widget _buildSaveButton(String title) {
//     return GestureDetector(
//       onTap: () async {
//         await _handleSaveAction(title);
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
//         margin: const EdgeInsets.only(top: 15),
//         decoration: BoxDecoration(
//             color: cyangreen, borderRadius: BorderRadius.circular(10)),
//         child: const Text("Save", style: TextStyle(height: 1.5, color: white)),
//       ),
//     );
//   }

//   Future<void> _handleSaveAction(String title) async {
//     if (title == "Contact Details" && selectedCountryCode.isEmpty) {
//       showToast('Please select a country code');
//       return; // Exit if no country code is selected
//     }
//     if (title == "Contact Details" && _phoneController.text.length < 8) {
//       showToast('Mobile number needs minimum 8 digits');
//       return; // Exit if contact number is empty
//     }

//     Navigator.pop(context);
//     setState(() => isLoading = true);
//     dynamic response;

//     switch (title) {
//       case "Contact Details":
//         response = await _saveContactDetails();
//         break;
//       case "Address":
//         response = await _saveAddress();
//         break;
//       case "Budget":
//         response = await _saveBudget();
//         break;
//       case "Wedding Date":
//         response = await _saveWeddingDate();
//         break;
//       case "Wedding Destination":
//         response = await _saveWeddingDestination();
//         break;
//       case "Venue":
//         response = await _saveVenue();
//         break;
//     }

//     if (response != null) {
//       showToast('Profile updated successfully');
//       showLocalNotification(
//         _getNotificationId(title),
//         'Profile updated',
//         '$title has been updated successfully',
//       );
//       initPref();
//     } else {
//       showToast('Try after sometime');
//     }
//   }

//   Future<dynamic> _saveContactDetails() async {
//     if (selectedCountryCode.isEmpty) {
//       showToast('Please select a country code');
//       return null;
//     }

//     // if (_phoneController.text.length != 13) {
//     //   showToast('Phone number must be ateast 13 digits');
//     //   return null;
//     // }

//     if (constant.userType == constant.exhibitorUser) {
//       return await apiValue.editExhibitorProfile(
//         context,
//         await capitalizeWords(_nameController.text),
//         _emailController.text,
//         selectedCountryCode,
//         _phoneController.text,
//         _officeNoController.text,
//       );
//     } else {
//       if (_nameController.text.isEmpty) {
//         showToast('Name cannot be empty');
//         return null;
//       }

//       return await apiValue.editVisitorProfile(
//         context,
//         'contact',
//         await capitalizeWords(_nameController.text),
//         _emailController.text,
//         selectedCountryCode,
//         _phoneController.text,
//         '',
//         '',
//         '',
//         '',
//         '',
//       );
//     }
//   }

//   Future<dynamic> _saveAddress() async {
//     return await apiValue.editVisitorProfile(
//       context,
//       'address',
//       '',
//       '',
//       '',
//       '',
//       _addressController.text,
//       '',
//       '',
//       '',
//       '',
//     );
//   }

//   Future<dynamic> _saveBudget() async {
//     return await apiValue.editVisitorProfile(
//       context,
//       'budget',
//       '',
//       '',
//       '',
//       '',
//       '',
//       _budgetController.text,
//       '',
//       '',
//       '',
//     );
//   }

//   Future<dynamic> _saveWeddingDate() async {
//     return await apiValue.editVisitorProfile(
//       context,
//       'expected_date',
//       '',
//       '',
//       '',
//       '',
//       '',
//       '',
//       '',
//       '',
//       _rawDate,
//     );
//   }

//   Future<dynamic> _saveWeddingDestination() async {
//     return await apiValue.editVisitorProfile(
//       context,
//       'destination',
//       '',
//       '',
//       '',
//       '',
//       '',
//       '',
//       _destinationController.text,
//       '',
//       '',
//     );
//   }

//   Future<dynamic> _saveVenue() async {
//     return await apiValue.editVisitorProfile(context, 'venue', '', '', '', '',
//         '', '', '', _venueController.text, '');
//   }

//   int _getNotificationId(String title) {
//     switch (title) {
//       case "Contact Details":
//         return 2;
//       case "Address":
//         return 4;
//       case "Budget":
//         return 5;
//       case "Wedding Date":
//         return 6;
//       case "Wedding Destination":
//         return 7;
//       case "Venue":
//         return 8;
//       default:
//         return 0;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Size size = MediaQuery.of(context).size;

//     return BaseScreen(
//       onItemSelected: (index) {
//         Navigator.pushNamed(context, getRouteForIndex(index));
//         // Navigator.pop(context, getRouteForIndex(index));
//       },
//       selectedIndex: 3,
//       child: isLoading ? _buildLoadingScreen(size) : _buildProfileScreen(size),
//     );
//   }

//   Widget _buildLoadingScreen(Size size) {
//     var width = MediaQuery.of(context).size.width;
//     return Scaffold(
//       appBar: AppBar(
//         shadowColor: Colors.transparent,
//         backgroundColor: Colors.transparent,
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.white),
//         scrolledUnderElevation: 0,
//         elevation: 0,
//         title: Text(
//           "My Profile",
//           style: TextStyle(

//               fontSize: convertFigmaToUIWidth(20, width),
//               fontWeight: FontWeight.w700,
//               color: Colors.white),
//         ),
//         flexibleSpace: Container(

//           height: convertFigmaToUIWidth(200, width),
//           decoration: BoxDecoration(
//             color: cyangreen,
//             borderRadius: const BorderRadius.only(
//                 bottomLeft: Radius.circular(30),
//                 bottomRight: Radius.circular(30)),
//           ),
//         ),
//       ),
//       body: const Center(child: CircularProgressIndicator()),
//     );
//   }

//   Widget _buildProfileScreen(Size size) {
//     var width = MediaQuery.of(context).size.width;
//     return Scaffold(
//       appBar: AppBar(
//         shadowColor: Colors.transparent,
//         backgroundColor: Color.fromRGBO(204, 232, 234, 0.7),
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.white),
//         scrolledUnderElevation: 0,
//         elevation: 0,
//         title: Text(
//           "My Profile",
//           style: TextStyle(
//               height: 1.5,

//               fontSize: convertFigmaToUIWidth(20, width),
//               fontWeight: FontWeight.w600,
//               color: Colors.white),
//         ),
//         flexibleSpace: Container(

//           height: convertFigmaToUIWidth(200, width),
//           decoration: BoxDecoration(
//             color: cyangreen,
//             borderRadius: const BorderRadius.only(
//                 bottomLeft: Radius.circular(30),
//                 bottomRight: Radius.circular(30)),
//           ),
//         ),
//         bottom: PreferredSize(
//           preferredSize: Size.fromHeight(convertFigmaToUIWidth(230, width) ?? 230),
//           child: Container(
//             height: convertFigmaToUIWidth(230, width),
//             width: size.width,
//             color: Colors.transparent,
//             child: Stack(
//               alignment: Alignment.topCenter,
//               children: [
//                 Positioned(
//                   top: 0,
//                   child: GestureDetector(
//                     onTap: onImageSelect,
//                     child: getCircularImageWidget(
//                         convertFigmaToUIWidth(200, width) ?? 200,
//                         constant.imageLinkValue,
//                         white,
//                         cyangreen,
//                         55,
//                         getNameInitials(constant.nameValue)),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           setState(() {
//             isLoading = true;
//             initPref();
//           });
//         },
//         child: Container(
//           height: size.height,
//           width: size.width,
//           color: Color.fromRGBO(204, 232, 234, 0.7),
//           child: SingleChildScrollView(
//             physics: const BouncingScrollPhysics(),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text(
//                   constant.nameValue,
//                   style: TextStyle(
//                       height: 1.5,
//                       // fontSize: 20,
//                       fontSize: convertFigmaToUIWidth(20, width),
//                       fontWeight: FontWeight.w400,
//                       color: Color.fromRGBO(85, 85, 85, 1)),
//                 ),
//                 if (constant.userType != constant.exhibitorUser) ...[
//                   const SizedBox(height: 9),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       if (constant.weddingRoleValue.toString() != 'null' &&
//                           constant.weddingRoleValue != '')
//                         Text(
//                           "${constant.weddingRoleValue} | ",
//                           style: TextStyle(
//                               fontSize: convertFigmaToUIWidth(17.2, width),
//                               fontWeight: FontWeight.w400,
//                               color: const Color.fromRGBO(2, 141, 148, 1)),
//                         ),
//                       Text(
//                         DateFormatter.formatDayWithSuffix(
//                             constant.expectedDateValue),
//                         style: TextStyle(
//                            fontSize: convertFigmaToUIWidth(17.2, width),
//                             fontWeight: FontWeight.w400,
//                             color: const Color.fromRGBO(85, 85, 85, 1)),
//                       ),
//                     ],
//                   ),
//                 ],
//                 SizedBox(height: convertFigmaToUIWidth(25, width)),
//                 _buildProfileTabs(size),
//                 if (constant.userType != constant.exhibitorUser)
//                   SizedBox(height: convertFigmaToUIWidth(100, width)),
//               ],
//             ),
//           ),
//         ),
//       ),
//       backgroundColor: Colors.white,
//     );
//   }

//   Widget _buildProfileTabs(Size size) {
//     return Column(
//       children: [
//         _buildTabContainer(
//           'Contact Details',
//           constant.phoneValue,
//           constant.emailValue,
//           constant.officeNumber,
//           '',
//           true,
//           () {
//             showDialog(
//               context: context,
//               builder: (context) {
//                 _phoneController.text = constant.phoneValue;
//                 return editDialog(
//                   height: size.height,
//                   width: size.width,
//                   title: 'Contact Details',
//                   text1: 'Name',
//                   text2: 'Mobile Number',
//                   text3: 'Email',
//                   text4: 'Office Number',
//                   controller1: _nameController,
//                   controller2: _phoneController,
//                   controller3: _emailController,
//                   controller4: _officeNoController,
//                   isTwoFields: true,
//                   isMultiLine: false,
//                 );
//               },
//             );
//           },
//         ),
//         if (constant.userType != constant.exhibitorUser &&
//             constant.addressValue != '')
//           _buildTabContainer(
//             'Address',
//             '',
//             '',
//             '',
//             constant.addressValue,
//             false,
//             () {
//               showDialog(
//                 context: context,
//                 builder: (context) {
//                   return editDialog(
//                     height: size.height,
//                     width: size.width,
//                     title: 'Address',
//                     text1: 'Address',
//                     text2: '',
//                     text3: '',
//                     text4: '',
//                     controller1: _addressController,
//                     controller2: TextEditingController(),
//                     controller3: TextEditingController(),
//                     controller4: TextEditingController(),
//                     isTwoFields: false,
//                     isMultiLine: true,
//                   );
//                 },
//               );
//             },
//           ),
//         if (constant.userType != constant.exhibitorUser &&
//             constant.budgetValue != '')
//           _buildTabContainer(
//             'Budget',
//             '',
//             '',
//             '',
//             constant.budgetValue,
//             false,
//             () {
//               showDialog(
//                 context: context,
//                 builder: (context) {
//                   return editDialog(
//                     height: size.height,
//                     width: size.width,
//                     title: 'Budget',
//                     text1: 'Budget',
//                     text2: '',
//                     text3: '',
//                     text4: '',
//                     controller1: _budgetController,
//                     controller2: TextEditingController(),
//                     controller3: TextEditingController(),
//                     controller4: TextEditingController(),
//                     isTwoFields: false,
//                     isMultiLine: false,
//                   );
//                 },
//               );
//             },
//           ),
//         if (constant.userType != constant.exhibitorUser &&
//             constant.expectedDateValue != '')
//           _buildTabContainer(
//             'Wedding Date',
//             '',
//             '',
//             '',
//             // constant.expectedDateValue,
//             DateFormatter.formatDayWithSuffix(constant.expectedDateValue),
//             false,
//             () {
//               _tempDateController.text =
//                   DateFormatter.formatDayWithSuffix(_rawDate);
//               showDialog(
//                 context: context,
//                 builder: (context) {
//                   return editDialog(
//                     height: size.height,
//                     width: size.width,
//                     title: 'Wedding Date',
//                     text1: 'Wedding Date',
//                     text2: '',
//                     text3: '',
//                     text4: '',
//                     // controller1: _weddingDateController,
//                     controller1: _tempDateController,
//                     controller2: TextEditingController(),
//                     controller3: TextEditingController(),
//                     controller4: TextEditingController(),
//                     isTwoFields: false,
//                     isMultiLine: false,
//                   );
//                 },
//               );
//             },
//           ),
//         if (constant.userType != constant.exhibitorUser &&
//             constant.destinationValue != '')
//           _buildTabContainer(
//             'Wedding Destination',
//             '',
//             '',
//             '',
//             constant.destinationValue,
//             false,
//             () {
//               showDialog(
//                 context: context,
//                 builder: (context) {
//                   return editDialog(
//                     height: size.height,
//                     width: size.width,
//                     title: 'Wedding Destination',
//                     text1: 'Wedding Destination',
//                     text2: '',
//                     text3: '',
//                     text4: '',
//                     controller1: _destinationController,
//                     controller2: TextEditingController(),
//                     controller3: TextEditingController(),
//                     controller4: TextEditingController(),
//                     isTwoFields: false,
//                     isMultiLine: true,
//                   );
//                 },
//               );
//             },
//           ),
//         if (constant.userType != constant.exhibitorUser &&
//             constant.destinationValue != '')
//           _buildTabContainer(
//             'Venue',
//             '',
//             '',
//             '',
//             constant.venueValue,
//             false,
//             () {
//               showDialog(
//                 context: context,
//                 builder: (context) {
//                   return editDialog(
//                     height: size.height,
//                     width: size.width,
//                     title: 'Venue',
//                     text1: 'Venue',
//                     text2: '',
//                     text3: '',
//                     text4: '',
//                     controller1: _venueController,
//                     controller2: TextEditingController(),
//                     controller3: TextEditingController(),
//                     controller4: TextEditingController(),
//                     isTwoFields: false,
//                     isMultiLine: true,
//                   );
//                 },
//               );
//             },
//           ),
//           SizedBox(height: 20),
//       ],
//     );
//   }

//   Widget _buildTabContainer(
//     String title,
//     String phone,
//     String email,
//     String officeNo,
//     String text,
//     bool isTwoValue,
//     VoidCallback onPressed,
//   ) {
//     var width = MediaQuery.of(context).size.width;
//     return Container(
//       margin: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
//       padding: const EdgeInsets.only(left: 20, right: 6, top: 12, bottom: 12),
//       decoration: BoxDecoration(
//           color: const Color.fromRGBO(204, 232, 234, 0.5),
//           borderRadius: BorderRadius.circular(10)),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                     height: 1.5,
//                     color: Color.fromRGBO(85, 85, 85, 1),
//                     // fontSize: 14,
//                     fontSize: convertFigmaToUIWidth(14, width),
//                     fontWeight: FontWeight.w600),
//               ),
//               // const SizedBox(height: 7),
//               SizedBox(height: convertFigmaToUIWidth(7, width)),
//               isTwoValue
//                   ? Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         RichText(
//                           text: TextSpan(
//                             children: [
//                               TextSpan(
//                                 text: 'Mobile Number: ',
//                                 style: TextStyle(
//                                     height: 1.5,
//                                     color: Color.fromRGBO(85, 85, 85, 1),
//                                     // fontSize: 11,
//                                     fontSize: convertFigmaToUIWidth(11, width),
//                                     fontWeight: FontWeight.w600),
//                               ),
//                               TextSpan(
//                                 text:
//                                     '${constant.countryCodeValue} ${constant.phoneValue}',
//                                 // text: '${constant.phoneValue}',
//                                 style: TextStyle(
//                                     height: 1.5,
//                                     color: Color.fromRGBO(85, 85, 85, 1),
//                                     // fontSize: 11,
//                                     fontSize: convertFigmaToUIWidth(11, width),
//                                     fontWeight: FontWeight.w400),
//                               ),
//                             ],
//                           ),
//                         ),
//                         // const SizedBox(height: 5),
//                         SizedBox(height: convertFigmaToUIWidth(5, width)),
//                         RichText(
//                           text: TextSpan(
//                             children: [
//                               TextSpan(
//                                 text: 'Email: ',
//                                 style: TextStyle(
//                                     height: 1.5,
//                                     color: Color.fromRGBO(85, 85, 85, 1),
//                                     // fontSize: 11,
//                                     fontSize: convertFigmaToUIWidth(11, width),
//                                     fontWeight: FontWeight.w600),
//                               ),
//                               TextSpan(
//                                 text: email,
//                                 style: TextStyle(
//                                     height: 1.5,
//                                     color: Color.fromRGBO(85, 85, 85, 1),
//                                     // fontSize: 11,
//                                     fontSize: convertFigmaToUIWidth(11, width),
//                                     fontWeight: FontWeight.w400),
//                               ),
//                             ],
//                           ),
//                         ),
//                         if (constant.userType == constant.exhibitorUser) ...[
//                           // const SizedBox(height: 5),
//                           SizedBox(height: convertFigmaToUIWidth(5, width)),
//                           RichText(
//                             text: TextSpan(
//                               children: [
//                                 TextSpan(
//                                   text: 'Office Number: ',
//                                   style: TextStyle(
//                                       height: 1.5,
//                                       color: Color.fromRGBO(85, 85, 85, 1),
//                                       // fontSize: 11,
//                                       fontSize:
//                                           convertFigmaToUIWidth(11, width),
//                                       fontWeight: FontWeight.w600),
//                                 ),
//                                 TextSpan(
//                                   text: officeNo,
//                                   style: TextStyle(
//                                       height: 1.5,
//                                       color: Color.fromRGBO(85, 85, 85, 1),
//                                       // fontSize: 11,
//                                       fontSize:
//                                           convertFigmaToUIWidth(11, width),
//                                       fontWeight: FontWeight.w400),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ],
//                     )
//                   : SizedBox(
//                       width: convertFigmaToUIWidth(300, width),
//                       child: RichText(
//                         text: TextSpan(
//                           children: [
//                             TextSpan(
//                               text: title == 'Budget' ? '£$text' : text,
//                               style: TextStyle(
//                                   color: Color.fromRGBO(85, 85, 85, 1),
//                                   fontSize: convertFigmaToUIWidth(11, width),
//                                   fontWeight: FontWeight.w400),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//             ],
//           ),
//           InkWell(
//             onTap: onPressed,
//             child: Icon(Icons.edit_note_rounded,
//                 color: cyangreen, size: convertFigmaToUIWidth(22, width)),
//           ),
//         ],
//       ),
//     );
//   }

//   onImageSelect() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? pickedFile =
//         await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       CroppedFile? croppedFile = await ImageCropper().cropImage(
//         sourcePath: pickedFile.path,
//         // cropStyle: CropStyle.circle,
//         // aspectRatioPresets: [CropAspectRatioPreset.square],
//         uiSettings: [
//           AndroidUiSettings(
//               cropStyle: CropStyle.circle,
//               aspectRatioPresets: [CropAspectRatioPreset.square],
//               toolbarTitle: 'Edit',
//               toolbarColor: cyangreen,
//               toolbarWidgetColor: Colors.white,
//               initAspectRatio: CropAspectRatioPreset.square,
//               lockAspectRatio: true),
//           IOSUiSettings(minimumAspectRatio: 1.0),
//         ],
//       );
//       if (croppedFile != null) {
//         File pic = File(croppedFile.path);
//         setState(() {
//           isLoading = true;
//         });
//         dynamic response = constant.userType == constant.exhibitorUser
//             ? await apiValue.editExhibitorProfileImage(context, pic)
//             : await apiValue.editVisitorProfileImage(context, pic);
//         if (response != null) {
//           showToast('Profile picture updated successfully');
//           showLocalNotification(9, 'Profile picture updated',
//               'The profile picture has been updated successfully');
//           initPref();
//         } else {
//           showToast('Try again later');
//         }
//       } else {
//         showToast('No image selected');
//       }
//     } else {
//       showToast('No image selected');
//     }
//   }
// }

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

import 'dart:io';
import 'package:event_pro/data/remote/api_value.dart';
import 'package:event_pro/data/local/contants.dart';
import 'package:event_pro/data/remote/get_user_data.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/view/base_screen.dart';
import 'package:event_pro/utils/basic_route.dart';
import 'package:event_pro/utils/color.dart';
import 'package:event_pro/sharedwidget/circular_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../data/local/shared_pref_helper.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _officeNoController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _weddingDateController = TextEditingController();
  final TextEditingController _tempDateController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();

  bool isLoading = true;
  String? selectedBudget;
  String fullPhoneNumber = '';
  String selectedCountryCode = SharedPreferencesHelper.getUserCountryCode();
  String _rawDate = '';

  final List<String> budgetList = [
    '0 - 10,000',
    '10,000 - 20,000',
    '20,000 - 30,000',
    '30,000 - 40,000',
    '40,000 Plus'
  ];

  @override
  void initState() {
    super.initState();
    initializeControllers();
    initPref();
  }

  void initializeControllers() {
    _nameController.text = constant.nameValue;
    _phoneController.text = constant.phoneValue;
    _emailController.text = constant.emailValue;
    _officeNoController.text = constant.officeNumber;
    _addressController.text = constant.addressValue;
    _rawDate = constant.expectedDateValue;
    _tempDateController.text = DateFormatter.formatDayWithSuffix(_rawDate);
    _budgetController.text = constant.budgetValue;
    _destinationController.text = constant.destinationValue;
    _venueController.text = constant.venueValue;

    if (budgetList.contains(constant.budgetValue)) {
      selectedBudget = constant.budgetValue;
    }
  }

  Future<void> initPref() async {
    await GetUserData().getUserDetails();
    setState(() {
      _venueController.text = constant.venueValue;
      isLoading = false;
    });
  }

  String formatDateWithSuffix(DateTime date) {
    final String day = DateFormat('d').format(date);
    final String month = DateFormat('MMM').format(date);
    final String year = DateFormat('y').format(date);
    String suffix = 'th';

    if (day.endsWith('1') && day != '11') {
      suffix = 'st';
    } else if (day.endsWith('2') && day != '12') {
      suffix = 'nd';
    } else if (day.endsWith('3') && day != '13') {
      suffix = 'rd';
    }

    return '$day$suffix $month $year';
  }

  Widget editDialog({
    required double height,
    required double width,
    required String title,
    required String text1,
    required String text2,
    required String text3,
    required String text4,
    required TextEditingController controller1,
    required TextEditingController controller2,
    required TextEditingController controller3,
    required TextEditingController controller4,
    required bool isTwoFields,
    required bool isMultiLine,
  }) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cyangreenLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                    height: 1.5,
                    color: const Color.fromRGBO(85, 85, 85, 1),
                    fontSize: convertFigmaToUIWidth(14, width),
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              _buildDialogFields(
                title: title,
                controller1: controller1,
                controller2: controller2,
                controller3: controller3,
                controller4: controller4,
                isTwoFields: isTwoFields,
                isMultiLine: isMultiLine,
                text1: text1,
                text2: text2,
                text3: text3,
                text4: text4,
              ),
              const SizedBox(height: 15),
              _buildSaveButton(title),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogFields({
    required String title,
    required TextEditingController controller1,
    required TextEditingController controller2,
    required TextEditingController controller3,
    required TextEditingController controller4,
    required bool isTwoFields,
    required bool isMultiLine,
    required String text1,
    required String text2,
    required String text3,
    required String text4,
  }) {
    var width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        if (title == 'Budget')
          _buildBudgetDropdown()
        else if (title == 'Wedding Date')
          _buildWeddingDateField(controller1)
        else
          _buildTextField(
            controller: controller1,
            labelText: title == 'Contact Details' ? text1 : null,
            isMultiLine: isMultiLine,
          ),
        if (isTwoFields) ...[
          SizedBox(height: convertFigmaToUIWidth(15, width)),
          _buildPhoneField(controller2, text2),
          SizedBox(height: convertFigmaToUIWidth(15, width)),
          _buildEmailField(controller3, text3),
          if (constant.userType == constant.exhibitorUser)
            SizedBox(height: convertFigmaToUIWidth(15, width)),
          if (constant.userType == constant.exhibitorUser)
            _buildOfficeNumberField(controller4, text4),
        ],
      ],
    );
  }

  Widget _buildBudgetDropdown() {
    var width = MediaQuery.of(context).size.width;
    return DropdownButtonFormField<String>(
      value: selectedBudget,
      isDense: true,
      isExpanded: true,
      hint: const Text('Select'),
      icon: const Icon(Icons.arrow_drop_down_sharp, color: cyangreen, size: 30),
      style: TextStyle(
          height: 1.5,
          color: Color.fromRGBO(85, 85, 85, 1),
          // fontSize: 15,
          fontSize: convertFigmaToUIWidth(15, width),
          fontWeight: FontWeight.w400),
      onChanged: (value) {
        setState(() {
          selectedBudget = value!;
          _budgetController.text = value;
        });
      },
      items: budgetList.map((type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        );
      }).toList(),
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildWeddingDateField(TextEditingController controller) {
    return TextField(
      controller: controller,
      maxLines: 1,
      autofocus: true,
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_month_outlined, color: cyangreen),
          onPressed: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) {
              _rawDate = DateFormat('yyyy-MM-dd').format(pickedDate);
              final String formattedDate =
                  DateFormatter.formatDayWithSuffix(_rawDate);
              _tempDateController.text = formattedDate;
              _weddingDateController.text = formattedDate;
            }
          },
        ),
      ),
      readOnly: true,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String? labelText,
    required bool isMultiLine,
  }) {
    var width = MediaQuery.of(context).size.width;
    return TextField(
      controller: controller,
      maxLines: isMultiLine ? 3 : 1,
      autofocus: true,
      decoration: InputDecoration(
        labelText: labelText,
        alignLabelWithHint: labelText != null,
        labelStyle: TextStyle(
            height: 1.5,
            color: const Color.fromRGBO(85, 85, 85, 1),
            // fontSize: 15,
            fontSize: convertFigmaToUIWidth(15, width),
            fontWeight: FontWeight.w600),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildPhoneField(TextEditingController controller, String labelText) {
    var width = MediaQuery.of(context).size.width;

    return Row(
      children: [
        /// ---- AUTO WIDTH COUNTRY FIELD ----
        IntrinsicWidth(
          child: Container(
            height: convertFigmaToUIWidth(50, width) ?? 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
            child: IntlPhoneField(
              initialCountryCode: getCountryISOCode(
                  SharedPreferencesHelper.getUserCountryCode()),
              showCountryFlag: true,
              showDropdownIcon: true,
              disableLengthCheck: true,
              dropdownIconPosition: IconPosition.trailing,
              flagsButtonPadding: const EdgeInsets.only(left: 12),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              onChanged: (phone) {
                setState(() {
                  selectedCountryCode = phone.countryCode;
                });
              },
              onCountryChanged: (country) {
                setState(() {
                  selectedCountryCode = "+${country.dialCode}";
                });
              },
            ),
          ),
        ),

        SizedBox(width: convertFigmaToUIWidth(8, width)),

        /// ---- PHONE NUMBER FIELD ----
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(13),
            ],
            decoration: InputDecoration(
              labelText: labelText,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(TextEditingController controller, String labelText) {
    var width = MediaQuery.of(context).size.width;
    return TextField(
      controller: controller,
      readOnly: _emailController.text.isNotEmpty,
      decoration: _emailController.text.isEmpty
          ? InputDecoration(
              labelText: labelText,
              alignLabelWithHint: true,
              labelStyle: TextStyle(
                  height: 1.5,
                  color: const Color.fromRGBO(85, 85, 85, 1),
                  // fontSize: 15,
                  fontSize: convertFigmaToUIWidth(15, width),
                  fontWeight: FontWeight.w600),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            )
          : InputDecoration(
              labelText: labelText,
              labelStyle: TextStyle(
                  height: 1.5,
                  color: const Color.fromRGBO(85, 85, 85, 1),
                  // fontSize: 15,
                  fontSize: convertFigmaToUIWidth(15, width),
                  fontWeight: FontWeight.w600),
              isDense: true,
              filled: true,
              fillColor: Colors.grey.shade300,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400)),
            ),
    );
  }

  Widget _buildOfficeNumberField(
      TextEditingController controller, String labelText) {
    var width = MediaQuery.of(context).size.width;
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
            height: 1.5,
            color: const Color.fromRGBO(85, 85, 85, 1),
            // fontSize: 15,
            fontSize: convertFigmaToUIWidth(15, width),
            fontWeight: FontWeight.w600),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(14)
      ],
    );
  }

  Widget _buildSaveButton(String title) {
    return GestureDetector(
      onTap: () async {
        await _handleSaveAction(title);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        margin: const EdgeInsets.only(top: 15),
        decoration: BoxDecoration(
            color: cyangreen, borderRadius: BorderRadius.circular(10)),
        child: const Text("Save", style: TextStyle(height: 1.5, color: white)),
      ),
    );
  }

  Future<void> _handleSaveAction(String title) async {
    if (title == "Contact Details" && selectedCountryCode.isEmpty) {
      showToast('Please select a country code');
      return; // Exit if no country code is selected
    }
    if (title == "Contact Details" && _phoneController.text.length < 8) {
      showToast('Mobile number needs minimum 8 digits');
      return; // Exit if contact number is empty
    }

    Navigator.pop(context);
    setState(() => isLoading = true);
    dynamic response;

    switch (title) {
      case "Contact Details":
        response = await _saveContactDetails();
        break;
      case "Address":
        response = await _saveAddress();
        break;
      case "Budget":
        response = await _saveBudget();
        break;
      case "Wedding Date":
        response = await _saveWeddingDate();
        break;
      case "Wedding Destination":
        response = await _saveWeddingDestination();
        break;
      case "Venue":
        response = await _saveVenue();
        break;
    }

    if (response != null) {
      showToast('Profile updated successfully');
      showLocalNotification(
        _getNotificationId(title),
        'Profile updated',
        '$title has been updated successfully',
      );
      initPref();
    } else {
      showToast('Try after sometime');
    }
  }

  Future<dynamic> _saveContactDetails() async {
    if (selectedCountryCode.isEmpty) {
      showToast('Please select a country code');
      return null;
    }

    if (constant.userType == constant.exhibitorUser) {
      return await apiValue.editExhibitorProfile(
        context,
        await capitalizeWords(_nameController.text),
        _emailController.text,
        selectedCountryCode,
        _phoneController.text,
        _officeNoController.text,
      );
    } else {
      if (_nameController.text.isEmpty) {
        showToast('Name cannot be empty');
        return null;
      }

      return await apiValue.editVisitorProfile(
        context,
        'contact',
        await capitalizeWords(_nameController.text),
        _emailController.text,
        selectedCountryCode,
        _phoneController.text,
        '',
        '',
        '',
        '',
        '',
      );
    }
  }

  Future<dynamic> _saveAddress() async {
    return await apiValue.editVisitorProfile(
      context,
      'address',
      '',
      '',
      '',
      '',
      _addressController.text,
      '',
      '',
      '',
      '',
    );
  }

  Future<dynamic> _saveBudget() async {
    return await apiValue.editVisitorProfile(
      context,
      'budget',
      '',
      '',
      '',
      '',
      '',
      _budgetController.text,
      '',
      '',
      '',
    );
  }

  Future<dynamic> _saveWeddingDate() async {
    return await apiValue.editVisitorProfile(
      context,
      'expected_date',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      _rawDate,
    );
  }

  Future<dynamic> _saveWeddingDestination() async {
    return await apiValue.editVisitorProfile(
      context,
      'destination',
      '',
      '',
      '',
      '',
      '',
      '',
      _destinationController.text,
      '',
      '',
    );
  }

  Future<dynamic> _saveVenue() async {
    return await apiValue.editVisitorProfile(context, 'venue', '', '', '', '',
        '', '', '', _venueController.text, '');
  }

  int _getNotificationId(String title) {
    switch (title) {
      case "Contact Details":
        return 2;
      case "Address":
        return 4;
      case "Budget":
        return 5;
      case "Wedding Date":
        return 6;
      case "Wedding Destination":
        return 7;
      case "Venue":
        return 8;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return BaseScreen(
      onItemSelected: (index) {
        Navigator.pushNamed(context, getRouteForIndex(index));
        // Navigator.pop(context, getRouteForIndex(index));
      },
      selectedIndex: 3,
      child: isLoading ? _buildLoadingScreen(size) : _buildProfileScreen(size),
    );
  }

  Widget _buildLoadingScreen(Size size) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          "My Profile",
          style: TextStyle(
              fontSize: convertFigmaToUIWidth(20, width),
              fontWeight: FontWeight.w700,
              color: Colors.white),
        ),
        flexibleSpace: Container(
          height: convertFigmaToUIWidth(200, width),
          decoration: BoxDecoration(
            color: cyangreen,
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30)),
          ),
        ),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildProfileScreen(Size size) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        backgroundColor: Color.fromRGBO(204, 232, 234, 0.7),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          "My Profile",
          style: TextStyle(
              height: 1.5,
              fontSize: convertFigmaToUIWidth(20, width),
              fontWeight: FontWeight.w600,
              color: Colors.white),
        ),
        flexibleSpace: Container(
          height: convertFigmaToUIWidth(200, width),
          decoration: BoxDecoration(
            color: cyangreen,
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30)),
          ),
        ),
        bottom: PreferredSize(
          preferredSize:
              Size.fromHeight(convertFigmaToUIWidth(230, width) ?? 230),
          child: Container(
            height: convertFigmaToUIWidth(230, width),
            width: size.width,
            color: Colors.transparent,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: 0,
                  child: GestureDetector(
                    onTap: onImageSelect,
                    child: getCircularImageWidget(
                        convertFigmaToUIWidth(200, width) ?? 200,
                        constant.imageLinkValue,
                        white,
                        cyangreen,
                        55,
                        getNameInitials(constant.nameValue)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            isLoading = true;
            initPref();
          });
        },
        child: Container(
          height: size.height,
          width: size.width,
          color: Color.fromRGBO(204, 232, 234, 0.7),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  constant.nameValue,
                  style: TextStyle(
                      height: 1.5,
                      // fontSize: 20,
                      fontSize: convertFigmaToUIWidth(20, width),
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(85, 85, 85, 1)),
                ),
                if (constant.userType != constant.exhibitorUser) ...[
                  const SizedBox(height: 9),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (constant.weddingRoleValue.toString() != 'null' &&
                          constant.weddingRoleValue != '')
                        Text(
                          "${constant.weddingRoleValue} | ",
                          style: TextStyle(
                              fontSize: convertFigmaToUIWidth(17.2, width),
                              fontWeight: FontWeight.w400,
                              color: const Color.fromRGBO(2, 141, 148, 1)),
                        ),
                      Text(
                        DateFormatter.formatDayWithSuffix(
                            constant.expectedDateValue),
                        style: TextStyle(
                            fontSize: convertFigmaToUIWidth(17.2, width),
                            fontWeight: FontWeight.w400,
                            color: const Color.fromRGBO(85, 85, 85, 1)),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: convertFigmaToUIWidth(25, width)),
                _buildProfileTabs(size),
                if (constant.userType != constant.exhibitorUser)
                  SizedBox(height: convertFigmaToUIWidth(100, width)),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildProfileTabs(Size size) {
    return Column(
      children: [
        _buildTabContainer(
          'Contact Details',
          constant.phoneValue,
          constant.emailValue,
          constant.officeNumber,
          '',
          true,
          () {
            showDialog(
              context: context,
              builder: (context) {
                _phoneController.text = constant.phoneValue;
                return editDialog(
                  height: size.height,
                  width: size.width,
                  title: 'Contact Details',
                  text1: 'Name',
                  text2: 'Mobile Number',
                  text3: 'Email',
                  text4: 'Office Number',
                  controller1: _nameController,
                  controller2: _phoneController,
                  controller3: _emailController,
                  controller4: _officeNoController,
                  isTwoFields: true,
                  isMultiLine: false,
                );
              },
            );
          },
        ),
        if (constant.userType != constant.exhibitorUser &&
            constant.addressValue != '')
          _buildTabContainer(
            'Address',
            '',
            '',
            '',
            constant.addressValue,
            false,
            () {
              showDialog(
                context: context,
                builder: (context) {
                  return editDialog(
                    height: size.height,
                    width: size.width,
                    title: 'Address',
                    text1: 'Address',
                    text2: '',
                    text3: '',
                    text4: '',
                    controller1: _addressController,
                    controller2: TextEditingController(),
                    controller3: TextEditingController(),
                    controller4: TextEditingController(),
                    isTwoFields: false,
                    isMultiLine: true,
                  );
                },
              );
            },
          ),
        if (constant.userType != constant.exhibitorUser &&
            constant.budgetValue != '')
          _buildTabContainer(
            'Budget',
            '',
            '',
            '',
            constant.budgetValue,
            false,
            () {
              showDialog(
                context: context,
                builder: (context) {
                  return editDialog(
                    height: size.height,
                    width: size.width,
                    title: 'Budget',
                    text1: 'Budget',
                    text2: '',
                    text3: '',
                    text4: '',
                    controller1: _budgetController,
                    controller2: TextEditingController(),
                    controller3: TextEditingController(),
                    controller4: TextEditingController(),
                    isTwoFields: false,
                    isMultiLine: false,
                  );
                },
              );
            },
          ),
        if (constant.userType != constant.exhibitorUser &&
            constant.expectedDateValue != '')
          _buildTabContainer(
            'Wedding Date',
            '',
            '',
            '',
            // constant.expectedDateValue,
            DateFormatter.formatDayWithSuffix(constant.expectedDateValue),
            false,
            () {
              _tempDateController.text =
                  DateFormatter.formatDayWithSuffix(_rawDate);
              showDialog(
                context: context,
                builder: (context) {
                  return editDialog(
                    height: size.height,
                    width: size.width,
                    title: 'Wedding Date',
                    text1: 'Wedding Date',
                    text2: '',
                    text3: '',
                    text4: '',
                    // controller1: _weddingDateController,
                    controller1: _tempDateController,
                    controller2: TextEditingController(),
                    controller3: TextEditingController(),
                    controller4: TextEditingController(),
                    isTwoFields: false,
                    isMultiLine: false,
                  );
                },
              );
            },
          ),
        if (constant.userType != constant.exhibitorUser &&
            constant.destinationValue != '')
          _buildTabContainer(
            'Wedding Destination',
            '',
            '',
            '',
            constant.destinationValue,
            false,
            () {
              showDialog(
                context: context,
                builder: (context) {
                  return editDialog(
                    height: size.height,
                    width: size.width,
                    title: 'Wedding Destination',
                    text1: 'Wedding Destination',
                    text2: '',
                    text3: '',
                    text4: '',
                    controller1: _destinationController,
                    controller2: TextEditingController(),
                    controller3: TextEditingController(),
                    controller4: TextEditingController(),
                    isTwoFields: false,
                    isMultiLine: true,
                  );
                },
              );
            },
          ),
        if (constant.userType != constant.exhibitorUser &&
            constant.destinationValue != '')
          _buildTabContainer(
            'Venue',
            '',
            '',
            '',
            constant.venueValue,
            false,
            () {
              showDialog(
                context: context,
                builder: (context) {
                  return editDialog(
                    height: size.height,
                    width: size.width,
                    title: 'Venue',
                    text1: 'Venue',
                    text2: '',
                    text3: '',
                    text4: '',
                    controller1: _venueController,
                    controller2: TextEditingController(),
                    controller3: TextEditingController(),
                    controller4: TextEditingController(),
                    isTwoFields: false,
                    isMultiLine: true,
                  );
                },
              );
            },
          ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTabContainer(
    String title,
    String phone,
    String email,
    String officeNo,
    String text,
    bool isTwoValue,
    VoidCallback onPressed,
  ) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
      padding: const EdgeInsets.only(left: 20, right: 6, top: 12, bottom: 12),
      decoration: BoxDecoration(
          color: const Color.fromRGBO(204, 232, 234, 0.5),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                    height: 1.5,
                    color: Color.fromRGBO(85, 85, 85, 1),
                    // fontSize: 14,
                    fontSize: convertFigmaToUIWidth(14, width),
                    fontWeight: FontWeight.w600),
              ),
              // const SizedBox(height: 7),
              SizedBox(height: convertFigmaToUIWidth(7, width)),
              isTwoValue
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Mobile Number: ',
                                style: TextStyle(
                                    height: 1.5,
                                    color: Color.fromRGBO(85, 85, 85, 1),
                                    // fontSize: 11,
                                    fontSize: convertFigmaToUIWidth(11, width),
                                    fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                text:
                                    '${constant.countryCodeValue} ${constant.phoneValue}',
                                // text: '${constant.phoneValue}',
                                style: TextStyle(
                                    height: 1.5,
                                    color: Color.fromRGBO(85, 85, 85, 1),
                                    // fontSize: 11,
                                    fontSize: convertFigmaToUIWidth(11, width),
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                        // const SizedBox(height: 5),
                        SizedBox(height: convertFigmaToUIWidth(5, width)),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Email: ',
                                style: TextStyle(
                                    height: 1.5,
                                    color: Color.fromRGBO(85, 85, 85, 1),
                                    // fontSize: 11,
                                    fontSize: convertFigmaToUIWidth(11, width),
                                    fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                text: email,
                                style: TextStyle(
                                    height: 1.5,
                                    color: Color.fromRGBO(85, 85, 85, 1),
                                    // fontSize: 11,
                                    fontSize: convertFigmaToUIWidth(11, width),
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                        if (constant.userType == constant.exhibitorUser) ...[
                          // const SizedBox(height: 5),
                          SizedBox(height: convertFigmaToUIWidth(5, width)),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Office Number: ',
                                  style: TextStyle(
                                      height: 1.5,
                                      color: Color.fromRGBO(85, 85, 85, 1),
                                      // fontSize: 11,
                                      fontSize:
                                          convertFigmaToUIWidth(11, width),
                                      fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text: officeNo,
                                  style: TextStyle(
                                      height: 1.5,
                                      color: Color.fromRGBO(85, 85, 85, 1),
                                      // fontSize: 11,
                                      fontSize:
                                          convertFigmaToUIWidth(11, width),
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    )
                  : SizedBox(
                      width: convertFigmaToUIWidth(300, width),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: title == 'Budget' ? '£$text' : text,
                              style: TextStyle(
                                  color: Color.fromRGBO(85, 85, 85, 1),
                                  fontSize: convertFigmaToUIWidth(11, width),
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
          InkWell(
            onTap: onPressed,
            child: Icon(Icons.edit_note_rounded,
                color: cyangreen, size: convertFigmaToUIWidth(22, width)),
          ),
        ],
      ),
    );
  }

  onImageSelect() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        // cropStyle: CropStyle.circle,
        // aspectRatioPresets: [CropAspectRatioPreset.square],
        uiSettings: [
          AndroidUiSettings(
              cropStyle: CropStyle.circle,
              aspectRatioPresets: [CropAspectRatioPreset.square],
              toolbarTitle: 'Edit',
              toolbarColor: cyangreen,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true),
          IOSUiSettings(minimumAspectRatio: 1.0),
        ],
      );
      if (croppedFile != null) {
        File pic = File(croppedFile.path);
        setState(() {
          isLoading = true;
        });
        dynamic response = constant.userType == constant.exhibitorUser
            ? await apiValue.editExhibitorProfileImage(context, pic)
            : await apiValue.editVisitorProfileImage(context, pic);
        if (response != null) {
          showToast('Profile picture updated successfully');
          showLocalNotification(9, 'Profile picture updated',
              'The profile picture has been updated successfully');
          initPref();
        } else {
          showToast('Try again later');
        }
      } else {
        showToast('No image selected');
      }
    } else {
      showToast('No image selected');
    }
  }
}
