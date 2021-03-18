import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'ApplicationConstants.dart';

class AdsRemove extends StatefulWidget {
  AdsRemove({Key key}) : super(key: key);

  @override
  _AdsRemoveState createState() => _AdsRemoveState();
}

class _AdsRemoveState extends State<AdsRemove> {

  InAppPurchaseConnection _iap = InAppPurchaseConnection.instance;

  bool _available = true;

  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];

  StreamSubscription _subscription;

  @override
  void initState() {
    _initialize();

    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  _getProducts() async {
    Set<String> ids = Set.from([ApplicationConstants.ad_remove_iap]);
    ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    setState(() {
      _products = response.productDetails;
      print('products are ${_products.toString()}');
    });
  }
  _getPastPurchases() async {
    QueryPurchaseDetailsResponse response = await _iap.queryPastPurchases();
    setState(() {
      _purchases = response.pastPurchases;
      print('purchases are ${_purchases.toString()}');

    });
  }
  void _initialize() async {

    _available = await _iap.isAvailable();
    if(_available){
      await _getProducts();
      await _getPastPurchases();
      List<Future> futures = [_getProducts(),_getPastPurchases()];
      await Future.wait(futures);

      _verifyPurchase();

      _subscription = _iap.purchaseUpdatedStream.listen((data){
        setState(() {
          print('NEW PURCHASE');
          _purchases = data;
          _verifyPurchase();
        });
      });

    }
  }

  PurchaseDetails _hasPurchased (String productID){
    print('checking hasPurchased $productID');
    return _purchases.firstWhere((element) => element.productID==productID,orElse: ()=> null);
  }

  Future<void> _verifyPurchase() async {
    PurchaseDetails purchase = _hasPurchased(ApplicationConstants.ad_remove_iap);
    final pending = !purchase.billingClientPurchase.isAcknowledged;
    if (pending) {
      await _iap.completePurchase(purchase);
    }

    if(purchase!=null&&purchase.status==PurchaseStatus.purchased&&purchase.billingClientPurchase.isAcknowledged){
      Fluttertoast.showToast(msg: 'Thank you for your purchase');
    }
  }

  void _buyProduct(ProductDetails prod){
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    _iap.buyNonConsumable(purchaseParam: purchaseParam).then(
        (value){
          if(value){

          }else{

          }
        }
    );

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Remove Ads?'),
        ),
        body:Column(
          children: [

            for(var prod in _products)
              if(_hasPurchased(prod.id)!=null)
                ...[
                  ListTile(
                    title:Text(prod.title) ,
                    subtitle: Text(prod.description),
                    trailing: ElevatedButton(onPressed: () {

                    },child: Text('Purchased'),
                    ),
                  ),
                ]
              else...[
                ListTile(
                  title:Text(prod.title) ,
                  subtitle: Text(prod.description),
                  trailing: ElevatedButton(onPressed: () {

                    _buyProduct(prod);
                  },child: Text(prod.price),
                  ),
                ),
              ]
          ],
        )
    );
  }
}