#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <net/ethernet.h>
#include <netinet/in.h>
#include <linux/if_ether.h>
#include <linux/if_packet.h>
#include <linux/if_arp.h>

void handle_tcp(unsigned char *tcp)
{
    printf("--------------------tcp header\n");
    for(int i = 0; i < 5; ++i)
    {
        for(int j = 0; j < 4; ++j)
        {
            unsigned char d = tcp[i*4+j];
            printf("%02x ", d);
        }
        printf("\n");
    }

    unsigned char ch = *(tcp + 12);
    ch &=  0xf0;
    ch >>= 4;
    ch *= 4;
    printf("header length = %d\n", (int)ch);

    char *data = (char *)(tcp + ch);
    printf("data is %s\n", data);
}

void handle_ip(unsigned char *ip)
{
#if 0
    printf("--------------------ip header\n");
    for(int i = 0; i < 5; ++i)
    {
        for(int j = 0; j < 4; ++j)
        {
            unsigned char d = ip[i*4+j];
            printf("%02x ", d);
        }
        printf("\n");
    }
#endif
    unsigned char protocal = *(ip + 9);
    unsigned char ch = ip[0];
    int len = ch & 0x0f; //0x45
    len *= 4;
    if(protocal == 0x06) //tcp
    {
        handle_tcp(ip + len);
    }
    else if(protocal == 0x11)//udp
    {

    }
}


void printf_eth_header(unsigned char *eth_frame)
{
    //dst:00:00:00:00:00:00
    //src:00:00:00:00:00:00
    //type:086

    unsigned char *p = eth_frame;

    printf("dst:%02x:%02x:%02x:%02x:%02x:%02x\n",
           p[0],p[1],p[2],p[3],p[4],p[5]);
    printf("src:%02x:%02x:%02x:%02x:%02x:%02x\n",
           p[6],p[7],p[8],p[9],p[10],p[11]);
    printf("type:%04x\n", ntohs(p[12]));

}

int main()
{
    //SOCK_RAW : 包括以太网帧frame 的头
    //SOCK——DGRAM: 只有以太网帧frame 的数据
    int sock = socket(AF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
    if(sock < 0)
    {
        printf("0\n");
        return 0;
    }

    struct ifreq ifstruct;
    strcpy(ifstruct.ifr_name, "ens33");

    if(ioctl(sock, SIOCGIFINDEX, &ifstruct) == -1)
    {
        printf("1\n");
        return 0;
    }
    
    struct sockaddr_ll addr; // low level
    addr.sll_family = AF_PACKET;
    addr.sll_ifindex = ifstruct.ifr_ifindex;
    addr.sll_protocol = htons(ETH_P_ALL);
    addr.sll_hatype = ARPHRD_ETHER; //ha == hardware
    addr.sll_pkttype = PACKET_OTHERHOST; //抓包，外面进来的
    addr.sll_halen = ETH_ALEN; //MAC地址长度
    addr.sll_addr[6] = 0; //MAC地址为6位，后面置0
    addr.sll_addr[7] = 0;

    if(ioctl(sock, SIOCGIFHWADDR, &ifstruct) == -1)
    {
        printf("2\n");
        return 0;
    }
    if(ioctl(sock, SIOCGIFFLAGS, &ifstruct) == -1)
    {
        printf("3\n");
        return 0;
    }
    ifstruct.ifr_ifru.ifru_flags |= IFF_PROMISC;
    if(ioctl(sock, SIOCSIFFLAGS, &ifstruct) == -1)
    {
        printf("4\n");
        return 0;
    }
    if(bind(sock, (struct sockaddr *)&addr, sizeof(struct sockaddr_ll)) == -1)
    {
        printf("5\n");
        return 0;
    }
    ioctl(sock, SIOCGIFHWADDR, &ifstruct);

    char buf[1518];//以太网帧最大长度
    while(1)
    {
        read(sock, buf, sizeof(buf));

        unsigned short eth_type = *(unsigned short *)(buf + 12);
        eth_type = ntohs(eth_type);
        if(eth_type == 0x0800)
        {
            handle_ip((unsigned char *)buf + 14);
        }

        //printf_eth_header((unsigned char *)buf);
        //printf("recv data : %s\n", buf);
    }


}
