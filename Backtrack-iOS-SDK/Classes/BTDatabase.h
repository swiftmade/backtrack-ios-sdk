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

@interface BTDatabase : NSObject
{
    FMDatabase* _database;
}

+(BTDatabase*)singleton;
-(void)reopenDatabase;

+(NSString*)bundleFilePath;
+(NSString*)localizeDynamicContent:(NSString*)content;

-(NSArray*)allPointsOfInterest;
-(NSArray*)pointsOfInterestWithType:(NSString *)type;
-(NSDictionary*)pointOfInterestById:(NSString*)ID;

@end
