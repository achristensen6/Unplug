//
//  User.m
//  Unplug
//
//  Created by Scott P. Chow on 1/20/18.
//  Copyright © 2018 sbhacks. All rights reserved.
//

#import "User.h"

@implementation User

-(instancetype) init:(FIRDataSnapshot *)snapshot {
    if(!self) {
        self = [User new];
    }
    if(snapshot.value == [NSNull null]) {
        return NULL;
    }
    self.name = snapshot.value[@"name"];
    self.balance = snapshot.value[@"balance"];
    self.uid = snapshot.key;
    return self;
}


-(NSDictionary *) toDict {
    NSDictionary *dict = @{@"name" : self.name,
                           @"balance" : self.balance};
    
    return dict;
}
@end
