#import <Foundation/Foundation.h>

static NSString *const __nonnull HaishinKit194Identifier = @"com.haishinkit.HaishinKit";
FOUNDATION_EXPORT double HaishinKit194VersionNumber;
FOUNDATION_EXPORT const unsigned char HaishinKit194VersionString[];

// @see http://stackoverflow.com/questions/35119531/catch-objective-c-exception-in-swift
NS_INLINE void nstry(void(^_Nonnull lambda)(void), void(^_Nullable error)(NSException *_Nonnull exception)) {
    @try {
        lambda();
    }
    @catch (NSException *exception) {
        if (error != NULL) {
            @try {
                error(exception);
            }@catch(NSException *exception) {

            }
        }
    }
}
