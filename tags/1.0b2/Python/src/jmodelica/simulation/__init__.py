#!/usr/bin/env python 
# -*- coding: utf-8 -*-
"""Contains code used for simulation of models.

This currently only includes an interface to SUNDIALS.
"""
__all__ = ['sundials']


class SimulationException(Exception):
    """ A simulation exception. """
    pass

class Simulator(object):
    pass
