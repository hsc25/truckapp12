import 'package:Fluttergram/main.dart';
import 'package:Fluttergram/myapp/profile_page.dart';
import 'package:Fluttergram/myapp/search_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

PageController pageController;

class Navigation extends StatefulWidget {
  Navigation({Key key, this.title, this.initPage = 0}) : super(key: key);
  final String title;
  final int initPage;

  @override
  _Navigation createState() => _Navigation();
}

class _Navigation extends State<Navigation> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return navigator();
  }

  navigator() {
    return Scaffold(
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: Colors.white,
        activeColor: Colors.black,
        inactiveColor: Colors.grey,
        items: <BottomNavigationBarItem>[

          BottomNavigationBarItem(
              icon: Icon(
                Icons.account_circle,
                // color: (_page == 4) ? Colors.black : Colors.grey,
              ),
              title: Container(height: 0.0),
              backgroundColor: Colors.white),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
                // color: (_page == 5) ? Colors.black : Colors.grey,
              ),
              title: Container(height: 0.0),
              backgroundColor: Colors.white),
        ],
        onTap: navigationTapped,
        currentIndex: _page,
      ),
      body: PageView(
        children: [
          Container(
              color: Colors.white,
              child: ProfilePage(
                userId: currentUserModel.id,
              )),
          Container(color: Colors.white, child: SearchPage()),
        ],
        controller: pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: onPageChanged,
      ),
    );
  }

  void navigationTapped(int page) {
    //Animating Page
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  @override
  void initState() {
    super.initState();
    _page = widget.initPage;
    pageController = PageController(initialPage: widget.initPage);
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }
}
