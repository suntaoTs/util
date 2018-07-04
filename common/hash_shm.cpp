//-------------------------------------------
//Cola's Hash Shm Library 1.03
//colaliang( SNG Instant Messaging Application Department )
//last update: 2012-12-27

#include "hash_shm.h"


const int PRIMER_TABLE_LEN = 64;
#if 0
const int PRIMER_TABLE[ PRIMER_TABLE_LEN ] = { 
    1511,1523,1531,1543,1549,1553,1559,1567,1571,1579,1583,1597,1601,1607,1609,1613,1619,1621,1627,1637,1657,1663,1667,1669,1693,
    1697,1699,1709,1721,1723,1733,1741,1747,1753,1759,1777,1783,1787,1789,1801,1811,1823,1831,1847,1861,1867,1871,1873,1877,1879,
    1889,1901,1907,1913,1931,1933,1949,1951,1973,1979,1987,1993,1997,1999
};
#endif
#if 0
const int PRIMER_TABLE[ PRIMER_TABLE_LEN ] = { 
    31547, 31567, 31573, 31583, 31601, 31607, 31627, 31643, 31649, 31657,
    31663, 31667, 31687, 31699, 31721, 31723, 31727, 31729, 31741, 31751,
    31769, 31771, 31793, 31799, 31817, 31847, 31849, 31859, 31873, 31883,
    31891, 31907, 31957, 31963, 31973, 31981, 31991, 32003, 32009, 32027,
    32029, 32051, 32057, 32059, 32063, 32069, 32077, 32083, 32089, 32099,
    32117, 32119, 32141, 32143, 32159, 32173, 32183, 32189, 32191, 32203,
    32213, 32233, 32237, 32251
};
#endif
const int PRIMER_TABLE[ PRIMER_TABLE_LEN ] = { 
    10099, 10103, 10111, 10133, 10139, 10141, 10151, 10159, 10163, 10169,
    10177, 10181, 10193, 10211, 10223, 10243, 10247, 10253, 10259, 10267,
    10271, 10273, 10289, 10301, 10303, 10313, 10321, 10331, 10333, 10337,
    10343, 10357, 10369, 10391, 10399, 10427, 10429, 10433, 10453, 10457,
    10459, 10463, 10477, 10487, 10499, 10501, 10513, 10529, 10531, 10559,
    10567, 10589, 10597, 10601, 10607, 10613, 10627, 10631, 10639, 10651,
    10657, 10663, 10667, 10687
};
unsigned long hash_time33(char const *str, int len  ) 
{ 
    //get from php
    unsigned long hash = 5381; 

    //variant with the hash unrolled eight times
    // if len not specify, use default time33
    char const *p = str; 
    if( len < 0 )
    { 
        for(; *p; p++) 
        { 
            hash = hash * 33 + *p; 
        }

        return hash; 
    }

#define TIME33_HASH_MIXED_CH() hash = ((hash<<5)+hash) + *p++
    //use eighe alignment
    for (; len >= 8; len -= 8) 
    { 
        TIME33_HASH_MIXED_CH();	// 1
        TIME33_HASH_MIXED_CH(); // 2 
        TIME33_HASH_MIXED_CH();	// 3 
        TIME33_HASH_MIXED_CH(); // 4 
        TIME33_HASH_MIXED_CH(); // 5 
        TIME33_HASH_MIXED_CH(); // 6 
        TIME33_HASH_MIXED_CH(); // 7 
        TIME33_HASH_MIXED_CH(); // 8 
    } 
    switch (len) 
    { 
        case 7: TIME33_HASH_MIXED_CH();
        case 6: TIME33_HASH_MIXED_CH();
        case 5: TIME33_HASH_MIXED_CH();
        case 4: TIME33_HASH_MIXED_CH();
        case 3: TIME33_HASH_MIXED_CH();
        case 2: TIME33_HASH_MIXED_CH();
        case 1: TIME33_HASH_MIXED_CH(); break; 
        case 0: break; 
    } 

    return hash; 
}

