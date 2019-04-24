//
//  MEOXMLReader
//
//  Created by Mitsuharu Emoto on 9/18/10.
//  Copyright 2010 Mitsuharu Emoto. All rights reserved.
//

#import "MEOXMLReader.h"

NSString *const meoXMLReaderTextNodeKey = @"text";

@interface MEOXMLReader () <NSXMLParserDelegate>
{
    MEOXMLReaderBlock completion_;
    
    __weak id<MEOXMLReaderDelegate> delegate_;
    NSDictionary *userInfo_;
    NSInteger tag_;
    
    NSInteger totalResult_;
    NSError *error_;
    
    NSMutableArray *dictionaryStack_;
    NSMutableString *textInProgress_;
}

-(NSString*)trim:(NSString*)string;

@end


@implementation MEOXMLReader

@synthesize delegate = delegate_;
@synthesize userInfo = userInfo_;
@synthesize error = error_;
@synthesize tag = tag_;

#pragma mark XMLReader

+(void)parseXMLString:(NSString *)string completion:(MEOXMLReaderBlock)completion
{
    MEOXMLReader *xml = [[MEOXMLReader alloc] init];
    [xml parseForXMLString:string
                completion:completion];
}

+(void)parseXMLData:(NSData *)data completion:(MEOXMLReaderBlock)completion
{
    MEOXMLReader *xml = [[MEOXMLReader alloc] init];
    [xml parseXMLData:data
           completion:completion];
}

- (id)init
{
    if (self = [super init]){
        error_ = nil;
        dictionaryStack_ = nil;
        textInProgress_ = nil;
        totalResult_ = 0;
    }
    return self;
}

- (void)dealloc
{
    error_ = nil;
    dictionaryStack_ = nil;
    textInProgress_ = nil;
}

-(void)parseForXMLString:(NSString *)string
{
    [self parseForXMLString:string completion:nil];
}


-(void)parseForXMLString:(NSString *)string completion:(MEOXMLReaderBlock)completion
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    [self parseXMLData:data completion:completion];
    
}

-(void)parseXMLData:(NSData *)data completion:(MEOXMLReaderBlock)completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Clear out any old data
        self->dictionaryStack_ = nil;
        self->textInProgress_ = nil;
        
        self->dictionaryStack_ = [[NSMutableArray alloc] init];
        self->textInProgress_ = [[NSMutableString alloc] init];
        
        // Initialize the stack with a fresh dictionary
        [self->dictionaryStack_ addObject:[NSMutableDictionary dictionary]];
        
        // Parse the XML
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
        parser.delegate = self;
        BOOL success = [parser parse];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSDictionary *dict = nil;
            if (success){
                dict = [self->dictionaryStack_ objectAtIndex:0];
            }
            if (self->delegate_ && [self->delegate_ respondsToSelector:@selector(xmlReader:parsed:)]) {
                [self->delegate_ xmlReader:self parsed:dict];
            }
            if (completion) {
                completion(dict);
            }
        });
    });
}

-(void)parseXMLData:(NSData *)data
{
    [self parseXMLData:data completion:nil];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        // Clear out any old data
//        dictionaryStack_ = nil;
//        textInProgress_ = nil;
//        
//        dictionaryStack_ = [[NSMutableArray alloc] init];
//        textInProgress_ = [[NSMutableString alloc] init];
//        
//        // Initialize the stack with a fresh dictionary
//        [dictionaryStack_ addObject:[NSMutableDictionary dictionary]];
//        
//        // Parse the XML
//        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
//        parser.delegate = self;
//        BOOL success = [parser parse];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            NSDictionary *dict = nil;
//            if (success){
//                dict = [dictionaryStack_ objectAtIndex:0];
//            }
//            if (delegate_ && [delegate_ respondsToSelector:@selector(xmlReader:parsed:)]) {
//                [delegate_ xmlReader:self parsed:dict];
//            }
//        });
//    });
}

-(NSString*)trim:(NSString*)string
{
    NSCharacterSet *characterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [string stringByTrimmingCharactersInSet:characterSet];
}


#pragma mark NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    // Get the dictionary for the current level in the stack
    NSMutableDictionary *parentDict = [dictionaryStack_ lastObject];

    // Create the child dictionary for the new element, and initilaize it with the attributes
    NSMutableDictionary *childDict = [NSMutableDictionary dictionary];
    [childDict addEntriesFromDictionary:attributeDict];
    
    // If there's already an item for this key, it means we need to create an array
    id existingValue = [parentDict objectForKey:elementName];
    if (existingValue)
    {
        NSMutableArray *array = nil;
        if ([existingValue isKindOfClass:[NSMutableArray class]])
        {
            // The array exists, so use it
            array = (NSMutableArray *) existingValue;
        }
        else
        {
            // Create an array if it doesn't exist
            array = [NSMutableArray array];
            [array addObject:existingValue];

            // Replace the child dictionary with an array of children dictionaries
            [parentDict setObject:array forKey:elementName];
        }
        
        // Add the new child dictionary to the array
        [array addObject:childDict];
    }
    else
    {
        // No existing value, so update the dictionary
        [parentDict setObject:childDict forKey:elementName];
    }
    
    // Update the stack
    [dictionaryStack_ addObject:childDict];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    // Update the parent dict with text info
    NSMutableDictionary *dictInProgress = [dictionaryStack_ lastObject];
    
    // Set the text property
    if ([textInProgress_ length] > 0)
    {
        [dictInProgress setObject:[self trim:textInProgress_] forKey:meoXMLReaderTextNodeKey];

        // Reset the text
        textInProgress_ = nil;
        textInProgress_ = [[NSMutableString alloc] init];
    }
    
    // Pop the current dict
    [dictionaryStack_ removeLastObject];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    // Build the text value
    [textInProgress_ appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    // Set the error pointer to the parser's error object
    error_ = parseError;
}

@end
