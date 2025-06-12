CC	        = gcc
CXX	        = g++
OBJCOPY	    = objcopy

CFLAGS	    =  -g -rdynamic -Wall -pthread -MMD -MP
CFLAGS      += -Iinclude -IfreeModbus/include -IfreeModbus/tcp -IfreeModbus/port

CCFLAGS	    =  -g -rdynamic -Wall -Wextra -Iinclude -MMD -MP

LDFLAGS     =  -g -rdynamic -lfltk -lX11 -lpthread

BUILD_DIR       = build
BUILD_SVEDB_DIR = build/Svedberg
BUILD_RSTL_DIR  = build/RSTL

NAME_SVEDB  = powerSource200A_Svedberg
NAME_RSTL   = powerSourceRSTL
BIN_SVEDB   = $(BUILD_SVEDB_DIR)/$(NAME_SVEDB)
BIN_RSTL    = $(BUILD_RSTL_DIR)/$(NAME_RSTL)

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
OBJS_RSTL  = $(addprefix $(BUILD_RSTL_DIR)/, $(CCSRC_RSTL:.cpp=.o) $(CSRC:.c=.o))
DEPS_SVEDB = $(OBJS_SVEDB:.o=.d)
DEPS_RSTL  = $(OBJS_RSTL:.o=.d)

.PHONY: clean all

all: $(BIN_SVEDB) $(BIN_RSTL)

$(BIN_SVEDB): $(OBJS_SVEDB)
	$(CXX) -o $@ $(OBJS_SVEDB) $(LDFLAGS)
	mkdir -p $(BUILD_SVEDB_DIR)/testing_TCP_master
	mkdir -p $(BUILD_SVEDB_DIR)/testing_TCP_slave
	cp $(BIN_SVEDB) $(BUILD_SVEDB_DIR)/testing_TCP_master/$(NAME_SVEDB)
	cp $(BIN_SVEDB) $(BUILD_SVEDB_DIR)/testing_TCP_slave/$(NAME_SVEDB)
	cp testing/Svedberg/testing_TCP_master/$(NAME_SVEDB).cfg $(BUILD_SVEDB_DIR)/testing_TCP_master/$(NAME_SVEDB).cfg
	cp testing/Svedberg/testing_TCP_slave/$(NAME_SVEDB).cfg  $(BUILD_SVEDB_DIR)/testing_TCP_slave/$(NAME_SVEDB).cfg

$(BIN_RSTL): $(OBJS_RSTL)
	$(CXX) -o $@ $(OBJS_RSTL) $(LDFLAGS)
	mkdir -p $(BUILD_RSTL_DIR)/testing_TCP_master
	mkdir -p $(BUILD_RSTL_DIR)/testing_TCP_slave
	cp $(BIN_RSTL) $(BUILD_RSTL_DIR)/testing_TCP_master/$(NAME_RSTL)
	cp $(BIN_RSTL) $(BUILD_RSTL_DIR)/testing_TCP_slave/$(NAME_RSTL)
	cp testing/RSTL/testing_TCP_master/$(NAME_RSTL).cfg $(BUILD_RSTL_DIR)/testing_TCP_master/$(NAME_RSTL).cfg
	cp testing/RSTL/testing_TCP_slave/$(NAME_RSTL).cfg  $(BUILD_RSTL_DIR)/testing_TCP_slave/$(NAME_RSTL).cfg

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

