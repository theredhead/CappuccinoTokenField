@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@implementation AppController : CPObject
{
    @outlet CPWindow theWindow;
	@outlet CPTokenField tokenField;
	@outlet CPButton alertButton;
}

- (@action)alertButtonClicked:(id)sender
{
	var theAlert = [[CPAlert alloc] init];
	var tokens = [tokenField objectValue];
	[theAlert setTitle: "TokenField stringValue"];
	[theAlert setInformativeText: [tokenField stringValue]];
	[theAlert setMessageText: [CPString stringWithFormat: "The tokenfield currently holds %d items:", [tokens count]]];
	[theAlert addButtonWithTitle:"Cool"];
	[theAlert runModal];
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    // This is called when the application is done loading.
}

- (void)awakeFromCib
{
    // [theWindow setFullPlatformWindow:YES];
	
	// just a non extensive list of languages
	var programmingLanguages = ["Algol", "c", "c#", "c++", "Objective-C", "Objective-J", "Pascal", "php", "Java", "d", "Ada", "Lisp", "Go", "Ruby", "Python", "JavaScript", "TypeScript", "COBOL", "BASIC"];
	// create the token field controller
	var theController = [[TokenFieldController alloc] initWithOptions: programmingLanguages];
	//set the tokenFields' delegate to the controller
	[tokenField setDelegate: theController];
}

@end

@implementation TokenFieldController : CPObject
{
	CPArray _options @accessors(property=options);
	BOOL _caseSensitive @accessors(getter=isCaseSensitive,setter=setCaseSensitive);
	BOOL _allowDuplicates @accessors(getter=doesAllowDuplicates,setter=setAllowDuplicates);
	BOOL _allowAdding @accessors(getter=doesAllowAdding,setter=setAllowAdding);
}

- (id)init
{
	if (self = [super init])
	{
		_options = [];
		_caseSensitive = NO;
		_allowDuplicates = NO;
		_allowAdding = NO;
	}
	return self;
}

- (BOOL)containsOption:(CPString)anOption
{
	var result = NO;
	if (_caseSensitive)
	{
		result = _options.indexOf(anOption) > 0;
	}
	else
	{
		var lowerCasedOption = anOption.toLowerCase();
		for (var i = 0; i < _options.length; i++)
		{
			if (_options[i].toLowerCase() == lowerCasedOption)
			{
				result = YES;
				break;
			}
		}
	}
	return result;
}

- (CPString)resolveToken:(CPString)aPotentiallyMisCasedToken
{
	var result = nil;
	var lowerCasedToken = aPotentiallyMisCasedToken.toLowerCase();
	for (var i = 0; i < _options.length; i++)
	{
		if (_options[i].toLowerCase() == lowerCasedToken)
		{
			result = _options[i];
			break;
		}
	}
	return result;
}

- (id)initWithOptions:(CPArray)options
{
	if (self = [self init])
	{
		_options = options;
	}
	return self;
}

- (CPArray)tokenField:(CPTokenField)tokenField completionsForSubstring:(CPString)substring indexOfToken:(CPInteger)tokenIndex indexOfSelectedItem:(CPInteger)selectedIndex 
{
	console.log('tokenField.objectValue: ', [tokenField objectValue]);
	console.log('-tokenField:completionsForSubstring:indexOfToken:indexOfSelectedItem:',[substring, tokenIndex, selectedIndex] );
	var result = [];
	if (substring.length > 0)
	{
		var lowerCasedSubstring = substring.toLowerCase();
		for (var i = 0; i < _options.length; i++)
		{
			if (_options[i].toLowerCase().indexOf(lowerCasedSubstring) > -1 || substring == "*")
			{
				if (_allowDuplicates || [tokenField objectValue].indexOf(_options[i]) == -1)
					result.push(_options[i]);
			}
		}
	}
	return result;
}

- (CPString)tokenField:(CPTokenField)tokenField displayStringForRepresentedObject:(id)representedObject
{
	console.log('-tokenField:displayStringForRepresentedObject:', representedObject);
	if ([self containsOption:representedObject])
		return representedObject;
	else
		return nil;
}

- (BOOL)tokenField:(CPTokenField)tokenField hasMenuForRepresentedObject:(id)representedObject
{
	console.log('-tokenField:hasMenuForRepresentedObject:', [representedObject]);
	return NO;
}

- (CPMenu)tokenField:(CPTokenField)tokenField menuForRepresentedObject:(id)representedObject
{
	console.log('-tokenField:menuForRepresentedObject:t', [representedObject]);
	return nil;
}

- (id)tokenField:(CPTokenField)tokenField representedObjectForEditingString:(CPString)editingString
{
	console.log('-tokenField:representedObjectForEditingString:', [editingString]);
	var result = nil;
	if ([self containsOption: editingString])
	{
		result = editingString;
	}
	return result;
}

- (CPArray)tokenField:(CPTokenField)tokenField shouldAddObjects:(CPArray)tokens atIndex:(CPUInteger)index
{
	console.log('-tokenField:shouldAddObjects:atIndex:', [tokens, index]);
	var result = [];
	for (var i = 0; i < tokens.length; i++)
	{
		if ([self containsOption: tokens[i]])
		{
			result.push([self resolveToken:tokens[i]]);
		}
		else if (_allowAdding)
		{
			_options.push(tokens[i]);
			result.push(tokens[i]);
		}
	}
	return result;
}

@end
