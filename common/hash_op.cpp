
#ifdef __cplusplus
extern "C" {
#endif

#include <string.h>
#include <time.h>
#include "hash_table.h"
#include "oi_shm.h"

#ifdef __cplusplus
}
#endif

#include "hash_op.h"
#include "proclock.h"
#include <stdlib.h>
//#include "Attr_API.h"

unsigned int BKDRHashEx(const char *str, unsigned int m)
{   
    unsigned int seed = 131;
    unsigned int hash = 0;

    while (*str)
    {
        hash = hash * seed + (*str++);
    }
    char *p = (char *)&m;
    hash = hash * seed + *p++;
    hash = hash * seed + *p++;
    hash = hash * seed + *p++;
    hash = hash * seed + *p;

    return (hash & 0x7FFFFFFF);
}
static int IsPrime(int num)
{   
    int i = 0;
    for(i = 2; i <= num / 2; i++){
        if(0 == num % i) return 0;
    }
    return 1;
}   

static int GetPrimeArray(int top, int num, C2_SIZE array[])
{
    int i = 0;
    for(; top > 0 && num > 0; top--){
        if(IsPrime(top)){
            array[i++] = top;
            num--;
        }
    }
    return 0;
}
int StreamNodeCmp(const void *_pKey,const void *_pNode)
{	
    const KeyNode *pKey = (const KeyNode *)_pKey;
    StreamNode *pNode= (StreamNode *)_pNode;

    if(pKey == NULL || pNode == NULL){ return -1; }
    if(pKey->domain_len > sizeof(pNode->domain) ||
            pKey->streamId_len > sizeof(pNode->streamId))
    {
        return -1;
    }

    if(pNode->domain_len > 0 
        && pKey->streamId_len > 0
            && pKey->domain_len == pNode->domain_len 
                && pKey->streamId_len == pNode->streamId_len
                    && strncmp(pKey->domain , pNode->domain, pKey->domain_len) == 0
                        && strncmp(pKey->streamId, pNode->streamId, pKey->streamId_len) == 0)
    {
        //printf("pkey->domain: %s, pkey->domain_len : %u\n", pKey->domain, pKey->domain_len);
        //printf("pNode->domain: %s\n", pNode->domain);
        return 0;
    }

    if(pKey->domain_len == 0 && pKey->streamId_len == 0 ) 
    {
        int loop = pNode->node_sum;
        uint32_t cur_time = (uint32_t)time(NULL);
        if(loop != 0)
        {
            int i = 0;
            uint32_t max_report_time = 0;

            for(i = 0; i < NODE_MAX; ++i)
            {
                if(pNode->_node[i].live_flag == 1 && max_report_time < pNode->_node[i].report_time)
                {
                    max_report_time = pNode->_node[i].report_time;
                }
            }

            if(max_report_time != 0 && cur_time - max_report_time > NODE_TIME_OUT)
            {
                Attr_API(3011878, 1);
                //printf("hash conflict ,pick an reuse one, cur_time = %u, max_report_time = %u \n", cur_time, max_report_time);
                memset(pNode, 0, sizeof(StreamNode));
                pNode->node_sum = 0;
                return 0;
            }
            else
            {
                return 1;
            }
        }
        else
        {
            return 0;
        }

    }

    return 1;
}

//void callback(StreamNode *node, void *param_out);

#if 0
void mycallback(StreamNode *m_pStreamNode, void *param_out)
{
    if(m_pStreamNode->node_sum == 0)
        return;
    int pos = 0;

    if(m_pStreamNode->node_sum != 0)
    {
        char  flag_char[65] = {0};
        uint64_t tmpflag = m_pStreamNode->_node[pos].valid_flag;
        for(int i = 0 ; i < 64; ++i)
        {
            if(tmpflag & 0x0000000000000001)
            {
                flag_char[63-i] = '1';
            }
            else
            {
                flag_char[63-i] = '0';
            }
            tmpflag >>= 1;
        }

        //_base->log_.LOG_P_FILE(LOG_DEBUG, "valid_flag: 0x  %llx\n", m_pStreamNode->_node[pos].valid_flag);

        std::string tmpLog;
        std::ostringstream oss;
        char buf[64] = {0};
        strncpy(buf, m_pStreamNode->domain, sizeof(buf));
        oss << "\nappid:        " << m_pStreamNode->appid 
            << "\nbizid:        " << m_pStreamNode->bizid
            << "\ndomain:       " << buf//m_pStreamNode->domain 
            << "\nnode_sum:    " << (uint16_t)m_pStreamNode->node_sum
            << "\nstream_id    " << m_pStreamNode->streamId
            //<< "\nuploadip:     " << inet_ntoa(*(struct in_addr*)m_pStreamNode->_node[pos].uploadip);

            << "\nsequence:     " << m_pStreamNode->_node[pos].sequence
            << "\nuploadip:     " << m_pStreamNode->_node[pos].uploadip
            << "\npath:         " << m_pStreamNode->_node[pos].path
            << "\nbegin:        " << (uint16_t)m_pStreamNode->_node[pos].begin
            << "\nend:          " << (uint16_t)m_pStreamNode->_node[pos].end
            << "\nreport_time:  " << (uint16_t)m_pStreamNode->_node[pos].report_time
            << "\nreport_number:" << m_pStreamNode->_node[pos].report_number
            << "\nlive_flag:    " << (uint16_t)m_pStreamNode->_node[pos].live_flag
            << "\nvalid_flag:   " << flag_char << "\n";
        tmpLog = oss.str();
        cout << tmpLog.c_str()<< "-----------------------------" << endl;
    }

}
#endif

int Foreach( HashTableWrap pstHashTableWrap, void (*callback)( StreamNode * node, void* param_out ), void* param_in )
{
    struct timeval t1, t2;
    gettimeofday(&t1, NULL);

    //int ret = 0;
    uint32_t i = 0;
    StreamNode *node = NULL;

    HashTable * pt = &pstHashTableWrap.table;

    for(i = 0; i < pstHashTableWrap.pInfo->uTotNode; ++i)
    {

        node = (StreamNode *)((char *)pt->pTable + i * pt->uNodeSize); 

        ShmLock(&node->lock);

        callback(node, param_in);

        ShmUnLock(&node->lock);
    }

    gettimeofday(&t2, NULL);
    printf("time(us):   ----   ------                %d \n", (int)(t2.tv_sec*1000*1000 + t2.tv_usec - t1.tv_sec * 1000 * 1000 - t1.tv_usec));

    return 0;

}

void *Collection_HashTableSearchEx(HashTable *pstHashTable, const void *pSearchKey, const void *pEmptyKey, unsigned uShortKey, int *piExist)
{   
    unsigned int i;
    void *pRow, *pNode, *pEmptyNode = NULL, *pFoundNode = NULL;
    C2_SIZE uNodeSize = pstHashTable->uNodeSize;

    for (i = 0, pRow = pstHashTable->pTable;
            i < pstHashTable->uRowNum;
            pRow = (char *)pRow + uNodeSize * pstHashTable->auNodeNums[i], i++) {
        pNode = (char *)pRow + uNodeSize * (uShortKey % pstHashTable->auMods[i]);
        StreamNode *pStream = (StreamNode *) pNode;
        ShmLock(&pStream->lock);

        if (pstHashTable->Compare(pSearchKey, pNode) == 0) {
            pFoundNode = pNode; break;
        }
        if (pEmptyNode == NULL && pstHashTable->Compare(pEmptyKey, pNode) == 0) {
            pEmptyNode = pNode;
            if (i == pstHashTable->uRowNum - 3) { Attr_API(3001102, 1); }
            else if (i == pstHashTable->uRowNum - 2) { Attr_API(3001103, 1); }
            else if (i == pstHashTable->uRowNum - 1) { Attr_API(3001104, 1); }
        }else{
            ShmUnLock(&pStream->lock);
        }
    }


    if (piExist) { *piExist = (pFoundNode != NULL); }
    if ( pFoundNode && pEmptyNode){
        ShmUnLock(&((StreamNode *)pEmptyNode)->lock);
    }

    return (pFoundNode ? pFoundNode : pEmptyNode);
}


int Shm_GetHashTable( HashTableWrap *pstHashTableWrap, uint32_t row, uint32_t col, size_t size, int iShmID, int (*Compare)(const void *pKey,const void *pNode))
{
    void *pTable;
    uint32_t auMods[HASH_MAX_ROW];
    uint32_t i = 0;

    if(pstHashTableWrap == NULL ) { return -1; }
    if(row <=0 || row > DIM(auMods)) { return -3; }
    if(col <= 0) { return -5; }

    GetPrimeArray(col, row, auMods);


    uint32_t uTableSize;
    uTableSize = HashTableEvalTableSize(size, row, auMods);

    if (!uTableSize) {
        return -11;
    }
    uTableSize += sizeof(HashTableInfo);

    if (GetShm2(&pTable, iShmID, uTableSize, IPC_CREAT | 0666) < 0) {
        Attr_API(3001105, 1);
        return -21;
    }

    pstHashTableWrap->pInfo = (HashTableInfo *)pTable;

    HashTableInfo *pInfo = pstHashTableWrap->pInfo;

    if (HashTableInit(&pstHashTableWrap->table, NULL, 0, (char *)pTable + sizeof(HashTableInfo), uTableSize - sizeof(HashTableInfo), 
                size, row, auMods, auMods, Compare) < 0) {
        Attr_API(3001122, 1);
        return -31;
    }

    HashTable *pt = &pstHashTableWrap->table;

    ShmLock(&pInfo->lock);
    if(pInfo->iInit == 0)
    {

        pInfo->uTotNode = 0;

        for(i = 0; i < pt->uRowNum; ++i)
        {
            pInfo->uTotNode += pt->auNodeNums[i];

        }
        memset(pt->pTable, 0, pInfo->uTotNode * pt->uNodeSize); //初始化清零
        pInfo->iInit = 1;

    }

    ShmUnLock(&pInfo->lock);

    return 0;

}   

