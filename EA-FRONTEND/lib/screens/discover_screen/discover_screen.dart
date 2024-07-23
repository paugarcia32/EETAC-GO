// ignore_for_file: use_build_context_synchronously
import 'package:dio/dio.dart';
import '../../models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../widgets/profile_screen/card_user_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  await dotenv.load();
}

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  List<User> friendsList = [];
  List<User> notFriendsList = [];
  List<User> filteredUsers = [];
  String? _idUser = "";

  @override
  void initState() {
    super.initState();
    getUserInfo();
    getFriends();
    getNotFriends();
  }

  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _idUser = prefs.getString('idUser');
    });
  }

  Future getFriends() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    String path = 'http://${dotenv.env['API_URL']}/user/friends/$_idUser';
    try {
      var response = await Dio().get(
        path,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      var users = response.data as List;

      setState(() {
        friendsList = users.map((user) => User.fromJson2(user)).toList();
      });
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   elevation: 0,
      //   behavior: SnackBarBehavior.floating,
      //   backgroundColor: Colors.transparent,
      //   content: AwesomeSnackbarContent(
      //     title: 'Unable! $e',
      //     message: 'Try again later.',
      //     contentType: ContentType.failure,
      //   ),
      // ));
    }
  }

  Future getNotFriends() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    String path =
        'http://${dotenv.env['API_URL']}/user/friends/unfollowing/$_idUser';
    try {
      var response = await Dio().get(
        path,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      var users = response.data as List;

      setState(() {
        notFriendsList = users.map((user) => User.fromJson2(user)).toList();
        notFriendsList =
            notFriendsList.where((user) => user.active == true).toList();
        filteredUsers = notFriendsList;
      });
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   elevation: 0,
      //   behavior: SnackBarBehavior.floating,
      //   backgroundColor: Colors.transparent,
      //   content: AwesomeSnackbarContent(
      //     title: 'Unable! $e',
      //     message: 'Try again later.',
      //     contentType: ContentType.failure,
      //   ),
      // ));
    }
  }

  void _runFilter(String enteredKeyword) {
    setState(() {
      filteredUsers = notFriendsList.where((user) {
        final lowerCaseKeyword = enteredKeyword.toLowerCase();
        return user.username.toLowerCase().startsWith(lowerCaseKeyword) &&
            user.active == true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Theme.of(context).backgroundColor,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 35, 25, 35),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        child: TextFormField(
                          onChanged: (value) => _runFilter(value),
                          cursorColor: const Color.fromARGB(255, 222, 66, 66),
                          style: const TextStyle(
                              color: Color.fromARGB(255, 25, 25, 25)),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.filter_box,
                            hintStyle: TextStyle(
                                color: Color.fromARGB(255, 146, 146, 146)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.fromLTRB(18.5, 14, 0, 0),
                            suffixIcon: Icon(
                              Icons.search_rounded,
                              color: Color.fromARGB(255, 222, 66, 66),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: CustomScrollView(
                    slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            try {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: MyUserCard(
                                  idUserSession: _idUser!,
                                  idCardUser: filteredUsers[index].idUser,
                                  attr1: notFriendsList[index]
                                          .imageURL
                                          ?.toString() ??
                                      '',
                                  attr2: filteredUsers[index].username,
                                  attr3: filteredUsers[index].level.toString(),
                                  following: false,
                                ),
                              );
                            } catch (e) {
                              return const SizedBox();
                            }
                          },
                          childCount: filteredUsers.length,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
