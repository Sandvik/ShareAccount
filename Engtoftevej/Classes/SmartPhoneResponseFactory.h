//
//  SmartPhoneResponseFactory.h
//
//  Created by Wojciech Chojnacki on 12/6/10.
//  Copyright 2010 Nykredit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SmartPhoneResponse.h"
#import "TransferResponse.h"
#import "GDataXMLNode.h"
#import "Utilities.h"
#import "ProductOverviewResponse.h"

@interface SmartPhoneResponseFactory : NSObject {

}


+(TransferResponse *) transferResponseFromJson:(NSData *)xmlData;
+(ProductOverviewResponse *) overviewResponseFromJSon:(NSData *)xmlData;
@end
