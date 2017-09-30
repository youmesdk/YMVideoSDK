//
//  IMyYouMeInterface.h
//  youme_voice_engine
//
//  Created by joexie on 16/1/11.
//  Copyright © 2016年 tencent. All rights reserved.
//

#ifndef IMyYouMeInterface_h
#define IMyYouMeInterface_h

#include <string>


void SetFixedIP (const std::string &strIP);
void SetTestConfig(bool bTest);
void SetNetworkChange();



void SetTestCategory(int iCategory);
#endif /* IMyYouMeInterface_h */
