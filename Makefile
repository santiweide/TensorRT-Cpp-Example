CXX = g++
CXXFLAGS = -std=c++14 -Wall -Wno-deprecated-declarations -Wfloat-conversion
DEBUGFLAGS = -DDEBUG
LDLIBS = -lnvinfer -lnvonnxparser -lcudart -lnvinfer_plugin

LDFLAGS = -L/home/fng685/trt10.9/usr/lib64 -Wno-deprecated-declarations

INCLUDEDIRS = -I/home/fng685/trt10.9/TensorRT/include -Isrc


SRCDIR = src
BINDIR = bin

SOURCES = $(wildcard $(SRCDIR)/*.cpp) main.cpp
SOURCES_C = $(wildcard $(SRCDIR)/*.cpp) main.c
OBJECTS = $(SOURCES:$(SRCDIR)/%.cpp=$(BINDIR)/%.o)
OBJECTS_C = $(SOURCES_C:$(SRCDIR)/%.cpp=$(BINDIR)/%.o)

SOURCES_G = $(wildcard $(SRCDIR)/*.cpp) gaussian_blur.cpp
OBJECTS_G = $(SOURCES_G:$(SRCDIR)/%.cpp=$(BINDIR)/%.o)

EXECUTABLE = main
EXECUTABLE_C = main_c
EXECUTABLE_G = gaussian_blur

.PHONY: all clean

all: $(EXECUTABLE) $(EXECUTABLE_C) $(EXECUTABLE_G)

$(BINDIR)/%.o: $(SRCDIR)/%.cpp | $(BINDIR)
	$(CXX) $(CXXFLAGS) $(DEBUGFLAGS) $(INCLUDEDIRS) -c $< -o $@

$(EXECUTABLE): $(OBJECTS)
	$(CXX) $(INCLUDEDIRS) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(EXECUTABLE_C): $(OBJECTS_C)
	$(CXX) $(INCLUDEDIRS) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(EXECUTABLE_G): $(OBJECTS_G)
	$(CXX) $(INCLUDEDIRS) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(BINDIR):
	mkdir -p $(BINDIR)

clean:
	rm -rf $(BINDIR) $(EXECUTABLE)
