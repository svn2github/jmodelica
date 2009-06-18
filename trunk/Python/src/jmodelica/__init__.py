import os
import sys

import common

# import options
_opath = common._jm_home+os.sep+'Options'
sys.path.append(_opath)
import options

"""The JModelica Python toolkit."""
__all__ = ['interactive', 'jmi', 'xmlparser', 'compiler', 'optimization', 'examples']


#load all options
common.user_options['cppad_home']=options.cppad_home
common.user_options['ipopt_home']=options.ipopt_home


