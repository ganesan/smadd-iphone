//
//  SmAddViewController.m
//  SmAddSample
//
//  Created by sumy on 11/07/07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SmAddViewController.h"
#import "SmAddGlobal.h"
#import <CommonCrypto/CommonDigest.h>
#import <sys/utsname.h>
#import <netinet/in.h>

#define SMADD_AD_LOAD_SUCCESS 1
#define SMADD_AD_LOAD_ERROR 0

@interface SmAddViewController()
//AdMob
#ifdef SMADD_ADMOB_NAME
- (void)showAdMob;
- (void)removeAdMob;
#endif

//AdMaker
#ifdef SMADD_ADMAKER_NAME
- (void)showAdMaker;
- (void)removeAdMaker;
#endif

//iAd
#ifdef SMADD_IAD_NAME
- (void)showIAd;
- (void)removeIAd;
#endif

//TGAd
#ifdef SMADD_TGAD_NAME
- (void)showTGAd;
- (void)removeTGAd;
#endif

//AdLantis(Beta)
#ifdef SMADD_ADLANTIS_NAME
- (void)showAdlantis;
- (void)removeAdlantis;
- (void)adlantisFailedNotificationRecive:(NSNotificationCenter*)center;
- (void)adlantisSuccessNotificationRecive:(NSNotificationCenter*)center;
#endif

//HouseAd
#ifdef SMADD_HOUSEAD_NAME
- (void)showHouseAd;
- (void)removeHouseAd;
#endif

//Common
- (void)tryNextAdLoad;
- (void)getEnableAdNamesSortByPriority;
- (void)getEnableAdNamesSortByPriorityDidEnd:(NSString*)result;
- (void)reciveAdStatus:(NSString*)adName
			  dataType:(int)dataType;
//AdStatusReport(FeatureService)
- (BOOL)checkFirstLaunchToday;
- (NSString*)devicePlatform;
- (BOOL)reachabilityForInternetConnection;
- (NSString*)getKeyForSaveUserDefaults:(NSString*)keyTypeString;
@end

@implementation SmAddViewController
#ifdef SMADD_ADMAKER_NAME
@synthesize adMaker;
#endif
#ifdef SMADD_ADMOB_NAME
@synthesize adMob;
#endif
#ifdef SMADD_IAD_NAME
@synthesize iAd;
#endif
#ifdef SMADD_TGAD_NAME
@synthesize tgAd;
#endif
#ifdef SMADD_ADLANTIS_NAME
@synthesize adlantis;
#endif
#ifdef SMADD_HOUSEAD_NAME
@synthesize houseAd;
#endif
@synthesize loadingAdPriorityNumber;
@synthesize enableAdNamesSortByPriority;
@synthesize isAdInTop;
@synthesize adError;
@synthesize adLoading;
@synthesize smaddAdServerUrl;
@synthesize enableAdNameSortByPriority;
@synthesize tag;

/**
 * This is AdViewController core method
 * These method control ad
 */
#pragma mark AdController
- (void)startAd{
	SMADD_LOG_METHOD
    if(adLoading)
        return;
    
	adLoading = YES;
    
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *defaultAds = [NSDictionary dictionaryWithObject:[enableAdNameSortByPriority componentsSeparatedByString:@","]
                                                           forKey:[self getKeyForSaveUserDefaults:[NSString stringWithFormat:@"SMADD_ENABLE_AD_NAMES_SORT_BY_DEFAULTS_%@", tag]]];
    [defaults registerDefaults:defaultAds];
	
    if(enableAdNamesSortByPriority) {
        [enableAdNamesSortByPriority release], enableAdNamesSortByPriority = nil;
    }
	enableAdNamesSortByPriority = [[NSArray alloc] initWithArray:[defaults objectForKey:[self getKeyForSaveUserDefaults:[NSString stringWithFormat:@"SMADD_ENABLE_AD_NAMES_SORT_BY_DEFAULTS_%@", tag]]]];
	SMADD_LOG(@"enableAdNamesSortByPriority_%@ = %@", tag, [enableAdNamesSortByPriority description])
	
	// Getting start priority most higher adservice
	loadingAdPriorityNumber = -1;
	[self tryNextAdLoad];
	
    // サーバのURLが設定されている場合のみ
    if(smaddAdServerUrl) {
        if(!_operationQueue) {
            _operationQueue = [[NSOperationQueue alloc] init];
            [_operationQueue setMaxConcurrentOperationCount:1];
        }
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                selector:@selector(getEnableAdNamesSortByPriority)
                                                                                  object:nil];
        [_operationQueue addOperation:operation];
        [operation release];
    }
}

/**
 * Please setting you use ad service remove method
 */
- (void)stopAd{
	SMADD_LOG_METHOD
    // Not edit
    loadingAdPriorityNumber = -1;
    adLoading = NO;
    
#ifdef SMADD_IAD_NAME
    [self removeIAd];
#endif
#ifdef SMADD_ADMOB_NAME
    [self removeAdMob];
#endif
#ifdef SMADD_ADMAKER_NAME
    [self removeAdMaker];
#endif
#ifdef SMADD_TGAD_NAME
    [self removeTGAd];
#endif
#ifdef SMADD_HOUSEAD_NAME
    [self removeHouseAd];
#endif
#ifdef SMADD_ADLANTIS_NAME
    [self removeAdlantis];
#endif
}

/**
 * Please setting you use ad service remove method
 */
- (void)reciveAdStatus:(NSString*)adName
			  dataType:(int)dataType {
	SMADD_LOG(@"-[AdViewController reciveAdStatus:%@ dataType:%d]", adName, dataType)
	// 広告のロード成功。次の広告種の読み込みを開始しない
	if(dataType == SMADD_AD_LOAD_SUCCESS) {
        adLoading = NO;
		return;
	}

#ifdef SMADD_IAD_NAME
	if([SMADD_IAD_NAME isEqualToString:adName]){
		if(dataType == SMADD_AD_LOAD_ERROR){
			[self tryNextAdLoad];
			[self removeIAd];
		}
        return;
	}
#endif
#ifdef SMADD_ADMAKER_NAME
	if([SMADD_ADMAKER_NAME isEqualToString:adName]){
		if(dataType == SMADD_AD_LOAD_ERROR){
			[self tryNextAdLoad];
			[self removeAdMaker];
		}
        return;
	}
#endif
#ifdef SMADD_ADMOB_NAME
	if([SMADD_ADMOB_NAME isEqualToString:adName]){
		if(dataType == SMADD_AD_LOAD_ERROR){
			[self tryNextAdLoad];
			[self removeAdMob];
		}
        return;
	}
#endif
#ifdef SMADD_TGAD_NAME
    if([SMADD_TGAD_NAME isEqualToString:adName]){
        if(dataType == SMADD_AD_LOAD_ERROR){
            [self tryNextAdLoad];
            [self removeTGAd];
        }
        return;
    }
#endif
#ifdef SMADD_HOUSEAD_NAME
	if([SMADD_HOUSEAD_NAME isEqualToString:adName]){
		if(dataType == SMADD_AD_LOAD_ERROR){
			[self tryNextAdLoad];
			[self removeHouseAd];
		}
        return;
	}
#endif
#ifdef SMADD_ADLANTIS_NAME
	if([SMADD_ADLANTIS_NAME isEqualToString:adName]){
		if(dataType == SMADD_AD_LOAD_ERROR){
			[self tryNextAdLoad];
			[self removeAdlantis];
		}
        return;
	}
#endif
    SMADD_LOG(@"reciveAdStatus: EXCEPTION_ERROR")
}

// 次の広告を読み込みに行く
- (void)tryNextAdLoad{
	loadingAdPriorityNumber++;
	SMADD_LOG(@"-[AdViewController tryNextAdLoad], loadingAdPriorityNumber = %d, [enableAdNamesSortByPriority count] = %d", loadingAdPriorityNumber, [enableAdNamesSortByPriority count])
	if([enableAdNamesSortByPriority count] <= loadingAdPriorityNumber) {
		SMADD_LOG(@"AdService is all failed")
        SMADD_LOG(@"adError = YES")
        adError = YES;
        adLoading = NO;
        return;
        
	}
    
    /**
     * If not online, use support offline adservice(Cache In File etc...)
     * Currently, only support adlantis
     */
    BOOL networkConecctionAvailabble = [self reachabilityForInternetConnection];
    SMADD_LOG(@"NetworkConennctionAvailabble: %d", networkConecctionAvailabble)
    if(!networkConecctionAvailabble) {
        SMADD_LOG(@"NetworkConennctionIsNotAvailabble")
#ifdef SMADD_ADLANTIS_NAME
        if([SMADD_ADLANTIS_NAME isEqualToString:[enableAdNamesSortByPriority objectAtIndex:loadingAdPriorityNumber]]){
            [self showAdlantis];
        }
#endif
        return;
    }
	
#ifdef SMADD_IAD_NAME
	if([SMADD_IAD_NAME isEqualToString:[enableAdNamesSortByPriority objectAtIndex:loadingAdPriorityNumber]]) {
        Class clazz = NSClassFromString(@"ADBannerView");
        if (clazz) {
            [self showIAd];
        }
        else {
            SMADD_LOG(@"tryNextAdLoad: iAd Not support this device")
            [self tryNextAdLoad];
        }
        return;
	}
#endif
#ifdef SMADD_ADMAKER_NAME
	if([SMADD_ADMAKER_NAME isEqualToString:[enableAdNamesSortByPriority objectAtIndex:loadingAdPriorityNumber]]) {
        [self showAdMaker];
        return;
	}
#endif
#ifdef SMADD_ADMOB_NAME
	if([SMADD_ADMOB_NAME isEqualToString:[enableAdNamesSortByPriority objectAtIndex:loadingAdPriorityNumber]]) {
        [self showAdMob];
        return;
	}
#endif
#ifdef SMADD_TGAD_NAME
    if([SMADD_TGAD_NAME isEqualToString:[enableAdNamesSortByPriority objectAtIndex:loadingAdPriorityNumber]]){
        [self showTGAd];
        return;
    }
#endif
#ifdef SMADD_HOUSEAD_NAME
	if([SMADD_HOUSEAD_NAME isEqualToString:[enableAdNamesSortByPriority objectAtIndex:loadingAdPriorityNumber]]){
        [self showHouseAd];
        return;
	}
#endif
#ifdef SMADD_ADLANTIS_NAME
	if([SMADD_ADLANTIS_NAME isEqualToString:[enableAdNamesSortByPriority objectAtIndex:loadingAdPriorityNumber]]){
		[self showAdlantis];
        return;
	}
#endif
#ifdef SMADD_ADDISABLE_NAME
    if([SMADD_ADDISABLE_NAME isEqualToString:[enableAdNamesSortByPriority objectAtIndex:loadingAdPriorityNumber]]){
		[self stopAd];
        return;
	}    
#endif
    
	SMADD_LOG(@"tryNextAdLoad: EXCEPTION_ERROR")
	[self tryNextAdLoad];
}


/**
 * This is AdMobDelagate section
 */
#pragma mark AdMobDelegate
#ifdef SMADD_ADMOB_NAME
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    SMADD_LOG_METHOD
    [self reciveAdStatus:SMADD_ADMOB_NAME
                dataType:SMADD_AD_LOAD_SUCCESS];
}
- (void)adView:(GADBannerView *)bannerView
didFailToReceiveAdWithError:(GADRequestError *)error {
    SMADD_LOG_METHOD
    SMADD_LOG(@"adView:didFailToReceiveAdWithError:%@", [error localizedDescription])
    [self reciveAdStatus:SMADD_ADMOB_NAME
                dataType:SMADD_AD_LOAD_ERROR];
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView {
    SMADD_LOG_METHOD
}

- (void)adViewDidDismissScreen:(GADBannerView *)bannerView {
    SMADD_LOG_METHOD
}

- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView {
    SMADD_LOG_METHOD
}
#endif


/**
 * This is iAdDelegate section
 */
#pragma mark iAdDelegate
#ifdef SMADD_IAD_NAME
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
	SMADD_LOG_METHOD
	return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
	SMADD_LOG_METHOD
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
	SMADD_LOG_METHOD
	[UIView beginAnimations:@"animateAdBannerOn" context:NULL];
	[banner setAlpha:1.0];
	[UIView commitAnimations];
	
	[self reciveAdStatus:SMADD_IAD_NAME
				dataType:SMADD_AD_LOAD_SUCCESS];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	SMADD_LOG_METHOD
	SMADD_LOG(@"%@", [error description])
    
	[UIView beginAnimations:@"animateAdBannerOff" context:NULL];
	[banner setAlpha:0.0];
	[UIView commitAnimations];
	
	[self reciveAdStatus:SMADD_IAD_NAME
				dataType:SMADD_AD_LOAD_ERROR];
}
#endif


/**
 * This is HouseAdDelagate section
 */
#pragma mark HouseAdDelagate
#ifdef SMADD_HOUSEAD_NAME
- (void)adViewTemplate:(AdViewTemplate *)adView didFailToReceiveAdWithError:(NSError *)error{
	SMADD_LOG_METHOD
	[self reciveAdStatus:SMADD_HOUSEAD_NAME
				dataType:SMADD_AD_LOAD_ERROR];
}

- (void)adViewTemplateDidLoadAd:(AdViewTemplate *)adView{
	SMADD_LOG_METHOD
	[self reciveAdStatus:SMADD_HOUSEAD_NAME
				dataType:SMADD_AD_LOAD_SUCCESS];
}
#endif

/**
 * This is AdMakerDelegate section
 */
#ifdef SMADD_ADMAKER_NAME
-(UIViewController*)currentViewControllerForAdMakerView:(AdMakerView*)view {
    SMADD_LOG_METHOD
	return self;
}

-(NSArray*)adKeyForAdMakerView:(AdMakerView*)view {
    SMADD_LOG_METHOD
	return [NSArray arrayWithObjects:SMADD_ADMAKER_AD_URL,SMADD_ADMAKER_SITE_ID,SMADD_ADMAKER_ZONE_ID,nil];
}

- (void)didLoadAdMakerView:(AdMakerView*)view {
    SMADD_LOG_METHOD
	[self.view addSubview:adMaker.view];
    [self reciveAdStatus:SMADD_ADMAKER_NAME
                dataType:SMADD_AD_LOAD_SUCCESS];
}

- (void)didFailedLoadAdMakerView:(AdMakerView*)view {
    SMADD_LOG_METHOD
    [self reciveAdStatus:SMADD_ADMAKER_NAME
                dataType:SMADD_AD_LOAD_ERROR];
}
#endif

/**
 * This is relate AdMob method section
 */
#pragma mark AdMob
#ifdef SMADD_ADMOB_PUBLISER_ID
- (void)showAdMob {
	SMADD_LOG_METHOD
    if(adMob == nil) {
        if(isAdInTop) {
            adMob = [[GADBannerView alloc]
                     initWithFrame:CGRectMake(0,0,GAD_SIZE_320x50.width,GAD_SIZE_320x50.height)];
        } else {
            adMob = [[GADBannerView alloc]
                     initWithFrame:CGRectMake(0,10,GAD_SIZE_320x50.width,GAD_SIZE_320x50.height)];
        }
        
        // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
        adMob.adUnitID = SMADD_ADMOB_PUBLISER_ID;
        
        // Let the runtime know which UIViewController to restore after taking
        // the user wherever the ad goes and add it to the view hierarchy.
        adMob.rootViewController = self;
        [adMob setDelegate:self];
        [self.view addSubview:adMob];
        
        // Initiate a generic request to load it with an ad.
        [adMob loadRequest:[GADRequest request]];
    }
    else {
        [adMob removeFromSuperview];
        [self.view addSubview:adMob];
        [adMob loadRequest:[GADRequest request]];
        SMADD_LOG(@"showAdMob: EXCEPTION_ERROR")
    }
}

- (void)removeAdMob {
	SMADD_LOG_METHOD
    if (adMob) {
        [adMob removeFromSuperview];
        adMob.delegate = nil;
        [adMob release];
        adMob = nil;
    }
}
#endif


/**
 * This is relate AdMaker method section
 */
#pragma mark AdMaker
#ifdef SMADD_ADMAKER_NAME
- (void)showAdMaker {
	SMADD_LOG_METHOD
	if(adMaker == nil) {
        SMADD_LOG(@"AdMaker alloc init")
		adMaker = [[AdMakerView alloc]init];
        [adMaker setAdMakerDelegate:self];
        adMaker.view.backgroundColor = [UIColor clearColor];
        if(isAdInTop) {
            [adMaker setFrame:CGRectMake(0,0,320,50)];
        }
        else {
            [adMaker setFrame:CGRectMake(0,10,320,50)];
        }
        [adMaker start];
	}
	else {
		SMADD_LOG(@"showAdMaker: EXCEPTION_ERROR")
	}    
}

- (void)removeAdMaker {
	SMADD_LOG_METHOD
    if(adMaker) {
        [adMaker setAdMakerDelegate:nil];
        [adMaker.view removeFromSuperview];
        [adMaker release];
        adMaker = nil;
    }
}
#endif


/**
 * This is relate iAd method section
 */
#pragma mark iAd
#ifdef SMADD_IAD_NAME
- (void)showIAd{
	SMADD_LOG_METHOD
	if(iAd == nil) {
        if(isAdInTop) {
            iAd = [[ADBannerView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        } else {
            iAd = [[ADBannerView alloc] initWithFrame:CGRectMake(0, 10, 320, 50)];
        }
	}
	else {
		SMADD_LOG(@"showIAd: EXCEPTION_ERROR")
	}
	[iAd setAlpha:0.0];
	// iAdの広告サイズを指定
    if (&ADBannerContentSizeIdentifierPortrait != nil) {
        [iAd setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierPortrait];
        // [iAd setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierLandscape];
        SMADD_LOG(@"Running on iOS 4.2 or newer.");
    } else {
        [iAd setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifier320x50];
        //[iAd setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifier480x32];
        SMADD_LOG(@"Running on Pre-iOS 4.2.");
    }
	[iAd setDelegate:self];
	[self.view addSubview:iAd];	
}

- (void)removeIAd{
	SMADD_LOG_METHOD
    if(iAd) {
        [iAd removeFromSuperview];
        [iAd setDelegate:nil];
        [iAd release];
        iAd = nil;
    }
}
#endif


/**
 * This is relate HouseAd method section
 */
#pragma mark HouseAd
#ifdef SMADD_HOUSEAD_NAME
- (void)showHouseAd{
	SMADD_LOG_METHOD
	if(houseAd == nil) {
        if(isAdInTop) {
            houseAd = [[AdViewTemplate alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
        }
        else {
            houseAd = [[AdViewTemplate alloc]initWithFrame:CGRectMake(0, 10, 320, 50)];
        }
	}
	else {
		SMADD_LOG(@"showHouseAd: EXCEPTION_ERROR")
	}
	[houseAd setDelegate:self];
	[houseAd setUrl:SMADD_HOUSEAD_URL];
	[houseAd setBannerLinkUrlHost:SMADD_HOUSEAD_LINK_HOSTNAME];
	[houseAd setBackgroundColor:[UIColor clearColor]]; //広告の背景を透明に
	[houseAd setController:self];
	[houseAd setOpaque:NO];
	[houseAd start];
	[self.view addSubview:houseAd];
}

- (void)removeHouseAd{
	SMADD_LOG_METHOD
    if(houseAd) {
        [houseAd removeFromSuperview];
        [houseAd release];
        houseAd = nil;
    }
}
#endif

#pragma mark TGAD
#ifdef SMADD_TGAD_NAME
//TGAd for iPhone
- (void)showTGAd {
	if(tgAd == nil) {
        if(isAdInTop) {
            tgAd = [TGAView requestWithKey:SMADD_TGAD_KEY Position:0.0];
        }
        else {
            tgAd = [TGAView requestWithKey:SMADD_TGAD_KEY Position:0.0];
        }
	}
	[self.view addSubview:tgAd];
}

- (void)removeTGAd {
    if(tgAd) {
        [tgAd removeFromSuperview];
        //[tgAd release];
        tgAd = nil;
    }
}
#endif


/*
 * this faunction is beta version, please carefully to use this
 */
#pragma mark AdLantis
#ifdef SMADD_ADLANTIS_NAME
- (void)showAdlantis {	
	if(adlantis == nil) {        
        if(adlantisAlreadyAlloc) {
            [self reciveAdStatus:SMADD_ADLANTIS_NAME dataType:YES];
        }
        else {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc addObserver:self selector:@selector(adlantisSuccessNotificationRecive:) name:@"AdlantisAdsUpdatedNotification" object:nil];
            //[nc addObserver:self selector:@selector(adlantisFailedNotificationRecive:) name:@"ADSessionDidCloseNotification" object:nil];
            //[nc addObserver:self selector:@selector(checkAdlantisLoaded:) name:@"AdlantisAdManagerAssetUpdatedNotification" object:nil];
            //[nc addObserver:self selector:@selector(checkAdlantisLoaded:) name:@"AdlantisPreviewWillBeShownNotification" object:nil];
            //[nc addObserver:self selector:@selector(checkAdlantisLoaded:) name:@"AdlantisPreviewWillBeHiddenNotification" object:nil];
            adlantisAlreadyAlloc = YES;
        }
        
        AdlantisAdManager.sharedManager.publisherID = SMADD_ADLANTIS_PUBLISHER_ID;
        if(isAdInTop) {
            adlantis = [[AdlantisView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        } else {
            adlantis = [[AdlantisView alloc] initWithFrame:CGRectMake(0, 10, 320, 50)];
        }
	}
    
	[self.view addSubview:adlantis];
}

- (void)removeAdlantis {
    if(adlantis) {
        [[AdlantisAdManager sharedManager] clearMemoryCache];
        [adlantis removeFromSuperview];
        [adlantis release];
        adlantis = nil;
    }
}

- (void)adlantisSuccessNotificationRecive:(NSNotificationCenter*)center {
	SMADD_LOG_METHOD
	[self reciveAdStatus:SMADD_ADLANTIS_NAME dataType:YES];
}
// Current, not use this. Use timeout counter
- (void)adlantisFailedNotificationRecive:(NSNotificationCenter*)center {
	SMADD_LOG_METHOD
	[self reciveAdStatus:SMADD_ADLANTIS_NAME dataType:NO];
}
#endif

#pragma mark CommonMethod, No need to edit

- (void)getEnableAdNamesSortByPriority {
	SMADD_LOG_METHOD
	
	NSString *urlString = [[[NSString alloc] initWithFormat:@"%@?udid=%@&locale=%@&language=%@&modelType=%@&osVersion=%@&appVersion=%@&firstLaunchToday=%d",
							smaddAdServerUrl, [UIDevice currentDevice].uniqueIdentifier, [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode], [[NSLocale preferredLanguages] objectAtIndex:0], [self devicePlatform], [UIDevice currentDevice].systemVersion, [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], [self checkFirstLaunchToday]] autorelease];
	urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@"_"];
	//NSString *urlString = AD_SERVER_URL;
	SMADD_LOG(@"%@", urlString)
	NSURL *url = [NSURL URLWithString:urlString];
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
	
	NSURLResponse *resp;
	NSError *err = nil;
	NSData *resultData = [NSURLConnection sendSynchronousRequest:req returningResponse:&resp error:&err];
	
	if (err) {
		SMADD_LOG(@"ERROR")
		return;
	}
	
	NSString *resultString = [[[NSString alloc] initWithData:resultData encoding:NSASCIIStringEncoding] autorelease];
	
	[self performSelectorOnMainThread:@selector(getEnableAdNamesSortByPriorityDidEnd:)
						   withObject:resultString
						waitUntilDone:YES];	
}

- (void)getEnableAdNamesSortByPriorityDidEnd:(NSString*)result{
	SMADD_LOG_METHOD
	SMADD_LOG(@"result = %@", result)
	if(result != nil && ![result isEqualToString:@""]) {
        NSMutableString *fixedResult = [NSMutableString stringWithString:result];
        [fixedResult replaceOccurrencesOfString:@"\n"
                                     withString:@""
                                        options:0
                                          range:NSMakeRange(0, [fixedResult length])];
        
        
		NSArray *array = [fixedResult componentsSeparatedByString:@","];
		if([array count] > 0){
            //check for a minimum of one available adname
            BOOL available = NO;
            for (NSString* nadname in array) {
                if(available) {
                    break;
                }
                SMADD_LOG(@"array = %@, enableAdNamesSortByPriority_%@ = %@", [array description], tag, [enableAdNamesSortByPriority description]);
                for(NSString* oadname in enableAdNamesSortByPriority) {
                    if([oadname isEqualToString:nadname]) {
                        available = YES;
                        break;
                    }
                }
            }
            
            if(available) {                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:array forKey:[self getKeyForSaveUserDefaults:[NSString stringWithFormat:@"SMADD_ENABLE_AD_NAMES_SORT_BY_DEFAULTS_%@", tag]]];
                [defaults synchronize];
                SMADD_LOG(@"save_%@: %@", tag, [array description])
            }
            else {
                SMADD_LOG(@"Not save, because available ad service name is not found")
            }
		}
        else {
            SMADD_LOG(@"Not save, because available ad service name is not found")
        }
	}	
}

// this sdk and server are use GMT
- (BOOL)checkFirstLaunchToday {
    SMADD_LOG_METHOD
    BOOL firstLaunchToday = YES;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *beforLaunchDay = [defaults objectForKey:[self getKeyForSaveUserDefaults:@"SMADD_BEFOR_LAUNCH_DAY"]];
    
    NSDate *todayDate = [NSDate date];
    NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSString *today = [formatter stringFromDate:todayDate];
    SMADD_LOG(@"today = %@", today)
    if([today isEqualToString:beforLaunchDay]){
        firstLaunchToday = NO;
    }
    else {
        [defaults setObject:today forKey:[self getKeyForSaveUserDefaults:@"SMADD_BEFOR_LAUNCH_DAY"]];
    }
    
    return firstLaunchToday;
}

- (NSString*)devicePlatform{
    SMADD_LOG_METHOD
    struct utsname u;
    uname(&u);
    return [NSString stringWithFormat:@"%s", u.machine];
}

- (NSString*)getKeyForSaveUserDefaults:(NSString*)keyTypeString {
    return [NSString stringWithFormat:@"%@:%@", smaddAdServerUrl, keyTypeString];
}

- (BOOL)reachabilityForInternetConnection {
    // Part 1 - Create Internet socket addr of zero
	struct sockaddr_in zeroAddr;
	bzero(&zeroAddr, sizeof(zeroAddr));
	zeroAddr.sin_len = sizeof(zeroAddr);
	zeroAddr.sin_family = AF_INET;
    
	// Part 2- Create target in format need by SCNetwork
	SCNetworkReachabilityRef target = 
    SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *) &zeroAddr);
    
	// Part 3 - Get the flags
	SCNetworkReachabilityFlags flags;
	SCNetworkReachabilityGetFlags(target, &flags);
    
	// Part 4 - Create output
	BOOL sNetworkReachable;
	if (flags & kSCNetworkFlagsReachable) {
		sNetworkReachable = YES;
    } else {
		sNetworkReachable = NO;
    }
    
    CFRelease(target);
    //    
    //	BOOL sCellNetwork;
    //	if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
    //		sCellNetwork = YES;
    //    } else {
    //		sCellNetwork = NO;
    //    }
    
    return sNetworkReachable;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code.
 }
 */

- (void)dealloc {
    SMADD_LOG_METHOD    
    
#ifdef SMADD_ADMAKER_NAME
    [adMaker release], adMaker = nil;
#endif
#ifdef SMADD_ADMOB_NAME
    adMob.delegate = nil;
    [adMob release], adMob = nil;
#endif
#ifdef SMADD_IAD_NAME
    iAd.delegate = nil;
    [iAd release], iAd = nil;
#endif
#ifdef SMADD_TGAD_NAME
    [tgAd release], tgAd = nil;
#endif
#ifdef SMADD_HOUSEAD_NAME
    [houseAd release], houseAd = nil;
#endif
#ifdef SMADD_ADLANTIS_NAME
    [adlantis release], adlantis = nil;
#endif
    
    //Not edit
    [_operationQueue cancelAllOperations], [_operationQueue release], _operationQueue = nil;
    [enableAdNamesSortByPriority release], enableAdNamesSortByPriority = nil;
    [smaddAdServerUrl release], smaddAdServerUrl = nil;
    [tag release], tag = nil;
    
    [super dealloc];
    SMADD_LOG(@"-[SmAddView dealloc] : [super dealloc]")
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.view setBackgroundColor:[UIColor clearColor]];
		[self.view setOpaque:NO];
        self.tag = @"0";
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
            isAdInTop:(BOOL)adInTop
     smaddAdServerUrl:(NSString*)serverUrlString
    enableAdNameSortByPriority:(NSString*)adNames {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Initialization code.
		[self.view setBackgroundColor:[UIColor clearColor]];
		[self.view setOpaque:NO];
        [self setSmaddAdServerUrl:serverUrlString];
        [self setEnableAdNameSortByPriority:adNames];
        [self setIsAdInTop:adInTop];
        self.tag = @"0";
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
            isAdInTop:(BOOL)adInTop
enableAdNameSortByPriority:(NSString*)adNames {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Initialization code.
		[self.view setBackgroundColor:[UIColor clearColor]];
		[self.view setOpaque:NO];
        [self setEnableAdNameSortByPriority:adNames];
        [self setIsAdInTop:adInTop];
        self.tag = @"0";
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
