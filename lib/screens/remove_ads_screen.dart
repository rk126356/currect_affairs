import 'dart:async';

import 'package:currect_affairs/common/colors.dart';
import 'package:currect_affairs/providers/ad_provider.dart';
import 'package:currect_affairs/utils/make_premium_firebase.dart';
import 'package:currect_affairs/widgets/hint_popup.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

class RemoveAdsScreen extends StatefulWidget {
  const RemoveAdsScreen({Key? key}) : super(key: key);

  @override
  State<RemoveAdsScreen> createState() => _RemoveAdsScreenState();
}

class _RemoveAdsScreenState extends State<RemoveAdsScreen> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = <ProductDetails>[];

  final _productIdList = [
    'remove_ads_original',
    'remove_ads_discounted',
  ];

  String? _queryProductError = "";
  bool _isAvailable = false;
  List<String> _notFoundIds = <String>[];
  bool _loading = true;
  bool _purchasePending = false;

  @override
  void initState() {
    super.initState();
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (Object e) {
      debugPrint("error :${e.toString()}");
    });

    initStoreInfo();
  }

  void restoredPurchase() {
    _inAppPurchase.restorePurchases();
  }

  Future<void> initStoreInfo() async {
    setState(() {
      _loading = true;
    });
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (kDebugMode) {
      print(isAvailable);
    }
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = <ProductDetails>[];
        _notFoundIds = <String>[];
        _loading = false;
      });
      return;
    }

    final ProductDetailsResponse productDetailResponse =
        await _inAppPurchase.queryProductDetails(_productIdList.toSet());
    if (productDetailResponse.error != null) {
      setState(() {
        _queryProductError = productDetailResponse.error!.message;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _notFoundIds = productDetailResponse.notFoundIDs;
        if (kDebugMode) {
          print('_notFoundIds :: ${_notFoundIds.toList()}');
        }
        _loading = false;
      });
      return;
    }

    if (kDebugMode) {
      print(productDetailResponse.productDetails);
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = null;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _notFoundIds = productDetailResponse.notFoundIDs;
        if (kDebugMode) {
          print("Products details empty");
        }
        if (kDebugMode) {
          print('_notFoundIds : ${_notFoundIds.toList()}');
        }
        if (kDebugMode) {
          print(
              'productDetailResponse error :: ${productDetailResponse.error}');
        }
        setState(() {
          _loading = true;
        });
      });
      return;
    }

    setState(() {
      _products = productDetailResponse.productDetails;
      _notFoundIds = productDetailResponse.notFoundIDs;
      _isAvailable = isAvailable;
      if (kDebugMode) {
        print('_notFoundIds error : ${_notFoundIds.toList()}');
      }
      _loading = false;
    });
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    if (kDebugMode) {
      print("Listening....");
    }

    purchaseDetailsList.forEach((purchaseDetails) async {
      final adProvider = Provider.of<AdProvider>(context, listen: false);
      if (purchaseDetails.status == PurchaseStatus.pending) {
        setState(() {
          _purchasePending = true;
        });
      } else {
        setState(() {
          _purchasePending = false;
        });
        if (purchaseDetails.status == PurchaseStatus.error) {
          showSnackBar('Purchase Error');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          if (purchaseDetails.status == PurchaseStatus.restored) {
            adProvider.setIsPremium(true);
            makePremium();
            showSuccess('Restored Successfully');
          } else {
            bool validPurchase = await _verifyPurchase(purchaseDetails);
            if (validPurchase) {
              adProvider.setIsPremium(true);
              makePremium();
              showSuccess('Purchased Successfully');
              await _inAppPurchase.completePurchase(purchaseDetails);
            } else {
              showSnackBar('Invalid Purchase');
              await _inAppPurchase.completePurchase(purchaseDetails);
            }
          }
        }
      }
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    return true;
  }

  void showSuccess(String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return HintPopup(
          btnTitle: "Yay!",
          explanation:
              "All ads are removed, please restart the app to remove the ads.",
          title: title,
          onNext: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 480,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(16),
                border: const Border(
                  top: BorderSide(
                    width: 2,
                    color: AppColors.primaryColor,
                  ),
                  bottom: BorderSide(
                    width: 2,
                    color: AppColors.primaryColor,
                  ),
                  left: BorderSide(
                    width: 2,
                    color: AppColors.primaryColor,
                  ),
                  right: BorderSide(
                    width: 2,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        const SizedBox(height: 16),
                        const Icon(
                          Icons.hide_image,
                          color: AppColors.primaryColor,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Remove Ads',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Say goodbye to ads forever with a one-time purchase!',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '80% OFF',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Original Price: ${_products[1].price}',
                          style: const TextStyle(
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _products[0].price,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 33,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            final PurchaseParam purchaseParam =
                                PurchaseParam(productDetails: _products[0]);
                            _inAppPurchase.buyNonConsumable(
                                purchaseParam: purchaseParam);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Buy Now',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            restoredPurchase();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 33, 19, 67),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Restore Purchase',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.close,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
