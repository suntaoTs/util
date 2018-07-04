#pragma once

#include <stdint.h>
#include <semaphore.h>
#include "proclock.h"


#ifdef __cplusplus
extern "C" {
#endif
#include "hash_table.h"
#include "Attr_API.h"
#ifdef __cplusplus
}
#endif

#define SHMKEY          0x10086
//#define LOCKKEY       0x66666

#define HASH_ROW        40
#define HASH_COL        10000

#define NODE_MAX        10
#define POINT_MAX       60
#define NODE_TIME_OUT   180

enum RetCode
{
    RET_SUCC            = 0,

    //collection_store
    HASH_SUCC           = 10000,
    
    HASH_ERR            = 10001,
    HASHSET_EXIST       = 10002,
    HASHREMOVE_NOTFOUND = 10003,
    STORE_DATA_ERR      = 10004,

    DEL_NOT_FIND        = 10005,
    CREATE_NEWNODE_TIMEOUT_4    = 1006,
    HASH_CONFLICT_3       = 1007,
    LOCK_TIME_OUT       = 1008,

    //msghandle
    PARSE_FAIL          = 11000,
    STORE_FAIL          = 11001,
    DELETE_FAIL         = 11002,
    DATA_UNVALID        = 11003,
    
};

#pragma pack(1)

typedef struct 
{ 

    //int32_t  iActiveTime;     // 最后一次操作的时间 
	//int32_t  iScanTime;       // 最后一次执行扫描的时间 
	//uint32_t uScanPos;        // 最后一次扫描的时间 

    //uint32_t uUsed;           // 使用的节点数 
    ProLock  lock;
    int32_t  iInit;           // 是否初始化过 
    uint32_t uTotNode;        // 总结点数 
	char     sReserved[1020];  // 保留字段 
} HashTableInfo; 

typedef struct 
{ 
	HashTable     table;  
	HashTableInfo *pInfo;    
} HashTableWrap; 

typedef struct
{
    char            domain[64];
    uint32_t        domain_len;
    char            streamId[256];
    uint32_t        streamId_len;
    uint32_t        uintKey;
} KeyNode;

typedef struct
{   
    uint16_t            report_interval;    //上报流逝时间
    uint16_t            audio_interval;     //视频流逝时间
    uint16_t            video_interval;     //音频流逝时间
    uint8_t             video_fps;          //视频帧率
    uint8_t             audio_fps;          //音频帧率
}Info;
//


typedef struct
{
    uint64_t        sequence;       //唯一标识流ID
    uint64_t        pass_sequence;  //之前的sequence
    uint32_t        uploadip;       //uploadNode对应的上传地址
    char            path[64];       //推流路径

    uint8_t         begin;          //开始下标用于形成5min的记录环
    uint8_t         end;            //尾部下标
    uint32_t        report_time;    //（改为本地存储时间） 时间戳,最后一点更新时间,如果是存储之前丢包的数据，不更新该时间
    uint64_t        report_number;   //也可选择其他形式的值，时间戳也可
    uint8_t         live_flag;      //该单一上传流是否还存活，是否可重用该uploadNode点
    uint64_t        valid_flag;     //所有的有效记录点个数，暂时将丢包的点置为0，下一个点进来时将时间缺失的点置为0
    Info            _info[POINT_MAX];   //60个点位信息
}UploadNode;

typedef struct
{
    ProLock         lock;
    uint32_t        appid;
    uint32_t        bizid;

    uint32_t        domain_len;
    uint32_t        streamId_len;
    char            domain[64];
    char            streamId[256];

    uint16_t         node_sum;
    UploadNode      _node[NODE_MAX];

}StreamNode;
