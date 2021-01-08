#import <stdint.h>
#import <CoreFoundation/CoreFoundation.h>

typedef struct BTUUID {
    uint8 type;
    uint8 bytes[16];
}

BTUUID BTUUIDCreateWithCString(const * char);
BTUUID BTUUIDCreateWithString(CFString);
void BTUUIDByteSwap(* BTAddress);
