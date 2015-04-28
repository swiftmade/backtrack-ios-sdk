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
    
    [[BTDatabase singleton] allPointsOfInterest];

    return self;
}

@end
