#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "Pelican.h"
#import "raros.hpp"
#import "dll.hpp"

FOUNDATION_EXPORT double PelicanVersionNumber;
FOUNDATION_EXPORT const unsigned char PelicanVersionString[];

