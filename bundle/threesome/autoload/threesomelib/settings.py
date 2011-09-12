import vim


def setting(name, default=None):
    full_name = 'g:threesome_' + name

    if not int(vim.eval('exists("%s")' % full_name)):
        return default
    else:
        return vim.eval(full_name)

def boolsetting(name):
    if int(setting(name, 0)):
        return True
    else:
        False
