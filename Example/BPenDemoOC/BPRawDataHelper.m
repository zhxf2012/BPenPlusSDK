//
//  BPRawDataHelper.m
//  BPenDemoOC
//
//  Created by Xingfa Zhou on 2023/5/26.
//  Copyright © 2023 bbb. All rights reserved.
//

#import "BPRawDataHelper.h"

@implementation BPRawDataHelper
+ (NSString *)dataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string;
}

+ (void)readRawDataFromFile:(NSString *)path andExportToTxtFile:(NSString *)txtPath completedHandel:(void (^) (bool,NSError*_Nullable))handel {
    NSError *error;
    NSError *error1;
    
    NSFileHandle* rawDataReader = [NSFileHandle fileHandleForReadingFromURL: [NSURL fileURLWithPath:path] error:&error];
    NSFileHandle* rawDataWriter = [NSFileHandle fileHandleForUpdatingURL: [NSURL fileURLWithPath:txtPath] error:&error1];
    if(error1 || (!rawDataWriter)) {
        handel(false,[NSError errorWithDomain:@"BPRawDataSaverDomain" code:2 userInfo:@{NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat: @"%@ 不能写入内容到%@",[error1 localizedFailureReason],txtPath]}]);
        return;
    }
    
    [rawDataWriter seekToEndOfFile];
    
    if ((!error) && (rawDataReader)) {
        NSData *data = [rawDataReader readDataToEndOfFile];
        NSUInteger i = 0;
        NSUInteger endIndex =  (data.length > 0) ? ( data.length-1) : 0;
        Byte* bytes = (Byte *)[data bytes];
 
        unsigned char currentType = 0x02;
        while (i < endIndex) {
            unsigned char length = bytes[i];
//            if((data.length < (2 + length)) || (length < 6)) {
//                handel(false,[NSError errorWithDomain:@"BPRawDataSaverDomain" code:0 userInfo:@{NSLocalizedFailureReasonErrorKey:@"错误的文件格式，非本SDK保存的格式"}]);
//                return;
//            }
            
            unsigned char type = bytes[i+1];
            if(type != currentType) {
                [rawDataWriter writeData:[[NSString stringWithFormat: @"\n\nChange to Type:%d\n\n",currentType] dataUsingEncoding:NSUTF8StringEncoding]];
                currentType = type;
            }
            
            
            if (type == 0x01) {
                
            } else if (type == 0x02) {
//                if((length < 12) ||(length > 80)) {
//                    handel(false,[NSError errorWithDomain:@"BPRawDataSaverDomain" code:0 userInfo:@{NSLocalizedFailureReasonErrorKey:@"错误的文件内容，非本SDK保存的格式"}]);
//                    return;
//                }
                
//                dataLenth = length - 12 ;
//
//                NSData *timeData = [data subdataWithRange:NSMakeRange(i + 2 + 6 + dataLenth, 6)];
//
//                Byte* bytes = (Byte *)[timeData bytes];
//
//                uint64_t timeStamp = ((uint64_t)bytes[0] << 40)|((uint64_t)bytes[1] << 32)|((uint64_t)bytes[2] << 24)|((uint64_t)bytes[3] << 16)|((uint64_t)bytes[4] << 8)|((uint64_t)bytes[5]) ;
//                NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000.0];
//                [date description]; //消除release时变量未用到的警告
//
            } else {
//                handel(false,[NSError errorWithDomain:@"BPRawDataSaverDomain" code:1 userInfo:@{NSLocalizedFailureReasonErrorKey:@"错误的文件内容，非当前版本SDK支持的格式"}]);
//                return;
                
                 
            }
           
          //NSData *macData = [data subdataWithRange:NSMakeRange(i+2, 6)];
           // NSData *pointData = [data subdataWithRange:NSMakeRange(i+8, dataLenth)];
            
            NSData *lineData = [data subdataWithRange:NSMakeRange(i, length+2)];
            NSString *string = [self dataToHexStr: lineData];
            [rawDataWriter writeData:[[NSString stringWithFormat:@"%d %@\n",length ,string] dataUsingEncoding:NSUTF8StringEncoding]];
            
            i += (length + 2);
          //  NSLog(@" lineData:%@ \n string:%@",lineData,string);
        }
        
        handel(true,nil);
    } else {
        handel(false,error);
    }
    [rawDataWriter closeFile];
}
@end
