//
//  BTDatabase.h
//  Pods
//
//  Created by Ahmet Özışık on 22.04.2015.
//
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "BacktrackSDK.h"
#import "BacktrackClient.h"

@interface BTDatabase : NSObject
{
    FMDatabase* _database;
}

+(BTDatabase*)singleton;
-(void)reopenDatabase;

+(NSString*)bundleFilePath;
+(NSString*)localizeDynamicContent:(NSString*)content;
// points of interest
-(NSArray*)allPointsOfInterest;
-(NSArray*)pointsOfInterestWithType:(NSString *)type;
-(NSDictionary*)pointOfInterestById:(NSString*)ID;
// photos
-(NSArray*)photosForPointOfInterest:(NSString*)ID;
// flowers
-(NSArray*)flowersByMonth:(bool)byMonth andAltitude:(int)altitude;
@end
