//
//  KRMapKit.h
//
//  ilovekalvar@gmail.com
//
//  Created by Kuo-Ming Lin on 2013/03/11.
//  Copyright (c) 2013年 Kuo-Ming Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^AddressConversionCompleted)(NSDictionary *addresses, NSError *error);
typedef void (^LocationConversionCompleted)(CLLocationCoordinate2D location);


@protocol KRMapKitDelegate;

@interface KRMapKit : NSObject<CLLocationManagerDelegate>
{
    //GPS Controller
    CLLocationManager *locationManager;
    //
    __weak id<KRMapKitDelegate> delegate;
    //民生路 195號
    __weak NSString *street;
    //台中市
    __weak NSString *subArea;
    //民生路
    __weak NSString *thoroughfare;
    //403
    __weak NSString *zip;
    //民生路 195號
    __weak NSString *name;
    //台中市
    __weak NSString *city;
    //台灣
    __weak NSString *country;
    //台中市
    __weak NSString *state;
    //西區
    __weak NSString *subLocality;
    //195號
    __weak NSString *subThoroughfare;
    //TW
    __weak NSString *countryCode;
    
    
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, weak) id<KRMapKitDelegate> delegate;
@property (nonatomic, weak) NSString *street;
@property (nonatomic, weak) NSString *subArea;
@property (nonatomic, weak) NSString *thoroughfare;
@property (nonatomic, weak) NSString *zip;
@property (nonatomic, weak) NSString *name;
@property (nonatomic, weak) NSString *city;
@property (nonatomic, weak) NSString *country;
@property (nonatomic, weak) NSString *state;
@property (nonatomic, weak) NSString *subLocality;
@property (nonatomic, weak) NSString *subThoroughfare;
@property (nonatomic, weak) NSString *countryCode;

+(KRMapKit *)sharedManager;
-(id)initWithDelegate:(id<KRMapKitDelegate>)_krDelegate;
/*
 * 開始 / 結束定位
 */
-(void)startLocation;
-(void)stopLocation;
/*
 * 將經緯度座標轉換成地址 ( Location convert to Address )
 */
-(void)startLocationToConvertAddress:(AddressConversionCompleted)_addressHandler;
/*
 * 取得當前緯 / 經度
 */
-(NSString *)currentLatitude;
-(NSString *)currentLongitude;
/*
 * 將地址轉換成經緯度座標 ( Address convert to Location )
 */
-(void)reverseLocationFromAddress:(NSString *)_address completionHandler:(LocationConversionCompleted)_locationHandler;


@end

@protocol KRMapKitDelegate <NSObject>

@optional
/*
 * 已將經緯度轉換為地址資料
 */
-(void)krMapKit:(KRMapKit *)_theKRMapKit didReverseGeocodeLocation:(NSArray *)_placemarks;
/*
 * 已離開該區域
 */
-(void)krMapKitLocationManager:(CLLocationManager *)_locationManager didExitRegion:(CLRegion *)region;
/*
 * 已更新定位區域
 */
-(void)krMapKitLocationManager:(CLLocationManager *)_locationManager didUpdateLocations:(NSArray *)locations;
/*
 *
 */
-(void)krMapKitLocationManager:(CLLocationManager *)_locationManager didUpdateHeading:(CLHeading *)newHeading;


@end

