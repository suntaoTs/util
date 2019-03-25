#include "counter.h"

namespace Counter{

	Counter::Counter():	m_file_name("default_name"),
	m_total(0), 
	m_empty(-1), 
	m_effective(0), 
	m_comment(0), 
	m_escape_flag(0)
	{}

	Counter::~Counter()
	{}

	int Counter::calculator(const char *file_name){

		/*	string path(file_name);
			string file;
			std::size_t pos = 0;

			if( (pos = path.rfind("/") ) != string::npos) {  //spilt path to real_file_name;
			file.substring(pos+1);
			}
			read_file(file);
		 */


#define BUF_MAX  1024
		if(file_name == nullptr){
			LOG_INFO("file_name ptr null\n");
			return -1;
		}

		m_file_name.assign(file_name);
		size_t pos = 0;
		if(	!( ( (pos = m_file_name.rfind(".cpp")) != std::string::npos && m_file_name[pos+4] == '\0')
					|| ( (pos = m_file_name.rfind(".cc")) != std::string::npos && m_file_name[pos+3] == '\0')
					|| ( (pos = m_file_name.rfind(".h")) != std::string::npos && m_file_name[pos+2] == '\0')
					|| ( (pos = m_file_name.rfind(".hpp")) != std::string::npos && m_file_name[pos+4] == '\0')
					|| ( (pos = m_file_name.rfind(".c")) != std::string::npos && m_file_name[pos+2] == '\0')
					|| ( (pos = m_file_name.rfind(".C")) != std::string::npos && m_file_name[pos+2] == '\0')
					|| ( (pos = m_file_name.rfind(".c++")) != std::string::npos && m_file_name[pos+4] == '\0') ) ){

			cout << "file: " << m_file_name << "-------------------- --------- Not c/cpp file" << endl;
			return -1;
		}


		char buf[BUF_MAX] = {0};
		std::string origin;
		ifstream ifs(file_name);

		if( !ifs.is_open() ){
			LOG_INFO("%s, open error\n", file_name);
			return -1;
		}
		while( !ifs.eof()){

			ifs.getline(buf, BUF_MAX, '\n');
			buf[BUF_MAX - 1] = '\0';
			origin = buf;

			analysis_line(origin);
		}
		return SUCCESS;

	}

	int Counter::analysis_line( std::string &buf){

		std::vector< std::string > rule_comment = { "//", "/*", "*/"};
		const char connecotr = '\\';
		const char escape = '\\';
		std::vector<char> rule_space = { '\r', '\t', ' '};

		trim_left(buf, rule_space);					// trim the left space
		//	cout << endl << "buf: " << buf << endl;
		if(buf[0] == '\0'){
			++m_empty;								// 空行
		}
		else{
			//注释
			comment(buf, 0, rule_comment);

		}
	}

	int Counter::comment_code_set(const std::string &buf, std::vector<int> &comment_pos){

		int begin = 0;

		if(m_rule_stack.size() != 0) {			// 上一行注释未结束
			if(m_rule_stack.top() == "//"){		//全部设置为comment

				int i = buf.size();
				comment_pos.push_back(begin);
				comment_pos.push_back(i);
				begin = i - 1;

				return 0;
			}
			else{
				comment_pos.push_back(begin);
			}
		}

		int flag_dot = 0;;
		for(int i = 0; i < buf.size(); ++i){

			if(flag_dot == 1 && buf[i] != '"'){
				continue;
			}

			if(m_rule_stack.size() == 0 
					|| (m_rule_stack.size() != 0 && m_rule_stack.top() != "//" && m_rule_stack.top() != "//") ){  // 去除双引号包含注释符号  eg: "//" "/*"	

				if(buf[i] == '"') {
					
					if(flag_dot == 0){
						flag_dot = 1;
					}
					else{
						flag_dot = 0;
					}
					continue;
				}
			}

			if(buf[i] == '/'){

				if(buf [i+1] == '*'){
					if( m_rule_stack.size() == 0){
						m_rule_stack.push("/*");

						comment_pos.push_back(i);
						begin = i;
					}
					else{
						LOG_INFO("stack push logic error: m_rule_stack.top()=%s, attempt to push = %s\n", m_rule_stack.top().c_str(), "/*"); 
						return -1;
					}
					++i;
				}
				else if(buf[i+1] == '/'){
					if( m_rule_stack.size() == 0){
						m_rule_stack.push("//");
					}
					i = buf.size();
					comment_pos.push_back(begin);
					comment_pos.push_back(i);
					begin = i - 1;
					++i;
				}
			}
			else if(buf[i] == '*' && buf[i+1] == '/'){
				if(m_rule_stack.top() == "/*"){
					m_rule_stack.pop();
					comment_pos.push_back(i+2);
					begin = i + 2;
				}
				else if(m_rule_stack.top() == "//"){
					LOG_INFO("error logic\n");
				}
				++i;
			}
		}

		return 0;

	}

	int Counter::set_flags(std::vector<int> &v_flags, std::vector<int> &comment_pos, const std::string &buf){

		//cout << "comment_pos.size() = " << comment_pos.size() << endl;
		int flag = 0;

		if(comment_pos.size() == 0){

			for(int i = 0 ; i < buf.size(); ++i){
				if(buf[i] != '\t' && buf[i] != '\r' && buf[i] != ' '){
					v_flags[i] = CODE;
				}
			}	
		}


		//comment_pos.push_back(v_flags.size());		//增加一个末尾
		int end = comment_pos[comment_pos.size() -1 ];

		for(int i = 0, j = 0; i < comment_pos.size() + 1; i+=2){

			for( ; j < v_flags.size() && j < buf.size(); ++j){

				if( i < comment_pos.size() ){

					if( j >= comment_pos[i+1])
						break;

					if( j >= comment_pos[i]							//　左闭右开区间
							&& j < comment_pos[i + 1])
					{
						v_flags[j] = COMMENT; 
					}
					else if(buf[j] != '\t' && buf[j] != '\r' && buf[j] != ' '){
						v_flags[j] = CODE;
					}
					else{
						v_flags[j] = 0;
					}
				}
				else if(buf[j] != '\t' && buf[j] != '\r' && buf[j] != ' '){
					v_flags[j] = CODE;
				}
				else{
					v_flags[j] = 0;
				}


			}

		}

		return 0;
	}

	int Counter::judge(std::vector<int> &v_flags){

		int flag_comment = 0;
		int flag_code = 0;


		for(int i = 0; i < v_flags.size(); ++i){
			if(v_flags[i] == COMMENT){
				flag_comment = 1;
			}
			else if(v_flags[i] == CODE){
				flag_code = 1;
			}
			/* 	if ( i < 52)
				cout << v_flags[i] << " ";*/
		}
		flag_comment <<= 1;

		return (flag_comment |= flag_code);		
		// 0x00 space  
		// 0x01 code   
		// 0x10 comment 
		// 0x11 coment_code

	}

	int Counter::comment(const std::string &buf, size_t search_begin, const std::vector<std::string> & rule){

		std::vector<int> v_flags(1024, 0);
		std::vector<int> comment_pos;
		int begin = 0;
		int end = 0;
		int ret = 0;
		size_t pos = search_begin;


		// 1. 遍历所有元素, 做标记
		comment_code_set(buf, comment_pos);

		// 2. 按照数组置位，标记flag
		set_flags(v_flags, comment_pos, buf);
		// 3. 统计是否有code comment
		if( (ret = judge(v_flags)) == 0x01 ){
			++m_effective;
		}
		else if(ret == 0x02){
			++m_comment;
		}
		else if( ret == 0x03){
			++m_comment;
			++m_effective;
		}
		else{
			++m_empty;
			LOG_INFO("error 0x00 -- space ret: %d\n", ret);	
		}

		++m_total;

		// 4. 标出末置位是否有连接符
		if(buf[buf.size()-1] != '\\' 
				&& m_rule_stack.size() != 0 
				&& m_rule_stack.top() == "//" ){
			m_rule_stack.pop();
			//		cout << "pop the // " << endl;
		}
		else if(buf[buf.size()-1] == '\\'){
			m_escape_flag = 1;
		}


	}

	int Counter::assign_value(std::vector<int> &flags, int begin, int end, int value){
		for(int i = begin; i < flags.size() && i < end; ++i){
			flags[i] = value;
		}
		return 0;
	}

	int Counter::trim_left(std::string &buf, const std::vector<char> &rule){

		size_t i = 0;

		for( ; i < buf.size(); ++i){
			if( buf[i] != '\t'
					&& buf[i] != '\r'
					&& buf[i] != ' '){
				break;
			}
		}

		if( i != 0){
			buf = buf.substr(i);
			return i - 1;
		}

		return 0;
	}


}

