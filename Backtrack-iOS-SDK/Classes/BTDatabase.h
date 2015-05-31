//
//  BTDatabase.h
//  Pods
//
//  Created by Ahmet Özışık on 22.04.2015.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "FMDB.h"
#import "BacktrackSDK.h"
#import "BacktrackClient.h"

@interface BTDatabase : NSObject
{
    FMDatabase* _database;
}

+(BTDatabase*)singleton;
-(void)reopenDatabase;

// helpers
+(NSString*)bundleFilePath;
+(NSString*)localizeDynamicContent:(NSString*)content;
+(NSArray*)resultsSortedByProximity:(NSArray*)results location:(CLLocation*)location;
// points of interest
-(NSArray*)allPointsOfInterest;
-(NSArray*)pointsOfInterestWithType:(NSString *)type;
-(NSDictionary*)pointOfInterestById:(NSString*)ID;
// photos
-(NSArray*)photosForPointOfInterest:(NSString*)ID;
-(NSString*)totalFilesizeOfPhotos;
-(NSArray*)allPhotos;
// flowers
-(NSArray*)flowersByMonth:(bool)byMonth andAltitude:(int)altitude;
// trip points
-(NSArray*)tripPointsAnnotatedFor:(CLLocation*)userLocation;
-(NSArray*)allTripPoints;
-(NSArray*)possibleDestinationPoints:(NSString*)departurePoint annotatedFor:(CLLocation*)userLocation;
-(NSArray*)possibleDestinationPoints:(NSString*)departurePoint;
-(NSDictionary*)routesBetween:(NSString*)fromPointID to:(NSString*)toPointID;;
@end
