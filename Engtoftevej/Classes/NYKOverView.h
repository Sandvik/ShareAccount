//
//  NYKOverView.h
//  MitNykredit
//
//  Created by Thomas Sandvik on 2/10/11.
//  Copyright 2011 Nykredit. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NYKOverView : NSObject {
@private 
	//Common for Accounta and Custodies
	NSString *name;
	NSString *overviewNumber;
    
	NSString *type; //Custody OR Account OR Mortgage
	NSString *currency;//Custody OR Mortgage
	
	//Only for Accounts
	NSDecimalNumber *balance;//Account OR Mortgage
	
	//Only for Custodies
	NSDecimalNumber *marketValue;
    
    //Only for Mortgages
    
	//Only for Insurances
    NSString *insuranceType;
    NSDecimalNumber *insurancePremium;
}
@property (nonatomic, copy) NSString *overviewNumber;
@property (nonatomic, copy) NSString *insuranceType;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *currency;
@property (nonatomic, retain) NSDecimalNumber *balance;
@property (nonatomic, retain) NSDecimalNumber *marketValue;
@property (nonatomic, retain) NSDecimalNumber *insurancePremium;

@end
