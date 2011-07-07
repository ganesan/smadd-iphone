//
//  SmAddGlobal.h
//
//  Created by sumy on 11/03/21.
//  Copyright 2011 sumyapp. All rights reserved.
//

#ifdef DEBUG
# define SMADD_LOG(...) NSLog(__VA_ARGS__) ;
# define SMADD_LOG_METHOD NSLog(@"%s", __func__) ;
#else
# define SMADD_LOG(...) ;
# define SMADD_LOG_METHOD ;
#endif