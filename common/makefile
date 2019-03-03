#gcc version
CC  = gcc
CXX = g++
GCCVER := $(shell $(CC) -dumpversion | awk -F. '{ print $$1"."$$2}' )

INC += -I../include/spp_incl/ 
INC += -I../include  
INC += -I./
INC += -I../lib/comm

#INC += -I../include/spp_incl/ -I../include  -I./
#LIB += -lsppasync -lasync_epoll -lcore -lprotobuf
LIB += -lprotobuf
#LIB += -loi_lib

LIB_INC += ../lib/comm/oi_lib.a

#BUILD_DIR=../../build 
OBJ_DIR=./obj
LIB_DIR=.

LIB_NAME=data_analyser.so 

TARGET = $(LIB_DIR)/$(LIB_NAME)

OBJ = $(OBJ_DIR)/service.o \
	  $(OBJ_DIR)/collection_store.o \
	  $(OBJ_DIR)/hash_op.o \
	  $(OBJ_DIR)/msghandle.o \
	  $(OBJ_DIR)/upload_quality.pb.o \
	  $(OBJ_DIR)/proclock.o \

OBJ_EXT= .o
CXXSRC_EXT= .cpp
CCSRC_EXT= .cc
CSRC_EXT= .c

ifeq ($(ARCH),32)
	CFLAGS += -m32 -march=pentium4
endif
CFLAGS  += -g -fPIC -shared -Wall -O2 -pipe -fno-ident -MMD -D_GNU_SOURCE -D_REENTRANT -fpermissive
CXXFLAGS+=$(CFLAGS)

$(OBJ_DIR)/%$(OBJ_EXT): %$(CCSRC_EXT)
	@echo
	@echo "Compiling $< ==> $@..."
	@-mkdir -p $(OBJ_DIR)
	$(CXX) $(INC) $(CXXFLAGS) -c $< -o $@


$(OBJ_DIR)/%$(OBJ_EXT): %$(CXXSRC_EXT)
	@echo
	@echo "Compiling $< ==> $@..."
	@-mkdir -p $(OBJ_DIR)
	$(CXX) $(INC) $(CXXFLAGS) -c $< -o $@

$(OBJ_DIR)/%$(OBJ_EXT): %$(CSRC_EXT)
	@echo
	@echo "Compiling $< ==> $@..."
	@-mkdir -p $(OBJ_DIR)
	$(CC) $(INC) $(CFLAGS) -c $< -o $@


all:$(TARGET)

$(TARGET) : $(OBJ)
	@echo
	@echo "Building $^ ==> $@..."
	@-mkdir -p $(LIB_DIR)
	make -C ../lib/comm
	$(CXX) -o $@ $^ $(CXXFLAGS) $(LIB_INC) $(LIB)
	install *.so ../../../bin

clean:
	@echo
	@echo "Cleaning..." 
	make -C ../lib/comm clean
	rm -rf $(OBJ_DIR)
	rm -f $(TARGET)	

all32:
	make -e ARCH=32
