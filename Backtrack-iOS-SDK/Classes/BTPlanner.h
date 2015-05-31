//
//  BTPlanner.h
//  Pods
//
//  Created by Ahmet Özışık on 31.05.2015.
//
//

#import "BTDatabase.h"

@interface BTPlanner : NSObject


-(void)planTripFrom:(NSString*)fromPointID toPoint:(NSString*)toPointID forkBlock:(BTTripForkBlock)forkHandler completionBlock:(BTObjectResultBlock)completionHandler;

@end
