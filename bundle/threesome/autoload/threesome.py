import vim, os, sys


# Add the library to the Python path.
for p in vim.eval("&runtimepath").split(','):
   plugin_dir = os.path.join(p, "autoload")
   if os.path.exists(os.path.join(plugin_dir, "threesomelib")):
      if plugin_dir not in sys.path:
         sys.path.append(plugin_dir)
      break


import threesomelib.init as threesome


# Wrapper functions ----------------------------------------------------------------

def ThreesomeInit():
    threesome.init()


def ThreesomeOriginal():
    threesome.modes.current_mode.key_original()

def ThreesomeOne():
    threesome.modes.current_mode.key_one()

def ThreesomeTwo():
    threesome.modes.current_mode.key_two()

def ThreesomeResult():
    threesome.modes.current_mode.key_result()


def ThreesomeGrid():
    threesome.modes.key_grid()

def ThreesomeLoupe():
    threesome.modes.key_loupe()

def ThreesomeCompare():
    threesome.modes.key_compare()

def ThreesomePath():
    threesome.modes.key_path()


def ThreesomeDiff():
    threesome.modes.current_mode.key_diff()

def ThreesomeDiffoff():
    threesome.modes.current_mode.key_diffoff()

def ThreesomeScroll():
    threesome.modes.current_mode.key_scrollbind()

def ThreesomeLayout():
    threesome.modes.current_mode.key_layout()

def ThreesomeNext():
    threesome.modes.current_mode.key_next()

def ThreesomePrev():
    threesome.modes.current_mode.key_prev()

def ThreesomeUse():
    threesome.modes.current_mode.key_use()

def ThreesomeUse1():
    threesome.modes.current_mode.key_use1()

def ThreesomeUse2():
    threesome.modes.current_mode.key_use2()

