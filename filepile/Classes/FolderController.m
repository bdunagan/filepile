//
//  FolderController.m
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

#import "FolderController.h"

@implementation FolderController

- (id)initWithPath:(NSString *)path
{
	if (self = [super initWithNibName:nil bundle:nil])
	{
		// Store the path.
		filePath = path;
		[filePath retain];
		
		// Setup title.
		[[self navigationItem] setTitle:[[NSFileManager defaultManager] displayNameAtPath:filePath]];
	}
	return self;
}

- (void)loadView
{
	// Set up table view.
	foldersView = [[[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain] autorelease];
	[foldersView setDelegate:self];
	[foldersView setDataSource:self];
	[foldersView setAutoresizesSubviews:YES];
	[foldersView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[self setView:foldersView];

	// Store the files and count.
	files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:NULL];
	[files retain];
	numFiles = [files count];
	
	// Store parents.
	NSMutableArray *tokens = [NSMutableArray arrayWithArray:[filePath componentsSeparatedByString:@"/"]];
	[tokens removeObject:@""];
	[tokens insertObject:@"/" atIndex:0];
	parentsArray = [[NSArray alloc] initWithArray:tokens];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	[files release];
	[filePath release];
	[parentsArray release];
	[super dealloc];
}

//
// TableView delegates
//

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [parentsArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Ignore all but the final section.
	if (section < [parentsArray count] - 1)
	{
		return 0;
	}
	else
	{
		return ([files count] == 0) ? 1 : [files count];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [parentsArray objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Recycle cells for speed. But keep in mind that settings persist.
	static NSString *MyIdentifier = @"MyIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
	}
	
	// Check for an empty folder.
	if ([files count] == 0)
	{
		[cell setText:@"Empty Directory"];
		[cell setTextColor:[UIColor grayColor]];
		[cell setAccessoryType:UITableViewCellAccessoryNone];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		return cell;
	}
	
	// Set text for current cell.
	NSString *currentFile = [files objectAtIndex:[indexPath row]];
	[cell setText:currentFile];
	
	// Set the cell type.
	NSString *currentPath = [NSString stringWithFormat:@"%@/%@", filePath, currentFile];
	
	// Ensure the file is readable.
	if ([[NSFileManager defaultManager] isReadableFileAtPath:currentPath])
	{
		// Determine the file's type.
		NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:currentPath error:NULL];
		NSString *fileType = [dict objectForKey:NSFileType];
		if (fileType == NSFileTypeDirectory)
		{
			// It's a readable directory.
			[cell setTextColor:[UIColor blackColor]];
			[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
			[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
		}
		else if (fileType == NSFileTypeSymbolicLink)
		{
			// Get the symbolic link's path.
			NSString *symbolicPath = [[NSFileManager defaultManager] pathContentOfSymbolicLinkAtPath:currentPath];
			if ([[NSFileManager defaultManager] isReadableFileAtPath:symbolicPath])
			{
				// It's a readable directory.
				[cell setTextColor:[UIColor blackColor]];
				[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
				[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
			}
			else
			{
				// It's an unreadable directory.
				[cell setTextColor:[UIColor grayColor]];
				[cell setAccessoryType:UITableViewCellAccessoryNone];
				[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
			}
		}
		else if (fileType == NSFileTypeRegular)
		{
			// It's a readable file.
			[cell setTextColor:[UIColor blackColor]];
			[cell setAccessoryType:UITableViewCellAccessoryNone];
			[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
		}
		else
		{
			// It's an unknown file.
			[cell setTextColor:[UIColor grayColor]];
			[cell setAccessoryType:UITableViewCellAccessoryNone];
			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		}
	}
	else
	{
		// It's an unreadable file.
		[cell setTextColor:[UIColor grayColor]];
		[cell setAccessoryType:UITableViewCellAccessoryNone];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Ignore action if no files to act on.
	if ([files count] == 0) return;

	// Get new file path.
	NSString *file = [files objectAtIndex:[indexPath row]];
	NSString *newFilePath = [NSString stringWithFormat:@"%@/%@", filePath, file];
	
	// Ensure the item is accessible through the file manager.
	if ([[NSFileManager defaultManager] isReadableFileAtPath:newFilePath])
	{
		// Add that view.
		[[[UIApplication sharedApplication] delegate] addPathView:newFilePath];
		// Deselect that row.
		[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	}
}

@end

