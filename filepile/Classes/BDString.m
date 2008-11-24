//
//  BDString.m
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

#import "BDString.h"

@implementation NSString (BDString)

// Produces human-readable file sizes: 1023 B, 1.5 KB, 4.9 MB, 192.4 GB
+ (NSString *)stringForHumanFileSize:(NSNumber *)fileSize
{
	NSString *fileSizeString;
	float decimalFileSize;
	uint64_t fileSizeNum = [fileSize unsignedLongLongValue];
	
	if (fileSizeNum < 1024)
	{
		// Less than 1 KB
		fileSizeString = [NSString stringWithFormat:@"%i B", fileSizeNum];
	}
	else if (fileSizeNum < 1024 * 1024)
	{
		// Less than 1 MB
		float decimalFileSize = fileSizeNum / 1024.0;
		fileSizeString = [NSString stringWithFormat:@"%3.1f KB", decimalFileSize];
	}
	else if (fileSizeNum < 1024 * 1024 * 1024)
	{
		// Less than 1 GB
		float decimalFileSize = fileSizeNum / 1024.0 / 1024.0;
		fileSizeString = [NSString stringWithFormat:@"%3.1f MB", decimalFileSize];
	}
	else
	{
		// More than 1 GB
		float decimalFileSize = fileSizeNum / 1024.0 / 1024.0 / 1024.0;
		fileSizeString = [NSString stringWithFormat:@"%3.1f GB", decimalFileSize];
	}
	
	return fileSizeString;
}

@end
