//
//  SearchResult.m
//  Search
//
//  Created by Julian Richardson on 1/31/12.
//  Copyright (c) 2012 Julian Richardson. Licensed under MIT license. See LICENCE.TXT.
//

#import "SearchResult.h"

@implementation SearchResult

@synthesize rank=_rank;
@synthesize score=_score;
@synthesize docid=_docid;
@synthesize docname=_docname;
@synthesize snippet=_snippet;
@synthesize payloads=_payloads;

- (id)initWithRank:(int)rank andScore:(double)score andDocID:(DocID)docid andDocname:(NSString *)docname andSnippet:(NSString *)snippet andPayloads:(NSDictionary *)payloads {
    if (( self = [super init])) {
        self.rank = rank;
        self.score = score;
        self.docid = docid;
        self.docname = docname;
        self.snippet = snippet;
        self.payloads = payloads;
    }
    return self;
}

- (void)dealloc {
    [_docname release];
    [_snippet release];
    [_payloads release];
    [super dealloc];
}

@end
