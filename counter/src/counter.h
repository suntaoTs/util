#pragma once

#include "my_head.h"
#include "my_define.h"
//file: ./a./b.cpp total: 123  empty: 123  effective: 123  comment: 123

namespace Counter{

	class Counter{
		public:
			Counter();
			~Counter();
			
			int calculator(const char *file_name);

			inline int print_all(){
				cout << "file:" << m_file_name << "\t\t"
						<< "\ttotal: " << m_total
						<< "\tempty: " << m_empty
						<< "\teffective: " << m_effective
						<< "\tcomment: " << m_comment << endl;
				return 0;
			}
	
		private:

			int analysis_line( std::string &buf);
			
			int comment_code_set(const std::string &buf, std::vector<int> &comment_pos);
	 		int set_flags(std::vector<int> &v_flags, std::vector<int> &comment_pos, const std::string &buf);
			int judge(std::vector<int> &v_flags);
			int comment(const std::string &buf, size_t search_begin, const std::vector<std::string> & rule);
			int assign_value(std::vector<int> &flags, int begin, int end, int value);
			int trim_left(std::string &buf, const std::vector<char> &rule);
	
		private:
			std::string	m_file_name;
			int32_t		m_total;
			int32_t		m_empty;
			int32_t		m_effective;
			int32_t		m_comment;

			int8_t			m_escape_flag;
			std::stack<std::string> m_rule_stack;
	};

}
