//
//  ViewController.m
//  KRMapKit
//
//  ilovekalvar@gmail.com
//
//  Created by Kuo-Ming Lin on 12/11/25.
//  Copyright (c) 2012年 Kuo-Ming Lin. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MKMapItem.h>
#import "KRAnnotationProtocol.h"
#import "KRAnnotationView.h"
#import "KRMapKit.h"

static NSString *_kPinIdentifier = @"_mapViewPins";

@interface ViewController()

@property (nonatomic, assign) BOOL _isCancelledCurrentLocationCallout;

@end

@interface ViewController(fixPrivate)



@end

@implementation ViewController(fixPrivate)

/*
 * @ 動態取得經緯度和增加大頭針
 */
-(void)_tapPress:(UIGestureRecognizer*)gestureRecognizer
{
    /*
     * @ 如果是長按的事件
     *   - 在一開始按下去時會先觸發 UIGestureRecognizerStateBegan，而不會觸發 UIGestureRecognizerStateChanged 的狀態。
     *
     * @ 如果是單擊的事件
     *   - 僅會觸發的是 UIGestureRecognizerStateEnded 狀態。
     */
    //是初次觸發手勢的狀態 OR 改變手勢的狀態
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        /*
         * @ touchPoint 是點擊的某點在地图中的位置
         */
        CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
        /*
         * @ 取得經緯度
         *   - 使用 coverPoint 方法將畫面座標點轉換成經緯度
         *   -
         */
        //取得該點的經緯度
        CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        //動態加入大頭針
        [self addAnnotationForMapView:self.mapView
                             latitude:touchMapCoordinate.latitude
                            longitude:touchMapCoordinate.longitude
                                title:@"點擊增加地點"
                             subtitle:@"哈哈"];
    }
    
}

-(void)_addGestureRecognizer{
    /*
     * @ 加入點擊手勢
     *   - 動態增加大頭針和取得該點的經緯度。
     *   - 單擊是點一下就會作動，那會跟「點二下放大」的動作相衝突。
     *   - 解法 1. 「長按」後再啟動手勢，並不是最好的方法，長按後拖動，會連續動啟長按手勢的觸發函式，造成無限增加大頭針的問題。
     *   - 解法 2. 最好的方法是「設一個關閉按鈕」，點下去，就「啟動單擊手勢」增加大頭針，再點下去，就「移除單擊手勢」。
     */
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_tapPress:)];
    //觸發時間
    longPressRecognizer.minimumPressDuration = 0.5f;
    [self.mapView addGestureRecognizer:longPressRecognizer];
}

-(void)_useCurrentLocationConvertToAddress
{
    [[KRMapKit sharedManager] startLocationToConvertAddress:^(NSDictionary *addresses, NSError *error) {
        NSLog(@"Your Address : %@", addresses);
    }];
}

-(void)_useAddressConvertToLocation:(NSString *)_address
{
    [[KRMapKit sharedManager] reverseLocationFromAddress:_address completionHandler:^(CLLocationCoordinate2D location) {
        NSLog(@"Address Location : %f, %f", location.latitude, location.longitude);
    }];
}

-(void)doYourselfToStartLocationAndGetCoordinates
{
    KRMapKit *_krMapKit = [[KRMapKit alloc] init];
    [_krMapKit startLocation];
    NSString *currentLatitude  = [_krMapKit currentLatitude];
    NSString *currentLongitude = [_krMapKit currentLongitude];
    [_krMapKit stopLocation];
    _krMapKit = nil;
    NSLog(@"current Latitude : %@, Longitude : %@", currentLatitude, currentLongitude);
}

@end


@implementation ViewController

@synthesize mapView;
@synthesize latitudeLabel;
@synthesize longitudeLabel;

-(void)viewDidLoad
{
    [super viewDidLoad];
        
    //增加額外的手勢操作
    [self _addGestureRecognizer];
    
    //設定 MapView 的委派
    mapView.delegate          = self;
    //允許縮放地圖
    mapView.zoomEnabled       = YES;
    //允許捲動地圖
    mapView.scrollEnabled     = YES;
    //以小藍點顯示使用者目前的位置
    mapView.showsUserLocation = YES;
    
    //CLLocationManager
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    //開始定位
    [locationManager startUpdatingLocation];
    //停止定位
    //[locationManager stopUpdatingLocation];
    //設定當使用者的位置超出 X 公尺後才呼叫其他定位方法 :: 預設為 kCLDistanceFilterNone
    locationManager.distanceFilter = 10.0f;
    
    //顥示當前緯 / 經度
    CLLocation *location = locationManager.location;
    latitudeLabel.text   = [NSString stringWithFormat:@"%lf", location.coordinate.latitude];
    longitudeLabel.text  = [NSString stringWithFormat:@"%lf", location.coordinate.longitude];
    
    //設定方向過濾方式
    locationManager.headingFilter = kCLHeadingFilterNone;
    //啟動指南針方向定位
    [locationManager startUpdatingHeading];
        
    //指定中心點為當前位置
    MKCoordinateRegion centerRegion;
    centerRegion.center.latitude  = location.coordinate.latitude;
    centerRegion.center.longitude = location.coordinate.longitude;
    
    //指定顯示區域範圍
    centerRegion.span.latitudeDelta  = 0.1;
    centerRegion.span.longitudeDelta = 0.1;
    
    //設定區域至 MapView 裡
    mapView.region = centerRegion;
    //設定標記
    [self addAnnotationForMapView:mapView
                         latitude:24.136845
                        longitude:120.685009
                            title:@"台中火車站"
                         subtitle:@"火車頭"];
    //
    [self addAnnotationForMapView:mapView
                         latitude:24.155006
                        longitude:120.662956
                            title:@"台中 SOGO"
                         subtitle:@"旁邊有老虎城"];
    
    //Parse Location to Address
    [self _useCurrentLocationConvertToAddress];
    //Parse Address to Location
    //Noted, 臺中 never convert with Apple, 台中 is correct.
    [self _useAddressConvertToLocation:@"台中市建國路172號"];
}

#pragma IBActions
/*
 * 外開官方 Apple Maps App 進行路徑規劃。
 */
//目前位置導航至指定位置
-(IBAction)currentDirection:(id)sender
{
    /*
     * 到台中火車站
     */
    CLLocationCoordinate2D firstGPSLocation;
    firstGPSLocation.latitude  = 24.136845;
    firstGPSLocation.longitude = 120.685009;
    MKPlacemark *place1 = [[MKPlacemark alloc] initWithCoordinate:firstGPSLocation addressDictionary:nil];
    MKMapItem *destination1 = [[MKMapItem alloc] initWithPlacemark:place1];
    destination1.name = @"台中火車站";
    NSDictionary* options = [[NSDictionary alloc] initWithObjectsAndKeys:
                             MKLaunchOptionsDirectionsModeDriving,
                             MKLaunchOptionsDirectionsModeKey, nil];
    /*
     * 啟動目前位置的導航路徑規劃
     */
    [destination1 openInMapsWithLaunchOptions:options];
}

//任二點導航
-(IBAction)anywhereDirection:(id)sender
{
    /*
     * 當前位置
     */
//    CLLocationCoordinate2D currentGPSLocation;
//    currentGPSLocation.latitude  = locationManager.location.coordinate.latitude;
//    currentGPSLocation.longitude = locationManager.location.coordinate.longitude;
//    MKPlacemark *place0 = [[MKPlacemark alloc] initWithCoordinate:currentGPSLocation addressDictionary:nil];
//    MKMapItem *destination0 = [[MKMapItem alloc] initWithPlacemark:place0];
//    destination0.name = @"當前位置";
    /*
     * 台中火車站
     */
    CLLocationCoordinate2D firstGPSLocation;
    firstGPSLocation.latitude  = 24.136845;
    firstGPSLocation.longitude = 120.685009;
    //目的地的大頭針
    MKPlacemark *place1 = [[MKPlacemark alloc] initWithCoordinate:firstGPSLocation addressDictionary:nil];
    //目的地( destination )
    MKMapItem *destination1 = [[MKMapItem alloc] initWithPlacemark:place1];
    destination1.name = @"台中火車站";
    /*
     * 到台中 SOGO
     */
    CLLocationCoordinate2D secondGPSLocation;
    secondGPSLocation.latitude  = 24.155006;
    secondGPSLocation.longitude = 120.662956;
    MKPlacemark *place2 = [[MKPlacemark alloc] initWithCoordinate:secondGPSLocation addressDictionary:nil];
    MKMapItem *destination2 = [[MKMapItem alloc] initWithPlacemark:place2];
    destination2.name = @"台中 SOGO";
    /*
     * 啟動任二點的導航路徑規劃
     */
    NSDictionary* options = [[NSDictionary alloc] initWithObjectsAndKeys:
                             MKLaunchOptionsDirectionsModeDriving,
                             MKLaunchOptionsDirectionsModeKey,
                             nil];
    //陣列第 1 個為出發地點，第二個為導航目的地
    NSArray *items = [[NSArray alloc] initWithObjects:
                      //destination0,
                      destination1,
                      destination2,
                      nil];
    //導航
    [MKMapItem openMapsWithItems:items launchOptions:options];
}

#pragma My Methods
//更新顥示的視野
-(void)updateReginForLocation:(CLLocation *)newLocation keepSpan:(BOOL)keepSpan
{
    MKCoordinateRegion theRegion;
    theRegion.center = newLocation.coordinate;
    if( !keepSpan ){
        MKCoordinateSpan theSpan;
        theSpan.latitudeDelta  = 0.1;
        theSpan.longitudeDelta = 0.1;
        theRegion.span = theSpan;
    }else{
        theRegion.span = mapView.region.span;
    }
    
    [mapView setRegion:theRegion animated:YES];
}

//新增地圖標記
-(void)addAnnotationForMapView:(MKMapView *)_theMapView
                      latitude:(float)_latitude
                     longitude:(float)_longitude
                         title:(NSString *)_theTitle
                      subtitle:(NSString *)_subtitle
{
    //宣告 GPS 定位的 2D 地圖物件
    //設定標記物件裡的 GPS 定位地圖物件
    CLLocationCoordinate2D mapCenter;
    //設定緯度
    mapCenter.latitude  = _latitude;
    //設定經度
    mapCenter.longitude = _longitude;
    //宣告自訂義的 Annotation (標記)物件
    KRAnnotationProtocol *krAnno = [[KRAnnotationProtocol alloc] initWithCoordinate:mapCenter
                                                                        customTitle:_theTitle
                                                                     customSubtitle:_subtitle];
    //設定圖片
    krAnno.leftImage      = [UIImage imageNamed:@"ele_author_small.png"];
    //將標記加入地圖裡
    [_theMapView addAnnotation:krAnno];
}

#pragma MKMapViewDelegate
/*
 * @ 要開始定位使用者位置
 */
-(void)mapViewWillStartLocatingUser:(MKMapView *)mapView{
    //NSLog(@"1");
}

/*
 * @ 開始載入地圖時，顥示等待的動畫
 */
-(void)mapViewWillStartLoadingMap:(MKMapView *)mapView{
    if( busy == nil ){
        busy = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        busy.frame = CGRectMake(120, 180, 80, 80);
        [self.view addSubview:busy];
    }
    busy.hidesWhenStopped = YES;
    [busy startAnimating];
    //NSLog(@"2");
}

/*
 * @ 完全載入地圖後，停止動畫
 */
-(void)mapViewDidFinishLoadingMap:(MKMapView *)mapView{
    [busy stopAnimating];
    //NSLog(@"3");
}

/*
 * @ 使用者位置更新後，讓現在位置置中
 */
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    //NSLog(@"4");
    if( !setup ){
        setup = YES;
        //更新顥示的視野
        [self updateReginForLocation:userLocation.location keepSpan:NO];
    }else{
        setup = NO;
        [self updateReginForLocation:userLocation.location keepSpan:YES];
    }
}

/*
 * @ 使用地圖標記 Pin ( Annotation )
 *   - 動態加入大頭針
 *   - 反解譯取得經緯度
 */
-(MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    /*
     * @ 如果是現在的位置，就不要使用標記功能
     */
    if( [annotation isKindOfClass:[MKUserLocation class]] )
    {
        return nil;
    }
    //
    KRAnnotationProtocol *_krAnnotation = (KRAnnotationProtocol *)annotation;
    NSString *_reusePinId = _kPinIdentifier;
    /*
     * @ Pin (標記元件) 是可以被重覆使用且客製化的
     *   - 這裡先試著取出「已經被定義且使用者 MapView 上的 Pin」，之後就重複使用該 Pin。
     *   - 原理跟 TableViewCell 的作動一樣。
     *
     * @ 原始為 MKPinAnnotationView ( 直接一個大頭針 View )
     *   而 MKAnnotationView 則是一個「點」的大頭針，兩者不同。
     *
     */
    KRAnnotationView *_krAnnotationView = (KRAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:_reusePinId];
    if( _krAnnotationView == nil )
    {
        _krAnnotationView = [[KRAnnotationView alloc] initWithAnnotation:_krAnnotation reuseIdentifier:_reusePinId];
    }
    //設定標記顏色
    //pin.pinColor = MKPinAnnotationColorPurple;
    //標記拖拉動畫
    //pin.animatesDrop = YES;
    //Callout 彈出註釋呼喚 ( Default is NO )
    _krAnnotationView.canShowCallout = YES;
    //可以拖拉
    //_krAnnotationView.draggable = YES;
    //點選標記時，說明的小圖示右方是一個單箭頭按鈕 : Accessory 附加物件
    _krAnnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    //pin.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"大頭針左側小圖.png"]];
    return _krAnnotationView;
}

/*
 * @ 當 Pin ( 大頭針 ) 的右側箭頭被按下時
 */
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if( [view.annotation isKindOfClass:[KRAnnotationProtocol class]] )
    {
        KRAnnotationProtocol *_krAnnotation = (KRAnnotationProtocol *)view.annotation;
        NSString *_idIndex = _krAnnotation.idIndex;
        if( _idIndex )
        {
            //... 看該 ID 底下的內容 Detail
        }
    }
}

/*
 * @ 當選擇 Pin 時
 *   - 此時才執行客製化 Pin 內容的動作
 */
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if( [view isKindOfClass:[KRAnnotationView class]] )
    {
        KRAnnotationView *_krAnnotationView   = (KRAnnotationView *)view;
        KRAnnotationProtocol *_krAnnotation   = (KRAnnotationProtocol *)_krAnnotationView.annotation;
        //UIView *_v = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 38.0f)];
        //[_v setBackgroundColor:[UIColor redColor]];
        //_krAnnotationView.customContentView   = _v;
        _krAnnotationView.leftImageView = [[UIImageView alloc] initWithImage:_krAnnotation.leftImage];
        [_krAnnotationView makeCustomContent];
    }
}

/*
 * @ 當離開 Pin 時
 *   - 此時要移除客製化 Pin 內容的動作
 */
-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    //...
}

/*
 * @ 每一次新增加完一個或一整批的大頭針後，就會觸發這裡
 *   - 要在這裡取消「Current Location」的彈出註釋視窗( Cancels Callout )
 */
-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    if( !self._isCancelledCurrentLocationCallout )
    {
        //NSLog(@"didAddAnnotationViews");
        for(MKAnnotationView *_subview in views)
        {
            if([_subview.annotation isKindOfClass:[MKUserLocation class]])
            {
                MKAnnotationView *_userLocationAnnotationView = _subview;
                _userLocationAnnotationView.canShowCallout = NO;
                break;
            }
        }
        self._isCancelledCurrentLocationCallout = YES;
    }
}




@end
