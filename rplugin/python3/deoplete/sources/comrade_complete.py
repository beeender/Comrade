from .base import Base


class Source(Base):
    def __init__(self, vim):
        Base.__init__(self, vim)

        self.name = 'Comrade'
        self.mark = '[Cde]'
        self.filetypes = []
        self.rank = 500
        self.max_pattern_length = 100
        self.min_pattern_length = 1
        # Just put all possible patterns here. Category them when we have a
        # performance issue.
        self.input_pattern = (r'(\.)\w*|'
                              r'(:)\w*|'
                              r'(::)\w*|'
                              r'(->)\w*|')
        self.is_debug_enabled = True

    def gather_candidates(self, context):
        buf_id = context["bufnr"]
        buf_changedtick = self.vim.request("nvim_buf_get_changedtick", buf_id)
        buf_name = self.vim.request("nvim_buf_get_name", buf_id)
        win = self.vim.current.window

        row = win.cursor[0] - 1
        col = win.cursor[1]
        ret = {
            "buf_id": buf_id,
            "buf_name": buf_name,
            "buf_changedtick": buf_changedtick,
            "row": row,
            "col": col,
            "new_request": not context["is_async"]}
        results = self.vim.call("comrade#RequestCompletion", buf_id, ret)

        if results:
            context["is_async"] = not results["is_finished"]
            return results["candidates"]

        context["is_async"] = False
        return []
