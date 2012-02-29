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

# Paths relative to the JModelica.org repo
FMI_XML_INC=$(abs_top_srcdir)/JMI/FMI/XML/include
JM_UTIL=$(abs_top_srcdir)/JMI/Util
THIRDPARTY_FMI=$(abs_top_srcdir)/ThirdParty/FMI

AUTOMAKE_OPTIONS = foreign

lib_LTLIBRARIES = libfmixml.la

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
                       $(FMI_XML_SRC)/fmi_xml_variable_list_impl.h \
                       $(FMI_XML_SRC)/fmi_xml_capabilities.c \
                       $(FMI_XML_SRC)/fmi_xml_type.c \
                       $(FMI_XML_SRC)/fmi_xml_vendor_annotations.c \
                       $(FMI_XML_SRC)/fmi_xml_capabilities_impl.h \
                       $(FMI_XML_SRC)/fmi_xml_type_impl.h \
                       $(FMI_XML_SRC)/fmi_xml_vendor_annotations_impl.h \
                       $(FMI_XML_SRC)/fmi_xml_cosim.c \
                       $(FMI_XML_SRC)/fmi_xml_unit.c 

libfmixml_la_CFLAGS = -Wall -std=c89 -pedantic -Wno-unused-function -I$(JM_UTIL) -I$(FMI_XML_INC) -I$(THIRDPARTY_FMI)

libfmixml_la_LDFLAGS = -no-undefined -static-libtool-libs                     
                       
include_HEADERS = $(FMI_XML_INC)/fmi_xml_capabilities.h \
                  $(FMI_XML_INC)/fmi_xml_model_description.h \
                  $(FMI_XML_INC)/fmi_xml_unit.h \
                  $(FMI_XML_INC)/fmi_xml_variable_list.h \
                  $(FMI_XML_INC)/fmi_xml_cosim.h \
                  $(FMI_XML_INC)/fmi_xml_type.h \
                  $(FMI_XML_INC)/fmi_xml_variable.h \
                  $(FMI_XML_INC)/fmi_xml_vendor_annotations.h
