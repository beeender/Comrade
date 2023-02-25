# ============================================================================
# AUTHOR: beeender <chenmulong at gmail.com>
# License: GPLv3
# ============================================================================

import os
import vim

from pathlib import Path

CONFIG_DIR = os.path.join(Path.home(), ".ComradeNeovim")

def pid_exists_unix(pid):
    try:
        os.kill(pid, 0)
    except ProcessLookupError:  # errno.ESRCH
        return False  # No such process
    except PermissionError:  # errno.EPERM
        return True  # Operation not permitted (i.e., process exists)
    else:
        return True  # no error, we can send a signal to the process

def pid_exists_win(pid):
    import ctypes
    kernel32 = ctypes.windll.kernel32
    SYNCHRONIZE = 0x100000

    process = kernel32.OpenProcess(SYNCHRONIZE, 0, pid)
    if process != 0:
        kernel32.CloseHandle(process)
        return True
    else:
        return False

def pid_exists(pid):
    if os.name == 'nt':
        return pid_exists_win(pid)
    return pid_exists_unix(pid)

def clean_up():
    if not os.path.isdir(CONFIG_DIR):
        return
    for file in os.listdir(CONFIG_DIR):
        filename = os.fsdecode(file)
        try:
            pid = int(filename)
        except ValueError:
            continue
        if pid < 0:
            continue

        # Remove non existing config files
        if not pid_exists(pid):
            try:
                os.remove(os.path.join(CONFIG_DIR, filename))
            except Exception:
                continue


def init():
    # Create the config dir
    if not os.path.isdir(CONFIG_DIR):
        os.makedirs(CONFIG_DIR)

    # Use PID as the file name
    pid = vim.funcs.getpid()
    # NVIM_LISTEN_ADDRESS is deprecated : https://neovim.io/doc/user/deprecated.html
    addr = os.getenv("NVIM_LISTEN_ADDRESS")
    if addr is None:
        addr = os.getenv("NVIM")

    version = vim.vars['comrade_version']
    cwd = os.getcwd()
    with open(os.path.join(CONFIG_DIR, f"{pid}"), "w") as pid_file:
        pid_file.write(addr + "\n")
        pid_file.write(version + "\n")
        pid_file.write(cwd)


clean_up()
init()
