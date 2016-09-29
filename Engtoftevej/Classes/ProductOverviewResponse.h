//
//  ProductOverviewResponse.h
//  MitNykredit
//
//  Created by Wojciech Chojnacki on 12/7/10.
//  Copyright 2010 Nykredit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SmartPhoneResponse.h"
#import "NYKAccount.h"
//#import "NYKCustody.h"
#import "NYKOverView.h"
//#import "NYKMortgage.h"
//#import "NYKInsurance.h"

@interface ProductOverviewResponse : SmartPhoneResponse {
	NSMutableArray *accounts;
	NSArray *custodies;
	NSMutableArray* overview;
    NSArray *mortgages;
    NSArray *insurances;
    NSArray *payments;
}

@property (nonatomic, copy) NSMutableArray *accounts;
@property (nonatomic, copy) NSArray *payments;
@property (nonatomic, copy) NSArray *insurances;
@property (nonatomic, copy) NSArray *custodies;
@property (nonatomic, copy) NSArray *mortgages;
@property (nonatomic, copy) NSMutableArray *overview;

@end
