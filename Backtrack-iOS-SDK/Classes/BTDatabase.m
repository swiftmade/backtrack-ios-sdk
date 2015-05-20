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
        
        NSMutableDictionary* object = [[NSMutableDictionary alloc] init];
        
        [object setValuesForKeysWithDictionary:@{
            @"id": [s stringForColumn:@"id"],
            @"name":  [BTDatabase localizeDynamicContent:[s stringForColumn:@"name"]],
            @"short_description": [BTDatabase localizeDynamicContent:[s stringForColumn:@"short_description"]],
            @"icon": [s stringForColumn:@"icon"],
            @"latitude": [NSNumber numberWithDouble:[s doubleForColumn:@"latitude"]],
            @"longitude": [NSNumber numberWithDouble:[s doubleForColumn:@"longitude"]],
            @"accommodation": [NSNumber numberWithInt:[s intForColumn:@"accommodation"]],
            @"restaurant": [NSNumber numberWithInt:[s intForColumn:@"restaurant"]],
            @"public_transport": [NSNumber numberWithInt:[s intForColumn:@"public_transport"]],
        }];
        
        if([s stringForColumn:@"photo_small_url"]) {
            [object setObject:[[BacktrackClient sharedClient] authenticatedURL:[s stringForColumn:@"photo_small_url"]] forKey:@"thumbnail"];
        }
        
        
        [results addObject:object];
    }
    
    return results;
}

-(NSArray*)allPointsOfInterest {
    return [self pointsOfInterestWithType:nil];
}

-(NSDictionary*)pointOfInterestById:(NSString*)ID {

    FMResultSet* s = [_database executeQuery:@"SELECT i.*, t.name as point_type, t.icon, p.photo_small_url FROM interesting_points i LEFT JOIN point_types t ON i.point_type_id = t.id LEFT JOIN point_photos p ON p.interesting_point_id = i.id AND p.thumbnail = 1 WHERE i.id = ?", ID];
    
    if([s next]) {
        NSMutableDictionary* object = [[NSMutableDictionary alloc] init];
        
        [object setValuesForKeysWithDictionary:@{
            @"id": [s stringForColumn:@"id"],
            @"name":  [BTDatabase localizeDynamicContent:[s stringForColumn:@"name"]],
            @"short_description": [BTDatabase localizeDynamicContent:[s stringForColumn:@"short_description"]],
            @"long_description": [BTDatabase localizeDynamicContent:[s stringForColumn:@"long_description"]],            
            @"icon": [s stringForColumn:@"icon"],
            @"latitude": [NSNumber numberWithDouble:[s doubleForColumn:@"latitude"]],
            @"longitude": [NSNumber numberWithDouble:[s doubleForColumn:@"longitude"]],
            @"accommodation": [NSNumber numberWithInt:[s intForColumn:@"accommodation"]],
            @"restaurant": [NSNumber numberWithInt:[s intForColumn:@"restaurant"]],
            @"public_transport": [NSNumber numberWithInt:[s intForColumn:@"public_transport"]],
            }];
        
        if([s stringForColumn:@"photo_small_url"]) {
            [object setObject:[[BacktrackClient sharedClient] authenticatedURL:[s stringForColumn:@"photo_small_url"]] forKey:@"thumbnail"];
        }
        
        return object;
    }
    
    return nil;
}

#pragma mark point photos
-(NSArray*)photosForPointOfInterest:(NSString*)ID {
    NSMutableArray* results = [[NSMutableArray alloc] init];
    
    FMResultSet* set = [_database executeQuery:@"SELECT photo_full_url FROM point_photos WHERE interesting_point_id = ? ORDER BY 'order' ASC", ID];
    
    while([set next]) {
        [results addObject:[[BacktrackClient sharedClient] authenticatedURL:[set stringForColumn:@"photo_full_url"]]];
    }
    
    return (NSArray*)results;
}

-(NSArray*)flowersByMonth:(bool)byMonth andAltitude:(int)altitude {
    
    NSMutableArray* results = [[NSMutableArray alloc] init];
    
    NSUInteger flowering_low = 1;
    NSUInteger flowering_high = 12;

    if(byMonth) {
        NSDate *currentDate = [NSDate date];
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDate]; // Get necessary date components
        
        flowering_low = [components month];
        flowering_high = [components month];
    }
    
    FMResultSet* set = [_database executeQuery:@"SELECT * FROM flowers WHERE flowering_low <= ? AND flowering_high >= ? ORDER BY latin_name ASC", [NSString stringWithFormat:@"%d", flowering_high], [NSString stringWithFormat:@"%d", flowering_low]];
    
    while([set next]) {
        [results addObject:@{
            @"id": [set stringForColumn:@"id"],
            @"latin_name": [set stringForColumn:@"latin_name"],
            @"common_name": [BTDatabase localizeDynamicContent:[set stringForColumn:@"common_name"]],
            @"family": [set stringForColumn:@"family"],
            @"height": [set stringForColumn:@"height"]
        }];
    }
    
    return results;
}
@end
