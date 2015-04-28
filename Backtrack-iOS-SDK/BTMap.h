//
//  BTMap.h
//  Pods
//
//  Created by Ahmet Özışık on 28.04.2015.
//
//
#import <Mapbox-iOS-SDK/Mapbox.h>

@interface BTMap : NSObject <RMMapViewDelegate>

@property(nonatomic, retain) RMMapView* mapView;

-(id)initWithOfflineMap:(NSString*)mapFile onView:(UIView*)mapContainer;

@end
