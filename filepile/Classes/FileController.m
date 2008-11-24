//
//  FileController.m
//  filepile
//
// Copyright 2008 Brian Dunagan (brian@bdunagan.com)
//
// MIT License
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//

#import "FileController.h"
#import "BDString.h"
#import "TextViewCell.h"
#import "ImagePreviewCell.h"
#import <Foundation/Foundation.h>

@implementation FileController

// Returns {@"name"=>name, @"value=>value} dictionary.
+ (NSDictionary *)stringsForAttribute:(NSString *)attribute fromDictionary:(NSDictionary *)attributesDict
{
	// Set up the env.
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	NSString *name;
	NSString *value;
	
	// Get the raw value.
	id *rawValue = [attributesDict valueForKey:attribute];

	if ([attribute isEqualToString:NSFileAppendOnly])
	{
		name = @"Append Only";
		value = [rawValue boolValue] ? @"True" : @"False";
	}
	else if ([attribute isEqualToString:NSFileBusy])
	{
		name = @"Busy";
		value = [rawValue boolValue] ? @"True" : @"False";
	}
	else if ([attribute isEqualToString:NSFileCreationDate])
	{
		name = @"Creation Date";
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		value = [dateFormatter stringFromDate:rawValue];
		[dateFormatter release];
	}
	else if ([attribute isEqualToString:NSFileOwnerAccountName])
	{
		name = @"Owner Account Name";
		value = rawValue;
	}
	else if ([attribute isEqualToString:NSFileGroupOwnerAccountName])
	{
		name = @"Group Owner Account Name";
		value = rawValue;
	}
	else if ([attribute isEqualToString:NSFileDeviceIdentifier])
	{
		name = @"Device Identifier";
		value = [rawValue stringValue];
	}
	else if ([attribute isEqualToString:NSFileExtensionHidden])
	{
		name = @"Extension Hidden";
		value = [rawValue boolValue] ? @"True" : @"False";
	}
	else if ([attribute isEqualToString:NSFileGroupOwnerAccountID])
	{
		name = @"Group Owner Account ID";
		value = [rawValue stringValue];
	}
	else if ([attribute isEqualToString:NSFileHFSCreatorCode])
	{
		name = @"HFS Creator Code";
		value = [rawValue stringValue];
	}
	else if ([attribute isEqualToString:NSFileHFSTypeCode])
	{
		name = @"HFS Type Code";
		value = [rawValue stringValue];
	}
	else if ([attribute isEqualToString:NSFileImmutable])
	{
		name = @"Immutable";
		value = [rawValue boolValue] ? @"True" : @"False";
	}
	else if ([attribute isEqualToString:NSFileModificationDate])
	{
		name = @"Modification Date";
		NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		value = [dateFormatter stringFromDate:rawValue];
	}
	else if ([attribute isEqualToString:NSFileOwnerAccountID])
	{
		name = @"Owner Account ID";
		value = [rawValue stringValue];
	}
	else if ([attribute isEqualToString:NSFilePosixPermissions])
	{
		name = @"Posix Permissions";
		value = [rawValue stringValue];
	}
	else if ([attribute isEqualToString:NSFileReferenceCount])
	{
		name = @"Reference Count";
		value = [rawValue stringValue];
	}
	else if ([attribute isEqualToString:NSFileSize])
	{
		name = @"Size";
		value = [NSString stringForHumanFileSize:rawValue];
	}
	else if ([attribute isEqualToString:NSFileSystemFileNumber])
	{
		name = @"System File Number";
		value = [rawValue stringValue];
	}
	else if ([attribute isEqualToString:NSFileSystemNumber])
	{
		name = @"System Number";
		value = [rawValue stringValue];
	}
	else if ([attribute isEqualToString:NSFileType])
	{
		name = @"Type";
		value = rawValue;
	}
	else
	{
		name = @"Unknown";
		value = @"Unknown";
	}

	[dict setObject:name forKey:@"name"];
	[dict setObject:value forKey:@"value"];
	
	return [NSDictionary dictionaryWithDictionary:dict];
}

- (id)initWithPath:(NSString *)path
{
	if (self = [super initWithNibName:nil bundle:nil])
	{
		// Retain file path
		filePath = path;
		[filePath retain];
		
		// Get this file's attributes.
		fileAttributesDict = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL];
		[fileAttributesDict retain];
		NSMutableArray *attributesArray = [NSMutableArray array];
		for (id key in fileAttributesDict)
		{
			// Add key to key array.
			[attributesArray addObject:key];
		}
		fileAttributesArray = [[NSArray alloc] initWithArray:attributesArray];

		// Setup title.
		[[self navigationItem] setTitle:[[NSFileManager defaultManager] displayNameAtPath:filePath]];
	}
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)loadView
{
	// Set up table view.
	fileView = [[[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStyleGrouped] autorelease];
	[fileView setDelegate:self];
	[fileView setDataSource:self];
	[fileView setAutoresizesSubviews:YES];
	[fileView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[self setView:fileView];
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview
	[super didReceiveMemoryWarning];
}

- (void)dealloc
{
	[filePath release];
	[fileAttributesArray release];
	[fileAttributesDict release];
	[super dealloc];
}

- (BOOL)isImageFormatSupported:(NSString *)extension
{
	return [[NSArray arrayWithObjects:@"tiff", @"tif", @"jpg", @"jpeg", @"gif", @"png", @"bmp", @"BMPf", @"ico", @"cur", @"xbm", nil] containsObject:extension];
}

//
// TableView delegates
//

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 1)
	{
		return [fileAttributesArray count];
	}
	else
	{
		return 1;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 1)
	{
		return @"Properties";
	}
	else
	{
		return @"Preview";
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat result;
	
	// Get the section and row.
	int section = [indexPath section];
	int row = [indexPath row];
	
	if (section == 1)
	{
		// Just a guess but this seems to be around the default row size.
		result = 44;
	}
	else
	{
		result = 200;
	}
	
	return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Get the section and row.
	int row = [indexPath row];
	int section = [indexPath section];

	// Use an existing cell if possible.
	NSString *TableViewId = @"TableViewId";
	NSString *TextViewId = @"TextViewId";
	NSString *ImagePreviewId = @"ImagePreviewId";
	UITableViewCell *cell;

	if (section == 1)
	{
		cell = [tableView dequeueReusableCellWithIdentifier:TableViewId];
		if (cell == nil)
		{
			cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
		}

		// Don't let the user select the row.
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		
		// Select the field to display.
		NSString *attribute = [fileAttributesArray objectAtIndex:row];
		NSDictionary *dict = [FileController stringsForAttribute:attribute fromDictionary:fileAttributesDict];
		[cell setText:[NSString stringWithFormat:@"%@: %@", [dict objectForKey:@"name"], [dict objectForKey:@"value"]]];
	}
	else
	{
		// Attempt to add preview.
		NSString *extension = [filePath pathExtension];
		if ([self isImageFormatSupported:[extension lowercaseString]])
		{
			cell = [tableView dequeueReusableCellWithIdentifier:ImagePreviewId];
			if (cell == nil)
			{
				cell = [[[ImagePreviewCell alloc] initWithFrame:CGRectZero reuseIdentifier:ImagePreviewId] autorelease];
			}

			[cell setImagePath:filePath];
		}
		else
		{
			cell = [tableView dequeueReusableCellWithIdentifier:TextViewId];
			if (cell == nil)
			{
				cell = [[[TextViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:TextViewId] autorelease];
			}

			[cell setTextPath:filePath];
		}
	}

	return cell;
}

@end
