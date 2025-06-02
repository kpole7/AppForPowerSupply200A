BUILD_DIR = build
BIN = $(BUILD_DIR)/powerSource200A_Svedberg

CC	        = gcc
CXX	        = g++
OBJCOPY	    = objcopy

CFLAGS	    =  -g -Wall -I. -IfreeModbus/include -IfreeModbus/tcp -IfreeModbus/port
CFLAGS      += -pthread -MMD -MP

CCFLAGS	    =  -g -Wall -Wextra -I. -MMD -MP

LDFLAGS     =  -lfltk -lX11 -lpthread

CSRC        = modbusTcpSlave.c \
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

CCSRC       = powerSource200A_Svedberg.cpp \
              modbusRtuMaster.cpp \
              multiChannel.cpp \
              dataSharingInterface.cpp \
              graphicalUserInterface.cpp \
              modbusTcpMaster.cpp \
              git_revision.cpp

OBJS = $(addprefix $(BUILD_DIR)/, $(CCSRC:.cpp=.o) $(CSRC:.c=.o))
DEPS = $(OBJS:.o=.d)

.PHONY: clean all

all: git_revision.cpp $(BIN)

git_revision.cpp:
	echo "// File generated automatically by make\nconst char TcpSlaveIdentifier[40] = \"ID: git commit time $$(git log -1 --format='%cd' --date=format:'%Y-%m-%d %H:%M:%S')\";" > git_revision.cpp

$(BIN): $(OBJS)
	$(CXX) -o $@ $(OBJS) $(LDFLAGS)
	mkdir -p build/testing_TCP_master
	mkdir -p build/testing_TCP_slave
	cp $(BIN) build/testing_TCP_master/powerSource200A_Svedberg
	cp $(BIN) build/testing_TCP_slave/powerSource200A_Svedberg
	cp testing_TCP_master/powerSource200A_Svedberg.cfg build/testing_TCP_master/powerSource200A_Svedberg.cfg
	cp testing_TCP_slave/powerSource200A_Svedberg.cfg build/testing_TCP_slave/powerSource200A_Svedberg.cfg

# ---------------------------------------------------------------------------
# rules for code generation
# ---------------------------------------------------------------------------
$(BUILD_DIR)/%.o: %.cpp
	@mkdir -p $(BUILD_DIR)
	$(CXX) $(CCFLAGS) -o $@ -c $<

$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(BUILD_DIR)
	@mkdir -p build/freeModbus
	@mkdir -p build/freeModbus/ascii
	@mkdir -p build/freeModbus/functions
	@mkdir -p build/freeModbus/port
	@mkdir -p build/freeModbus/rtu
	@mkdir -p build/freeModbus/tcp
	$(CC) $(CFLAGS) -o $@ -c $<

# ---------------------------------------------------------------------------
#  # compiler generated dependencies
# ---------------------------------------------------------------------------
-include $(DEPS)

clean:
	rm -rf $(BUILD_DIR)
	rm -f git_revision.cpp

