import re
from .base import Base
from deoplete.util import getlines

class Source(Base):
    def __init__(self, vim):
        Base.__init__(self, vim)

        self.name = 'intellij-complete'
        self.mark = '[idea]'
        self.filetypes = ['java']
        self.rank = 100
        self.max_pattern_length = 100
        self.is_bytepos = True
        self.input_pattern = '[^. \t0-9]\.\w*'
        self.is_debug_enabled = True

    def get_complete_position(self, context):
        m = re.search(r'\w*$', context['input'])
        return m.start() if m else -1


    def gather_candidates(self, context):
        #self.print_error(context)
        buf = self.vim.current.buffer
        win = self.vim.current.window
        path = buf.name


        row = win.cursor[0] - 1
        col = win.cursor[1]
        ret = {
            "buf_id" : buf.number,
            "buf_name" : buf.name,
            "path" : path,
            "row" : row,
            "col" : col};
        return self.vim.call("ComradeRpcRequest", "IntelliJComplete", ret)
