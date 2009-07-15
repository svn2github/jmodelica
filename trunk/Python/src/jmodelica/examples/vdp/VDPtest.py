#!/usr/bin/python
# -*- coding: utf-8 -*-
""" Specific tests for the VDP oscillator.

"""
import jmodelica.jmi as jmi
import jmodelica.optimicacompiler as oc

def setup():
    """ Test module level setup
    """
    oc.compile_model("VDP.mo", "VDP_pack.VDP_Opt", target='ipopt')


def test_simple_load_model():
    """ Try loading the model """
    cstr = jmi.Model("VDP_pack_VDP_Opt")

    pi = cstr.getPI();
    x = cstr.getX();
    dx = cstr.getDX();
    u = cstr.getU();
    w = cstr.getW();

