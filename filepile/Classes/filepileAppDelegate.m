//
//  filepileAppDelegate.m
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

#import "filepileAppDelegate.h"
#import "FolderController.h"
#import "FileController.h"

@implementation filepileAppDelegate

@synthesize window;
@synthesize navigationController;

- (id)init {
	if (self = [super init])
	{
	}
	return self;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	// Initialize navigation here rather than in IB to get initial path.
	FolderController *folderController = [[[FolderController alloc] initWithPath:@"/"] autorelease];
//	FolderController *folderController = [[[FolderController alloc] initWithPath:NSHomeDirectory()] autorelease];
	navigationController = [[UINavigationController alloc] initWithRootViewController:folderController];
	
	// Add delegate to receive memory warnings generated by you.
//	[[NSNotificationCenter defaultCenter] addObserver:[[UIApplication sharedApplication] delegate] selector:@selector(applicationDidReceiveMemoryWarning:) name:@"UIApplicationMemoryWarningNotification" object:nil];

	// Start timer for memory warnings.
//	NSTimer *timer;
//	timer = [NSTimer scheduledTimerWithTimeInterval: 60
//											   target: self
//											 selector: @selector(triggerMemoryWarning)
//											 userInfo: nil
//											  repeats: YES];
	
	// Set up window.
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// UI already gone by this call.
}

- (void)dealloc
{
	[navigationController release];
	[window release];
	[super dealloc];
}

- (void)addPathView:(NSString *)path
{
	// Get the file's type.
	NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL];
	NSString *fileType = [dict objectForKey:NSFileType];
	if (fileType == NSFileTypeDirectory)
	{
		// Add a folder view.
		FolderController *folderController = [[[FolderController alloc] initWithPath:path] autorelease];
		[navigationController pushViewController:folderController animated:YES];
	}
	else if (fileType == NSFileTypeSymbolicLink)
	{
		// Ensure the file path is readable.
		NSString *symbolicPath = [[NSFileManager defaultManager] pathContentOfSymbolicLinkAtPath:path];
		// TODO: doesn't account for relative paths yet
		if ([[NSFileManager defaultManager] isReadableFileAtPath:symbolicPath])
		{
			// Add a folder view.
			FolderController *folderController = [[[FolderController alloc] initWithPath:symbolicPath] autorelease];
			[navigationController pushViewController:folderController animated:YES];
		}
	}
	else if (fileType == NSFileTypeRegular)
	{
		// Add a file view.
		FileController *fileController = [[[FileController alloc] initWithPath:path] autorelease];
		[navigationController pushViewController:fileController animated:YES];
	}
	else
	{
		// Ignore this request.
	}
}

- (void)triggerMemoryWarning
{
	// Post 'low memory' notification that will propagate out to controllers
	// Note: UIApplicationDidReceiveMemoryWarningNotification doesn't work for some reason.
	[[NSNotificationCenter defaultCenter] postNotificationName:@"UIApplicationMemoryWarningNotification" object:[UIApplication sharedApplication]];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	// Show user 'low memory' alert.
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Low Memory" message:@"This app might crash soon."
//												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//	[alert show];
//	[alert release];
}

@end