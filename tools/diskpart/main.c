#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

struct DiskPartArgs
{
    uint32_t part_num;
    uint64_t sector_start;
    uint64_t sector_cnt;
};

static bool only_nums(const char* str);

int main(int argc, char** argv)
{
    if(argc < 2)
    {
        printf("Usage: diskpart (disk image) [options]\n");
        return 1;
    }

    struct DiskPartArgs args = {
        .sector_cnt = 0,
        .sector_start = 0,
        .part_num = 0
    };
    
    for(int i = 1; i < argc; ++i)
    {
        if(strcmp(argv[i], "-s") == 0)
        {
            if(i == argc - 1)
            {
                printf("Failed to provide size argument for -s.\n");
                return 1;
            }
            ++i;
            if(!only_nums(argv[i]))
            {
                printf("Invalid size argument for -s.\n");
                return 1;
            }
            args.sector_cnt = atoi(argv[i]);
        }
        else if(strcmp(argv[i], "-b"))
        {
        }
    }

    printf("Start: %lu, Size: %lu\n", args.sector_start, args.sector_cnt);

    return 0;
}

static bool only_nums(const char* str)
{
    while(*str != '\0')
    {
        if(*str < '0' || *str > '9')
            return false;
        ++str;
    }
    return true;
}
