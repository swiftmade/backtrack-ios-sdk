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
    if(content == nil || [content isEqualToString:@""]) {
        return @"";
    }
    
    NSData * jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSError * error=nil;
    NSDictionary * parsedData = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    if(error || ! parsedData || ! [parsedData isKindOfClass:[NSDictionary class]]) {
        return @"";
    }
    
    return parsedData[[BacktrackSDK language]] == nil || [parsedData[[BacktrackSDK language]] isEqualToString:@""] ? parsedData[@"en"] : parsedData[[BacktrackSDK language]];
}

#pragma mark points of interest
-(NSArray*)pointsOfInterestWithType:(NSString *)type {
    
    NSMutableArray* results = [[NSMutableArray alloc] init];
    NSString* query = @"SELECT i.*, t.name as point_type, t.icon, p.photo_small_url FROM interesting_points i LEFT JOIN point_types t ON i.point_type_id = t.id LEFT JOIN point_photos p ON p.interesting_point_id = i.id AND p.thumbnail = 1";
    
    FMResultSet *s;
    
    if(type != nil && ! [type isKindOfClass:[NSNull class]]) {
        s = [_database executeQuery:[NSString stringWithFormat:@"%@ WHERE t.icon = ?", query], type];
    } else {
        s = [_database executeQuery:query];
    }
    
    while([s next]) {
        
        NSString* thumbnail = [s stringForColumn:@"photo_small_url"] ? [s stringForColumn:@"photo_small_url"] : @"";
        
        NSDictionary* point = @{
            @"id": [s stringForColumn:@"id"],
            @"name":  [BTDatabase localizeDynamicContent:[s stringForColumn:@"name"]],
            @"short_description": [BTDatabase localizeDynamicContent:[s stringForColumn:@"short_description"]],
            @"icon": [s stringForColumn:@"icon"],
            @"latitude": [NSNumber numberWithDouble:[s doubleForColumn:@"latitude"]],
            @"longitude": [NSNumber numberWithDouble:[s doubleForColumn:@"longitude"]],
            @"thumbnail": thumbnail,
            @"accommodation": [NSNumber numberWithInt:[s intForColumn:@"accommodation"]],
            @"restaurant": [NSNumber numberWithInt:[s intForColumn:@"restaurant"]],
            @"public_transport": [NSNumber numberWithInt:[s intForColumn:@"public_transport"]],
        };
        
        [results addObject:point];
    }
    
    return results;
}

-(NSArray*)allPointsOfInterest {
    return [self pointsOfInterestWithType:nil];
}

-(NSDictionary*)pointOfInterestById:(NSString*)ID {

    FMResultSet* s = [_database executeQuery:@"SELECT i.*, t.name as point_type, t.icon, p.photo_small_url FROM interesting_points i LEFT JOIN point_types t ON i.point_type_id = t.id LEFT JOIN point_photos p ON p.interesting_point_id = i.id AND p.thumbnail = 1 WHERE i.id = ?", ID];
    
    if([s next]) {
        
        NSString* thumbnail = [s stringForColumn:@"photo_small_url"] ? [s stringForColumn:@"photo_small_url"] : @"";
        
        return @{
            @"id": [s stringForColumn:@"id"],
            @"name":  [BTDatabase localizeDynamicContent:[s stringForColumn:@"name"]],
            @"short_description": [BTDatabase localizeDynamicContent:[s stringForColumn:@"short_description"]],
            @"long_description": [BTDatabase localizeDynamicContent:[s stringForColumn:@"long_description"]],            
            @"icon": [s stringForColumn:@"icon"],
            @"latitude": [NSNumber numberWithDouble:[s doubleForColumn:@"latitude"]],
            @"longitude": [NSNumber numberWithDouble:[s doubleForColumn:@"longitude"]],
            @"thumbnail": thumbnail,
            @"accommodation": [NSNumber numberWithInt:[s intForColumn:@"accommodation"]],
            @"restaurant": [NSNumber numberWithInt:[s intForColumn:@"restaurant"]],
            @"public_transport": [NSNumber numberWithInt:[s intForColumn:@"public_transport"]],
        };
    }
    
    return nil;
}



@end
