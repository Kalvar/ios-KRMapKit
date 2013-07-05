## Screen Shot

<img src="https://dl.dropbox.com/u/83663874/GitHubs/KRMapKit-1.png" alt="KRMapKit" title="KRMapKit" style="margin: 20px;" class="center" /> &nbsp;
<img src="https://dl.dropbox.com/u/83663874/GitHubs/KRMapKit-2.png" alt="KRMapKit" title="KRMapKit" style="margin: 20px;" class="center" />

## Supports

KRMapKit supports ARC.

## How To Get Started

KRMapKit can get route directions with user location or address conversion, and you can use it to Location convert to Address or Address convert to Location, and it can easy get Coordinates ( Latitude, Longitude ) with current position.

And the sample project includes the Apple's MakKit, CoreLocation to show some using sample methods, I wanna try to description the orignal methods they how to used, so it mixes more code in the project.

``` objective-c
#import "KRMapKit.h"

@property (nonatomic, strong) KRMapKit *krMapKit;

-(void)viewDidLoad
{
	[super viewDidLoad];
	krMapKit = [[KRMapKit alloc] initWithDelegate:self];
	[self useCurrentLocationConvertToAddress];
	[self useAddressConvertToLocation];
}

-(void)useCurrentLocationConvertToAddress
{
	[self.krMapKit startLocationToConvertAddress:^(NSDictionary *addresses, NSError *error) {
        NSLog(@"Your Address : %@", addresses);
        [self.krMapKit stopLocation];
    }];
}

-(void)useAddressConvertToLocation
{
    [self.krMapKit reverseLocationFromAddress:@"台中市建國路172號" completionHandler:^(CLLocationCoordinate2D location) {
        NSLog(@"Address Location : %f, %f", location.latitude, location.longitude);
    }];
}

-(void)doYourselfToStartLocationAndGetCoordinates
{
    [self.krMapKit startLocation];
    NSString *currentLatitude  = [self.krMapKit currentLatitude];
    NSString *currentLongitude = [self.krMapKit currentLongitude];
    //[self.krMapKit stopLocation];
}
```

## Version

KRMapKit now is V0.3 beta.

## License

KRMapKit is available under the MIT license ( or Whatever you wanna do ). See the LICENSE file for more info.
