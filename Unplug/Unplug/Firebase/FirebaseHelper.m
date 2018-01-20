//
//  FirebaseHelper.m
//  Unplug
//
//  Created by Scott P. Chow on 1/20/18.
//  Copyright © 2018 sbhacks. All rights reserved.
//

#import "FirebaseHelper.h"

static FirebaseHelper *sharedAPIWrapper;

@implementation FirebaseHelper

+(instancetype) sharedWrapper {
    if(!sharedAPIWrapper)
        sharedAPIWrapper = [[self alloc] init];
    
    return sharedAPIWrapper;
}

- (id) init {
    if (self = [super init]) {
        ref = [[FIRDatabase database] reference];   
    }
    
    return self;
}



-(void)getUserWithUID: (NSString *) uid completion: (void (^)(User *)) completion {
    FIRDatabaseReference *userRef = [[ref child:@"users"] child:uid];
    
    [userRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        User *user = [[User alloc] init:snapshot];
        completion(user);
    }];
}

-(void)createUser:(User *)newUser {
    FIRDatabaseReference *userRef = [[ref child:@"users"] child:newUser.uid];
    [userRef setValue: [newUser toDict]];
}

-(void)setCurrentUser:(User *) user {
    currentUser = user;
}
-(User *)getCurrentUser {
    return currentUser;
}

-(void)handleLogin:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error completion:(void (^)(BOOL)) completion {
    if (error == nil && !result.isCancelled) {
        
        FIRAuthCredential *credential = [FIRFacebookAuthProvider credentialWithAccessToken:[FBSDKAccessToken currentAccessToken].tokenString];
        [[FIRAuth auth] signInWithCredential:credential completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
            if (error != NULL) {
                return;
            }
            [FirebaseHelper.sharedWrapper getUserWithUID:user.uid completion:^(User *user) {
                if (user == NULL) {
                    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"name"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                        if (error) {
                            NSLog(@"%@", error.localizedDescription);
                        } else {
                            NSLog(@"fetched user:%@", result);
                            User *newUser = [[User alloc] init];
                            newUser.uid = [[FIRAuth auth] currentUser].uid;
                            newUser.name = [result objectForKey:@"name"];
                            newUser.balance = @0;
                            [FirebaseHelper.sharedWrapper createUser:newUser];
                            [FirebaseHelper.sharedWrapper setCurrentUser:newUser];
                        }
                    }];
                } else {
                    [FirebaseHelper.sharedWrapper setCurrentUser:user];
                }
                //                TODO: Transition Here
                completion(YES);
            }];
        }];
    } else {
        NSLog(@"%@", error.localizedDescription);
        completion(NO);
    }
}

@end
