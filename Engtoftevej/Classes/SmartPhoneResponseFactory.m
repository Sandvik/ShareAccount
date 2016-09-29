//
//  SmartPhoneResponseFactory.m
//  MitNykredit
//
//  Created by Wojciech Chojnacki on 12/6/10.
//  Copyright 2010 Nykredit. All rights reserved.
//

#import "SmartPhoneResponseFactory.h"
#import "Utilities.h"
#import "JSON.h"

@interface SmartPhoneResponseFactory(Private)


@end;

NSString * const kAccount = @"A";
NSString * const kCustody = @"C";
NSString * const kMortgage = @"M";
NSString * const kInsurance = @"I";

@implementation SmartPhoneResponseFactory



//
// parse overview response
//
+(ProductOverviewResponse *) overviewResponseFromJSon:(NSData *)xmlData{
    NSString *jsonString = [[[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding]autorelease];
    NSLog(@"SpendingData %@", jsonString);
    
    ProductOverviewResponse *response = [[[ProductOverviewResponse alloc] init] autorelease];	
    
    NSDictionary *json = [jsonString JSONValue];   
	NSLog(@"json %@", json);
    // Iterate it
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    //[dateFormat setLocale:[NSLocale currentLocale]];
    //[dateFormat setDateStyle:NSDateFormatterShortStyle];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSMutableArray *paymentsArray = [[NSMutableArray alloc] init];
    for (NSDictionary *status in json)
    {
        NYKGeneralAccount *payment= [[NYKGeneralAccount alloc] init];

        NSString *ttt = [status valueForKey:@"postnote"];
        NSLog(@"%@",ttt);
        if ([status valueForKey:@"postnote"] == [NSNull null]) {
            NSLog(@"JA");
            ttt=@"No comments";
        }else{
            NSData *asciiData = [ttt dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            
            NSString *asciiString = [[NSString alloc] initWithData:asciiData encoding:NSUTF8StringEncoding];
            NSLog(@"%@",asciiString);            
        }
        
        if ([ttt isEqualToString:@""]) {
            ttt=@"No comments";
        }
        
        
        NSDecimalNumber *transferAmount = [NSDecimalNumber decimalNumberWithString:[status valueForKey:@"price"]];
        payment.price = transferAmount;
        payment.postnote=ttt;
        payment.transactionDate = [dateFormat dateFromString:[status valueForKey:@"cur_timestamp"]];
        payment.type = [status valueForKey:@"type"];
        payment.objectName = [status valueForKey:@"person"];
        payment.afstemtJN = [status valueForKey:@"afstemtYN"];        
        payment.ident =[[status valueForKey:@"id"] intValue];
        [paymentsArray addObject:payment];
        [payment release];  
    }  
	 [dateFormat release];
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"transactionDate"
                                                  ascending:NO] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSArray * tt =	[paymentsArray sortedArrayUsingDescriptors:sortDescriptors]; 
   
    response.accounts =[NSMutableArray arrayWithArray:tt] ;
    
    
    [paymentsArray release];
    return response;
}
//
// parse transfer response
//
+(TransferResponse *) transferResponseFromJson:(NSData *)xmlData{    
    NSString *jsonString = [[[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding]autorelease];
	NSLog(@"SpendingData %@", jsonString); 
    NSLog(@"SpendingData %d", jsonString.length);
    TransferResponse *response = [[[TransferResponse alloc] init] autorelease]; 
    if (jsonString !=nil && jsonString.length > 0 ) {
        NSDictionary *json = [jsonString JSONValue];
        response.fromAccountBalance = [json valueForKeyPath:@"transferConfirmation.fromAccountBalance"]; 
        response.toAccountBalance = [json valueForKeyPath:@"transferConfirmation.toAccountBalance"]; 
        response.customer = [json valueForKeyPath:@"transferConfirmation.amountCovered"]; 
        
        if([[json valueForKeyPath:@"transferConfirmation.amountCovered"] intValue]==0){
            response.amountCovered = NO;
        }else{
            response.amountCovered = YES;
        } 
    }	   
        return response;
}




+(void) parseStandardJSONHeaders:(NSDictionary *)root response:(SmartPhoneResponse **)aResponse {
	SmartPhoneResponse *response = *aResponse;
    
    NSString *status = [root valueForKey:@"status"];
    if([status isEqualToString:@"OK"]){
        response.status = SmartPhoneResponseStatusOK;
    } 
    else if([status isEqualToString:@"ERR"]) {
        response.status = SmartPhoneResponseStatusERROR;
        
        NSMutableArray *messagesArray = [[NSMutableArray alloc] init];	
        NSArray *items = [root valueForKeyPath:@"messages"];
//        DLog(@"items %@", items);
        NSEnumerator *enumerator = [items objectEnumerator];
        NSDictionary* item;
        while ((item = (NSDictionary*)[enumerator nextObject])) {
//            DLog(@"text = %@",  [item objectForKey:@"message"]);
//            DLog(@"nodeId = %@",  [item objectForKey:@"property"]);
            
            NSString *itemTxt = [item objectForKey:@"message"];
            [messagesArray addObject:itemTxt];
            
        }
//        DLog(@"spendingsArray = %@",  messagesArray);
        
        response.messages = messagesArray;
        
        [messagesArray release];
        
        
    }
    else if([status isEqualToString:@"SES_INV"]){
        response.status = SmartPhoneResponseStatusSESSION_INVALID;            
        
    } 
    else if([status isEqualToString:@"OK_OLD_PROT"]){
        response.status = SmartPhoneResponseStatusOK;
        
    } 
    else if([status isEqualToString:@"ERR_PROTOCOL_NOT_SUPPORTED"]){
        response.status = SmartPhoneResponseStatusPROTOCOLNOTSUPPORTED;
        
    } 
    else response.status = SmartPhoneResponseStatusUNKNOW;
    
}



@end
