PLATFORM=win32

COMPILED=false

ifeq (win, $(findstring win,$(PLATFORM)))
SUFF=dll
PREF=
SHARED_FLAGS=-shared -Wl,-soname,
COMPILED=true
endif

ifeq (darwin, $(findstring darwin,$(PLATFORM)))
SUFF=dylib
PREF=lib
SHARED_FLAGS=-dynamiclib -Wl,-install_name,@rpath/
COMPILED=true
endif

ifeq (false, $(findstring false,$(COMPILED)))
SUFF=so
PREF=lib
SHARED_FLAGS=-shared -Wl,-soname,
endif

CC=gcc

DIR=../Library/$(PLATFORM)
INC=-I../Include -I$(JMODELICA_HOME)/include

all : add_shared add_static array_shared array_static use_modelica_error

add_shared: $(PREF)addNumbers.$(SUFF) lib_dir
	mv $< $(DIR)

add_static: libaddNumbers.a lib_dir
	mv $< $(DIR)


array_shared: $(PREF)arrayFunctions.$(SUFF) lib_dir
	mv $< $(DIR)

array_static: libarrayFunctions.a lib_dir
	mv $< $(DIR)


ext_objects: libextObjects.a lib_dir
	mv $< $(DIR)


use_modelica_error: libuseModelicaError.a lib_dir
	mv $< $(DIR)


lib_dir:
	mkdir -p $(DIR)

%.o: %.c
	$(CC) -c -fPIC $(INC) $< -o $@

$(PREF)%.$(SUFF): %.o
	$(CC) $(SHARED_FLAGS)$@ -o $@ $^

lib%.a: %.o
	$(AR) rcs $@ $<

clean:
	rm -rf $(DIR) *.o

.PHONY: lib_dir all clean add_shared add_static array_shared array_static use_modelica_error