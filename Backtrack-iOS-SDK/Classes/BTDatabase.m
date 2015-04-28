//
//  BTDatabase.m
//  Pods
//
//  Created by Ahmet Özışık on 22.04.2015.
//
//

#import "BTDatabase.h"


NSString* const BTBundleFileName = @"BacktrackDataBundle.sqlite";

@implementation BTDatabase
static BTDatabase *_database;


+(BTDatabase*)singleton {
    if(_database == nil) {
        _database = [[BTDatabase alloc] init];
    }
    
    return _database;
}

- (id)init {
    if (self = [super init]) {
        _database = [FMDatabase databaseWithPath:[BTDatabase bundleFilePath]];
        // actually, it happnes for the first time..
        [self openDatabase];
    }
    
    return self;
}

- (void)dealloc {
    if(_database != nil) {
        [_database close];
    }
}


-(void)openDatabase {
    // check for db
    if(_database == nil) {
        return;
    }
    
    if( ! [_database open]) {
        NSLog(@"Database could not be opened");
        return;
    }
}

-(void)reopenDatabase
{
    if(_database == nil) {
        return;
    }
    
    [_database close];
    [self openDatabase];
}


+(NSString*)bundleFilePath {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:BTBundleFileName];
    
    // copy the file from the main bundle to the documents path if it does not exist
    if( ! [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"BacktrackDataBundle" ofType:@"sqlite"];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:sourcePath]) {
            NSLog(@"Important Warning: Please include a BacktrackDataBundle.sqlite in your main bundle");
            [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:filePath error:nil];
        }
    }
    
    return filePath;
}

+(NSString*)localizeDynamicContent:(NSString*)content
{
    NSData * jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSError * error=nil;
    NSDictionary * parsedData = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    return (parsedData[[BacktrackSDK language]] == nil) ? parsedData[@"en"] : parsedData[[BacktrackSDK language]];
}

#pragma mark points of interest
-(NSArray*)pointsOfInterestWithScope:(NSString *)scope {
    FMResultSet *s = [_database executeQuery:@"SELECT i.*, t.name as point_type, t.icon FROM interesting_points i, point_types t WHERE i.point_type_id = t.id"];
    
    while([s next]) {
        //NSLog(@"gotcha %@", [BTDatabase localizeDynamicContent:[s stringForColumn:@"name"]]);
        NSLog(@"gotcha %@", [s stringForColumn:@"icon"]);
    }
    
    return @[];
}

-(NSArray*)allPointsOfInterest {
    return [self pointsOfInterestWithScope:nil];
}

@end
