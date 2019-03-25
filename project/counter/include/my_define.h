
//#define LOG		std::cout << "["##__FILE__ << __LINE__
#define LOG_INFO(format, ...)		\
{									\
	fprintf(stdout, "[INFO] [%s]:[%s]:[%d] --- " format "", \
			__FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__ );\
}
