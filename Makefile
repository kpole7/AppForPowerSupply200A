CC	        = gcc
CXX	        = g++
OBJCOPY	    = objcopy

CFLAGS	    =  -g -Wall -Wextra -pthread -MMD -MP
CFLAGS      += -Iinclude -IfreeModbus/include -IfreeModbus/tcp -IfreeModbus/port

CCFLAGS	    =  -g -Wall -Wextra -Iinclude -MMD -MP

LDFLAGS     =  -lfltk -lX11 -lpthread

BUILD_DIR       = build
BUILD_SVEDB_DIR = build/Svedberg
BUILD_RSTL_DIR  = build/RSTL

BIN_SVEDB = $(BUILD_SVEDB_DIR)/powerSource200A_Svedberg
BIN_RSTL = $(BUILD_RSTL_DIR)/powerSourceRSTL

CSRC        = source/common/modbusTcpSlave.c \
              freeModbus/port/portother.c \
              freeModbus/port/portevent.c \
              freeModbus/port/porttcp.c \
              freeModbus/mb.c \
              freeModbus/tcp/mbtcp.c \
              freeModbus/functions/mbfunccoils.c \
              freeModbus/functions/mbfuncdiag.c \
              freeModbus/functions/mbfuncholding.c \
              freeModbus/functions/mbfuncinput.c \
              freeModbus/functions/mbfuncother.c \
              freeModbus/functions/mbfuncdisc.c \
              freeModbus/functions/mbutils.c 

CCSRC       = source/common/main.cpp \
              source/common/multiChannel.cpp \
              source/common/dataSharingInterface.cpp \
              source/common/graphicalUserInterface.cpp \
              source/common/modbusTcpMaster.cpp \
              source/common/git_revision.cpp

CCSRC_SVEDB = $(CCSRC) source/svedberg/modbusRtuMaster.cpp

CCSRC_RSTL  = $(CCSRC) source/rstl/protocolRstlMaster.cpp

OBJS_SVEDB = $(addprefix $(BUILD_SVEDB_DIR)/, $(CCSRC_SVEDB:.cpp=.o) $(CSRC:.c=.o))
OBJS_RSTL  = $(addprefix $(BUILD_SVEDB_DIR)/, $(CCSRC_SVEDB:.cpp=.o) $(CSRC:.c=.o))
DEPS_SVEDB = $(OBJS_SVEDB:.o=.d)
DEPS_RSTL  = $(OBJS_RSTL:.o=.d)

.PHONY: clean all

all: $(BIN_SVEDB) $(BIN_RSTL)

$(BIN_SVEDB): $(OBJS_SVEDB)
	$(CXX) -o $@ $(OBJS_SVEDB) $(LDFLAGS)
#	mkdir -p build/testing_RTU_master_TCP_master
#	mkdir -p build/testing_RTU_master_TCP_slave
#	cp $(BIN) build/testing_RTU_master_TCP_master/powerSource200A_Svedberg
#	cp $(BIN) build/testing_RTU_master_TCP_slave/powerSource200A_Svedberg
#	cp testing_RTU_master_TCP_master/powerSource200A_Svedberg.cfg build/testing_RTU_master_TCP_master/powerSource200A_Svedberg.cfg
#	cp testing_RTU_master_TCP_slave/powerSource200A_Svedberg.cfg build/testing_RTU_master_TCP_slave/powerSource200A_Svedberg.cfg

$(BIN_RSTL): $(OBJS_RSTL)
	$(CXX) -o $@ $(OBJS_RSTL) $(LDFLAGS)

# ---------------------------------------------------------------------------
# rules for code generation
# ---------------------------------------------------------------------------
source/common/git_revision.cpp:
	echo "// File generated automatically by make\nconst char TcpSlaveIdentifier[40] = \"ID: git commit time $$(git log -1 --format='%cd' --date=format:'%Y-%m-%d %H:%M:%S')\";" > source/common/git_revision.cpp

$(BUILD_SVEDB_DIR)/%.o: %.cpp
	mkdir -p $(dir $@)
	$(CXX) $(CCFLAGS) -DPOWER_SOURCE_SVEDBERG -o $@ -c $<

$(BUILD_RSTL_DIR)/%.o: %.cpp
	mkdir -p $(dir $@)
	$(CXX) $(CCFLAGS) -DPOWER_SOURCE_RSTL -o $@ -c $<

$(BUILD_SVEDB_DIR)/%.o: %.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -DPOWER_SOURCE_SVEDBERG -o $@ -c $<

$(BUILD_RSTL_DIR)/%.o: %.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -DPOWER_SOURCE_RSTL -o $@ -c $<

# ---------------------------------------------------------------------------
#  # compiler generated dependencies
# ---------------------------------------------------------------------------
-include $(DEPS_SVEDB)

-include $(DEPS_RSTL)

clean:
	rm -rf $(BUILD_DIR)
	rm -f source/common/git_revision.cpp

