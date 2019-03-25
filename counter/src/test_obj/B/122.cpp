
/*

   1. input:	counter ./obj_src_path
   2. output:	file: ./a.cpp  total: 123  empty: 123  effective: 123  comment: 123
file: ./a./b.cpp  total: 123  empty: 123  effective: 123  comment: 123




1. 读取文件夹所有文件
2. 统计行数
2.1 两种注释方法　
2.2 \t \r space 为空行
2.3 \n 行数增加
 */



#include "my_head.h"
#include "my_define.h"
#include "counter.h"
using namespace Counter;

namespace Counter{


	int recursive_read_dir(const char *dir_path){
		if(dir_path == nullptr){
			LOG_INFO("%s\n", "dir_path null");
			return -1;
		}

		DIR *handler = nullptr;
		struct dirent * dir = nullptr;
		std::string base_path(dir_path);
		
		if( (handler = opendir(dir_path) ) == nullptr){
			LOG_INFO("%s errno %d\n","opendir error: ", errno);
			return -2;
		}

		while( (dir = readdir(handler)) != nullptr){
			if(dir->d_name[0] == '.'
					&& (dir->d_name[1] == '\0' || dir->d_name[1] == '.')){
				continue;
			}
			else if(dir->d_type == DT_DIR){				//　directory
				if(base_path[base_path.size() - 1] != '/')
					base_path += "/";
				base_path += dir->d_name;
				recursive_read_dir(base_path.c_str());
			}
			else if(dir->d_type == DT_REG){				// regular file

				std::string temp(base_path);
				temp += "/";
				temp += dir->d_name;
				Counter auto_count;
				auto_count.calculator(temp.c_str());
				auto_count.print_all();
			}

		}

		return SUCCESS;



	}
}

	int main(int argc, char *argv[]){

		int ret = 0;

		if(argc != 2){
			LOG_INFO("%s %s %s\n", "error argument eg: \n", argv[0], "dir_path");
			return ARGUMENT_INVALID;
		}

		//读取文件路径
		if( (ret = recursive_read_dir(argv[1]) ) != 0){
			LOG_INFO("%s %d\n", "recursive read dir error ret: ",ret);
			return ERR_READDIR;
		}


		return SUCCESS;
	}
