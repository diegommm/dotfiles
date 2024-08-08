# ============================================================================
# FILE: size.py
# AUTHOR: Shougo Matsushita <Shougo.Matsu at gmail.com>
# License: MIT license
# ============================================================================

from defx.base.column import Base
from defx.context import Context
from defx.util import Nvim, readable

import typing


class Column(Base):

    def __init__(self, vim: Nvim) -> None:
        super().__init__(vim)

        self.name = 'size'

    def get(self, context: Context, candidate: dict) -> str:
        path = candidate['action__path']
        if not readable(path) or path.is_dir():
            return ' ' * 8
        size = self._get_size(path.stat().st_size)
        return '{:>5s}{:>3s}'.format(size[0], size[1])

    def _get_size(self, size: float) -> typing.Tuple[str, str]:
        multiple = 1024
        suffixes = ['KB', 'MB', 'GB', 'TB']
        if size < multiple:
            return (str(size), 'B')
        for suffix in suffixes:
            size /= multiple
            if size < multiple:
                return ('{:.1f}'.format(size), suffix)
        return ('INF', '')

    def length(self, context: Context) -> int:
        return 8

    def highlight(self) -> None:
        self.vim.command(
            f'highlight default link {self.syntax_name} Constant')
