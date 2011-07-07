//
//  SmAddViewController.h
//  SmAddSample
//
//  Created by sumy on 11/07/07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>

//////////////////
/*
 This SmAdd SDK is support these sdk
 - AdMaker : AdMakerSDK3.3 2011-05-25
 - AdMob : 2011-05-01
 - iAd : iOS4.3
 - AdLantis : AdLantis iPhone SDK version v1.3
 - TGAD : v1.3.1
 */
//////////////////

//////////////////
//iAd
//////////////////
#import <iAd/iAd.h> //iad
#define SMADD_IAD_NAME @"iad"

//////////////////
//AdMaker
//////////////////
#import "AdMakerView.h" //admaker
#import "AdMakerDelegate.h" //admaker
#define SMADD_ADMAKER_NAME @"admaker"
#define SMADD_ADMAKER_AD_URL @"http://images.ad-maker.info/apps/taijyukei.html"
#define SMADD_ADMAKER_SITE_ID @"53"
#define SMADD_ADMAKER_ZONE_ID @"215"

//////////////////
//AdMob
//////////////////
#import "GADBannerView.h" //admob
#import "GADBannerViewDelegate.h" //admob
#define SMADD_ADMOB_NAME @"admob"
#define SMADD_ADMOB_PUBLISER_ID @"a14ca8667b7c2e6"

//////////////////
//TG-AD
//////////////////
#import "TGAView.h" //tgad
#define SMADD_TGAD_NAME @"tgad"
#define SMADD_TGAD_KEY @"mdGfd2eMfYuT"

//////////////////
//HouseAD
//////////////////
#import "AdViewTemplate.h" //housead
#define SMADD_HOUSEAD_NAME @"housead"
#define SMADD_HOUSEAD_URL @"http://public.sumyapp.com/sumyapp_banner.html"
#define SMADD_HOUSEAD_LINK_HOSTNAME @"public.sumyapp.com"

//////////////////
//AdLantis
//////////////////
#import "AdlantisView.h" //adlantis
#import "AdlantisAdManager.h" //adlantis
#define SMADD_ADLANTIS_NAME @"adlantis"
#define SMADD_ADLANTIS_PUBLISHER_ID @"NDU1Mg%3D%3D%0A"

//////////////////
//SmAdd
//////////////////
#define SMADD_TIMEOUT_TIME 15
#define SMADD_ADDISABLE_NAME @"disable"

//TODO: remove not use adservice's delegate
@interface SmAddViewController : UIViewController<UIWebViewDelegate, ADBannerViewDelegate, GADBannerViewDelegate, AdViewTemplateDelegate> {
	//AdMaker
#ifdef SMADD_ADMAKER_NAME
    AdMakerView *adMaker;
#endif
    
	//AdMob
#ifdef SMADD_ADMOB_NAME
    GADBannerView *adMob;
#endif
    
	//iAd
#ifdef SMADD_IAD_NAME
    ADBannerView *iAd;
#endif
    
	//HouseAd
#ifdef SMADD_HOUSEAD_NAME
    AdViewTemplate *houseAd;
#endif
    
	//TGAd
#ifdef SMADD_TGAD_NAME
    TGAView *tgAd;
#endif
    
	//adlantis
#ifdef SMADD_ADLANTIS_NAME
    AdlantisView *adlantis;
    BOOL adlantisAlreadyAlloc;
#endif
    
	//Common
    int retryCount;
	int loadingAdPriorityNumber;
	NSArray *enableAdNamesSortByPriority;
	BOOL isAdInTop;
	BOOL adError;
    BOOL adLoading;
	NSOperationQueue *_operationQueue;
    NSString *smaddAdServerUrl;
    NSString *enableAdNameSortByPriority;
    NSString *tag;
}
- (void)startAd;
- (void)stopAd;
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
            isAdInTop:(BOOL)adInTop
     smaddAdServerUrl:(NSString*)serverUrlString
enableAdNameSortByPriority:(NSString*)adNames;
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
            isAdInTop:(BOOL)adInTop
enableAdNameSortByPriority:(NSString*)adNames;
#ifdef SMADD_ADMAKER_NAME
@property (retain, readonly) AdMakerView *adMaker;
#endif
#ifdef SMADD_ADMOB_NAME
@property (retain, readonly) GADBannerView *adMob;
#endif
#ifdef SMADD_IAD_NAME
@property (retain, readonly) ADBannerView *iAd;
#endif
#ifdef SMADD_HOUSEAD_NAME
@property (retain, readonly) AdViewTemplate *houseAd;
#endif
#ifdef SMADD_TGAD_NAME
@property (retain, readonly) TGAView *tgAd;
#endif
#ifdef SMADD_ADLANTIS_NAME
@property (retain, readonly) AdlantisView *adlantis;
#endif
#ifdef SMADD_AMEAD_NAME
@property (retain, readonly) SmAddAmeAdView *ameAd;
#endif
@property (readonly) int loadingAdPriorityNumber;
@property (retain, readonly) NSArray *enableAdNamesSortByPriority;
@property (readwrite) BOOL isAdInTop;
@property (readonly) BOOL adError;
@property (readonly) BOOL adLoading;
@property (retain, readwrite) NSString *smaddAdServerUrl;
@property (retain, readwrite) NSString *enableAdNameSortByPriority;
@property (retain, readwrite) NSString *tag;
@end