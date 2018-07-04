#pragma once

#include <string>


#include "mydefine.h"


    unsigned int BKDRHashEx(const char *str, unsigned int m);
    
    int StreamNodeCmp(const void *_pKey,const void *_pNode);
    
    int Shm_GetHashTable(HashTableWrap *pstHashTableWrap, uint32_t row, uint32_t col, size_t size, int iShmID, int (*Compare)(const void *pKey,const void *pNode));

    int Foreach( HashTableWrap pstHashTableWrap, void (*callback)( StreamNode * node, void* param_out ), void* param_in );
    
    void *Collection_HashTableSearchEx(HashTable *pstHashTable, const void *pSearchKey, const void *pEmptyKey, unsigned uShortKey, int *piExist);
    //void *Dispatch_HashTableSearchEx(HashTable *pstHashTable, const void *pSearchKey, const void *pEmptyKey, unsigned uShortKey, int *piExist);

