import 'package:flutter/material.dart';
import 'package:musikat_web_admin/models/user_model.dart';
import 'package:musikat_web_admin/screens/users/user_info_screen.dart';
import 'package:musikat_web_admin/utils/constants.dart';
import 'package:musikat_web_admin/widgets/loading_indicator.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  bool _isAscending = true;
  int _sortColumnIndex = 0;
  String _searchQuery = '';

  void _sortTable(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _isAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    right: 30, left: 30, top: 30, bottom: 10),
                child: Text(
                  'Users',
                  style: welcomeStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 30),
                child: Container(
                  margin: const EdgeInsets.all(5),
                  padding: const EdgeInsets.all(5),
                  width: 250,
                  height: 50,
                  child: SearchBar(
                      hintText: 'Search for a user...',
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      }),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<UserModel>>(
                  future: UserModel.getUsers(),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<List<UserModel>> snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: LoadingIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      final users = snapshot.data;
                      final filteredUsers = users!
                          .where((user) =>
                              user.uid.toLowerCase().contains(_searchQuery) ||
                              user.username
                                  .toLowerCase()
                                  .contains(_searchQuery) ||
                              user.email.toLowerCase().contains(_searchQuery))
                          .toList();
                      filteredUsers.sort((a, b) {
                        final aValue = _sortColumnIndex == 0
                            ? a.uid
                            : _sortColumnIndex == 1
                                ? a.username
                                : a.email;
                        final bValue = _sortColumnIndex == 0
                            ? b.uid
                            : _sortColumnIndex == 1
                                ? b.username
                                : b.email;
                        final comparison = Comparable.compare(aValue, bValue);
                        return _isAscending ? comparison : -comparison;
                      });
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: DataTable(
                            dataRowMinHeight: 5,
                            columns: [
                              DataColumn(
                                label: const Text('USER ID',
                                    style: TextStyle(color: Colors.white)),
                                onSort: (columnIndex, ascending) {
                                  _sortTable(columnIndex, ascending);
                                },
                              ),
                              DataColumn(
                                label: const Text('USERNAME',
                                    style: TextStyle(color: Colors.white)),
                                onSort: (columnIndex, ascending) {
                                  _sortTable(columnIndex, ascending);
                                },
                              ),
                              DataColumn(
                                label: const Text('EMAIL',
                                    style: TextStyle(color: Colors.white)),
                                onSort: (columnIndex, ascending) {
                                  _sortTable(columnIndex, ascending);
                                },
                              ),
                              const DataColumn(
                                label: Icon(Icons.view_agenda,
                                    color: Colors.white),
                              ),
                              const DataColumn(
                                label: Icon(Icons.delete, color: Colors.white),
                              ),
                            ],
                            rows: filteredUsers
                                .map((user) => DataRow(
                                      cells: [
                                        DataCell(
                                          Text(user.uid, style: sideNavStyle),
                                        ),
                                        DataCell(
                                          Text(user.username,
                                              style: sideNavStyle),
                                        ),
                                        DataCell(
                                          Text(user.email, style: sideNavStyle),
                                        ),
                                        DataCell(
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          UserInfoScreen(
                                                            selectedUser: user.uid,
                                                          )));
                                            },
                                            child: Text(
                                              'View',
                                              style: shortDefaultStyle,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: musikatColor,
                                            ),
                                            onPressed: () {},
                                            child: Text(
                                              'Delete',
                                              style: shortDefaultStyle,
                                            ),
                                          ),
                                        )
                                      ],
                                    ))
                                .toList(),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
