import vim
from bufferlib import buffers
from ..settings import setting


def bind(key, to, options='', mode=None, leader=None):
    if not leader:
        leader = setting('leader', '<localleader>')

    vim.command('nnoremap %s %s%s %s' % (options, leader, key, to))

def unbind(key, options='', leader=None):
    if not leader:
        leader = setting('leader', '<localleader>')

    vim.command('unmap %s %s%s' % (options, leader, key))

def bind_for_all(key, to, options='', mode=None, leader=None):
    if not leader:
        leader = setting('leader', '<localleader>')

    with buffers.remain():
        for b in buffers.all:
            b.open()
            bind(key, to, options, mode, leader)

def unbind_for_all(key, options='', leader=None):
    if not leader:
        leader = setting('leader', '<localleader>')

    with buffers.remain():
        for b in buffers.all:
            b.open()
            unbind(key, options, leader)
