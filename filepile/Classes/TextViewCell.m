//
//  TextViewCell.m
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

#import "TextViewCell.h"

@implementation TextViewCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier])
	{
		// Make sure the user cannot select this cell.
		[self setSelectionStyle:UITableViewCellSelectionStyleNone];
	}
	return self;
}

- (void)dealloc {
	[textPath release];
	[preview release];
	[super dealloc];
}

- (void)setTextPath:(NSString *)newTextPath
{
	[newTextPath retain];
	[textPath release];
	textPath = newTextPath;

	NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:textPath];
	NSData *data = [handle readDataOfLength:1024];
	preview = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	[handle closeFile];
}

- (void)layoutSubviews
{
	// Layout super views.
	[super layoutSubviews];

	// Layout UITextView, with a little margin.
	int margin = 5;
	CGRect contentRect = [[self contentView] bounds];
	CGFloat newX = contentRect.origin.x + margin;
	CGFloat newY = contentRect.origin.y + margin;
	CGFloat maxWidth = contentRect.size.width - 2 * margin;
	CGFloat maxHeight = contentRect.size.height - 5 * margin;

	if ([preview length] > 0)
	{
		// Display the file preview.
		CGRect textViewRect = CGRectMake(newX, newY, maxWidth, maxHeight);
		UITextView *textView = [[[UITextView alloc] initWithFrame:textViewRect] autorelease];
		[textView setDelegate:self];
		[textView setBackgroundColor:[UIColor whiteColor]];
		[textView setFont:[UIFont systemFontOfSize:12]];
		[textView setEditable:NO];
		[textView setText:preview];
		[textView setTextColor:[UIColor blackColor]];
		[[self contentView] addSubview:textView];

		// Display a message explaining the preview.
		CGRect messageRect = CGRectMake(newX + margin, newY + maxHeight + 1 * margin, maxWidth, 2 * margin);
		UITextField *message = [[[UITextField alloc] initWithFrame:messageRect] autorelease];
		[message setTextColor:[UIColor grayColor]];
		[message setFont:[UIFont systemFontOfSize:10]];
		[message setText:@"Preview is limited to 1KB. Scroll the cell if it's not visible."];
		[[self contentView] addSubview:message];
	}
	else
	{
		// The file is empty. Display note to user.
		CGRect textViewRect = CGRectMake(newX, newY, maxWidth, maxHeight);
		UITextView *textView = [[[UITextView alloc] initWithFrame:textViewRect] autorelease];
		[textView setDelegate:self];
		[textView setBackgroundColor:[UIColor whiteColor]];
		[textView setFont:[UIFont systemFontOfSize:12]];
		[textView setEditable:NO];
		[textView setTextColor:[UIColor grayColor]];
		[textView setText:@"Empty file"];
		[[self contentView] addSubview:textView];
	}
}

@end
