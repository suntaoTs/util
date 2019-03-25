
#pragma once
enum RET_CODE
{
	SUCCESS					= 0,
	ARGUMENT_INVALID		= 1000,
	ERR_READDIR				= 1001
};

enum FLAG
{
	CODE	= 100,
	COMMENT = 200
};


#include <stdio.h>
#include <iostream>
#include <dirent.h>
#include <sys/types.h>
#include <errno.h>
#include <stdint.h>

#include <fstream>
#include <stack>
#include <vector>
#include <string>

using namespace std;

