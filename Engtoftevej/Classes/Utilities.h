//
//  Utilities.h
//  MitNykredit
//
//  Created by Internet & Bank afd. Koncernudvikling on 26/11/10.
//  Copyright 2010 Nykredit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NYKGeneralAccount.h"
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "MyCLController.h"


#define kSimulatorLat			55.766338
#define kSimulatorlong			12.496262

@interface Utilities : NSObject {

}
+(NSString *)futureDate:(NSDate *) myDate;
+(NSDate *)dateFromXmlStringCustody:(NSString *) str;
+ (NSMutableString *) formatAccountnumber:(NSString *) t ;
+(NSDecimalNumber *) getPercentageOfValue: (NSDecimalNumber *) custodyValue value: (NSDecimalNumber *) value;
//+(NSString*)findAccountname:(NSString*)accountnumber;
//+(NSArray*)findDifferentDatesInArray:(NSArray*)dates;
//+(int)findNumbersOfItems:(NSArray*)dates date: (NSDate *) key;
//+(NSArray*)buildPaymentsArr:(NSArray*)dates date: (NSDate *) key;
//+(NSMutableArray*)findAllType:(NSArray*)searchSpendingArray;

+ (NSString *)uniqueString;

+(BOOL)verifyModula10:(NSString*)cardId;
//+(BOOL)isExternalAccount:(NYKGeneralAccount *)gAccount;
//+(BOOL) isExternalAccountNumber:(NSString *)accountNumber;
+ (void)setToolbarTitle:(NSString *)title navigation:(UINavigationItem*)navigation;
//+ (NSMutableArray*) loadFromFile;
//+(void)trackApp:(NSString *)pageName channel:(NSString *)channel prop:(NSString *)prop events:(NSString *)events eVar:(NSString *)eVar eVarIndhold:(NSString *)eVarIndhold;
+(NSDate*)getNextWeekday;

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
+(void)checkPercentage;
@end
