
PLATFORM=win32

ifeq (win, $(findstring win,$(PLATFORM)))
SUFF=dll
PREF=
LINKER_FLAGS=-shared -Wl,-soname,
endif
ifeq (darwin, $(findstring darwin,$(PLATFORM)))
SUFF=dylib
LINKER_FLAGS=-dynamiclib -Wl,-dylib_install_name,
PREF=lib
else
SUFF=so
LINKER_FLAGS=-shared -Wl,-soname,
PREF=lib
endif

CC=gcc

DIR=../Library/$(PLATFORM)
INC=../Include

all : add_shared add_static array_shared array_static

add_shared: $(PREF)addNumbers.$(SUFF) lib_dir
	mv $< $(DIR)

add_static: libaddNumbers.a lib_dir
	mv $< $(DIR)


array_shared: $(PREF)arrayFunctions.$(SUFF) lib_dir
	mv $< $(DIR)

array_static: libarrayFunctions.a lib_dir
	mv $< $(DIR)


lib_dir:
	mkdir -p $(DIR)

%.o: %.c
	$(CC) -c -fPIC -I$(INC) $< -o $@

$(PREF)%.$(SUFF): %.o
	$(CC) $(LINKER_FLAGS)$@ -o $@ $^

lib%.a: %.o
	$(AR) rcs $@ $<

clean:
	rm -rf $(DIR) *.o

.PHONY: lib_dir all clean add_shared add_static array_shared array_static