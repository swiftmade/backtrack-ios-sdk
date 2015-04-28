//
//  BTDatabase.h
//  Pods
//
//  Created by Ahmet Özışık on 22.04.2015.
//
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface BTDatabase : NSObject
{
    FMDatabase* _database;
}

+(BTDatabase*)singleton;
-(void)reopenDatabase;

+(NSString*)bundleFilePath;

-(NSArray*)allPointsOfInterest;
-(NSArray*)pointsOfInterestWithScope:(NSString*)scope;


@end
