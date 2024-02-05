import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:musikat_web_admin/controller/auth_controller.dart';
import 'package:musikat_web_admin/models/user_model.dart';
import 'package:musikat_web_admin/screens/categories/categories_screen.dart';
import 'package:musikat_web_admin/screens/home_screen.dart';
import 'package:musikat_web_admin/screens/playlists/playlists_screen.dart';
import 'package:musikat_web_admin/screens/users/user_list_screen.dart';
import 'package:musikat_web_admin/services/image_service.dart';
import 'package:musikat_web_admin/utils/constants.dart';
import 'package:musikat_web_admin/widgets/avatar.dart';
import 'package:musikat_web_admin/widgets/custom_dialog.dart';
import 'package:musikat_web_admin/widgets/toast_msg.dart';
import 'package:side_navigation/side_navigation.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final AuthController _authCon = AuthController();

  List<Widget> views = const [
    HomeScreen(),
    CategoriesScreen(),
    UserListScreen(),
    PlaylistScreen(),
    CategoriesScreen(),
  ];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideNavigationBar(
            theme: SideNavigationBarTheme(
              backgroundColor: drawerColor,
              togglerTheme: const SideNavigationBarTogglerTheme(
                  expandIconColor: Colors.white, shrinkIconColor: Colors.white),
              itemTheme: SideNavigationBarItemTheme(
                selectedBackgroundColor: musikatColor3,
                selectedItemColor: Colors.white,
                iconSize: 20,
              ),
              dividerTheme:  SideNavigationBarDividerTheme(
                showMainDivider: true,
                showFooterDivider: true,
                showHeaderDivider: true,
                mainDividerColor: musikatBackgroundColor,
              ),
            ),
            header: SideNavigationBarHeader(
                image: Image.asset(
                  'assets/images/musikat_logo.png',
                  width: 35,
                  height: 35,
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'MuSikat',
                      style: sloganStyle,
                    ),
                  ],
                ),
                subtitle: Text(
                  'administrator',
                  style: shortDefaultStyle,
                )),
            footer: SideNavigationBarFooter(
              label: StreamBuilder<UserModel>(
                stream: UserModel.fromUidStream(
                    uid: FirebaseAuth.instance.currentUser!.uid),
                builder: (context, AsyncSnapshot<UserModel?> snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return Container();
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  } else {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: (){
                            ImageService.updateProfileImage(context);
                          },
                          child: AvatarImage(
                            uid: FirebaseAuth.instance.currentUser!.uid,
                            radius: 20,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Row(
                          children: [
                            Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${snapshot.data!.firstName} ${snapshot.data!.lastName}',
                                    style: mediumThickStyle,
                                  ),
                                  Text(
                                    snapshot.data!.email,
                                    style: shortDefaultStyle,
                                  ),
                                ]),
                            const SizedBox(width: 10),
                            IconButton(
                                onPressed: () {
                                  _authCon.logout();
                                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                                  ToastMessage.show(context, 'Logged out');
                                },
                                icon: const Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                  size: 20,
                                )),
                          ],
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
            selectedIndex: selectedIndex,
            items: const [
              SideNavigationBarItem(
                icon: Icons.home,
                label: 'Home',
              ),
              SideNavigationBarItem(
                icon: Icons.dashboard,
                label: 'Categories',
              ),
              SideNavigationBarItem(
                icon: Icons.person,
                label: 'Users',
              ),
              SideNavigationBarItem(
                icon: Icons.queue_music,
                label: 'Playlists',
              ),
              SideNavigationBarItem(
                icon: Icons.report,
                label: 'Reports',
              ),
            ],
            onTap: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: views.elementAt(selectedIndex),
          )
        ],
      ),
    );
  }
}
