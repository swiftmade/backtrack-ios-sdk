//
//  BTMap.m
//  Pods
//
//  Created by Ahmet Özışık on 28.04.2015.
//
//
#import "BTMap.h"

@implementation BTMap
@synthesize mapView;

-(id)init {
    // no need for an access token, we are completely offline
    [[RMConfiguration sharedInstance] setAccessToken:@"<random string>"];
    return [super init];
}

-(id)initWithOfflineMap:(NSString*)mapFile onView:(UIView*)mapContainer {
    self = [self init];
    
    RMMBTilesSource* mapResource = [[RMMBTilesSource alloc] initWithTileSetResource:mapFile ofType:@"mbtiles"];
    
    mapView = [[RMMapView alloc] initWithFrame:mapContainer.frame andTilesource:mapResource];
    // support for retina displays
    mapView.adjustTilesForRetinaDisplay = YES;
    // show mapView on the container provided
    [mapContainer addSubview:mapView];
    // user tracking mode is none by default
    mapView.userTrackingMode = RMUserTrackingModeNone;
    // set auto-resizing mask
    mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    mapView.delegate = self;
    
    [self loadInterestingPoints];
    return self;
}

-(void)loadInterestingPoints {
    NSArray *results = [[BTDatabase singleton] allPointsOfInterest];
    
    for(NSDictionary *point in results) {
        
        CLLocationDegrees latitude = [point[@"latitude"] doubleValue];
        CLLocationDegrees longitude = [point[@"longitude"] doubleValue];
        
        RMAnnotation *annotation = [[RMAnnotation alloc] initWithMapView:mapView coordinate:CLLocationCoordinate2DMake(latitude, longitude) andTitle:point[@"name"]];
        
        annotation.userInfo = point;
        
        [mapView addAnnotation:annotation];
    }
}

- (RMMapLayer *)mapView:(RMMapView *)map_view layerForAnnotation:(RMAnnotation *)annotation
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"MakiBundle" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    UIImage* icon = [UIImage imageNamed:annotation.userInfo[@"icon"] inBundle:bundle compatibleWithTraitCollection:nil];

    RMMarker* marker = [[RMMarker alloc] initWithUIImage:icon];
    
    return marker;
}

@end
