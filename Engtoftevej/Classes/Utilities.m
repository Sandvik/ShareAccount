#import "Utilities.h"
#import "AppDataCache.h"
#import "NYKAccount.h"


@implementation Utilities

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Retunerer førtkommende hverdag hvis man er på en lørdag eller søndag
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
+(NSDate*)getNextWeekday{
    NSDate *now = [NSDate date];
    int daysToAdd;    
    NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
    // create a calendar
    NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    
    
    NSDateFormatter* theDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [theDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [theDateFormatter setDateFormat:@"EEEE"];
    NSString *weekDay =  [theDateFormatter stringFromDate:now];	
      
    if ([weekDay isEqualToString:@"Sunday"]) {
        //Læg 1 dag til
        daysToAdd=1;        
    }
    else if ([weekDay isEqualToString:@"Saturday"]) {
        daysToAdd=2;
    }
    [components setDay:daysToAdd];
    NSDate *newDate2 = [gregorian dateByAddingComponents:components toDate:now options:0];
    weekDay =  [theDateFormatter stringFromDate:newDate2];	
    return newDate2;    
}


+ (void)setToolbarTitle:(NSString *)title navigation:(UINavigationItem*)navigation{
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(96, 14, 127,14)];
	titleLabel.text = title;
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.adjustsFontSizeToFitWidth = NO;
	titleLabel.font = [UIFont fontWithName:@"FoundryFormSans-Medium" size:21];
	[titleLabel sizeToFit];
    navigation.titleView = titleLabel;
}

+ (NSDecimalNumber *) getPercentageOfValue: (NSDecimalNumber *) custodyValue value: (NSDecimalNumber *) value  {
    NSDecimalNumber *tmp = [NSDecimalNumber decimalNumberWithString:@"100"];
    NSDecimalNumber *tmp0 = [value decimalNumberByDividingBy:custodyValue];
    NSDecimalNumber *tmp2 =[tmp0 decimalNumberByMultiplyingBy:tmp];
    return tmp2;
}

+ (NSMutableString *) formatAccountnumber:(NSString *) t  {
    if (t!=nil) {
        NSMutableString *muta = [NSMutableString stringWithString:t];
        if([muta length]>4)[muta insertString:@"-" atIndex:4];
        return muta;
    }
    return nil;    
}

+(NSString *)futureDate:(NSDate *) myDate{
    NSDate *today = [NSDate date];
    //Date check
    if (myDate==nil) {
        return @"";
    }
    
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:flags fromDate:today];
    
    NSDate* dateOnly = [calendar dateFromComponents:components];
    
    int dayMyday = [myDate timeIntervalSince1970] /86400;
    int dayToday = [dateOnly timeIntervalSince1970] /86400;
    
	//NSTimeInterval dateTime;
	if (dayToday == dayMyday){
		return @"TODAY";
        //NSLog (@"Dates are equal");
	}else if(dayToday > dayMyday){
        return @"BEFORETODAY";
    }
    else if(dayToday < dayMyday){
        return @"AFTERTODAY";
    }
	return @"";
}

//
// convert date used in java xml's, for example 2010-12-06T18:05:50.115+01:00
//
+(NSDate *)dateFromXmlStringCustody:(NSString *) str {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-ddZZZ"];
	NSMutableString *tmp = [[NSMutableString alloc] init];
	[tmp appendString:str];
	NSRange range;
	range.length = 1;
	range.location = [str length]-3;
	[tmp deleteCharactersInRange:range];
	NSDate *date = [dateFormat dateFromString:tmp];  
	[tmp release];
	[dateFormat release];
	return date;
}




//Generate unique string as key
+ (NSString *)uniqueString{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    [(NSString *)uuidStr autorelease];
    return (NSString *)uuidStr;
}

//A modula check on the paymentID -- Check original from PBS
+(BOOL)verifyModula10:(NSString*)cardId{
    DLog(@"number %@",cardId);
    //NSString *stringWitoutZero = [cardId stringByReplacingOccurrencesOfString:@"0" withString:@""];
    int csum =0;
    int weight = 1;
    int digits = [cardId length];  
    for (int i =digits-1;i >= 0; --i){
        char t = [cardId characterAtIndex:i];
        int cg =(int)(t-'0');
        int val = cg * weight;        
        if(val > 9){  
            val -= 9;
        }  
        csum += val;
        weight = (weight == 1) ? 2 : 1;  
    }   
    if (csum % 10 == 0) {
        return YES;
    }else{
        return NO;
    }  
}


+(void)checkPercentage{
    //Alle procenttal skal give 100% hverken mere eller mere
    
    
    double percent = 0;;
    for(int i=0;i<[[AppDataCache sharedAppDataSource].peopleList count];i++){
        NYKGeneralAccount *acc =[[AppDataCache sharedAppDataSource].peopleList objectAtIndex:i];
        double tmpPercent = acc.fordeling;
        percent = percent + tmpPercent;
    }
    
    NSLog(@"%f",percent);
    
    if (percent!=100) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Percentage is not 100%"
                              message: @"The overall percentage is not 100%.\n Please correct the various peoples percentage rate, so the total percentage equals 100%. Otherwise, the final accounting will NOT be calculated correctly!\n \n GO to the section 'Who else is associated with this account'"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    
}




@end
