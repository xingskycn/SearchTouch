# SearchTouch 

This is a search engine written in Objective C which compiles and runs
on Mac OSX or iOS.

## License

The software is distributed under an MIT license. See LICENSE.TXT for
details. If you use SearchTouch in a project, I would appreciate an
acknowledgement, but it is not required.

## Contributors

All of the code has been contributed by Julian Richardson,
julianrichardson@acm.org. Contributions are very welcome. Please contact
me if you would like to contribute, or if you have bug reports,
questions or suggestions.

## Incorporating into your project

The *src/* directory contains all the files needed to incorporate a
search engine into your code.

Using XCode, add that entire directory to your project by selecting the menu item:

File -> Add Files to *your project*

then navigating to the *SearchTouch* project folder and selecting the *src* folder.

You will also need to ensure your code is linked to the Core Data
framework: select your target, build target, select the *Build Phases*
tab, expand the *Link Binary With Libraries* item, hit the "+" and
select *CoreData.Framework*.

## Automatic Reference Counting (ARC) or Manual Memory Management?
The code is currently set up to use ARC.

## Building an index

You must supply the path to a file which contains a list of files to
index, separated by newlines. Each line in that file list should be a
full path name. For example, if the contents of */Users/you/files.txt* is:

     /Users/you/world_factbook/2001.txt
     /Users/you/world_factbook/2002.txt

then you should initialize an instance of the Index class with:

     #include <Search.h>

     NSString *filelist = @"/Users/you/files.txt";
     Index *index = [[Index alloc] initWithFilenamesFromFile:filelist];

You can then build a searchable index of the contents of *2001.txt* and
*2002.txt* with:

    [index buildIndex:nil];

The single argument to buildIndex is a dictionary of options. Currently the
only option supported is storetext, which stores the tokenized text of the
indexed documents in the index. So instead of the above line of code you
could write:

    [index buildIndex:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"storetext"]];

## Searching an index

Given an index built as above, search the index with:

    Search *s = [[Search alloc] initWithQueryString:searchtermtext andIndex:index];
    NSArray *rankedResults = [s rankedResults];

where searchtermtext is a string containing a list of space-separated
search terms. This string is normalized by downcasing and removing all
punctuation and stop words before performing the search - searches for
*enable improvement*, *the imProvement ENABLE* should give the same
results.

*rankedResults* lists every document in the index which contains all of
the search terms. It is represented as an array of *SearchResult*
instances, ranked (best first) using TFIDF according to the [BM25
formula]:http://en.wikipedia.org/wiki/Probabilistic_relevance_model_(BM25).

Each SearchResult instance has the following readable instance variables:

    int rank;
    double score;
    DocID docid;
    NSString *docname;
    NSString *snippet;
    NSDictionary *postingsForTerm;

*snippet* is currently always the empty string.

*postingsForTerm* is a dictionary mapping each search term to a *Postings* instance, with readable instance variables:

    DocID docid;
    int npostings;
    uint32_t *positions;

So for example, the first position of the first *enable* in the first result for the query *enable improvement* can be found by:

    Search *s = [[Search alloc] initWithQueryString:@"enable improvement" andIndex:index];
    NSArray *rankedResults = [s rankedResults];

    SearchResult *topresult = [rankedResults objectAtIndex:0];
    Postings *postingsForEnable = [[topresult postingsForTerm] valueForKey:@"enable"];
    uint32_t firstPosition = (postingsForEnable.positions)[0];

## Choosing a back end data structure

By default, *Core Data* is used to store and manipulate search
indexes. If you don't want to use Core Data, there is an alternative set
of data structures, based on *CFTree*. Building and searching these
indexes is fast, but they cannot be saved to persistent storage - they
must be rebuilt every time your app is used. To use these data
structures, define the *NO_CORE_DATA* preprocessor symbol in the
*Preprocessor Macros Not Used in Precompiled Headers* section of your
target's *Build Settings*.

## Using an index which was previously built

When using Core Data, built indexes are stored in a file
*DataModel.sqlite* in the top level directory of your application. You
can check to see whether an index already exists using `(BOOL)[index
hasBeenBuilt]`. If an index has already been built then you can use it
directly without rebuilding it, e.g.

    NSString *filelist = @"/Users/you/files.txt";
    Index *index = [[Index alloc] initWithFilenamesFromFile:filelist];
    Search *s = [[Search alloc] initWithQueryString:searchtermtext andIndex:index];
    NSArray *rankedResults = [s rankedResults];

## Stop Words

The following are considered stop words and neither indexed nor searched for: 

    a, an, and, but, he, her, hers, him, his, how, i, it, its, of, or, she, the, their, them, there, these, they, to, who, why, where, when, what, which, you, your

