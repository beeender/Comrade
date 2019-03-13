import re
from .base import Base
from deoplete.util import getlines

class Source(Base):
    def __init__(self, vim):
        Base.__init__(self, vim)

        self.name = 'ComradeIntelliJ-complete'
        self.mark = '[Cde]'
        self.filetypes = []
        self.rank = 150
        self.max_pattern_length = 100
        self.input_pattern = '[^. \t0-9]\.\w*'
        self.is_debug_enabled = True

    def gather_candidates(self, context):
        #self.print_error(context)
        buf_id = context["bufnr"]
        buf_changedtick = self.vim.request("nvim_buf_get_changedtick", buf_id)
        buf_name = self.vim.request("nvim_buf_get_name", buf_id)
        win = self.vim.current.window

        row = win.cursor[0] - 1
        col = win.cursor[1]
        ret = {
            "buf_id" : buf_id,
            "buf_name" : buf_name,
            "buf_changedtick" : buf_changedtick,
            "row" : row,
            "col" : col,
            "new_request" : not context["is_async"]};
        results = self.vim.call("comrade#RequestCompletion", buf_id, ret)

        if results:
            context["is_async"] = not results["is_finished"]
            return results["candidates"]

        context["is_async"] = False
        return []
