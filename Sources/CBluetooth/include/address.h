#import <stdint.h>
#import <CoreFoundation/CoreFoundation.h>

typedef struct BTAddress {
    uint8 bytes[6];
}

BTAddress BTAddressCreateWithCString(const * char);
BTAddress BTAddressCreateWithString(CFString);
void BTAddressByteSwap(* BTAddress);
