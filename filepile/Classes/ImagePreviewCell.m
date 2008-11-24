//
//  ImagePreviewCell.m
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

#import "ImagePreviewCell.h"

@implementation ImagePreviewCell

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
	[imagePath release];
	[super dealloc];
}

- (void)setImagePath:(NSString *)newImagePath
{
	// Retain the new UIImageView.
	[newImagePath retain];
	[imagePath release];
	imagePath = newImagePath;
	
	// Get the file's size.
	NSNumber *fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:imagePath error:NULL] valueForKey:NSFileSize];
	isSmallImage = [fileSize unsignedLongValue] < 51200 ? YES : NO;
}

- (void)layoutSubviews
{
	// Layout super views.
	[super layoutSubviews];

	// Calculate sizes, with a small margin for the UITableView.
	int margin = 5;
	CGRect contentRect = [[self contentView] bounds];
	CGFloat newX = contentRect.origin.x + margin;
	CGFloat newY = contentRect.origin.y + margin;
	CGFloat maxWidth = contentRect.size.width - 2 * margin;
	CGFloat maxHeight = contentRect.size.height - 2 * margin;
	
	if (isSmallImage)
	{
		// Get the image and its size.
		UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
		CGSize imageSize = [image  size];
		
		// Start with the default image size.
		CGRect imageViewRect = CGRectMake(newX, newY, imageSize.width, imageSize.height);
		if (imageSize.width > maxWidth || imageSize.height > maxHeight)
		{
			// Image is larger than cell. Shrink to fit in the cell, keeping the aspect ratio.
			CGFloat aspectRatio = imageSize.width / imageSize.height;
			if (aspectRatio > maxWidth / maxHeight)
			{
				imageViewRect = CGRectMake(newX, newY, maxWidth, maxWidth * imageSize.height / imageSize.width);
			}
			else
			{
				imageViewRect = CGRectMake(newX, newY, maxHeight * imageSize.width / imageSize.height, maxHeight);
			}
		}

		// Create UIImageView for image.
		UIImageView *imageView = [[[UIImageView alloc] initWithFrame:imageViewRect] autorelease];
		[imageView setImage:image];
		[[self contentView] addSubview:imageView];
	}
	else
	{
		// The image is too large. Display note to user.
		UITextField *message = [[[UITextField alloc] init] autorelease];
		[message setTextColor:[UIColor grayColor]];
		[message setFont:[UIFont systemFontOfSize:12]];
		[message setText:@"Preview is limited to images smaller than 50KB."];
		[message setFrame:CGRectMake(newX + margin, newY + 1 * margin, maxWidth, 2 * margin)];
		[[self contentView] addSubview:message];
	}
}

@end
