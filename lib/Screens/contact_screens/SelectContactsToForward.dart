//*************   © Copyrighted by OkiTel. An Exclusive item of Kostricani. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:fiberchat/Configs/Enum.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Screens/call_history/callhistory.dart';
import 'package:fiberchat/Screens/calling_screen/pickup_layout.dart';
import 'package:fiberchat/Services/Providers/AvailableContactsProvider.dart';
import 'package:fiberchat/Services/Providers/GroupChatProvider.dart';
import 'package:fiberchat/Services/Providers/Observer.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Models/DataModel.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectContactsToForward extends StatefulWidget {
  const SelectContactsToForward({
    required this.currentUserNo,
    required this.contentPeerNo,
    required this.model,
    required this.prefs,
    required this.onSelect,
    required this.messageOwnerPhone,
    this.groupID,
  });
  final String? groupID;
  final String? currentUserNo;
  final String? contentPeerNo;
  final DataModel? model;
  final SharedPreferences prefs;
  final String messageOwnerPhone;
  final Function(List<dynamic> selectedList) onSelect;

  @override
  _SelectContactsToForwardState createState() =>
      new _SelectContactsToForwardState();
}

class _SelectContactsToForwardState extends State<SelectContactsToForward>
    with AutomaticKeepAliveClientMixin {
  GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();
  Map<String?, String?>? contacts;
  bool isGroupsloading = true;
  List<Map<String, dynamic>> joinedGroupsList = [];
  List<Map<String, dynamic>> selectedDynamicListFORUSERS = [];
  List<Map<String, dynamic>> selectedDynamicListFORGROUPS = [];
  @override
  bool get wantKeepAlive => true;

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void initState() {
    super.initState();
    fetchJoinedGroups();
  }

  fetchJoinedGroups() async {
    await FirebaseFirestore.instance
        .collection(DbPaths.collectiongroups)
        .where(Dbkeys.groupMEMBERSLIST, arrayContains: widget.currentUserNo)
        .orderBy(Dbkeys.groupCREATEDON, descending: true)
        .get()
        .then((groupsList) {
      if (groupsList.docs.length > 0) {
        groupsList.docs.forEach((group) {
          joinedGroupsList.add(group.data());
          if (groupsList.docs.last[Dbkeys.groupID] == group[Dbkeys.groupID]) {
            isGroupsloading = false;
            print('isGroupsloading $isGroupsloading');
          }
          setState(() {});
        });
      } else {
        isGroupsloading = false;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  loading() {
    return Stack(children: [
      Container(
        child: Center(
            child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(fiberchatBlue),
        )),
      )
    ]);
  }

  int currentUploadingIndex = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Fiberchat.toast(widget.contentPeerNo.toString());
    return PickupLayout(
        prefs: widget.prefs,
        scaffold: Fiberchat.getNTPWrappedWidget(ScopedModel<DataModel>(
            model: widget.model!,
            child: ScopedModelDescendant<DataModel>(
                builder: (context, child, model) {
              return Consumer<AvailableContactsProvider>(
                  builder: (context, contactsProvider, _child) => Consumer<
                          List<GroupModel>>(
                      builder: (context, groupList, _child) => Scaffold(
                          bottomSheet: selectedDynamicListFORUSERS.length !=
                                      0 ||
                                  selectedDynamicListFORGROUPS.length != 0
                              ? Container(
                                  padding: EdgeInsets.only(top: 6),
                                  width: MediaQuery.of(context).size.width,
                                  height: 97,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    physics: AlwaysScrollableScrollPhysics(),
                                    children: [
                                      ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          itemCount:
                                              selectedDynamicListFORGROUPS
                                                  .reversed
                                                  .toList()
                                                  .length,
                                          itemBuilder: (context, int i) {
                                            var m = selectedDynamicListFORGROUPS
                                                .reversed
                                                .toList()[i];
                                            return Stack(
                                              children: [
                                                Container(
                                                  width: 80,
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          11, 10, 12, 10),
                                                  child: Column(
                                                    children: [
                                                      customCircleAvatarGroup(
                                                          url: m.containsKey(Dbkeys
                                                                  .groupPHOTOURL)
                                                              ? m[Dbkeys
                                                                  .groupPHOTOURL]
                                                              : '',
                                                          radius: 20),
                                                      SizedBox(
                                                        height: 7,
                                                      ),
                                                      Text(
                                                        selectedDynamicListFORGROUPS
                                                                    .reversed
                                                                    .toList()[i]
                                                                [Dbkeys
                                                                    .groupNAME] ??
                                                            '',
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Positioned(
                                                  right: 17,
                                                  top: 5,
                                                  child: new InkWell(
                                                    onTap: () {
                                                      setStateIfMounted(() {
                                                        selectedDynamicListFORGROUPS
                                                            .remove(
                                                                selectedDynamicListFORGROUPS
                                                                    .reversed
                                                                    .toList()[i]);
                                                      });
                                                    },
                                                    child: new Container(
                                                      width: 20.0,
                                                      height: 20.0,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      decoration:
                                                          new BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.black,
                                                      ),
                                                      child: Icon(
                                                        Icons.close,
                                                        size: 14,
                                                        color: Colors.white,
                                                      ),
                                                    ), //............
                                                  ),
                                                )
                                              ],
                                            );
                                          }),
                                      ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          itemCount: selectedDynamicListFORUSERS
                                              .reversed
                                              .toList()
                                              .length,
                                          itemBuilder: (context, int i) {
                                            return widget.contentPeerNo ==
                                                        selectedDynamicListFORUSERS
                                                                .reversed
                                                                .toList()[i]
                                                            [Dbkeys.phone] ||
                                                    widget.currentUserNo ==
                                                        selectedDynamicListFORUSERS
                                                                .reversed
                                                                .toList()[i]
                                                            [Dbkeys.phone]
                                                ? SizedBox(
                                                    height: 0,
                                                    width: 0,
                                                  )
                                                : Stack(
                                                    children: [
                                                      Container(
                                                        width: 80,
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                11, 10, 12, 10),
                                                        child: Column(
                                                          children: [
                                                            customCircleAvatar(
                                                                url: selectedDynamicListFORUSERS
                                                                        .reversed
                                                                        .toList()[i]
                                                                    [Dbkeys
                                                                        .photoUrl],
                                                                radius: 20),
                                                            SizedBox(
                                                              height: 7,
                                                            ),
                                                            Text(
                                                              selectedDynamicListFORUSERS
                                                                      .reversed
                                                                      .toList()[i]
                                                                  [Dbkeys
                                                                      .nickname],
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Positioned(
                                                        right: 17,
                                                        top: 5,
                                                        child: new InkWell(
                                                          onTap: () {
                                                            setStateIfMounted(
                                                                () {
                                                              selectedDynamicListFORUSERS.remove(
                                                                  selectedDynamicListFORUSERS
                                                                      .reversed
                                                                      .toList()[i]);
                                                            });
                                                          },
                                                          child: new Container(
                                                            width: 20.0,
                                                            height: 20.0,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(2.0),
                                                            decoration:
                                                                new BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            child: Icon(
                                                              Icons.close,
                                                              size: 14,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ), //............
                                                        ),
                                                      )
                                                    ],
                                                  );
                                          }),
                                    ],
                                  ),
                                )
                              : SizedBox(),
                          key: _scaffold,
                          backgroundColor: fiberchatWhite,
                          appBar: AppBar(
                            elevation:
                                DESIGN_TYPE == Themetype.messenger ? 0.4 : 1,
                            actions: <Widget>[
                              selectedDynamicListFORUSERS.length != 0 ||
                                      selectedDynamicListFORGROUPS.length != 0
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.check,
                                        color: DESIGN_TYPE == Themetype.whatsapp
                                            ? fiberchatWhite
                                            : fiberchatBlack,
                                      ),
                                      onPressed: () {
                                        List<dynamic> finalList = [];
                                        selectedDynamicListFORGROUPS
                                            .forEach((element) {
                                          finalList.add(element);
                                          setStateIfMounted(() {});
                                        });
                                        selectedDynamicListFORUSERS
                                            .forEach((element) {
                                          finalList.add(element);
                                          setStateIfMounted(() {});
                                        });
                                        widget.onSelect(finalList);
                                        Navigator.of(context).pop();
                                      })
                                  : SizedBox()
                            ],
                            titleSpacing: -5,
                            leading: IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: Icon(
                                Icons.arrow_back,
                                size: 24,
                                color: DESIGN_TYPE == Themetype.whatsapp
                                    ? fiberchatWhite
                                    : fiberchatBlack,
                              ),
                            ),
                            backgroundColor: DESIGN_TYPE == Themetype.whatsapp
                                ? fiberchatDeepGreen
                                : fiberchatWhite,
                            centerTitle: false,
                            // leadingWidth: 40,
                            title: Text(
                              getTranslated(
                                  this.context, 'selectcontactstoforward'),
                              style: TextStyle(
                                fontSize: 18,
                                color: DESIGN_TYPE == Themetype.whatsapp
                                    ? fiberchatWhite
                                    : fiberchatBlack,
                              ),
                            ),
                          ),
                          body: RefreshIndicator(
                            onRefresh: () {
                              return contactsProvider.fetchContacts(context,
                                  model, widget.currentUserNo!, widget.prefs);
                            },
                            child: contactsProvider
                                            .searchingcontactsindatabase ==
                                        true ||
                                    isGroupsloading == true
                                ? loading()
                                : contactsProvider
                                            .alreadyJoinedUsersPhoneNameAsInServer
                                            .length ==
                                        0
                                    ? ListView(shrinkWrap: true, children: [
                                        Padding(
                                            padding: EdgeInsets.only(
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    2.5),
                                            child: Center(
                                              child: Text(
                                                  getTranslated(context,
                                                      'nosearchresult'),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: fiberchatGrey)),
                                            ))
                                      ])
                                    : ListView(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 10, 10, 10),
                                        physics:
                                            AlwaysScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        children: [
                                          ListView.builder(
                                            padding: EdgeInsets.all(0),
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount: joinedGroupsList.length,
                                            itemBuilder: (context, i) {
                                              return Column(
                                                children: [
                                                  ListTile(
                                                    trailing: Container(
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                fiberchatGrey,
                                                            width: 1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: selectedDynamicListFORGROUPS.lastIndexWhere((element) =>
                                                                  element[Dbkeys
                                                                      .groupID] ==
                                                                  joinedGroupsList[
                                                                          i][
                                                                      Dbkeys
                                                                          .groupID]) >=
                                                              0
                                                          ? Icon(
                                                              Icons.check,
                                                              size: 19.0,
                                                              color:
                                                                  fiberchatLightGreen,
                                                            )
                                                          : Icon(
                                                              null,
                                                              size: 19.0,
                                                            ),
                                                    ),
                                                    leading: customCircleAvatarGroup(
                                                        url: joinedGroupsList[i]
                                                                .containsKey(Dbkeys
                                                                    .groupPHOTOURL)
                                                            ? joinedGroupsList[
                                                                    i][
                                                                Dbkeys
                                                                    .groupPHOTOURL]
                                                            : '',
                                                        radius: 22),
                                                    title: Text(
                                                      joinedGroupsList[i]
                                                          [Dbkeys.groupNAME],
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: fiberchatBlack,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    subtitle: Text(
                                                      '${joinedGroupsList[i][Dbkeys.groupMEMBERSLIST].length} ${getTranslated(context, 'participants')}',
                                                      style: TextStyle(
                                                        color: fiberchatGrey,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      final observer =
                                                          Provider.of<Observer>(
                                                              this.context,
                                                              listen: false);
                                                      setStateIfMounted(() {
                                                        if (selectedDynamicListFORGROUPS
                                                                .lastIndexWhere((element) =>
                                                                    element[Dbkeys
                                                                        .groupID] ==
                                                                    joinedGroupsList[
                                                                            i][
                                                                        Dbkeys
                                                                            .groupID]) >=
                                                            0) {
                                                          selectedDynamicListFORGROUPS
                                                              .remove(
                                                                  joinedGroupsList[
                                                                      i]);
                                                          setStateIfMounted(
                                                              () {});
                                                        } else {
                                                          if (selectedDynamicListFORUSERS
                                                                      .length +
                                                                  selectedDynamicListFORGROUPS
                                                                      .length >
                                                              observer.maxNoOfContactsSelectForForward -
                                                                  1) {
                                                            Fiberchat.toast(
                                                                getTranslated(
                                                                        context,
                                                                        'maxallowed') +
                                                                    ' : ${observer.maxNoOfContactsSelectForForward}');
                                                          } else {
                                                            selectedDynamicListFORGROUPS
                                                                .add(
                                                                    joinedGroupsList[
                                                                        i]);
                                                            setStateIfMounted(
                                                                () {});
                                                          }
                                                        }
                                                      });
                                                    },
                                                  ),
                                                  Divider(
                                                    height: 2,
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                          ListView.builder(
                                            padding: EdgeInsets.all(0),
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount: contactsProvider
                                                .alreadyJoinedUsersPhoneNameAsInServer
                                                .length,
                                            itemBuilder: (context, idx) {
                                              String phone = contactsProvider
                                                  .alreadyJoinedUsersPhoneNameAsInServer[
                                                      idx]
                                                  .phone;
                                              Widget? alreadyAddedUser;

                                              return widget.contentPeerNo ==
                                                          contactsProvider
                                                              .alreadyJoinedUsersPhoneNameAsInServer[
                                                                  idx]
                                                              .phone ||
                                                      widget.currentUserNo ==
                                                          contactsProvider
                                                              .alreadyJoinedUsersPhoneNameAsInServer[
                                                                  idx]
                                                              .phone
                                                  ? SizedBox(
                                                      height: 0,
                                                      width: 0,
                                                    )
                                                  : alreadyAddedUser ??
                                                      FutureBuilder<
                                                              Map<String,
                                                                  dynamic>>(
                                                          future:
                                                              contactsProvider
                                                                  .getUserDoc(
                                                                      phone),
                                                          builder: (BuildContext
                                                                  context,
                                                              AsyncSnapshot<
                                                                      Map<String,
                                                                          dynamic>>
                                                                  snapshot) {
                                                            if (snapshot
                                                                .hasData) {
                                                              Map<String,
                                                                      dynamic>
                                                                  user =
                                                                  snapshot
                                                                      .data!;
                                                              return Column(
                                                                children: [
                                                                  ListTile(
                                                                    trailing:
                                                                        Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        border: Border.all(
                                                                            color:
                                                                                fiberchatGrey,
                                                                            width:
                                                                                1),
                                                                        borderRadius:
                                                                            BorderRadius.circular(5),
                                                                      ),
                                                                      child: selectedDynamicListFORUSERS.lastIndexWhere((element) => element[Dbkeys.phone] == user[Dbkeys.phone]) >=
                                                                              0
                                                                          ? Icon(
                                                                              Icons.check,
                                                                              size: 19.0,
                                                                              color: fiberchatLightGreen,
                                                                            )
                                                                          : Icon(
                                                                              null,
                                                                              size: 19.0,
                                                                            ),
                                                                    ),
                                                                    leading:
                                                                        customCircleAvatar(
                                                                      url: user[
                                                                          Dbkeys
                                                                              .photoUrl],
                                                                      radius:
                                                                          22,
                                                                    ),
                                                                    title: Text(
                                                                        user[Dbkeys.nickname] ??
                                                                            '',
                                                                        style: TextStyle(
                                                                            color:
                                                                                fiberchatBlack)),
                                                                    subtitle: Text(
                                                                        phone,
                                                                        style: TextStyle(
                                                                            color:
                                                                                fiberchatGrey)),
                                                                    // contentPadding: EdgeInsets.symmetric(
                                                                    //     horizontal:
                                                                    //         10.0,
                                                                    //     vertical:
                                                                    // 0.0),
                                                                    onTap: () {
                                                                      final observer = Provider.of<
                                                                              Observer>(
                                                                          this
                                                                              .context,
                                                                          listen:
                                                                              false);
                                                                      setStateIfMounted(
                                                                          () {
                                                                        if (selectedDynamicListFORUSERS.lastIndexWhere((element) =>
                                                                                element[Dbkeys.phone] ==
                                                                                user[Dbkeys.phone]) >=
                                                                            0) {
                                                                          selectedDynamicListFORUSERS
                                                                              .remove(snapshot.data!);
                                                                          setStateIfMounted(
                                                                              () {});
                                                                        } else {
                                                                          if (snapshot.data![Dbkeys.phone] ==
                                                                              widget.messageOwnerPhone) {
                                                                          } else {
                                                                            if (selectedDynamicListFORUSERS.length + selectedDynamicListFORGROUPS.length >
                                                                                observer.maxNoOfContactsSelectForForward - 1) {
                                                                              Fiberchat.toast(getTranslated(context, 'maxallowed') + ' : ${observer.maxNoOfContactsSelectForForward}');
                                                                            } else {
                                                                              selectedDynamicListFORUSERS.add(snapshot.data!);
                                                                              setStateIfMounted(() {});
                                                                            }
                                                                          }
                                                                        }
                                                                      });
                                                                    },
                                                                  ),
                                                                  Divider(
                                                                    height: 2,
                                                                  )
                                                                ],
                                                              );
                                                            }
                                                            return SizedBox();
                                                          });
                                            },
                                          ),
                                        ],
                                      ),
                          ))));
            }))));
  }
}
