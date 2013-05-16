#
#    Copyright (C) 2009 Modelon AB
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License version 3 as published 
#    by the Free Software Foundation, or optionally, under the terms of the 
#    Common Public License version 1.0 as published by IBM.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License, or the Common Public License, for more details.
#
#    You should have received copies of the GNU General Public License
#    and the Common Public License along with this program.  If not, 
#    see <http://www.gnu.org/licenses/> or 
#    <http://www.ibm.com/developerworks/library/os-cpl.html/> respectively.
#

FMI_XML_SRC=FMI/XML/src
FMI_DLL_SRC=FMI/DLL/src
FMI_ZIP_SRC=FMI/ZIP/src
FMI_IMP_SRC=FMI/Import
JM_UTIL_SRC=Util

# Paths relative to the JModelica.org repo
FMI_XML_INC=$(abs_top_srcdir)/JMI/FMI/XML/include
FMI_DLL_INC=$(abs_top_srcdir)/JMI/FMI/DLL/include
FMI_ZIP_INC=$(abs_top_srcdir)/JMI/FMI/ZIP/include
FMI_IMP_INC=$(abs_top_srcdir)/JMI/FMI/Import/include
JM_UTIL=$(abs_top_srcdir)/JMI/Util
THIRDPARTY_FMI_INC=$(abs_top_srcdir)/ThirdParty/FMI
THIRDPARTY_EXPAT_INC=$(EXPAT_HOME)/include
THIRDPARTY_MINIZIP_INC=$(MINIZIP_HOME)/include

AUTOMAKE_OPTIONS = foreign

lib_LTLIBRARIES = libfmixml.la libfmidll_1_0_cs.la libfmidll_1_0_me.la libfmizip.la libjm_util.la libfmi1_imp.la

libfmixml_la_SOURCES = $(FMI_XML_SRC)/fmi_xml_model_description.c \
                       $(FMI_XML_SRC)/fmi_xml_unit_impl.h \
                       $(FMI_XML_SRC)/fmi_xml_model_description_impl.h \
                       $(FMI_XML_SRC)/fmi_xml_variable.c \
                       $(FMI_XML_SRC)/fmi_xml_parser.c \
                       $(FMI_XML_SRC)/fmi_xml_variable_impl.h \
                       $(FMI_XML_SRC)/fmi_callbacks.c \
                       $(FMI_XML_SRC)/fmi_xml_parser.h	\
                       $(FMI_XML_SRC)/fmi_xml_variable_list.c \
                       $(FMI_XML_SRC)/fmi_callbacks.h \
                       $(FMI_XML_SRC)/fmi_xml_query.h \
                       $(FMI_XML_SRC)/fmi_xml_query.c \
                       $(FMI_XML_SRC)/fmi_xml_variable_list_impl.h \
                       $(FMI_XML_SRC)/fmi_xml_capabilities.c \
                       $(FMI_XML_SRC)/fmi_xml_type.c \
                       $(FMI_XML_SRC)/fmi_xml_vendor_annotations.c \
                       $(FMI_XML_SRC)/fmi_xml_capabilities_impl.h \
                       $(FMI_XML_SRC)/fmi_xml_type_impl.h \
                       $(FMI_XML_SRC)/fmi_xml_vendor_annotations_impl.h \
                       $(FMI_XML_SRC)/fmi_xml_cosim.c \
                       $(FMI_XML_SRC)/fmi_xml_unit.c 

libfmixml_la_CFLAGS = -Wall -std=c89 -pedantic -Wno-unused-function -I$(JM_UTIL) -I$(FMI_XML_INC) -I$(THIRDPARTY_FMI_INC) -I$(THIRDPARTY_EXPAT_INC) 

libfmixml_la_LDFLAGS = -no-undefined -static-libtool-libs                       
                       
libfmidll_1_0_cs_la_SOURCES = $(FMI_DLL_SRC)/1.0-CS/fmi_dll_1_0_cs.c \
                              $(FMI_DLL_SRC)/Common/fmi_dll_common.c
                     
libfmidll_1_0_cs_la_CFLAGS = -Wall -std=c89 -pedantic -Wno-unused-function -I$(JM_UTIL) -I$(FMI_DLL_INC) -I$(THIRDPARTY_FMI_INC)

libfmidll_1_0_cs_la_LDFLAGS = -no-undefined -static-libtool-libs
                       
libfmidll_1_0_me_la_SOURCES = $(FMI_DLL_SRC)/1.0-ME/fmi_dll_1_0_me.c \
                              $(FMI_DLL_SRC)/Common/fmi_dll_common.c
                     
libfmidll_1_0_me_la_CFLAGS = -Wall -std=c89 -pedantic -Wno-unused-function -I$(JM_UTIL) -I$(FMI_DLL_INC) -I$(THIRDPARTY_FMI_INC)

libfmidll_1_0_me_la_LDFLAGS = -no-undefined -static-libtool-libs                      

libfmizip_la_SOURCES = $(FMI_ZIP_SRC)/fmi_zip_unzip.c 
                     
libfmizip_la_CFLAGS = -Wall -std=c89 -pedantic -Wno-unused-function -I$(JM_UTIL) -I$(FMI_ZIP_INC) -I$(THIRDPARTY_MINIZIP_INC)

libfmizip_la_LDFLAGS = -no-undefined -static-libtool-libs                       

libfmi1_imp_la_SOURCES = $(FMI_IMP_SRC)/src/fmi_import_util.c \
                         $(FMI_IMP_SRC)/include/fmi_import_util.h
                     
libfmi1_imp_la_CFLAGS = -Wall -std=c89 -pedantic -Wno-unused-function -I$(THIRDPARTY_FMI_INC) -I$(FMI_DLL_INC) -I$(FMI_IMP_INC) -I$(FMI_ZIP_INC) -I$(FMI_XML_INC) -I$(JM_UTIL)

libfmi1_imp_la_LDFLAGS = -no-undefined -static-libtool-libs             
         
libjm_util_la_SOURCES = $(JM_UTIL_SRC)/fmi_functions.h \
                        $(JM_UTIL_SRC)/fmi_types.h \
                        $(JM_UTIL_SRC)/jm_callbacks.c \
                        $(JM_UTIL_SRC)/jm_callbacks.h \
                        $(JM_UTIL_SRC)/jm_named_ptr.c \
                        $(JM_UTIL_SRC)/jm_named_ptr.h \
                        $(JM_UTIL_SRC)/jm_stack.h \
                        $(JM_UTIL_SRC)/jm_stack_template.h \
                        $(JM_UTIL_SRC)/jm_string_set.h \
                        $(JM_UTIL_SRC)/jm_templates_inst.c \
                        $(JM_UTIL_SRC)/jm_types.h \
                        $(JM_UTIL_SRC)/jm_vector_template.h \
                        $(JM_UTIL_SRC)/jm_vector.h \
                        $(JM_UTIL_SRC)/jm_wc_match.c \
                        $(JM_UTIL_SRC)/jm_wc_match.h
                     
libjm_util_la_CFLAGS = -Wall -std=c89 -pedantic -Wno-unused-function

libjm_util_la_LDFLAGS = -no-undefined -static-libtool-libs  

include_HEADERS = $(FMI_XML_INC)/fmi_xml_capabilities.h \
                  $(FMI_XML_INC)/fmi_xml_model_description.h \
                  $(FMI_XML_INC)/fmi_xml_unit.h \
                  $(FMI_XML_INC)/fmi_xml_variable_list.h \
                  $(FMI_XML_INC)/fmi_xml_cosim.h \
                  $(FMI_XML_INC)/fmi_xml_type.h \
                  $(FMI_XML_INC)/fmi_xml_variable.h \
                  $(FMI_XML_INC)/fmi_xml_vendor_annotations.h \
                  $(FMI_DLL_INC)/fmi_dll_1_0_cs.h \
                  $(FMI_DLL_INC)/fmi_dll_1_0_me.h \
                  $(FMI_DLL_INC)/fmi_dll_common.h \
                  $(FMI_DLL_INC)/fmi_dll_types.h \
                  $(FMI_ZIP_INC)/fmi_zip_unzip.h
                  
                  
