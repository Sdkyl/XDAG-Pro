import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/common/helper.dart';
import 'package:xdag/desktop/change_name_page.dart';
import 'package:xdag/desktop/create_page.dart';
import 'package:xdag/desktop/modal_frame.dart';
import 'package:xdag/desktop/security_page.dart';
import 'package:xdag/model/db_model.dart';
import 'package:xdag/model/wallet_modal.dart';
import 'package:xdag/page/common/check_page.dart';
import 'package:xdag/page/common/create_wallet_page.dart';
import 'package:xdag/widget/button.dart';
import 'package:xdag/widget/desktop.dart';
import 'package:xdag/widget/nav_header.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WalletListPage extends StatefulWidget {
  const WalletListPage({super.key});
  @override
  State<WalletListPage> createState() => _WalletListPageState();
}

class _WalletListPageState extends State<WalletListPage> {
  List<Wallet> list = [];
  void toCreatePage(BuildContext context, int type) async {
    if (Helper.isDesktop) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return DesktopCreateWalletPage(boxSize: const Size(500, 400), type: type);
        },
      );
    } else {
      await Navigator.pushNamed(context, '/create', arguments: CreateWalletPageRouteParams(isImport: type == 1));
    }

    getList();
  }

  @override
  void initState() {
    super.initState();
    getList();
  }

  void getList() async {
    WalletModal walletModal = Provider.of<WalletModal>(context, listen: false);
    List<Wallet> arr = [];
    for (int i = 0; i < walletModal.walletList.length; i++) {
      Wallet? wallet = walletModal.walletList.getAt(i);
      arr.add(wallet!);
    }
    setState(() {
      list = arr;
    });
  }

  void changeItem(int index, bool isDelete) {
    WalletModal walletModal = Provider.of<WalletModal>(context, listen: false);
    if (isDelete) {
      setState(() {
        list.removeAt(index);
      });
    } else {
      setState(() {
        Wallet? wallet = walletModal.walletList.getAt(index);
        list.insert(index, wallet!);
      });
    }
  }

  void deleteItem(int index) async {
    if (Helper.isDesktop) {
      showDialog(
        context: context,
        builder: (BuildContext context) => DesktopLockPage(
          checkCallback: (p0) async {
            if (p0) {
              WalletModal walletModal = Provider.of<WalletModal>(context, listen: false);
              await walletModal.deleteWallet(walletModal.walletList.getAt(index)!, index);
              getList();
            }
          },
        ),
      );
    } else {
      bool? res = await showModalBottomSheet(
        backgroundColor: DarkColors.bgColor,
        context: context,
        isScrollControlled: true,
        builder: (BuildContext buildContext) => CheckPage(
          onlyPassword: true,
          checkCallback: (bool isCheck) async {
            if (isCheck) {
              WalletModal walletModal = Provider.of<WalletModal>(context, listen: false);
              await walletModal.deleteWallet(walletModal.walletList.getAt(index)!, index);
              if (walletModal.walletList.isEmpty && mounted) {
                Navigator.of(context).pop(true);
              }
            }
          },
        ),
      );
      if (res != true) {
        changeItem(index, false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenHelper.initScreen(context);
    return Scaffold(
      backgroundColor: DarkColors.bgColor,
      body: Column(
        children: [
          NavHeader(
            title: AppLocalizations.of(context)!.select_Wallet,
            rightWidget: Helper.isDesktop
                ? const SizedBox(width: 40)
                : Row(
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: MyCupertinoButton(
                          padding: EdgeInsets.zero,
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          onPressed: () async {
                            Helper.changeAndroidStatusBarAndNavBar(true);
                            await showCupertinoModalPopup(
                              context: context,
                              barrierColor: Colors.black.withAlpha(153),
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: DarkColors.bgColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                  titlePadding: const EdgeInsets.fromLTRB(12.0, 15.0, 12, 0),
                                  insetPadding: const EdgeInsets.fromLTRB(15.0, 25.0, 15.0, 0.0),
                                  contentPadding: const EdgeInsets.fromLTRB(15.0, 25.0, 15.0, 0.0),
                                  actionsPadding: const EdgeInsets.fromLTRB(15.0, 25.0, 15.0, 20.0),
                                  title: Row(
                                    children: <Widget>[
                                      MyCupertinoButton(
                                        padding: EdgeInsets.zero,
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(color: DarkColors.blockColor, borderRadius: BorderRadius.circular(20.0)),
                                          child: const Icon(Icons.close, color: Colors.white, size: 24),
                                        ),
                                        onPressed: () => Navigator.of(context).pop(),
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: Center(
                                            child: Text(
                                              AppLocalizations.of(context)!.tips,
                                              style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w700)),
                                            ),
                                          )),
                                      const SizedBox(width: 40)
                                    ],
                                  ),
                                  content: Text(
                                    AppLocalizations.of(context)!.wallet_tips,
                                    style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.w500)),
                                  ),
                                  actions: <Widget>[
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Button(
                                          text: AppLocalizations.of(context)!.continueText,
                                          bgColor: DarkColors.mainColor,
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        )
                                      ],
                                    )
                                  ],
                                );
                              },
                            );
                            Helper.changeAndroidStatusBarAndNavBar(false);
                          },
                          child: const Icon(Icons.info_outline, color: Colors.white, size: 30),
                        ),
                      ),
                      const SizedBox(width: 15),
                    ],
                  ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 20),
              itemCount: list.length,
              itemBuilder: (BuildContext buildContext, int index) {
                Wallet? wallet = list[index];
                return Item(
                  wallet: wallet,
                  changeItem: changeItem,
                  index: index,
                  deleteItem: deleteItem,
                );
              },
            ),
          ),
          Container(height: 1, color: DarkColors.lineColor),
          Container(
            margin: EdgeInsets.fromLTRB(15, 20, 15, ScreenHelper.bottomPadding > 0 ? ScreenHelper.bottomPadding : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Button(
                  height: Helper.isDesktop ? 45 : 50,
                  text: AppLocalizations.of(context)!.createWallet,
                  width: ScreenHelper.screenWidth - 30,
                  bgColor: DarkColors.mainColor,
                  onPressed: () => toCreatePage(context, 0),
                ),
                const SizedBox(height: 20),
                Button(
                  height: Helper.isDesktop ? 45 : 50,
                  text: AppLocalizations.of(context)!.importWallet,
                  width: ScreenHelper.screenWidth - 30,
                  bgColor: DarkColors.lineColor,
                  onPressed: () => toCreatePage(context, 1),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class Item extends StatelessWidget {
  final Wallet? wallet;
  final void Function(int index, bool isDelete) changeItem;
  final void Function(int index) deleteItem;
  final int index;
  const Item({super.key, required this.wallet, required this.changeItem, required this.index, required this.deleteItem});

  void deleteItemFunc(BuildContext context) async {
    if (Helper.isDesktop) {
      final shouldDelete = await showDialog(
        context: context,
        builder: (BuildContext context) => DesktopAlertModal(
          title: AppLocalizations.of(context)!.attention,
          content: AppLocalizations.of(context)!.delete_tip,
        ),
      );
      if (shouldDelete == true) {
        deleteItem(index);
      }
      return;
    }
    changeItem(index, true);
    Helper.changeAndroidStatusBarAndNavBar(true);

    final shouldDelete = await showCupertinoModalPopup(
      context: context,
      barrierColor: Colors.black.withAlpha(153),
      builder: (BuildContext context) {
        Widget bottom = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Button(
              text: AppLocalizations.of(context)!.continueText,
              width: ScreenHelper.screenWidth - 60,
              bgColor: DarkColors.redColor,
              onPressed: () => Navigator.pop(context, true),
            ),
            const SizedBox(height: 20),
            Button(
              text: AppLocalizations.of(context)!.cancel,
              width: ScreenHelper.screenWidth - 60,
              bgColor: DarkColors.lineColor,
              onPressed: () => Navigator.pop(context, false),
            ),
          ],
        );
        return AlertDialog(
          backgroundColor: DarkColors.bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          titlePadding: const EdgeInsets.fromLTRB(12.0, 15.0, 12, 0),
          insetPadding: const EdgeInsets.fromLTRB(15.0, 25.0, 15.0, 0.0),
          contentPadding: const EdgeInsets.fromLTRB(15.0, 25.0, 15.0, 0.0),
          actionsPadding: const EdgeInsets.fromLTRB(15.0, 25.0, 15.0, 20.0),
          title: Row(
            children: <Widget>[
              MyCupertinoButton(
                padding: EdgeInsets.zero,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: DarkColors.blockColor,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
                onPressed: () => Navigator.pop(context, false),
              ),
              Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.attention,
                      style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w700)),
                    ),
                  )),
              const SizedBox(width: 40)
            ],
          ),
          content: Text(
            AppLocalizations.of(context)!.delete_tip,
            style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.w500)),
          ),
          actions: <Widget>[bottom],
        );
      },
    );
    Helper.changeAndroidStatusBarAndNavBar(false);
    if (shouldDelete == true) {
      deleteItem(index);
    } else {
      changeItem(index, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget icon = wallet!.isDef ? const CheckDot(color: DarkColors.mainColor, size: 20) : const SizedBox(width: 20);
    WalletModal walletModal = Provider.of<WalletModal>(context);
    Widget btn = Container(
      height: 70,
      decoration: BoxDecoration(
        color: DarkColors.blockColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wallet!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 3),
                  Text(wallet!.address, maxLines: 1, style: Helper.fitChineseFont(context, const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w700))),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (!Helper.isDesktop) const SizedBox(width: 0) else IconButton(onPressed: () => deleteItemFunc(context), icon: const Icon(Icons.delete, color: Colors.white)),
            SizedBox(width: Helper.isDesktop ? 10 : 0),
            if (!Helper.isDesktop)
              const SizedBox(width: 0)
            else
              IconButton(
                  onPressed: () {
                    showDialog(context: context, builder: (BuildContext context) => ChangeNamePage(index: index));
                  },
                  icon: const Icon(Icons.edit, color: Colors.white)),
            SizedBox(width: Helper.isDesktop ? 10 : 0),
            if (!Helper.isDesktop) icon else IconButton(onPressed: () => walletModal.changeSelect(wallet!), icon: wallet!.isDef ? const Icon(Icons.check_circle_rounded, color: DarkColors.mainColor) : const Icon(Icons.radio_button_unchecked, color: Colors.white)),
          ],
        ),
      ),
    );

    if (!Helper.isDesktop) {
      Widget btn1 = btn;
      btn = Dismissible(
        direction: DismissDirection.endToStart,
        onDismissed: (direction) => deleteItemFunc(context),
        key: Key(wallet!.address),
        background: Container(
          color: Colors.red,
          child: const Row(
            children: [
              Spacer(),
              Padding(
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.delete, color: Colors.white),
              ),
            ],
          ),
        ),
        child: MyCupertinoButton(padding: EdgeInsets.zero, onPressed: () => walletModal.changeSelect(wallet!), child: btn1),
      );
    }
    return Container(
      margin: Helper.isDesktop ? const EdgeInsets.fromLTRB(15, 0, 15, 15) : const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: btn,
      ),
    );
  }
}
